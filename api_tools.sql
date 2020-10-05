-- Create the table to map the 
DROP VIEW IF EXISTS CCAMTables;
DROP TABLE IF EXISTS CCAMArchiveLatest;
CREATE TABLE CCAMArchiveLatest(
fn varchar(256)not null,
cmpsize bigint not null flag=1,
uncsize bigint not null flag=2,
method int not null flag=3,
date datetime not null flag=4)
engine=connect table_type=ZIP file_name='/tmp/CCAMArchiveLatest/CCAM_DBF.zip';


-- Create a view of the current list of CCM tables
CREATE VIEW CCAMTables AS SELECT fn, SUBSTRING(fn, 1, locate('.',fn)-1) tn FROM `CCAMArchiveLatest` WHERE fn like 'R_%.dbf';

-- Drop all CCAM Tables
-- @param schema the schema name to filter
DROP PROCEDURE IF EXISTS dropCCAMTables;
DELIMITER //

CREATE PROCEDURE dropCCAMTables
(IN tschema VARCHAR(64))
BEGIN

 SELECT * FROM (
  SELECT CONCAT('DROP TABLE ', tschema, '.', GROUP_CONCAT(table_name) , ';')
  FROM INFORMATION_SCHEMA.TABLES
  WHERE table_name LIKE 'R_%' and table_schema = tschema
 ) a INTO @dropCCAM;

 PREPARE dropCCAMStatement FROM @dropCCAM;
 EXECUTE dropCCAMStatement;
 DEALLOCATE PREPARE dropCCAMStatement;

END //
DELIMITER ;

DROP TABLE IF EXISTS CCAMArchiveLatest;

-- Table that displays the latests DBF from CCAM
-- When CCAM_DBF.zip is updated (either when replacing the file or when updating the CCAMArchiveLatest symlink)
-- data will be refreshed on the next select, automatically, enjoy :)
-- @param schema the schema name to use
DROP PROCEDURE IF EXISTS createCCAMTables;
DELIMITER //
CREATE PROCEDURE createCCAMTables
(IN tschema VARCHAR(64))
BEGIN
	DECLARE finished INTEGER DEFAULT 0;
	DECLARE fileName varchar(256) DEFAULT "";
	DECLARE tableName varchar(256) DEFAULT "";

	-- declare cursor to look for CCAM tables
	DECLARE curCCAM 
		CURSOR FOR 
			SELECT tn, fn FROM CCAMTables;

	-- declare NOT FOUND handler
	DECLARE CONTINUE HANDLER 
        FOR NOT FOUND SET finished = 1;

	OPEN curCCAM;

	buildTable: LOOP
		FETCH curCCAM INTO tableName, fileName;
		IF finished = 1 THEN 
			LEAVE buildTable;
		END IF;
		-- Dynamically build the table create query
		SET @qry = CONCAT('CREATE TABLE ', tschema, '.', tableName, ' engine=CONNECT table_type=DBF CHARSET=cp850 file_name="/tmp/CCAMArchiveLatest/',fileName,'" option_list="Accept=1";');
		PREPARE createCCAM FROM @qry;
		EXECUTE createCCAM;
		DEALLOCATE PREPARE createCCAM;
	END LOOP buildTable;

	CLOSE curCCAM;
END //
DELIMITER ;


-- CCAM Refresh procedure
-- @param schema the schema name to use
DROP PROCEDURE IF EXISTS refreshCCAMTables;
DELIMITER //
CREATE PROCEDURE refreshCCAMTables
(IN tschema VARCHAR(64))
BEGIN
CALL dropCCAMTables(tschema);
CALL createCCAMTables(tschema);
END //
DELIMITER ;


-- Create a daily refresh of the CCAM tables
DROP EVENT IF EXISTS `RefreshCCAM`;
CREATE EVENT `RefreshCCAM` ON SCHEDULE
        EVERY 1 DAY
ON COMPLETION NOT PRESERVE
ENABLE
COMMENT 'Daily refresh of the CCMAM tables'
DO CALL refreshCCAMTables('APICCAMNGAP');


-- Enable the even scheduler
SET GLOBAL event_scheduler=ON

