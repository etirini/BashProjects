#!/bin/bash
#CASE statements
echo Seleccionar una opcion 

echo 'a imprimo tu vieja'
echo 'b imprimo tu hermana'
echo 'c vemos ls'
echo 'd uptime'

	read choices
	case $choices in  
a) echo tuvieja;;
b) echo tuhermana;;
c) ls;;
d) uptime;;
*) echo no es una opcion valida

	esac

