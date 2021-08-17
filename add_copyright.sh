#!/bin/bash
# Usage
# Arguments:
# $1: regex to find files
# $2: path to copyright file to use
# $3: regex to find if existing copyright is already in the file
# $4: optionally, modifify an existing copyright file by providing the path to it

if [ -z "${1}" ]; then findRegex="./*.py"; else findRegex="${1}"; fi
if [ -z "${2}" ]; then copyrightFilePath="./copyright.txt"; else copyrightFilePath="${2}"; fi
if [ -z "${3}" ]; then copyrightString="Copyright"; else copyrightString="${3}"; fi
if [ -z "${4}" ]; then existingCopyrightFilePath=""; else existingCopyrightFilePath="${4}"; fi

# Replacing ~ by $HOME of found inside copyrightFilePath
copyrightFilePath="${copyrightFilePath/#\~/$HOME}"

if [ ! -z "${existingCopyrightFilePath}" ]; then
    existingCopyrightFilePath="${existingCopyrightFilePath/#\~/$HOME}"
fi

# Listing all files
listofFiles=$(find . -regex ${findRegex})

copyrightContent=$(cat "${copyrightFilePath}")

# Loop on each file
# If copyrightString is NOT found inside the file then add copyrightFilePath content
# as a prefix of the file
COUNTER=0
for i in ${listofFiles}
do
  if (! grep -q "${copyrightString}" "${i}"); then
      echo "Adding copyright to ${i}."
      cat "${copyrightFilePath}" "${i}" > "${i}".new && mv "${i}".new "${i}";
      COUNTER=$((COUNTER + 1))
  else
      if [ ! -z "${existingCopyrightFilePath}" ]; then
          echo "Modifying copyright of ${i}"
          LANG=C
          perl -0777 -ne '$#ARGV==1 ? $s=s/\n\z//r : $#ARGV==0 ? $r=$_ : print s/\Q$s/$r/gr' ${existingCopyrightFilePath} ${copyrightFilePath} ${i} > "${i}".new && mv "${i}".new "${i}"
          COUNTER=$((COUNTER + 1))
      fi
  fi
done

echo "Added copyright to ${COUNTER} files."
echo "Done! ⭐"
