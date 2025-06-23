#!/bin/bash
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

#WRAPPER
distro=$(lsb_release -ds)
separator=$(awk -v len="60" 'BEGIN { for (i=0; i<len; i++) printf "∙" }')

# OUTPUT
output=$(echo -e \
"${separator} ${distro}\n\
\t ▸ architecture \t \
${kernel}\n  \
\t\t\t\t ${nodename}\n\
\t\t\t\t ${releasename}\n\
\t\t\t\t ${releaseversion}\n\
\t\t\t\t ${platform}\n\
\t\t\t\t ${os}\n \
\t ▸ CPU physical \t ${CPUp}\n\
\t ▸ CPU virtual \t\t ${CPUv}\n\
\t ▸ Memory usage \t ${mem}\n\
\t ▸ Disk usage \t\t ${disk}\n\
\t ▸ CPU load \t\t ${load}\n\
\t ▸ Last boot \t\t ${boot}\n\
\t ▸ LVM use \t\t ${lvm}\n\
\t ▸ TCP connections \t ${tcp} ESTABLISHED\n\
\t ▸ User log \t\t ${users}\n\
\t ▸ Network \t\t ${network}\n\
\t ▸ Sudo \t\t ${sudo}\n\
${separator} ${distro}\n\
")

wall "$output"
