#!/bin/sh

for FILE in "$@"
do
    echo "Fixing file $FILE"
    dd if=$FILE of=1 bs=16384 count=1
    dd if=$FILE of=2 bs=16384 skip=2
    cat 1 2 > temp/$FILE
    rm 1 2
done