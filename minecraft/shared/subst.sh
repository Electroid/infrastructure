#! /bin/bash

cd $1

for file in *.yml; do
	envsubst < $file > $file
done

cd ..