#!/bin/bash
#
# Deal with CCAM reference data
#
# @author bugeaud at gmail dot com

# Fetch the latest version of the CCAM archives from the download website
# @return the latest version available
#
fetchCCAMLatestVersion(){
 curl -s https://www.ameli.fr/accueil-de-la-ccam/telechargement/fichiers-informatiques-nouvelle-structure/index.php | \
 grep -Eoi '<a [^>]+>' |  \
 grep -Po 'href="([^\"]+)"' | \
 grep -Po '[^\"]+_DBF_PART[^\"]+\.zip' | \
 sed 's/\(.*\)CCAM\(.*\)_DBF_\(.*\)\.zip/\2/' | uniq | sort -nr | head -1
}

# Return the latest CCAM version as per the current website
# @return the latest version with a format like 06300 for version 63.0
printCCAMLatestVersion(){
 local version=$(fetchCCAMLatestVersion)
 niceCCAMVersion $version
}

# Format the version from the CCAM archive
# @param version the unformated version (like 06300)
# @return the formated version to ease the reading
niceCCAMVersion(){
 local version=$1
 echo $((10#$version)) | sed 's,\(.*\)^0\(.\}\)$,\1\.\2,'
}

# Download the given CCAM archive version to the current folder. Multiple part will be downloaded if required.
# @param version the version ID (like 06300 for version 63.0)
downloadCCAMVersion(){
 local version=$1
 curl -s https://www.ameli.fr/accueil-de-la-ccam/telechargement/fichiers-informatiques-nouvelle-structure/index.php | \
  grep -Eoi '<a [^>]+>' |  \
  grep -Po 'href="([^\"]+)"' | \
  grep -Po '[^\"]+_DBF_PART[^\"]+\.zip' | \
  grep $version | \
  sed 's/^/https\:\/\/www.ameli.fr/' | xargs -n 1 curl -s -O
}

# Download the lates CCAM archive version. Unzip it to a dedicated /tmp subfolder. Generate the table create script. Point /tmp/CCAMArchiveLatest to that folder.
downloadCCAMLatest(){
 local version=$(fetchCCAMLatestVersion)
 local storage="/tmp/CCAMArchive$version"
 rm -Rf $storage
 mkdir -p $storage
 cd $storage
 downloadCCAMVersion $version

 # Expand the archives
 unzip \*.zip

 #Generate the table create scripts
 ls *.dbf | sed 's/\(.*\)\.dbf/create table \1 engine=CONNECT table_type=DBF CHARSET=cp850 file_name=\"\/docker-entrypoint-initdb.d\/&\" option_list="Accept=1";/' > api-ccam-create.sql

 #Generate the table drop scripts
 ls *.dbf | sed 's/\(.*\)\.dbf/DROP TABLE IF EXISTS \1;/' > api-ccam-drop.sql

 cd -
 # Let this version be the latest
 ln -sfn $storage /tmp/CCAMArchiveLatest
 echo $version
}

#Update the CCAM DB to the latest data
executeCCAMUpdate(){

#First drop

#Second recreate


}


runCCAMSQL(){
 local database=$1
 local username=$2
 local password=$3
 local script=$4

}

deleteExistingCCAMTables(){
 
}




# Default function
init(){
 echo ""
}

calledProcedure=${1:-init}
shift
echo "$(tput setaf 10)FINE$(tput sgr0) Calling procedure $calledProcedure with parameters : $@"

# Those two lines are required to be  written in any script using this library
#
eval $calledProcedure $@
echo "$(tput setaf 10)DONE$(tput sgr0) Called $calledProcedure"
