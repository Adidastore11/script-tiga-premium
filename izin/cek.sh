#!/bin/bash

MYIP=$(curl -s ipv4.icanhazip.com)
TODAY=$(date +%Y-%m-%d)

DATA=$(curl -s https://raw.githubusercontent.com/Adidastore11/script-tiga-premium/main/izin/ip)

FOUND="NO"

while read -r line; do
  # skip baris kosong
  [[ -z "$line" ]] && continue

  # skip baris yang tidak diawali #
  [[ "${line:0:1}" != "#" ]] && continue

  # format: # nama YYYY-MM-DD IP
  EXP=$(echo "$line" | awk '{print $3}')
  IP=$(echo "$line" | awk '{print $4}')

  if [[ "$IP" == "$MYIP" ]]; then
    FOUND="YES"

    if [[ "$TODAY" > "$EXP" ]]; then
      echo "❌ VPS EXPIRED ($EXP)"
      exit 1
    else
      echo "✅ VPS AKTIF sampai $EXP"
      exit 0
    fi
  fi
done <<< "$DATA"

if [[ "$FOUND" == "NO" ]]; then
  echo "❌ VPS tidak terdaftar di izin"
  exit 1
fi
