#!/bin/bash

MYIP=$(curl -s ipv4.icanhazip.com)
TODAY=$(date +%Y-%m-%d)

DATA=$(curl -s https://raw.githubusercontent.com/Adidastore11/script-tiga-premium/main/izin/ip)

IZIN_DIR="/etc/izin"
mkdir -p $IZIN_DIR

FOUND="NO"

while read -r line; do
  [[ -z "$line" ]] && continue
  [[ "${line:0:1}" != "#" ]] && continue

  NAME=$(echo "$line" | awk '{print $2}')
  EXP=$(echo "$line" | awk '{print $3}')
  IP=$(echo "$line" | awk '{print $4}')

  if [[ "$IP" == "$MYIP" ]]; then
    FOUND="YES"

    if [[ "$(date -d "$TODAY" +%s)" -gt "$(date -d "$EXP" +%s)" ]]; then
      echo "EXPIRED" > $IZIN_DIR/status
      echo 0 > $IZIN_DIR/days
      echo "$NAME" > $IZIN_DIR/name
      echo "$EXP" > $IZIN_DIR/expired
      exit 1
    else
      DAYS_LEFT=$(( ( $(date -d "$EXP" +%s) - $(date -d "$TODAY" +%s) ) / 86400 ))
      echo "ACTIVE" > $IZIN_DIR/status
      echo "$DAYS_LEFT" > $IZIN_DIR/days
      echo "$NAME" > $IZIN_DIR/name
      echo "$EXP" > $IZIN_DIR/expired
      exit 0
    fi
  fi
done <<< "$DATA"

if [[ "$FOUND" == "NO" ]]; then
  echo "NOT_REGISTERED" > $IZIN_DIR/status
  echo 0 > $IZIN_DIR/days
  exit 1
fi
