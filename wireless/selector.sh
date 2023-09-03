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

    maclist=()
    chanlist=()
    cryplist=()
    keylist=()
    
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

            maclist+=("$mac")
            chanlist+=($chan)
            cryplist+=($cryp)
            keylist+=($key)

        fi
        numline=$((numline-1))
    done < redes/redes-01.csv
    #echo "saliendo aca"
    
    listaredesactivas "$(declare -p maclist)" "$(declare -p chanlist)" "$(declare -p cryplist)" "$(declare -p keylist)"
}

function listaredesactivas() {
    local maclist chanlist cryplist keylist
    eval "$(echo "$1")"
    eval "$(echo "$2")"
    eval "$(echo "$3")"
    eval "$(echo "$4")"

    for ((i=0; i<${#maclist[@]}; i++)); do
        echo "test"
        #xterm -T "verifica si activa" -e sudo airodump-ng wlan0mon -d ${maclist[$i]}  &
        airodump-ng -d ${maclist[$i]} --uptime 5 wlan0 &
        sleep 3     
    done
}

wlan0monitor
