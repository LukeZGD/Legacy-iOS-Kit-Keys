#!/bin/bash

devices=(iPhone2,1 iPhone3,1 iPhone3,2 iPhone3,3 iPhone4,1 iPhone5,1 iPhone5,2 iPhone5,3 iPhone5,4 iPad1,1 iPad2,1 iPad2,2 iPad2,3 iPad2,4 iPad2,5 iPad2,6 iPad2,7 iPad3,1 iPad3,2 iPad3,3 iPad3,4 iPad3,5 iPad3,6 iPod2,1 iPod3,1 iPod4,1 iPod5,1)

for device in ${devices[@]}; do
    echo $device
    json=$(curl "https://firmware-keys.ipsw.me/device/$device")
    mkdir $device

    len=$(echo "$json" | jq length)
    builds=()
    i=0
    while (( i < len )); do
        builds+=($(echo "$json" | jq -r ".[$i].buildid"))
        ((i++))
    done

    cd $device
    for build in ${builds[@]}; do
        echo $build
        mkdir $build
        cd $build
        curl -L "http://127.0.0.1:8888/firmware/$device/$build" -o index.html
        #curl -LO https://api.ipsw.me/v2.1/$device/$build/sha1sum
        #curl -LO https://api.ipsw.me/v2.1/$device/$build/url
        cd ..
        [[ ! -s $build/index.html ]] && rm -rf $build
    done
    cd ..
done
