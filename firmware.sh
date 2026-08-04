#!/usr/bin/env bash

set -euo pipefail

# --- Device Configuration ---
devices=(
    iPhone1,1 iPhone1,2 iPhone2,1 iPhone3,1 iPhone3,2 iPhone3,3 iPhone4,1 iPhone5,1 iPhone5,2 iPhone5,3 iPhone5,4
    iPad1,1 iPad2,1 iPad2,2 iPad2,3 iPad2,4 iPad2,5 iPad2,6 iPad2,7 iPad3,1 iPad3,2 iPad3,3 iPad3,4 iPad3,5 iPad3,6
    iPod1,1 iPod2,1 iPod3,1 iPod4,1 iPod5,1

    iPhone6,1 iPhone6,2 iPhone7,1 iPhone7,2 iPhone8,1 iPhone8,2 iPhone8,4 iPhone9,1 iPhone9,2 iPhone9,3 iPhone9,4
    iPad4,1 iPad4,2 iPad4,3 iPad4,4 iPad4,5 iPad4,6 iPad4,7 iPad4,8 iPad4,9 iPad5,1 iPad5,2 iPad5,3 iPad5,4
    iPod7,1 iPod9,1

    iPhone10,1 iPhone10,2 iPhone10,3 iPhone10,4 iPhone10,5 iPhone10,6
    iPad6,3 iPad6,4 iPad6,7 iPad6,8 iPad6,11 iPad6,12 iPad7,1 iPad7,2 iPad7,3 iPad7,4 iPad7,5 iPad7,6 iPad7,11 iPad7,12

    AppleTV2,1 AppleTV3,1 AppleTV3,2 AppleTV5,3
)

# --- Helper Functions ---
fetch_build() {
    local device="$1"
    local build="$2"
    local target_dir="$device/$build"
    local target_file="$target_dir/index.html"

    echo "  -> Processing build: $build"

    # Pre-check existing file validity
    if [[ -f "$target_file" ]]; then
        if grep -q "no firmware keys" "$target_file" 2>/dev/null; then
            rm -rf "$target_dir"
        elif [[ -s "$target_file" ]]; then
            return 0  # Valid non-empty file already exists, skip download
        fi
    fi

    mkdir -p "$target_dir"

    # Download index.html
    # Adjust URL as needed (e.g., https://api.m1sta.xyz/wikiproxy/$device/$build)
    curl -sSL "http://127.0.0.1:8888/firmware/$device/$build" -o "$target_file" || true

    # Post-download validation
    if grep -q "no firmware keys" "$target_file" 2>/dev/null || [[ ! -s "$target_file" ]]; then
        rm -rf "$target_dir"
    fi
}

# --- Main Logic ---
for device in "${devices[@]}"; do
    echo "========================================"
    echo "Processing Device: $device"
    echo "========================================"

    mkdir -p "$device"

    # 1. Fetch JSON and extract official build IDs efficiently in a single step
    json=$(curl -sSL "https://api.ipsw.me/v4/device/$device?type=ipsw" || echo "")

    builds=()
    if [[ -n "$json" ]]; then
        mapfile -t builds < <(echo "$json" | jq -r '.firmwares[].buildid // empty')
    fi

    # 2. Append legacy / special-case build IDs
    case "$device" in
        iPod1,1    ) builds+=(5A347 5B108 5C1 5F137 5G77 5H11);;&
        iPod[12],1 ) builds+=(7A341 7C145 7D11 7E18);;
    esac

    case "$device" in
        iPhone1,1 | iPod1,1 ) builds+=(5A147p 5A225c 5A240d 5A258f 5A274d 5A292g 5A308 5A331 5F90);;&
        iPhone1,1 ) builds+=(5A345);;&

        iPhone1,[12] | iPod1,1 ) builds+=(7A238j 7A259g 7A280f 7A300g 7A312g 7A341);;&
        iPhone2,1 ) builds+=(7C97d 7C106c 7C116a);;&

        AppleTV2,1 ) builds+=(8F5148c 8F5153d 8F5166b 9A5220p 9A5248d 9A5259f 9A5288d 9A5302b 9A5313e 9B5127c 9B5141a 10B5105c 11D5099e);;&
        iPad1,1 ) builds+=(8C5091e 8C5101c 8C5115c 8C134 8C134b 8C148 8F5148b 8F5153d 8F5166b 8F190);;&
        iPhone1,2 | iPhone2,1 | iPod[23],1 ) builds+=(8A230m 8A248c 8A260b 8A274b 8A293);;&
        iPhone1,2 | iPhone[23],1 | iPod[23],1 ) builds+=(8B5080c 8B5091b 8B5097d);;&
        iPhone1,2 | iPhone[23],1 | iPod[234],1 ) builds+=(8B117 8C5091e 8C5101c 8C5115c 8C134);;&
        iPhone[23],1 | iPod[34],1 ) builds+=(8F5148b 8F5153d 8F5166b 8F190);;&

        AppleTV[23],1 ) builds+=(10A5316k 10A5338d 10A5355d 10A5376e 10B5117b 10B5126b);;&
        AppleTV[23],1 | AppleTV3,2 ) builds+=(11A4372q 11A4400f 11A4435d 11A4449a 11D5115d 11D5127c 11D5134c 11D5145e 11D169b);;&
        iPad1,1 | iPad2,[123] | iPhone2,1 | iPhone3,[13] | iPod[34],1 ) builds+=(9A5220p 9A5248d 9A5259f 9A5274d 9A5288d 9A5302b 9A5313e 9A332 9A334);;&
        iPad1,1 | iPad2,[123] | iPhone[24],1 | iPhone3,[13] | iPod[34],1 ) builds+=(9A402 9A404 9B5117b 9B5127c 9B5141a 9B155 9B174);;&

        iPad2,[1234] | iPad3,[123] | iPhone2,1 | iPhone3,[13] | iPhone4,1 | iPod4,1 ) builds+=(10A5316k 10A5338d 10A5355d 10A5376e 10A403);;&
        iPad2,[12345] | iPad3,[1234] | iPhone2,1 | iPhone3,[13] | iPhone4,1 | iPhone5,[12] | iPod[45],1 ) builds+=(10B5095f);;&
        iPad2,[1234567] | iPad3,[123456] | iPhone2,1 | iPhone3,[13] | iPhone4,1 | iPhone5,[12] | iPod[45],1 ) builds+=(10B5105c 10B5117b 10B5126b 10B141 10B311);;&
        iPad2,[1234567] | iPad3,[123456] ) builds+=(10B318a);;&
        iPhone2,1 | iPhone3,[13] | iPhone4,1 | iPhone5,[12] | iPod[45],1 ) builds+=(10B318);;&
        iPhone4,1 ) builds+=(10B142);;&
        iPhone5,[12] ) builds+=(10B143);;&
        iPhone3,[12] | iPod4,1 ) builds+=(10B144);;&

        AppleTV3,[12] ) builds+=(12A4297e 12A4318c 12A4331d 12A4345d 12A365b 12B401 12B407 12F61 12H825 12H833 12H836 12H841);;&
        AppleTV3,1 ) builds+=(12F5037c 12F5047f);;&

        iPad2,[1234] | iPad3,[123456] ) builds+=(11A4400f 11A4414e 11A4435d 11A4449a 11A4449d 11A465 11D5099e 11D5115d 11D5127c 11D5134c 11D5145e 11D167);;&
        iPad4,[12] ) builds+=(11D5099e 11D5115d 11D5127c 11D5134c 11D5145e 11D167);;&
        iPad2,[567] ) builds+=(11A4400f 11A4414e 11A4435d 11A4449a 11A4449d 11A465);;&
        iPad2,[567] | iPad4,[45] ) builds+=(11D5099e 11D5115d 11D5127c 11D5134c 11D5145e 11D167);;&
        iPhone3,[123] | iPhone4,1 | iPhone5,[12] ) builds+=(11A4372q 11A4400f 11A4414e 11A4435d 11A4449a 11A4449d 11A465);;&
        iPhone3,[123] | iPhone4,1 | iPhone5,[1234] | iPhone6,[12] ) builds+=(11D5099e 11D5115d 11D5127c 11D5134c 11D5145e);;&
        iPhone3,3 | iPhone4,1 | iPhone5,[1234] | iPhone6,[12]  ) builds+=(11D167);;&
        iPhone3,[12] ) builds+=(11D169);;&
        iPod5,1 ) builds+=(11A4372q 11A4400f 11A4414e 11A4435d 11A4449a 11A4449d 11A465 11D5099e 11D5115d 11D5127c 11D5134c 11D5145e 11D167);;&

        iPad2,[1234] | iPad3,[123456] ) builds+=(12A4265u 12A4297e 12A4318c 12A4331d 12A4345d 12A365 12B401 12B407 12D445d 12D5452a 12D5461b 12D5480a 12F5027d 12F5037c 12F5047f 12F61 12H4074d 12H4086d 12H4098c 12H4125a 12H318);;&
        iPad2,1 ) builds+=(12D436);;&
        iPad2,[124] | iPad3,[123456] ) builds+=(12H304);;&
        iPad4,[123] ) builds+=(12A4265u 12A4297e 12A4318c 12A4331d 12A4345d 12A365 12B401 12B407);;&
        iPad4,2 | iPad5,4 ) builds+=(12B408);;&
        iPad4,[123] | iPad5,3 ) builds+=(12B432);;&
        iPad4,[123] | iPad5,[34] ) builds+=(12D445d 12D5452a 12D5461b 12D5480a 12F5027d 12F5037c 12F5047f 12F61 12H4074d 12H4086d 12H4098c 12H4125a 12H304 12H318);;&
        iPad2,[567] | iPad4,[456] ) builds+=(12A4265u 12A4297e 12A4318c 12A4331d 12A4345d 12A365 12B401 12B407);;&
        iPad2,5 | iPad4,[456] ) builds+=(12B432);;&
        iPad2,[456] | iPad4,[456789] ) builds+=(12D445d 12D5452a 12D5461b 12D5480a 12F5027d 12F5037c 12F5047f 12F61 12H4074d 12H4086d 12H4098c 12H4125a 12H304 12H318);;&
        iPhone4,1 | iPhone5,[1234] | iPhone6,[12] ) builds+=(12A4265u 12A4297e 12A4318c 12A4331d 12A4345d 12A365);;&
        iPhone4,1 | iPhone5,[1234] | iPhone[67],[12] ) builds+=(12B401 12B407 12B432 12D445d 12D5452a 12D5461b 12D5480a 12F5027d 12F5037c 12F5047f 12F61 12H4074d 12H4086d 12H4098c 12H4125a 12H304 12H318);;&
        iPhone6,1 | iPhone7,[12] ) builds+=(12B408);;&
        iPhone4,1 | iPhone6,2 ) builds+=(12D436);;&
        iPod5,1 ) builds+=(12A4265u 12A4297e 12A4318c 12A4331d 12A4345d 12A365 12B401 12B407 12B432 12D436 12D445d 12D5452a 12D5461b 12D5480a 12F5027d 12F5037c 12F5047f 12F61 12H4074d 12H4086d 12H4098c 12H4125a 12H304);;&
        iPod[57],1 ) builds+=(12H318);;&

        AppleTV5,3 ) builds+=(13T5347l 13T5365h 13T5379f 13T396 13U5069b 13U5077a 13U713 13Y5179e 13Y5189e 13Y5198c 13Y5210d 13Y5220c 13Y5232a 13Y763b 13Y763c 13Y768 13Y772 13Y807 13Y816 13Y825);;&
        iPad[23456],* | iPhone[45678],* | iPod[57],1 ) builds+=(13A4254v 13A4280e 13A4293f 13A4293g 13A4305g 13A4325c 13A340 13A341 13B5110e 13B5119e 13B5130b 13B136 13B137 13B139 13C5055d 13C5060d 13C71 13C75 13D11 13D14 13E5181d 13E5181f 13E5191d 13E5200d 13E5214d 13E5225a 13E5231a 13E5233a 13E5234a 13F51a 13F61 13F65 13F68 13G12 13G21 13G29 13G33 13G34);;&

        iPad[67],* | iPhone[89],* | iPhone10,* | iPod9,1 ) builds+=(18C65);;&
    esac

    # Deduplicate builds array using sort -u
    mapfile -t unique_builds < <(printf "%s\n" "${builds[@]}" | sort -u)

    # 3. Download builds
    for build in "${unique_builds[@]}"; do
        [[ -z "$build" ]] && continue
        fetch_build "$device" "$build"
    done
done
