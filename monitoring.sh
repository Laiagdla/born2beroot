#!/bin/bash
e='\e'
RST=$e'[0m'
RED=$e'[38;2;255;0;0m'    # Red
ORA=$e'[38;2;255;165;0m'  # Orange
YEL=$e'[38;2;255;255;0m'  # Yellow
GRE=$e'[38;2;0;128;0m'    # Green
BLU=$e'[0;94m'    # Blue
PUR=$e'[38;2;128;0;128m'  # Purple

# HEADER
CHAR='▒▒'
FLAG="${RED}${CHAR}${RST}\
${ORA}${CHAR}${RST}\
${YEL}${CHAR}${RST}\
${GRE}${CHAR}${RST}\
${BLU}${CHAR}${RST}\
${PUR}${CHAR}${RST}\
"
user=$(who | awk -v host="$(hostname)" '{print $1"@"host" ("$2")"}')
date=$(date "+(%a %b %d %H:%M:%S %Y)")

# INFO
kernel=$(uname -s)
nodename=$(uname -n)
releasename=$(uname -r)
releaseversion=$(uname -v)
platform=$(uname -i)
os=$(uname -o)
CPUp=$(grep "physical id" /proc/cpuinfo | sort -u | wc -l)
CPUv=$(grep "processor" /proc/cpuinfo | wc -l)
mem=$(free -m | awk '$1 == "Mem:" {printf("%s / %sMB (%.2f%%)", $3, $2, $3/$2*100)}')
disk=$(df -Bm | awk '/^\/dev\// && !/\/boot$/ \
	{used += $3; free += $2} END \
	{printf("%sMB / %.2fGb (%.2f%%)", used, free/1024, used/free*100)}')
load=$(top -bn1 | awk '/^%Cpu/ {printf("%.1f%%"), $2 + $4}')
boot=$(who -b | awk '$1 == "system" {print $3 " " $4}')
lvm=$(lsblk | awk '/lvm/ {count++} END {if (count) {print "yes"} else {print "no"}}')
tcp=$(cat /proc/net/sockstat{,6} | awk '$1 == "TCP:" {print $3}')
users=$(users | wc -w)
network=$(ip -o link | awk -v ip="$(hostname -i)" \
	'/link\/ether/ && /state UP/ {print "IP " ip " (" $17 ")"}')
sudo=$(journalctl _COMM=sudo | grep COMMAND | wc -l)

# FOOTER
distro=$(lsb_release -ds)
broadcast_msg_len=$(echo -n "Broadcast message from" | wc -m)
user_len=$(echo -n "$user" | wc -m)
date_len=$(echo -n "$date" | wc -m)
distro_len=$(echo -n "$distro" | wc -m)
spacelen=$((broadcast_msg_len + user_len + date_len - distro_len))
separator=$(awk -v len="$spacelen" 'BEGIN { for (i=0; i<len; i++) printf "∙" }')

# OUTPUT
output=$(echo -e \
"$FLAG ${PUR} Broadcast message from ${user} ${date} $FLAG \n \
\t ${GRE}▸ architecture${RST} \t \
${BLU}${kernel}\n  \
\t\t\t\t ${nodename}\n\
\t\t\t\t ${releasename}\n\
\t\t\t\t ${releaseversion}\n\
\t\t\t\t ${platform}\n\
\t\t\t\t ${os}\n ${RST}\
\t ${GRE}▸ CPU physical${RST} \t ${CPUp}\n\
\t ${GRE}▸ CPU virtual${RST} \t\t ${CPUv}\n\
\t ${GRE}▸ Memory usage${RST} \t ${mem}\n\
\t ${GRE}▸ Disk usage${RST} \t\t ${disk}\n\
\t ${GRE}▸ CPU load${RST} \t\t ${load}\n\
\t ${GRE}▸ Last boot${RST} \t\t ${boot}\n\
\t ${GRE}▸ LVM use${RST} \t\t ${lvm}\n\
\t ${GRE}▸ TCP connections${RST} \t ${tcp} ESTABLISHED\n\
\t ${GRE}▸ User log${RST} \t\t ${users}\n\
\t ${GRE}▸ Network${RST} \t\t ${network}\n\
\t ${GRE}▸ Sudo${RST} \t\t ${sudo}\n\
$FLAG ${PUR} ${separator} ${distro}  $FLAG \n\
")

echo "$output"
