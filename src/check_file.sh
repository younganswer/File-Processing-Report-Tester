#!/bin/bash

check_file() {
	text="CHECKING FILE"
	printf "${COLOR_TITLE}"
	printf "%.s${CHAR_LENGTH}" $(seq 1 ${TITLE_LENGTH})
	printf "\n${CHAR_WIDTH}\033[$(( (${TITLE_LENGTH} - ${#text}) / 2 ))G${text}\033[${TITLE_LENGTH}G${CHAR_WIDTH}\n"
	printf "%.s${CHAR_LENGTH}" $(seq 1 ${TITLE_LENGTH})
	printf "\n\n${DEFAULT}"

	sleep 2

	if [ -e "${PATH_SUBMIT}/main.c" ]; then
		SRC_FILE="main.c"
		COMPILER="clang"
	elif [ -e "${PATH_SUBMIT}/main.cpp" ]; then
		SRC_FILE="main.cpp"
		COMPILER="clang++"
	else
		SRC_FILE="missing_source_file"
		COMPILER="missing_compiler"
	fi

	printf "SOURCE FILE"
	if [ -e "${PATH_SUBMIT}"/${SRC_FILE} ]; then
		printf "${COLOR_OK}\nfound${DEFAULT}\n\n"
		retvalue=1
	else
		printf "${COLOR_FAIL}\nnot found${DEFAULT}\n\n"
		printf "${COLOR_FAIL}Please provide a source file to test or check the path in ${UNDERLINE}my_config.sh${DEFAULT}\n"
		printf "${COLOR_FAIL}Test exited.${DEFAULT}\n"
		exit
	fi
}