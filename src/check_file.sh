#!/bin/bash

check_file() {
	text="CHECKING FILE"
	printf "${COLOR_TITLE}"
	printf "%.s${CHAR_LENGTH}" $(seq 1 ${TITLE_LENGTH})
	printf "\n${CHAR_WIDTH}\033[$(( (${TITLE_LENGTH} - ${#text}) / 2 ))G${text}\033[${TITLE_LENGTH}G${CHAR_WIDTH}\n"
	printf "%.s${CHAR_LENGTH}" $(seq 1 ${TITLE_LENGTH})
	printf "\n\n${DEFAULT}"

	sleep 2

	printf "SOURCE FILE"
	if [ -e "${PATH_SUBMIT}"/${SRC_FILE} ]; then
		printf "${COLOR_OK}\nfound${DEFAULT}\n\n"
		retvalue=1
	else
		printf "${COLOR_FAIL}\nnot found${DEFAULT}\n\n"
		retvalue=0
	fi
	return ${retvalue}
}