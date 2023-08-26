#!/bin/bash

function wlan0monitor() {
    echo 'Cambiando monitor mode'
    sudo ifconfig wlan0 down
    sleep .8
    sudo iwconfig wlan0 mode monitor
    sleep .8
    sudo ifconfig wlan0 up
    sleep .8
    echo 'wlan0 en modo monitor'
    startadump
}

function startadump() {
    echo 'iniciando escaneo'
    airodump-ng -w coso1 wlan0 > /dev/null & 
    airodump_pid=$!
    sleep 10
    kill $airodump_pid    
    recuperaredes
}

function recuperaredes() {

    lines=$(wc -l 'coso1-01.csv' | awk '{print $1}')
    numline=$((lines))

    while IFS=',' read -r mac _ _ chan _ cryp _ _ _ _ _ _ _ key
    do
        mac=$(echo "$mac" | xargs)
        chan=$(echo "$chan" | xargs)
        cryp=$(echo "$cryp" | xargs)
        key=$(echo "$key" | xargs)

        if [[ "$mac" != "BSSID" && "$cryp" == "WPA2" ]]; then
            
            if [ "$key" == "," ]; then 
                key=$mac
            fi
            
            if [[ "${key: -1}" == "," ]]; then
                key="${key%,}"
            fi

            echo "atacando linea $numline contiene MAC: $mac, CHANNEL: $chan, SEGURIDAD: $cryp, NOMBRE: $key"
            #atacar $mac $chan $key
        fi
        numline=$((numline-1))
    done < coso1-01.csv
}

function atacar() {
    local mac=$1
    local chan=$2
    local key=$3

    sudo airodump-ng -w $key -c $chan --bssid $mac wlan0 > airodump.txt
}

wlan0monitor