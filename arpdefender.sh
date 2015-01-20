#!/bin/bash

declare -a c=0
declare -a hostname
declare -a ip
declare -a mac

function getcurrentarray {
	c=0
	while read line; do
		hostname[$c]=`echo $line | cut -d' ' -f1`
		ip[$c]=`echo $line | cut -d' ' -f2 | cut -d'(' -f2 | cut -d')' -f1`
		mac[$c]=`echo $line | cut -d' ' -f4`
		((c++))
	done <<EOT
$(arp -a)
EOT
}

function ipfrommac {
	for i in `seq 0 $((c-1))`; do
		if [ "${mac[$i]}" == "$1" ]; then
			result="${ip[$i]}"
			return
		fi
	done
	result="(unknown)"
}

function checkip {
	for i in `seq 0 $((c-1))`; do
		if [ "${ip[$i]}" == "$1" ]; then
			if [ "${mac[$i]}" != "$2" ]; then
				echo "IP ${ip[$i]} (${hostname[$i]}) has changed MAC address (previous: (${mac[$i]}), new: $2"
				mac[$i]="$2"
				ipfrommac "$2"
				echo "Possible attacker IP: $result"
			fi
		fi
	done
}

while true; do
	getcurrentarray
	sleep 5
	while read line; do
		current_ip=`echo $line | cut -d' ' -f2 | cut -d'(' -f2 | cut -d')' -f1`
		current_mac=`echo $line | cut -d' ' -f4`
		checkip "$current_ip" "$current_mac"
	done <<EOT
$(arp -a)
EOT
done
