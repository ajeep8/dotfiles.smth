#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: $0 filename.md"
  exit 1
fi

count1=0
count2=0
count3=0
count4=0
count5=0
count6=0
isCode=0

while read -r line; do
  if [[ $line =~ '```' ]]; then
    ((isCode = !isCode))
  fi
  if (( $isCode == 1 )); then
    echo "$line"
    continue
  fi

  if [[ $line == "# "* ]]; then
    ((count1++))
    count2=0
    echo "${line:0:2}$count1 ${line:2}"
  elif [[ $line == "## "* ]]; then
    ((count2++))
    count3=0
    echo "${line:0:3}$count1.$count2 ${line:3}"
  elif [[ $line == "### "* ]]; then
    ((count3++))
    count4=0
    echo "${line:0:4}$count1.$count2.$count3 ${line:4}"
  elif [[ $line == "#### "* ]]; then
    ((count4++))
    count5=0
    echo "${line:0:5}$count1.$count2.$count3.$count4 ${line:5}"
  elif [[ $line == "##### "* ]]; then
    ((count5++))
    count6=0
    echo "${line:0:6}$count1.$count2.$count3.$count4.$count5 ${line:6}"
  elif [[ $line == "###### "* ]]; then
    ((count6++))
    echo "${line:0:7}$count1.$count2.$count3.$count4.$count5.$count6 ${line:7}"
  else
    echo "$line"
  fi  
done < "$1"
