#!/bin/bash

compile() {
	retvalue=0

	${COMPILER} $1 "${PATH_TEST}"/${PATH_SUBMIT}/${SRC_FILE} -o user_exe 2>> "${PATH_DEEPTHOUGHT}"/deepthought
	if [ ! -e "${PATH_TEST}/user_exe" ]; then
		retvalue=1
	fi

	return $retvalue
}

print_compilation_result() {
	if [ $1 -eq 0 ]; then
		printf "\033[$2G${COLOR_OK}success${DEFAULT}"
	else
		printf "\033[$2G${COLOR_FAIL}failure${DEFAULT}"
	fi
}

check_compilation() {
	text="COMPILING"
	printf "${COLOR_TITLE}"
	printf "%.s${CHAR_LENGTH}" $(seq 1 ${TITLE_LENGTH})
	printf "\n${CHAR_WIDTH}\033[$(( (${TITLE_LENGTH} - ${#text}) / 2 ))G${text}\033[${TITLE_LENGTH}G${CHAR_WIDTH}\n"
	printf "%.s${CHAR_LENGTH}" $(seq 1 ${TITLE_LENGTH})
	printf "\n\n${DEFAULT}"

	sleep 2

	if [ -e ${PATH_TEST}/user_exe ]; then
		rm -f ${PATH_TEST}/user_exe
	fi

	text="= Compiling "
	printf "\n${text}" >> "${PATH_DEEPTHOUGHT}"/deepthought
	printf "%.s=" $(seq 1 $(( 80 - ${#text} ))) >> "${PATH_DEEPTHOUGHT}"/deepthought

	if [ "${SRC_FILE}" == "missing_source_file" ]; then
		text="Missing source file, can't compile."
		printf "\033[$(( (${TITLE_LENGTH} - ${#text}) / 2 ))G${COLOR_FAIL}${text}${DEFAULT}\n\n"
		printf "\n${text}\n" >> "${PATH_DEEPTHOUGHT}"/deepthought
		return 1
	fi

	printf "\n$> ${COMPILER} -Wall -Wextra -Werror -g3 -fsanitize=address ${PATH_TEST}/${PATH_SUBMIT}/${SRC_FILE} -o user_exe\n" >> "${PATH_DEEPTHOUGHT}"/deepthought

	compile "-Wall -g3 -fsanitize=address"
	WALL=$?
	compile "-Wextra -g3 -fsanitize=address"
	WEXTRA=$?
	compile "-Werror -g3 -fsanitize=address"
	WERROR=$?
	compile "-g3"
	retvalue=$?
	
	printf "COMPILER\033[16GRESULT\033[32G-Wall\033[48G-Wextra\033[64G-Werror\n"
	printf "${COLOR_OK}${COMPILER}${DEFAULT}"
	print_compilation_result $retvalue 16
	print_compilation_result $WALL 32
	print_compilation_result $WEXTRA 48
	print_compilation_result $WERROR 64

	printf "\n\n"

	make -s -C "${PATH_TEST}"/test ${PROJECT}

	return $retvalue
}