#!/bin/bash

# Peringatan :
# 				Jangan pernah menjalankan skrip ini jika tidak tahu apa yang skrip ini lakukan pada sistem anda.
# 				Kerusakan pada sistem yang disebabkan oleh skrip ini bukanlah tanggung jawab saya.

pwd_=$(dirname $0)
home_conf_file=(/etc/xdg/compton.conf $HOME/.fehbg $HOME/.xinitrc $HOME/.ncmpcpp/ $HOME/.config/i3/ $HOME/.config/polybar/ $HOME/.config/powerline/ $HOME/.config/rofi/ $HOME/.config/xfce4/)
#home_conf_file=(/etc/xdg/compton.conf $HOME/.gtkrc-2.0 $HOME/.fehbg $HOME/.xinitrc $HOME/.ncmpcpp/ $HOME/.config/gtk-3.0 $HOME/.config/gpicview/ $HOME/.config/i3/ $HOME/.config/polybar/ $HOME/.config/powerline/ $HOME/.config/rofi/ $HOME/.config/xfce4/)
runtime_dependencies=(sudo sed grep)

ifFail() {
	if [ $1 -gt 0 ]
	then
		echo "$2"
		exit $1
	fi
}

dependenciesCheck() {
	echo "checking dependencies...."

	for i in ${runtime_dependencies[*]}
	do
		echo -n "  [*] $i .... "
		which $i &> /dev/null

		if [ $? -gt 0 ]
		then
			echo "is not installed ...."
			exit 1
		else
			echo "is ok ...."
		fi
	done

	echo "checking dependencies.... done..."
	echo
}

getConf() {
	local var=$1
	local file=(${home_conf_file[*]})
	local temp_var=""

	for i in ${home_conf_file[*]}
	do
		if [ $(echo $i | grep -c $HOME) -gt 0 ]
		then
			temp_var=$(echo $i | sed -e "s#$HOME#$pwd_/$var/home/user#g")

			if [ -d $temp_var ]
			then
				rm -rv $temp_var

				ifFail $? "Error : failed to remove $temp_var" 
			fi

			cp -rv $i $temp_var

			ifFail $? "Error : copy file"
		else
			cp -rv $i $pwd_/$var$i

			ifFail $? "Error : copy file"
		fi
	done
	
}

setConf() {
	local file_dest=""
	local file_src=()
	local var=$1
	local temp_var=""
	local counter=0

	file_dest=(${home_conf_file[*]})

	while [ $counter -lt ${#file_dest[*]} ]
	do
		if [ $(echo ${file_dest[$counter]} | grep -c $HOME) -gt 0 ]
		then
			file_src[$counter]=$(echo ${file_dest[$counter]} | sed -e "s#$HOME#$pwd_/$var/home/user#g")
		else
			file_src[$counter]=$pwd_/$var${file_dest[$counter]}
		fi

		((counter++))
	done

	counter=0
	while [ $counter -lt ${#file_src[*]} ]
	do
		if [ -w ${file_dest[$counter]} ]
		then
			if [ -d ${file_src[$counter]} ]
			then
				cp -rv ${file_src[$counter]}* ${file_dest[$counter]}

				ifFail $? "Error : copy file"
			else
				cp -rv ${file_src[$counter]} ${file_dest[$counter]}

				ifFail $? "Error : copy file"
			fi
		else
			sudo cp -rv ${file_src[$counter]} ${file_dest[$counter]}
			
			ifFail $? "Error : copy file"
		fi
		
		((counter++))
	done


}

helpMe() {
	echo "usage :"
	echo -e "\t$0 [opt]"
	echo
	echo "opt :"
	echo -e "\tset\t: Set conf file"
	echo -e "\tget\t: Get conf file"
}

awww() {
	echo "\"$0 help\" for help"
}

fire() {
	local arg=""

	case $2 in
		light | dark) arg=$2
			;;
		"") echo "argument 2 is empty"
			awww
			exit 2
			;;
		*) echo "unknown argument 2 \"$2\""
			awww
			exit 3
			;;
	esac

	dependenciesCheck
	$1 $arg
}

case $1 in
	set) fire "setConf" $2
		;;
	get) fire "getConf" $2
		;;
	help) helpMe
		;;
	*) awww
		;;
esac