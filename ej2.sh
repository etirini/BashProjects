#!/bin/bash
#Ej 2. Corriendo comandos basicos de administracion
echo "Running basic admin commands"
echo
top | head -10 
#top hijackea la sesion y no permite correr otro comando. Por lo que lo pipeamos a head -10 para que pase una parte y dsp siga con el resto
echo
df -h
echo
uptime
echo
echo "EOF"