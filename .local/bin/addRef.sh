#!/bin/bash

if [[ $# -lt 3 ]] ; then
    echo 'addRef.sh the.md Fig Tbl'
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


# 如果想删除 {#fig:Figxxx}、{#tbl:Tblxxx}，可运行`sed -i 's/{#.*:.*}$//' 文件名`，但注意，如果已经引用过，再次自动添加后id可能会变
