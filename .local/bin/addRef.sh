#!/bin/bash

if [ "$1" = "-r" ]; then
    if [ -n "$2" ] && [ -f "$2" ]; then
        sed -i 's/ *{#.\+:.\+}//' $2
        sed -i 's/ *#.\+:.\+}/}/' $2
    else
	echo "Usage: addRef.sh -r the.md    # remove {#fig:Figxxx},{#tbl:Tblxxx}"
    fi
    exit 0
fi

if [[ $# -lt 3 ]] ; then
    echo 'Usage: addRef.sh the.md Fig Tbl    # add {#fig:Figxxx},{#tbl:Tblxxx}'
    echo "Usage: addRef.sh -r the.md    # remove {#fig:Figxxx},{#tbl:Tblxxx}"
    echo "But if you had refered any of them, the id may change whan re-auto-add next time."
    exit 1
fi

tmp1=$(mktemp)
counter=1
while IFS= read -r line; do
    if [[ $line =~ ^!\[.+\](.+)\{[^#]+\} ]]; then
        modified_line=$(sed -E "s/\}/ #fig:$2$counter\}/" <<< "$line")
        echo "$modified_line"
        ((counter++))
    elif [[ $line =~ ^!\[.+\]([^#]+)$ ]]; then
        modified_line=$(sed -E "s/$/\{#fig:$2$counter\}/" <<< "$line")
        echo "$modified_line"
        ((counter++))
    else
        echo "$line"
    fi
done < $1 > $tmp1

tmp=$(mktemp)
counter=1
while IFS= read -r line; do
    if [[ $line =~ Table:\ [^#]+$ ]]; then
        modified_line=$(sed -E "s/$/ \{#tbl:$3$counter\}/" <<< "$line")
        echo "$modified_line"
        ((counter++))
    else
        echo "$line"
    fi
done < $tmp1 > $tmp

if [ $4 ]; then
tmp2=$(mktemp)
cp $tmp $tmp2
counter=1
while IFS= read -r line; do
    if [[ $line =~ ^#+\ +[^#]+$ ]]; then
        modified_line=$(sed -E "s/$/ \{#sec:$4$counter\}/" <<< "$line")
        echo "$modified_line"
        ((counter++))
    else
        echo "$line"
    fi
done < $tmp2 > $tmp
fi

mv $tmp $1
