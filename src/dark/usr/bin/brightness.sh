#!/bin/bash

# Pastikan modul i2c-dev sudah di load
# Pastikan sudah melakukan check dan mendapatkan nilai kembalian 1

termIfNotRoot() {
	if [ ! $EUID -eq 0 ]
	then
		echo "Please use sudo or root account!"
		exit 1;
	fi
}

get() {
	termIfNotRoot
	
	ddcutil getvcp 10 | awk '{ print $9 }' | sed 's/,//g'
}

set() {
	termIfNotRoot
	
	if [ ! -z $1 ]
	then
		ddcutil setvcp 10 $1
	else
		echo "Do nothing."
	fi
}

increase() {
	termIfNotRoot

	ddcutil setvcp 10 + 5
}

decrease() {
	termIfNotRoot

	ddcutil setvcp 10 - 5
}

check() {
	termIfNotRoot
	
	ddcutil capabilities | grep -c "Feature: 10"
}

helpMe() {
	echo "usage:"
	echo -e "\t$(basename $0) [option] [value]"
	echo "option:"
	echo -e "\tget\t\t: Get current brightness level"
	echo -e "\tset\t\t: Set brightness level"
	echo -e "\tincrease\t: Increase brightness level"
	echo -e "\tdecrease\t: Decrease brightness level"
	echo -e "\tcheck\t\t: Check capabilities"
}

case $1 in
	"set" ) $1 $2
		;;
	"get" | "increase" | "decrease" | "check" ) $1
		;;
	"help" | "--help" | "-h" ) helpMe
		;;
	* ) echo -e "Use \"help\" for help"
		;;
esac
