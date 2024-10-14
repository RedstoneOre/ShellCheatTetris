#! /bin/bash

# This is a header for reading input
# You can use it in your object but
#	The maker won't take responsibility for BUGs.
# To Use This,please set tty -echo before

# Get Curser Pos
function Read_GetPos {
	[ "$Read_DoOpNinp" == 1 ] &&
	while read -t 0.01 -N 1 Read_OpNinp;do 
		[ "$Read_OpNinp" == '' ] || {
			# echo -n '[get'"$Read_OpNinp"']'
			Read_OpGot[${#Read_OpGot[@]}]="$Read_OpNinp"
			false
		} &&
			break
	done
	echo -n '[6n'
	read -d ''
	read -d 'R' Read_GetPos
	Read_Pos=''"$Read_GetPos"'H'
}

#Insert
function Read_Ins {
	Read_InsPos="$[Read_InsPos+1]"
	Read_Line[Read_InsPos]="$1"
	case "$1" in
		'') Read_Print='[\e]' ;;
		'') Read_Print='[C-s]' ;;
		'') Read_Print='[C-q]' ;;
		'') Read_Print='[C-c]' ;;
		'') Read_Print='[C-v]' ;;
		'') Read_Print='[C-x]' ;;
		'') Read_Print='[C-z]' ;;
		'') Read_Print='[C-a]' ;;
		'') Read_Print='[\b]' ;;
		'') Read_Print='[C-w]' ;;
		'') Read_Print='[C-o]' ;;
		'	') Read_Print='{[D	}' ;;
		'
') Read_Print='[Enter]' ;;
		[0-9a-zA-Z~!@#$%^\&*\(\)_+\`\-=\[\]\\{}\|\;\':\",./\<\>\?\ ]) Read_Print="$1" ;;
		*) Read_Print="[$(echo -n "$1" | od -A n -t x1)]"
	esac
	[ "${#Read_Print}" -gt 1 ] && echo -n '[31m'
	echo -n "$Read_Print"
	[ "${#Read_Print}" -gt 1 ] && echo -n '[0m'
	echo -n '[K'
	Read_GetPos
	Read_PrSize[Read_InsPos+1]="$Read_Pos"
}
#Remove
function Read_Remove {
	[ "$Read_InsPos" -ge 0 ] && {
		echo -n "${Read_PrSize[Read_InsPos]}"'[K'
		[ "$Read_InsPos" -gt 0 ] && Read_InsPos="$[Read_InsPos-1]"
	}
}
#Connect
function Read_Connect {
	sz=-100
	for Read_Connecti;do
		[ "$sz" -le -100 ] && {
			sz="$Read_Connecti"
			continue
		}
		echo -n "$Read_Connecti"
		sz="$[sz-1]"
		[ "$sz" -le 0 ] && break
	done
}

#Read Autocomplete
# Read Files
function Read_File {
	Read_Fileg=( "$1"* )
	Read_AcReq=()
	Read_FileSz="${#1}"
	for Read_Filei in "${Read_Fileg[@]}";do
		Read_AcReq[${#Read_AcReq[@]}]="${Read_Filei:$Read_FileSz}"
	done
	Read_AcReq[${#Read_AcReq[@]}]=''
}
#None
function Read_None {
	return
}
function Read_Autocomplete {
	Read_GetPos
	Read_ComPos="$Read_Pos"
	"$1" "$2"
	while true;do
		Read_requireKey=''
		for Read_Comi in "${Read_AcReq[@]}";do
			[ "$Read_requireKey" != '' ] && {
			       	[ "${Read_Comi:0:1}" == "$Read_requireKey" ] ||
					continue
			}
			echo -n '[33m'"$Read_Comi"' [AutoComplete][0m[K'"$Read_Pos"
			read -N 1 Read_ComOp
			case "$Read_ComOp" in
				'	') continue ;;
				'') read -t 0.01 -N 1 || {
						echo -n '[K'
						Read_ComRes=''
						return
					};break ;;
				'
')
					Read_ComRes="$Read_Comi"
					return ;;
				*) Read_requireKey="$Read_ComOp" ;;
			esac
		done
	done
}

#Read Main
function Read_Read {
	Read_InsMode=0
	Read_GetPos
	Read_Line=() Read_PrSize=( "$Read_Pos" ) Read_InsPos=0
	Read_OpGot=() Read_OpCur=0
	while true;do
		[ "${#Read_OpGot[@]}" -gt "$Read_OpCur" ] && {
			Read_DoOpNinp=0
			# echo -n '[33m[MemOpGet'"${#Read_OpGot[@]} $Read_OpCur $Read_Op"'][0m'
			Read_Op="${Read_OpGot[Read_OpCur]}"
			Read_OpCur="$[Read_OpCur+1]"
			[ "${#Read_OpGot[@]}" -le "$Read_OpCur" ] && {
				Read_OpGot=() Read_OpCur=0
			}
			true
		} || {
			Read_DoOpNinp=1
			read -N 1 Read_Op
		}
		[ "$Read_InsMode" == 1 ] && {
			Read_Ins "$Read_Op"
			while true;do
				Read_Op=''
				read -N 1 -t 0.01 Read_Op
				[ "${#Read_Op}" -gt 0 ] || break
				Read_Ins "$Read_Op"
			done
			Read_InsMode=0
		} || {
			case "$Read_Op" in
				[0-9a-zA-Z~!@#$%^\&*\(\)_+\`\-=\[\]\\{}\|\;\':\",./\<\>\?\ ]) Read_Ins "$Read_Op" ;;
				'') read -N 3 -t 0.01 Read_Op
					if [ "$Read_Op" == '[2~' ];then
						Read_InsMode=1
					else
						Read_Ins ''
					fi;;
				'') Read_Remove;;
				'	') Read_Autocomplete "$1" "$(Read_Connect "$Read_InsPos" "${Read_Line[@]}")"
					Read_DoOpNinp=0
					Read_ComSz="${#Read_ComRes}"
					for((Read_ComGeti=0;Read_ComGeti<Read_ComSz;++Read_ComGeti));do
						Read_Ins "${Read_ComRes:$Read_ComGeti:1}"
					done ;;
				'
') Read_Result="$(Read_Connect "$Read_InsPos" "${Read_Line[@]}")";break ;;
			esac
		}
	done
}
false && {
	trap '' SIGINT
	stty -echo
	Read_Read Read_File
	e="$Read_Result"
	echo -n "  Res:$e"
	stty echo
}
