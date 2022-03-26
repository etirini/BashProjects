#!/bin/bash
# If statements

#if basico
count=1900
if [ $count -eq 100 ]
then
    echo count is 100
else 
    echo count is not 100
fi

#verifica si existe un file

if [ -e /mnt/c//Users/etiri/Documents/Bash/ej7.sh ]
    then
    echo El archivo existe
    else
    echo El archivo no existe
fi