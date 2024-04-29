#!/bin/bash

if [[ $# -lt 3 ]] ; then
    echo 'Usage: addRef.sh the.md Fig Tbl'
    echo "If you want to delete {#fig:Figxxx},{#tbl:Tblxxx}, run: sed -i 's/{#.*:.*}//' filename.md."
    echo "But if you had refered any of them, the id may change whan re-auto-add next time."
    exit 1
fi

counter=1
while :
do
    match=$(grep -m 1 "\!\[.*\](.*)$" "$1")
    echo "$match"
    if [[ -n "$match" ]]; then
	sed -i -E "0,/\!\[.*\]\(.*\)$/s//&{#fig:$2$counter}/" $1
        ((counter++))
    else
        break
    fi
done

counter=1
while :
do
    match=$(grep -m 1 "^Table: [^{}]*$" "$1")
    echo "$match"
    if [[ -n "$match" ]]; then
	sed -i -E "0,/Table: [^{}]*$/s//& {#tbl:$3$counter}/" $1
        ((counter++))
    else
        break
    fi
done

if [ $4 ]; then
    counter=1
    while :
    do
        match=$(grep -m 1 "^#\+ [^{}]*$" "$1")
        echo "$match"
        if [[ -n "$match" ]]; then
    	sed -i -E "0,/^#[^{}]*$/s//& {#sec:$4$counter}/" $1
            ((counter++))
        else
            break
        fi
    done
fi

