#!/bin/bash
host="$1"
index="/usr/lib/nagios/plugins/ganglia/index.html"
plugins="/usr/lib/nagios/plugins/"
mem=$2

if [ "$mem" = "ram" ]; then
ram_total=$($plugins/check_ganglia.py -F $index -H $host -M mem_total | awk  '{print $8}' | sed -s 's/mem_total=//g' | awk -F "." '{print $1}')
ram_free=$($plugins/check_ganglia.py -F $index -H $host -M mem_free | awk  '{print $8}' | sed -s 's/mem_free=//g' | awk -F "." '{print $1}')
ram=$(echo "$ram_free/$ram_total" | bc -l) 
ram_perc=$(echo "$ram * 100" | bc -l | awk -F "." '{print $1}')

echo "OK: ram_free=$ram_free, ram_perc_free=$ram_perc% | ram_free=$ram_free ram_total=$ram_total ram_perc_free=$ram_perc"
fi


if [ "$mem" = "swap" ]; then
swap_total=$($plugins/check_ganglia.py -F $index -H $host -M swap_total | awk  '{print $8}' | sed -s 's/swap_total=//g' | awk -F "." '{print $1}')
swap_free=$($plugins/check_ganglia.py -F $index -H $host -M swap_free | awk  '{print $8}' | sed -s 's/swap_free=//g' | awk -F "." '{print $1}')
swap=$(echo "$swap_free/$swap_total" | bc -l)
swap_perc=$(echo "$swap * 100" | bc -l | awk -F "." '{print $1}')

echo "OK: swap_free=$swap_free, swap_perc_free=$swap_perc% | swap_free=$swap_free swap_total=$swap_total swap_perc_free=$swap_perc"
fi

