# arpdefender
MiTM (arp poisoning) prevention on LAN networks

Currently this script is only a small test script, do not use in production environments!

The script generate a IP+ARP association table and then checks every 5 seconds for changes,
when it detects a change in the current ARP table it reverts the IP to the original MAC address
with a static ARP entry, and prompts the user if he wants to keep the change blocked. If the
user don't want to block the change, it deletes the previously created static ARP entry.

To run it, you need bash and zenity (for GUI interaction) and of course, root access.

# Limitations:
- Synchronous GUI! When the GUI is active, the process is stopped!
- Blocking is not instantaneous, the ARP table can be poisoned up to 5 seconds (due to check rate).
- Zenity requirements for GUI interaction, I didn't tested running the script from startup (i.e. /etc/rc.local)

# Disclaimer:
I do not assure that the script will block ALL the MiTM attacks, nor even all the ARP spoofing attacks.
This is only a small test script to implement further if it is successful, no more no less.
I'm glad if it works well for you, but I'm not responsible or liable of any failure, loss of performance,
loss of data or any other type of damage directly or indirectly derived from the use of this script.
You use it at your very own responsability.
