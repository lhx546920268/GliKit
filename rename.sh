#!/bin/bash

function renameFile(){

cd $1
for element in `ls`
do
if [ -d $element ]
then
renameFile $element
else
rename 's/\+Sea/\+GK/' *.h
fi
done
cd ..
}

renameFile "GliKit"
