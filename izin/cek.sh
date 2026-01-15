#!/bin/bash
# ====== CEK IZIN VPS ======

# Ambil IP VPS
MYIP=$(curl -s ipv4.icanhazip.com)

# Tanggal hari ini (epoch)
TODAY_EPOCH=$(date +%s)

# Ambil data izin dari GitHub
DATA=$(curl -s https://raw.githubusercontent.com/Adidastore11/script-tiga-premium/main/izin/ip)

FOUND="NO"

while read -r line; do
  # skip baris kosong
  [[ -z "$line" ]] && continue

  # hanya proses baris izin
  [[ "${line:0:1}" != "#" ]] && continue

  # format: # nama YYYY-MM-DD IP
  NAME=$(echo "$line" | awk '{print $2}')
  EXP=$(echo "$line" | awk '{print $3}')
  IP=$(echo "$line" | awk '{print $4}')

  if [[ "$IP" == "$MYIP" ]]; then
    FOUND="YES"

    EXP_EPOCH=$(date -d "$EXP" +%s 2>/dev/null)

    if [[ -z "$EXP_EPOCH" ]]; then
      echo "❌ FORMAT TANGGAL SALAH ($EXP)"
      exit 1
    fi

    if [[ "$TODAY_EPOCH" -gt "$EXP_EPOCH" ]]; then
      echo "❌ VPS EXPIRED ($EXP)"
      exit 1
    else
      LEFT=$(( (EXP_EPOCH - TODAY_EPOCH) / 86400 ))
      echo "✅ VPS AKTIF"
      echo "Nama        : $NAME"
      echo "Expired     : $EXP"
      echo "Sisa Hari   : $LEFT Hari"
      exit 0
    fi
  fi
done <<< "$DATA"

if [[ "$FOUND" == "NO" ]]; then
  echo "❌ VPS TIDAK TERDAFTAR DI IZIN"
  exit 1
fi
