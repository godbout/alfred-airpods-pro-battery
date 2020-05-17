BLUETOOTH_DEFAULTS=$(defaults read /Library/Preferences/com.apple.Bluetooth)
SYSTEM_PROFILER=$(system_profiler SPBluetoothDataType 2>/dev/null)
MAC_ADDRESS=$(grep -B2 "Minor Type: Headphones" <<< "${SYSTEM_PROFILER}" | awk '/Address/{print $2}')
CONNECTED=$(grep -A6 "${MAC_ADDRESS}" <<< "${SYSTEM_PROFILER}" | awk '/Connected: Yes/{print 1}')
BLUETOOTH_DATA=$(grep -iA6 '"'"${MAC_ADDRESS}"'"' <<< "${BLUETOOTH_DEFAULTS}")
BATTERY_LEVELS=("BatteryPercentCase" "BatteryPercentLeft" "BatteryPercentRight")

if [[ "${CONNECTED}" ]]; then
  for i in "${BATTERY_LEVELS[@]}"; do
    declare -x "${i}"="$(awk -v pattern="${i}" '$0 ~ pattern {gsub(";", ""); print $3}' <<< "${BLUETOOTH_DATA}")"
    [[ ! -z "${!i}" ]] && OUTPUT="${OUTPUT} $(awk '/BatteryPercent/{print substr($0, 15, 1)": "}' <<< "${i}")${!i}%"
  done
  printf -v res "%s" "${OUTPUT}"
else
  printf -v res "Not Connected"
fi

battery=$(echo $res | awk '
  {
    if ($2 ~ "n|Not")
      print "Not Connected";
    else if ($2 == "0%")
      print " L: " $4 " R: " $6;
    else
      print " L: " $4 " R: " $6 " (C: "$2 ")";
  }
')

cat << EOB
{"items": [
    {
        "uid": "battery",
        "title": "$battery",
    }
]}
EOB
