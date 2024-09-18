#!/bin/bash

PATH_TEST="$(cd "$(dirname "$0")" && pwd -P)"

exec 2> /dev/null

source "${PATH_TEST}"/src/check_compilation.sh
source "${PATH_TEST}"/src/check_file.sh
source "${PATH_TEST}"/src/color.sh
source "${PATH_TEST}"/src/init_deepthought.sh
source "${PATH_TEST}"/src/select_project.sh
source "${PATH_TEST}"/src/test.sh
source "${PATH_TEST}"/src/variable.sh

cd "${PATH_TEST}"

if [ ! -e "${PATH_TEST}"/my_config.sh ]; then
	printf "${BOLD}my_config.sh${DEFAULT} file is not found\n"
	printf "Creating file...\n"
	if [ -e "${PATH_TEST}"/src/config_template.sh ]; then
		cp "${PATH_TEST}"/src/config_template.sh "${PATH_TEST}"/my_config.sh
		printf "File created with success in ${BOLD}${PURPLE}${PATH_TEST}\n${DEFAULT}"
		printf "${RED}${UNDERLINE}Edit my_config.sh file${DEFAULT} with the path of your project and launch script.\n"
	else
		printf "Can't create my_config.sh file, try to update or clone again the repository and retry.\n"
		exit
	fi
	exit
fi

source "${PATH_TEST}"/my_config.sh

clear

init_deepthought

select_project

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

check_file
if [ $retvalue -eq 0 ]; then
	printf "${COLOR_FAIL}Please provide a source file to test or check the path in ${UNDERLINE}my_config.sh${DEFAULT}\n"
	printf "${COLOR_FAIL}Test exited.${DEFAULT}\n"
	exit
fi

sleep 2

check_compilation
if [ $retvalue -eq 0 ]; then
	printf "${COLOR_FAIL}Test exited.${DEFAULT}\n\n"
	printf "A deepthought file has been created in ${UNDERLINE}${COLOR_DEEPTHOUGHT_PATH}\"${PATH_DEEPTHOUGHT}\"\n${DEFAULT}"
	exit
fi

sleep 2

test_function

if [ $retvalue -eq 1 ]; then
	printf "Fail: ${RED}[KO]${DEFAULT}  Abort: ${RED}A${DEFAULT}  Bus error: ${RED}B${DEFAULT}  Segmentation fault: ${RED}S${DEFAULT}  Timeout: ${RED}T${DEFAULT}\n\n"
fi

if [ -e "${PATH_TEST}/test/test_exe" ]; then
	make -C "${PATH_TEST}"/test fclean
fi

if [ -e "${PATH_TEST}/user_exe" ]; then
	rm -rf "${PATH_TEST}"/user_exe*
fi

rm -rf "${PATH_TEST}/output"

sleep 3

printf "A deepthought file has been created in ${UNDERLINE}${COLOR_DEEPTHOUGHT_PATH}\"${PATH_DEEPTHOUGHT}\"\n${DEFAULT}"
