#!/bin/bash
SYSTEM_PROFILER=$(system_profiler SPBluetoothDataType 2>/dev/null)

CONNECTED=$(awk '/  Connected:/{f=1;next} /Not Connected:/{f=0} f' <<< "${SYSTEM_PROFILER}" | grep -B4 "Battery Level:")

print_device() {
    # echo $device
    if [ "$device" != "" ]; then
        CASE_BATTERY_LEVEL=$(echo "${device}" | awk '/Case Battery Level/{print $4}')
        LEFT_BATTERY_LEVEL=$(echo "${device}" | awk '/Left Battery Level/{print $4}')
        RIGHT_BATTERY_LEVEL=$(echo "${device}" | awk '/Right Battery Level/{print $4}')
        battery="🅛 ${LEFT_BATTERY_LEVEL} 🅡 ${RIGHT_BATTERY_LEVEL} | Case: ${CASE_BATTERY_LEVEL}"
        if [[ "$LEFT_BATTERY_LEVEL" = "" && "$RIGHT_BATTERY_LEVEL" = ""  ]]; then
            battery=$(echo "${device}" | awk '/Battery Level/{print $3}')
        fi
        if [[ "$battery" != "" ]]; then
            ## customize the row as you wish
            # echo "<item> <subtitle>$battery</subtitle> <title>$name</title> </item>"
            # echo "<item> <title>$name $battery</title> </item>"
            # echo "<item> <title>$battery - $name</title> </item>"
            echo "<item> <title>$battery</title> <subtitle>$name</subtitle> </item>"
        fi
    fi
}


COUNT=$(echo $CONNECTED | grep -c "Vendor ID: 0x004C")

if [[ "$COUNT" != "0"  ]]; then

    echo "<?xml version='1.0' encoding='utf-8'?> <items>" # use XML as it will be easier to print logs to the output into alfred with echo

    nl=$'\n'
    name=""
    device=""

    CONNECTED="$CONNECTED$nl--" # append a separator to the end

    ## split CONNECTED into devices

    echo "${CONNECTED}" | while read -r line
    do
        if [ "$device" = "" ]
            then
            name=${line%?} # remove the colon: at the last place of device name
            device="$line"
        elif [ "$line" = "--" ]
            then
            print_device # print device battery in XML
            device=""
        else
            echo $line
            device="$device$nl$line" # append more lines to the device
        fi
    done

    echo "</items>"

else
cat << EOB
    {"items": [
        {
            "uid": "battery",
            "title": "not connected",
        }
    ]}
EOB
fi
