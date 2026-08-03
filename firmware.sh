#!/usr/bin/env bash

devices=(iPhone1,1 iPhone1,2 iPhone2,1 iPhone3,1 iPhone3,2 iPhone3,3 iPhone4,1 iPhone5,1 iPhone5,2 iPhone5,3 iPhone5,4
         iPad1,1 iPad2,1 iPad2,2 iPad2,3 iPad2,4 iPad2,5 iPad2,6 iPad2,7 iPad3,1 iPad3,2 iPad3,3 iPad3,4 iPad3,5 iPad3,6
         iPod1,1 iPod2,1 iPod3,1 iPod4,1 iPod5,1

         iPhone6,1 iPhone6,2 iPhone7,1 iPhone7,2 iPhone8,1 iPhone8,2 iPhone8,4 iPhone9,1 iPhone9,2 iPhone9,3 iPhone9,4
         iPad4,1 iPad4,2 iPad4,3 iPad4,4 iPad4,5 iPad4,6 iPad4,7 iPad4,8 iPad4,9 iPad5,1 iPad5,2 iPad5,3 iPad5,4
         iPod7,1 iPod9,1

         iPhone10,1 iPhone10,2 iPhone10,3 iPhone10,4 iPhone10,5 iPhone10,6
         iPad6,3 iPad6,4 iPad6,7 iPad6,8 iPad6,11 iPad6,12 iPad7,1 iPad7,2 iPad7,3 iPad7,4 iPad7,5 iPad7,6 iPad7,11 iPad7,12)

for device in ${devices[@]}; do
    echo
    echo $device
    json=$(curl "https://api.ipsw.me/v4/device/$device?type=ipsw")
    mkdir -p $device

    len=$(echo "$json" | jq -r ".firmwares | length")
    builds=()
    i=0
    while (( i < len )); do
        builds+=($(echo "$json" | jq -r ".firmwares[$i].buildid"))
        ((i++))
    done
    case $device in
        iPod1,1    ) builds+=(5A347 5B108 5C1 5F137 5G77 5H11);&
        iPod[12],1 ) builds+=(7A341 7C145 7D11 7E18);;
    esac

    pushd $device
    for build in ${builds[@]}; do
        echo $build
        [[ -d $build ]] && continue
        mkdir -p $build
        pushd $build
        #curl -L "https://api.m1sta.xyz/wikiproxy/$device/$build" -o index.html
        curl -L "http://127.0.0.1:8888/firmware/$device/$build" -o index.html
        #curl -LO https://api.ipsw.me/v2.1/$device/$build/sha1sum
        #curl -LO https://api.ipsw.me/v2.1/$device/$build/url
        popd # $build
        [[ ! -s $build/index.html ]] && rm -rf $build
    done
    case $device in
        iPad[67],* | iPhone[89],* | iPhone10,* | iPod9,1 )
            build="18C65"
            echo $build
            mkdir -p $build
            pushd $build
            curl -L "http://127.0.0.1:8888/firmware/$device/$build" -o index.html
            popd # $build
            [[ ! -s $build/index.html ]] && rm -rf $build
        ;;
    esac
    popd # $device
done
