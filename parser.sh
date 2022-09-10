#!/bin/bash
# Convert PDF to TXT with python3 using PyPDF2 (pip install needed)
python3 - << EOF
from PyPDF2 import PdfReader
reader = PdfReader("$1")
f = open("tmp.txt", "w")
for page in reader.pages:
    f.write(page.extract_text())
f.close()
EOF
# Remove blank newlines (BUG 1)
while read -r line; do
    if [[ ${#line} -gt 1 ]]; then
        echo "$line"
    fi
done < "./tmp.txt" > "./raw.txt" && rm "./tmp.txt"
# Adjust format to show all results in single line (BUG 2)
sed ':a;N;$!ba;s/,\n/, /g' < "./raw.txt" > "./in.txt" && rm "./raw.txt"
# Adjust format to space out KTU ID (BUG 3)
grep -oE "[L]*ADR[0-9]+[A-Z]{2}[0-9]{3}" < "./in.txt" | while read -r f; do
    sed -i "s/$f/$f, /g" in.txt
done
# Figure out first and last line numbers
FIRST_LINE=$(grep -nE ".*" < "./in.txt" | head -1 | grep -oE "^[0-9]+")
LAST_LINE=$(grep -nE ".*" < "./in.txt" | tail -1 | grep -oE "^[0-9]+")
# Fetch stream lines
# STREAM_LINES=$(grep "Course Code Course" -B1 -n < "in.txt" | grep -E "[0-9]+-" | grep -oE "^[0-9]+")
STREAM_COUNTER=-1
STREAM_LINES=()
STREAM_LINES+=("$FIRST_LINE")
while read -r STREAM_LINE; do
    STREAM_LINES+=("$STREAM_LINE")
    STREAM_COUNTER=$((STREAM_COUNTER+1))
done < <(grep "Course Code Course" -B1 -n < "in.txt" | grep -E "[0-9]+-" | grep -oE "^[0-9]+")
STREAM_LINES+=("$((LAST_LINE+1))")
# Fetch streams
# STREAMS=$(grep "Course Code Course" -B1 -n < "in.txt" | grep -E "[0-9]+-" | sed -E "s/^[0-9]+-//g")
STREAMS=()
while read -r STREAM; do
    STREAMS+=("$STREAM")
done < <(grep "Course Code Course" -B1 -n < "in.txt" | grep -E "[0-9]+-" | sed -E "s/^[0-9]+-//g")
# Format in.txt to remove whitespace after ',' for csv
sed -i "s/, /,/g" "./in.txt"
# Dump csv
[ -f "./in.csv" ] && rm "./in.csv"
echo -e "KTUID,COURSE_1,COURSE_2,COURSE_3,COURSE_4,COURSE_5,COURSE_6,COURSE_7,COURSE_8" > "./in.csv"
#  | sed "s/\([A-Z][A-Z][A-Z][0-9][0-9][0-9][(]\)//g;s/)//g" for capturing
grep -oE "[L]*ADR[0-9]+[A-Z]{2}[0-9]{3}.*" < "in.txt" | sed "s/Absent/AB/g;s/Withheld/WI/g" >> "./in.csv"
# echo -e "FL=$FIRST_LINE :: LL=$LAST_LINE"
HDR_DATA=$(sed -n "${STREAM_LINES[0]},$((STREAM_LINES[1]-1))p" "./in.txt")
FILENAME=$(echo -e "$HDR_DATA" | grep "B.Tech" | sed "s/ /_/g")
echo -e "FILENAME: $FILENAME"
# echo -e "${STREAM_LINES[0]} - $((STREAM_LINES[1]-1)) :: HEADER"
echo -e "$HDR_DATA"
# echo -e "-- STREAMS --"
for ((i=0; i <= STREAM_COUNTER; i++)); do
    # echo -e "${STREAM_LINES[i+1]} - $((${STREAM_LINES[i+2]}-1))" "::" "${STREAMS[i]}"
    sed -n "${STREAM_LINES[i+1]},$((${STREAM_LINES[i+2]}-1))p" "./in.txt" | sed "s/Absent/AB/g;s/Withheld/WI/g" | while read -r row; do
        ktuid_tmp=$(echo -e "$row" | grep -oE "[L]*ADR[0-9]+[A-Z]{2}[0-9]{3}")
        branch_tmp=$(echo -e "$ktuid_tmp" | grep -oP "[L]*ADR[0-9]+\K([A-Z]{2})(?=[0-9]{3})")
        echo "${row/$ktuid_tmp/}" | sed "s/,/\n/g" | while read -r subrow; do
            grade_tmp=$(echo -e "$subrow" | grep -oP "[A-Z]{2}[A-Z]*[0-9]{3}[0-9]*[(]\K([SABCDEFOP]*[+]*|AB|WI)(?=[)])")
            if [[ $(( ${#subrow} )) -gt 0 && $(( ${#ktuid_tmp} )) -gt 9 ]]; then
                echo "$ktuid_tmp,${subrow/($grade_tmp)/},$grade_tmp,$branch_tmp"
            fi
        done
    done
done > "./${FILENAME}.csv"