#!/usr/bin/env bash

CACHE="$HOME/.cache/razer-battery"

mkdir -p "$(dirname "$CACHE")"

read -r BATTERY CHARGING <<< "$(python - <<'PY'
import dbus
from openrazer.client import DeviceManager

dm = DeviceManager()

for d in dm.devices:
    if "DeathAdder" in d.name:
        power = dbus.Interface(d._dbus, "razer.device.power")
        print(round(power.getBattery()), power.isCharging())
        break
PY
)"

# Ignore the fake 0% reported during sleep
if [[ "$BATTERY" == "0" && -f "$CACHE" ]]; then
    BATTERY=$(cat "$CACHE")
elif [[ -n "$BATTERY" && "$BATTERY" != "0" ]]; then
    echo "$BATTERY" > "$CACHE"
fi

if [[ -n "$BATTERY" ]]; then
    if [[ "$CHARGING" == "1" || "$CHARGING" == "True" ]]; then
        printf '{"text":"󰚥","tooltip":"Razer DeathAdder V2 Pro\\nCharging: %s%%"}\n' "$BATTERY"
    else
        printf '{"text":"󰍽","tooltip":"Razer DeathAdder V2 Pro\\nBattery: %s%%"}\n' "$BATTERY"
    fi
else
    printf '{"text":"󰍽","tooltip":"Razer mouse unavailable"}\n'
fi
