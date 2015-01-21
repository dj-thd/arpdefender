#!/bin/bash

declare -a c=0
declare -a hostname
declare -a ip
declare -a mac

function getcurrentarray {
	c=0
	while read line; do
		current_mac=`echo $line | cut -d' ' -f4`
		if [[ "$current_mac" != "<incomplete>" ]]; then
			hostname[$c]=`echo $line | cut -d' ' -f1`
			ip[$c]=`echo $line | cut -d' ' -f2 | cut -d'(' -f2 | cut -d')' -f1`
			mac[$c]="$current_mac"
			((c++))
		fi
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
				arp -s "${ip[$i]}" "${mac[$i]}"
				previous_mac="${mac[$i]}"
				ipfrommac "$2"
				echo "`date '+%F %H:%I:%S'` - Target: $1, original MAC: $previous_mac, spoofed MAC: $2, spoofed MAC alternate IP addr: $result" >> /var/log/arpdefender
				zenity --title "arpdefender" --question --text "A possible arp spoof attack has been detected, logged and blocked.\nDetails are following here:\n\nSpoofed IP: $1\nPrevious MAC address: $previous_mac\nNew MAC address (presumably attacker MAC): $2\nPossible attacker IP: $result\n\nWould you like to keep blocking it permanently for 1 hour?"
				if [[ "$?" != 0 ]]; then
					arp -d "$1"
				else
					mac[$i]="$2"
				fi
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
		if [[ "$current_mac" != "<incomplete>" ]]; then
			checkip "$current_ip" "$current_mac"
		fi
	done <<EOT
$(arp -a)
EOT
done
