#!/bin/bash
# Input output
#para concatenar la ejecucion de un comando contenido en una variable dentro de un echo (ver linea ) al momento de definir la vriable se tiene que colocar el comando entre ``.
#esto no es necesario si solamente quiero ejecutar el comando desde una variable sin concatenar con texto (como en ej anterior)


coso=`hostname`

echo "hello my name is Tuvieja"
echo
echo "Voquienso"
echo
read name
echo 
echo "hola $name"
echo "el nombre del host es $coso"