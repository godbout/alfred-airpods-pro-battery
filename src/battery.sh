SYSTEM_PROFILER=$(system_profiler SPBluetoothDataType 2>/dev/null)
MAC_ADDRESS=$(grep -B8 "Minor Type: Headphones" <<< "${SYSTEM_PROFILER}" | awk '/Address/{print $2}')
CONNECTED=$(grep -A6 "${MAC_ADDRESS}" <<< "${SYSTEM_PROFILER}" | awk '/Connected: Yes/{print 1}')

if [[ "${CONNECTED}" ]]; then
  CASE_BATTERY_LEVEL=$(grep -A6 "${MAC_ADDRESS}" <<< "${SYSTEM_PROFILER}" | awk '/Case Battery Level/{print $4}')
  LEFT_BATTERY_LEVEL=$(grep -A6 "${MAC_ADDRESS}" <<< "${SYSTEM_PROFILER}" | awk '/Left Battery Level/{print $4}')
  RIGHT_BATTERY_LEVEL=$(grep -A6 "${MAC_ADDRESS}" <<< "${SYSTEM_PROFILER}" | awk '/Right Battery Level/{print $4}')
  battery="L: ${LEFT_BATTERY_LEVEL} R: ${RIGHT_BATTERY_LEVEL} C: ${CASE_BATTERY_LEVEL}"
else
  battery="not connected"
fi

cat << EOB
{"items": [
    {
        "uid": "battery",
        "title": "$battery",
    }
]}
EOB
