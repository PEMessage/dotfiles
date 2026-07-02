#!/bin/bash


for x in "$@"
do
jar tf "$x"  | grep '\.class$' | sed 's/\.class$//; s/\//./g' | xargs javap -classpath "$x" -public
done
