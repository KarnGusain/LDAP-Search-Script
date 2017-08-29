#!/bin/bash
#Author : karn Kumar (08/02/2017)
# s=1; s*=2; s*=3 here using math, the value s will be divisible by 6 only if both 2 and 3 factors are there, here multiple occurrences won't change the condition but only the latest values encountered are used.

# s && !(s%6) checks for divisibility by 6 and whether value is initialized in "dn" check.

# s=0 reset value after printing, so that printing will be suspended until the next group.

# sep you want the triples separated by an empty line, we don't want to add after every group, since it will leave an empty line at the end, or similarly at the beginning. Alternative is, using a late initialized variable (after first use). So there won't be an empty line at the beginning or the end, but in between groups.
# mapfile is bash build in function can be used with BASH Version >= 4.0 onwards

set -f      # to prevent filename expansion

mapfile -t PLIST < <(ldapsearch -h its3 -x -LLL -b "ou=profile,o=example.com" "cn=*" | awk '/^dn/ {s =1; dn=$0} /^preferredServerList/ {s*=2; ps=$0}/^defaultServerList/ {s*=3; ds=$0} s && !(s%6) {print sep dn ORS ps ORS ds; sep=ORS; s=0}' | awk '/preferredServerList/ { print $2,$3,$4 }')

mapfile -t DLIST < <(ldapsearch -h its3 -x -LLL -b "ou=profile,o=example.com" "cn=*" | awk '/^dn/ {s =1; dn=$0} /^preferredServerList/ {s*=2; ps=$0}/^defaultServerList/ {s*=3; ds=$0} s && !(s%6) {print sep dn ORS ps ORS ds; sep=ORS; s=0}' | awk '/defaultServerList/ { print $2,$3,$4 }')

mapfile -t LLIST < <(ldapsearch -h its3 -x -LLL -b "ou=profile,o=example.com" "cn=*" | awk '/^dn/ {s =1; dn=$0} /^preferredServerList/ {s*=2; ps=$0}/^defaultServerList/ {s*=3; ds=$0} s && !(s%6) {print sep dn ORS ps ORS ds; sep=ORS; s=0}' | awk '/dn/ {print $2}'| cut -d "," -f1 | cut -d"=" -f2)

count_x=${#PLIST[@]}
count_y=${#DLIST[@]}
count_l=${#LLIST[@]}

#echo $count_x
#echo $count_y
#echo $count_l

# Find out which of the two is larger in size, assuming that's a possibility
if [[ $count_x -lt $count_y ]]
  then
    count=$count_y
else
  count=${count_x}
#elif
# count=${count_l}
fi

printf "=%.0s"  $(seq 1 150)
printf "\n"
printf "%-50s : %-50s : %-50s\n"         "PreferredList IP's"  "DefaultServerList IP's"   "Location"            # print header
printf "=%.0s"  $(seq 1 150)                                                                                    # print separator
printf "\n"                                                                                                     # print newline

for i in $(seq $count);
do
  printf "%-50s : %-50s : %-50s\n"  "${PLIST[i-1]}"    "${DLIST[i-1]}" "${LLIST[i-1]}"
done
