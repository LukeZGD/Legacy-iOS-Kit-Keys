#!/bin/bash

devices=(iPhone1,1 iPhone1,2 iPhone2,1 iPhone3,1 iPhone3,2 iPhone3,3 iPhone4,1 iPhone5,1 iPhone5,2 iPhone5,3 iPhone5,4
         iPad1,1 iPad2,1 iPad2,2 iPad2,3 iPad2,4 iPad2,5 iPad2,6 iPad2,7 iPad3,1 iPad3,2 iPad3,3 iPad3,4 iPad3,5 iPad3,6
         iPod1,1 iPod2,1 iPod3,1 iPod4,1 iPod5,1)
#devices=(iPhone8,1 iPhone8,2 iPhone8,4 iPhone9,1 iPhone9,2 iPhone9,3 iPhone9,4 iPad5,1 iPad5,2 iPad5,3 iPad5,4 iPod9,1)
#devices=(iPhone7,1 iPhone7,2 iPod7,1)

for device in ${devices[@]}; do
    echo $device
    json=$(curl "https://api.ipsw.me/v4/device/$device?type=ipsw")
    mkdir $device

    len=$(echo "$json" | jq -r ".firmwares | length")
    builds=()
    i=0
    while (( i < len )); do
        builds+=($(echo "$json" | jq -r ".firmwares[$i].buildid"))
        ((i++))
    done

    pushd $device
    for build in ${builds[@]}; do
        if [[ $device == "iPhone8"* || $device == "iPhone9"* || $device == "iPad5"* || $device == "iPod9,1" ]]; then
            case $build in
                "18"* | "19"* ) :;;
                * ) continue;;
            esac
        elif [[ $device == "iPhone7"* || $device == "iPod7,1" ]]; then
            case $build in
                "15E"* | "15F"* | "15G"* | "16"* ) :;;
                * ) continue;;
            esac
        fi
        echo $build
        mkdir $build
        pushd $build
        curl -L "https://api.m1sta.xyz/wikiproxy/$device/$build" -o index.html
        #curl -LO https://api.ipsw.me/v2.1/$device/$build/sha1sum
        #curl -LO https://api.ipsw.me/v2.1/$device/$build/url
        popd # $build
        [[ ! -s $build/index.html ]] && rm -rf $build
    done
    if [[ $device == "iPhone8"* || $device == "iPhone9"* || $device == "iPad5"* || $device == "iPod9,1" ]]; then
        build="18C65"
        echo $build
        mkdir $build
        pushd $build
        curl -L "http://127.0.0.1:8888/firmware/$device/$build" -o index.html
        popd # $build
        [[ ! -s $build/index.html ]] && rm -rf $build
    fi
    popd # $device
done
