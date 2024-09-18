#!/bin/bash

source "${PATH_TEST}"/src/testcase.sh

diff_test() {
	text="\n= TEST CASE $1 "
	printf "${text}" >> "${PATH_DEEPTHOUGHT}"/deepthought
	printf "%.s=" $(seq 1 $(( 60 - ${#text} ))) >> "${PATH_DEEPTHOUGHT}"/deepthought
	printf "\n" >> "${PATH_DEEPTHOUGHT}"/deepthought
	if [ $1 -lt 10 ]; then
		text="0"
	else
		text=""
	fi
	printf "$> ./user_exe < $2\n" >> "${PATH_DEEPTHOUGHT}"/deepthought

	if command -v setarch &> /dev/null; then
		setarch $(uname -m) --addr-no-randomize "${PATH_TEST}"/user_exe < "$2" > /dev/null 2> "${PATH_TEST}"/output/${PROJECT}/user_output_test${text}$1
	else
		"${PATH_TEST}"/user_exe < "$2" > "${PATH_TEST}"/output/${PROJECT}/user_output_test${text}$1 2>&1
	fi

	SIG=$?
	if [ $SIG -eq 134 ]; then
		printf "Command './user_exe tc${text}$1' got killed by an Abort\n" >> "${PATH_DEEPTHOUGHT}"/deepthought
		printf "\033[$((RESULT_COL + 5))G${COLOR_FAIL}A${DEFAULT}\n"
		retvalue=1
	elif [ $SIG -eq 138 ]; then
		printf "Command './user_exe tc${text}$1' got killed by a Bus error\n" >> "${PATH_DEEPTHOUGHT}"/deepthought
		printf "\033[$((RESULT_COL + 5))G${COLOR_FAIL}B${DEFAULT}\n"
		retvalue=1
	elif [ $SIG -eq 139 ]; then
		printf "Command './user_exe tc${text}$1' got killed by a Segmentation fault\n" >> "${PATH_DEEPTHOUGHT}"/deepthought
		printf "\033[$((RESULT_COL + 5))G${COLOR_FAIL}S${DEFAULT}\n"
		retvalue=1
	elif [ $SIG -eq 142 ]; then
		printf "Command './user_exe tc${text}$1' got killed by a Timeout\n" >> "${PATH_DEEPTHOUGHT}"/deepthought
		printf "\033[$((RESULT_COL + 5))G${COLOR_FAIL}T${DEFAULT}\n"
		retvalue=1
	else
		"${PATH_TEST}"/test/test_exe < "$2" > "${PATH_TEST}"/output/${PROJECT}/output_test${text}$1 2>&1
		DIFF=$(diff -u "${PATH_TEST}"/output/${PROJECT}/user_output_test${text}$1 "${PATH_TEST}"/output/${PROJECT}/output_test${text}$1)
		printf "$> diff -u user_output_test${text}$1 output_test${text}$1\n" >> "${PATH_DEEPTHOUGHT}"/deepthought
		if [ "$DIFF" != "" ] || [ ! -e "${PATH_TEST}"/output/${PROJECT}/user_output_test${text}$1 ]; then
			echo "${DIFF}" | cat -e >> "${PATH_DEEPTHOUGHT}"/deepthought
			printf "\nDiff KO :(\n" >> "${PATH_DEEPTHOUGHT}"/deepthought
			printf "\033[$((RESULT_COL + 2))G${COLOR_FAIL}[KO]${DEFAULT}\n"
			retvalue=1
		else
			printf "\nDiff OK :D\n" >> "${PATH_DEEPTHOUGHT}"/deepthought
			printf "\033[$((RESULT_COL + 2))G${COLOR_OK}[OK]${DEFAULT}\n"
			retvalue=0
		fi
	fi

	return $retvalue
}

test_simple() {
	printf "${COLOR_PART}${UNDERLINE}TEST SIMPLE CASES\n\n${DEFAULT}"
	printf "${COLOR_TITLE}${UNDERLINE}TEST CASE\033[${RESULT_COL}GRESULT\n${DEFAULT}"

	let "i=0"
	let "success=0"
	simple_cases=()
	while IFS= read -r file; do
		simple_cases+=("$file")
	done < <(find "${PATH_TEST}/testcase" -type f -name 'simple*' | sort)
	total=${#simple_cases[@]}
	retvalue=0
	while [ $i -lt $total ]; do
		if [ $i -lt 10 ]; then
			text="0"
		else
			text=""
		fi
		printf "${COLOR_TESTCASE}#${text}$i"
		diff_test $i "${simple_cases[$i]}"
		if [ $? -eq 0 ]; then
			let "success += 1"
		fi
		let "i += 1"
		sleep 0.5
	done

	if [ $total -lt 10 ]; then
		total="0${total}"
	fi
	if [ $success -lt 10 ]; then
		success="0${success}"
	fi

	printf "\n${COLOR_TOTAL}Total: ${success}/${total}${DEFAULT}\n\n"

	if [ $success -eq $total ]; then
		retvalue=0
	else
		retvalue=1
	fi

	return $retvalue
}

test_random() {
	printf "${COLOR_PART}${UNDERLINE}TEST RANDOM CASES\n\n${DEFAULT}"

	printf "${COLOR_TITLE}Generate test cases... "
	generate_testcases 25
	printf "done\n\n${DEFAULT}"

	printf "${COLOR_TITLE}${UNDERLINE}TEST CASE\033[${RESULT_COL}GRESULT\n${DEFAULT}"

	let "i=0"
	let "success=0"
	random_cases=()
	while IFS= read -r file; do
		random_cases+=("$file")
	done < <(find "${PATH_TEST}/testcase" -type f -name 'random*' | sort)
	total=${#random_cases[@]}
	retvalue=0
	while [ $i -lt $total ]; do
		if [ $i -lt 10 ]; then
			text="0"
		else
			text=""
		fi
		printf "${COLOR_TESTCASE}#${text}$i"
		diff_test $i "${random_cases[$i]}"
		if [ $? -eq 0 ]; then
			let "success += 1"
		fi
		let "i += 1"
		sleep 0.5
	done

	remove_testcases

	if [ $total -lt 10 ]; then
		total="0${total}"
	fi
	if [ $success -lt 10 ]; then
		success="0${success}"
	fi

	printf "\n${COLOR_TOTAL}Total: ${success}/${total}${DEFAULT}\n\n"

	if [ $success -eq $total ]; then
		retvalue=0
	else
		retvalue=1
	fi

	return $retvalue
}

test_user_defined() {
	user_defined_cases=()
	while IFS= read -r file; do
		user_defined_cases+=("$file")
	done < <(find "${PATH_TEST}/testcase" -type f -not -name 'simple*' -not -name 'random*' -not -name '*output*' -not -name '.DS_Store' -not name 'README.md' | sort)
	total=${#user_defined_cases[@]}
	retvalue=0
	if [ $total -eq 0 ]; then
		return $retvalue
	fi

	printf "${COLOR_TITLE}${UNDERLINE}TEST CASE"
	printf "\033[${RESULT_COL}GRESULT\n${DEFAULT}"

	while [ $i -lt $total ]; do
		if [ $i -lt 10 ]; then
			text="0"
		else
			text=""
		fi
		printf "${COLOR_TESTCASE}#${text}$i"
		diff_test $i "${user_defined_cases[$i]}"
		if [ $? -eq 0 ]; then
			let "success += 1"
		fi
		let "i += 1"
		sleep 0.5
	done

	if [ $total -lt 10 ]; then
		total="0${total}"
	fi
	if [ $success -lt 10 ]; then
		success="0${success}"
	fi

	printf "\n${COLOR_TOTAL}Total: ${success}/${total}${DEFAULT}\n\n"

	if [ $success -eq $total ]; then
		retvalue=0
	else
		retvalue=1
	fi

	return $retvalue
}

test_function() {
	text="STARTING TESTS"
	printf "${COLOR_TITLE}"
	printf "%.s${CHAR_LENGTH}" $(seq 1 ${TITLE_LENGTH})
	printf "\n${CHAR_WIDTH}\033[$(( (${TITLE_LENGTH} - ${#text}) / 2 ))G${text}\033[${TITLE_LENGTH}G${CHAR_WIDTH}\n"
	printf "%.s${CHAR_LENGTH}" $(seq 1 ${TITLE_LENGTH})
	printf "\n\n${DEFAULT}"

	mkdir -p "${PATH_TEST}"/output/${PROJECT}

	let "failed=0"
	test_functions=("test_simple" "test_random" "test_user_defined")
	for test_function in "${test_functions[@]}"; do
		sleep 2
		$test_function
		if [ $? -eq 1 ]; then
			let "failed += 1"
		fi
	done

	if [ $failed -eq 0 ]; then
		retvalue=0
	else
		retvalue=1
	fi
	
	return $retvalue
}