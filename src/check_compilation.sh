#!/bin/bash

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
		retvalue=0
		return $retvalue
	fi

	printf "\n$> ${COMPILER} -Wall -Wextra -Werror -g3 -fsanitize=address ${PATH_TEST}/${PATH_SUBMIT}/${SRC_FILE} -o user_exe\n" >> "${PATH_DEEPTHOUGHT}"/deepthought

	${COMPILER} -g3 -fsanitize=address "${PATH_TEST}"/${PATH_SUBMIT}/${SRC_FILE} -o user_exe 2>> "${PATH_DEEPTHOUGHT}"/deepthought
	if [ -e "${PATH_TEST}/user_exe" ]; then
		RESULT=1
		rm -f ${PATH_TEST}/user_exe
	else
		RESULT=0
		retvalue=0
	fi

	${COMPILER} -Wall -g3 -fsanitize=address "${PATH_TEST}"/${PATH_SUBMIT}/${SRC_FILE} -o user_exe 2>> "${PATH_DEEPTHOUGHT}"/deepthought
	if [ -e "${PATH_TEST}/user_exe" ]; then
		WALL=1
		rm -f ${PATH_TEST}/user_exe
	else
		WALL=0
	fi

	${COMPILER} -Wextra -g3 -fsanitize=address "${PATH_TEST}"/${PATH_SUBMIT}/${SRC_FILE} -o user_exe 2>> "${PATH_DEEPTHOUGHT}"/deepthought
	if [ -e "${PATH_TEST}/user_exe" ]; then
		WEXTRA=1
		rm -f ${PATH_TEST}/user_exe
	else
		WEXTRA=0
	fi

	${COMPILER} -Werror -g3 "${PATH_TEST}"/${PATH_SUBMIT}/${SRC_FILE} -o user_exe 2>> "${PATH_DEEPTHOUGHT}"/deepthought
	if [ -e "${PATH_TEST}/user_exe" ]; then
		WERROR=1
		rm -f ${PATH_TEST}/user_exe
	else
		WERROR=0
	fi

	${COMPILER} -g3 "${PATH_TEST}"/${PATH_SUBMIT}/${SRC_FILE} -o user_exe 2>> "${PATH_DEEPTHOUGHT}"/deepthought
	
	printf "COMPILER\033[16GRESULT\033[32G-Wall\033[48G-Wextra\033[64G-Werror\n"
	printf "${COLOR_OK}${COMPILER}${DEFAULT}"
	if [ $RESULT -eq 1 ]; then
		printf "\033[16G${COLOR_OK}success${DEFAULT}"
	else
		printf "\033[16G${COLOR_FAIL}failure${DEFAULT}"
	fi
	if [ $WALL -eq 1 ]; then
		printf "\033[32G${COLOR_OK}success${DEFAULT}"
	else
		printf "\033[32G${COLOR_FAIL}failure${DEFAULT}"
	fi
	if [ $WEXTRA -eq 1 ]; then
		printf "\033[48G${COLOR_OK}success${DEFAULT}"
	else
		printf "\033[48G${COLOR_FAIL}failure${DEFAULT}"
	fi
	if [ $WERROR -eq 1 ]; then
		printf "\033[64G${COLOR_OK}success${DEFAULT}"
	else
		printf "\033[64G${COLOR_FAIL}failure${DEFAULT}"
	fi

	printf "\n\n"

	make -s -C "${PATH_TEST}"/test ${PROJECT}

	return $retvalue
}