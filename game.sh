#! /bin/bash

#Exiting
function Exit {
	GameRetVal="${1:-0}"
	true
}
#Get Path
GameDir="$(realpath "$0")"
GameDir="${GameDir%\/*}"
[ "$GameDir" == '' ] && Exit 13 || {

#Init Cheating
CheatBreakTime=0 CheatSendBackTime=0
CheatBreak=0     CheatSendBack=0

#Including
. "$GameDir"'/config.sh' "$GameDir"'/config' # Config
. "$GameDir"'/read.sh' # Reading and Autocomplete
. "$GameDir"'/read_saveformat.sh' # Saving and Reading save

ver='CHEAT-TETRIS beta-1.0 N.7'
[ "$1" == -c ] && [ "$TipFile" != '' ] && {
	GameTipTxt="$(<"$GameDir"'/'"$TipFile")"
	echo "${GameTipTxt//###/$ver}"
}
Read_Saveformat_Init "$ExecuteAblePath"
Read_Saveformat_Read "$GameDir"'/saveformat.dat'

#Connect strings
function connect {
	for ctI;do
		echo -n "$ctI"
	done
}

#Echo Without Options
function OEcho {
	echo -n "$*"'
'
}
#Clear
function rs {
	clear
	echo -n $'\e''c[0;0H'
}
#Get Timestamp
function ts {
	date +%s
}

#Update Sleep Time
function resSleep {
	sleepLastTime="$(date +%s%N)"
}

#Show Tip
function tip {
	[ "$PrintFlag" != 1 ] && echo -n $'\e''[0m['"$[y+2]"';2H'
	echo -n "$1"
	PrintFlag=1
}

#Render border
function rb {
	rs
	RenderWide="$[x*2]"
	BorderChar="${blockChars[3]}"
	for((i=1;i<=y;++i));do
		echo "$BorderChar"$'\e''['"$RenderWide"'C'"$BorderChar"
	done
	for((i=1;i<=x;++i));do
		echo -n "$BorderChar"' '
	done
	echo -n "$BorderChar$BorderChar"
}
#Render Next Tip
function rnxt {
	echo -n $'\e''[7;'"$[2*x+4]"'HNext: [6n'
	read -r -d '[' tmp
	read -r -d ';' nxtShowPos[0]
	read -r -d 'R' nxtShowPos[1]
	nxtShowPos[1]="$[nxtShowPos[1]/2]"
}

#Reading
function GetOp {
	read -r -N 1 Op
}
function ReadLine {
	while true;do
		read 
	done
}

#Score
sc=0 tm="$(ts)"
function scinit {
	echo -n $'\e''[3;'"$[2*x+4]"'HScore: [6n'
	read -r -d 'R' scShowPos
	scShowPos="${scShowPos}H"
}
function scupd {
	sc="$1"
	echo -n $'\e''[0m'"$scShowPos$sc"
}

#During
# Cheat
function CheatCheck {
	[ "$[$1+$2]" -le "$NowBlockCnt" ]
	return "$?"
}
function CheatCD {
	echo -n "$[$1+$2-NowBlockCnt]"
}
function CheatPrint {
	tip "$1"': CD '"$(CheatCD "$2" "$3")"' blocks'
	resSleep
}


# Block
function blockInGround {
	igrBlockShapes=(${shapes[$1]})
	igrBlockShape=(${igrBlockShapes[$3]//,/ })
	for((bci=${#igrBlockShape[@]}-1;bci>=1;--bci));do
		tmp="${igrBlockShape[$bci]}"
		tmp2="${map[$bci+$4-1]}"
		for((bcj=0;bcj<${#tmp};++bcj));do
			{ { [ "$CheatBreak" != 1 ] && [ "${tmp:$bcj:1}" == 1 ] && [ "${tmp2:$[bcj+$5-1]:1}" != 0 ]; } ||
			 [ "$[bci+$4-1]" -gt "$y" ]; } &&
				return 0
		done
	done
	return 1
}
function blockUpdate {
	updBlockColor=$'\e''['"${colors[$2]}"';'"$[$2?30:0]"'m'
	updBlockChar="${blockChars[$2?1:0]}"
	updBlockShapes=(${shapes[$1]})
	updBlockShape=(${updBlockShapes[$3]//,/ })
	updBlockOffset="${updBlockShape[0]}"
	updBlockTpColumn="$[$5+updBlockOffset]"
	updBlockStuckTag=0
	{ [ "$updBlockTpColumn" -gt "$[x-${#updBlockShape[1]}+updBlockOffset+1]" ] ||
	  [ "$updBlockTpColumn" -lt 1 ] ||
	  blockInGround "$@"; } && {
		updBlockStuckTag=1
		[ "$6" != 1 ] && return 1
	}
	echo -n "$updBlockColor"$'\e''['"$4;$[updBlockTpColumn*2]"'H'
	for((bri=1;bri<${#updBlockShape[@]};++bri));do
		tmp="${updBlockShape[bri]}"
		for((brj=updBlockOffset;brj<${#tmp};++brj));do
			if [ "${tmp:$brj:1}" == 1 ];then
				echo -n "$updBlockChar"' '
			else
				echo -n $'\e''[2C'
			fi
		done
		echo -n $'\e''['"$[(${#tmp}-updBlockOffset)*2]"'D[B'
	done
	echo -n $'\e''[0m['"${#updBlockShape[@]}"'A'
	[ "$updBlockOffset" -gt 0 ] && echo -n $'\e''['"$updBlockOffset"'D'
	return "$updBlockStuckTag"
}
# Map
function ClearMap {
	tmp=()
	for((cmi=0;cmi<x;++cmi));do
		tmp[cmi]="${blockChars[0]}"' '
	done
	tmp="$(connect "${tmp[@]}")"
	for((cmi=1;cmi<=y;++cmi));do
		echo -n $'\e''['"$cmi"';2H'"$tmp"
	done
}
function PrintMap {
	for((pmi=$2;pmi<=$3;++pmi));do
		echo -n $'\e''['"$pmi"';2H'
		tmp="${map[$pmi]}"
		for((pmj=0;pmj<x;++pmj));do
			printColor="${tmp:$pmj:1}"
			if [ "$printColor" == 0 ];then
				echo -n $'\e''[2C'
			else
				printColor="$[printColor*$1]"
				printChar="${blockChars[2]}"
				[ "$printColor" == 0 ] && printChar="${blockChars[0]}"
				echo -n $'\e''['"${colors[printColor]}"';'"$[$printColor?30:0]"'m'"$printChar"' '
			fi
		done
	done
}
function ClearLine {
	PrintMap 0 0 "$1"
	for((cli=$1;cli>0;--cli));do
		map[cli]="${map[cli-1]}"
	done
	map[0]="$mapEmptyLine"
	PrintMap 1 0 "$1"
}
function JoinMap {
	joinBlockShapes=(${shapes[$1]})
	joinBlockShape=(${joinBlockShapes[$3]//,/ })
	JoinColor="$[$2*(1-CheatBreak)]"
	for((jmi=${#joinBlockShape[@]}-1;jmi>=1;--jmi));do
		tmp="${joinBlockShape[jmi]}"
		jmidx="$[jmi+$4-1]"
		tmp2="${map[jmidx]}"
		tmp2s="${#tmp2}"
		tmp3=()
		for((jmj=0;jmj<tmp2s;++jmj));do
			tmp3[jmj]="${tmp2:$jmj:1}"
		done
		for((jmj=0;jmj<${#tmp};++jmj));do
			[ "${tmp:$jmj:1}" == 1 ] && {
				p="$[jmj+$5-1]"
				tmp3[p]="$JoinColor"
			}
		done
		map[jmidx]="$(connect "${tmp3[@]}")"
	done
	PrintMap 1 "$4" "$[${#joinBlockShape[@]}+$4-2]"
	for((jmi=${#joinBlockShape[@]}-1;jmi>=1;--jmi));do
		jmidx="$[jmi+$4-1]"
		[ "$(expr index "${map[$jmidx]}" 0)" == 0 ] && {
			ClearLine "$jmidx"
			scupd "$[sc+x]"
			jmi="$[jmi+1]"
		}
	done
}
# New
function NewBlock {
	[ "$1" != 0 ] && {
		nowBlock=("${nextBlock[@]}")
		nowPos=("${nextPos[@]}")
		NowBlockCnt="$[NowBlockCnt+1]"
		nextBlock=("$[RANDOM%(${#shapes[@]}-1)+1]"
		 "$[(RANDOM%(${#colors[@]}-1)+1)]" 0)
		nextBlockRotations=(${shapes[${nextBlock[0]}]})
		nextBlock[2]="$[RANDOM%${#nextBlockRotations[@]}]"
		nextPos=(0 "$sp")
		blockInGround "${nowBlock[@]}" "${nowPos[@]}" && {
			echo -n $'\e''[0m['"$[y+3]"';3HGAME OVER!'
			read -t 3;read -N 1
			endp
		}
	}
	blockUpdate 0 0 0 "${nxtShowPos[@]}" 1
	blockUpdate "${nextBlock[@]}" "${nxtShowPos[@]}" 1
	echo -en $'\e''ANo.'"$[NowBlockCnt+1]"' Code: '"${nextBlock[*]}"
}
# Control
function move {
	blockUpdate "${nowBlock[0]}" 0 "${nowBlock[2]}" "${nowPos[@]}"
	movePos="${nowPos[1]}"
	blockInGround "${nowBlock[@]}" "${nowPos[0]}" "$[nowPos[1]+$1]" || movePos="$[nowPos[1]+($1)]"
	if blockUpdate "${nowBlock[@]}" "${nowPos[0]}" "$movePos";then
		nowPos[1]="$movePos"
	else
		blockUpdate "${nowBlock[@]}" "${nowPos[@]}" 1
	fi
	[ "$CheatBreak" == 1 ] && JoinMap "${nowBlock[0]}" 0 "${nowBlock[2]}" "${nowPos[@]}"
}
function rotation {
	# switch style
	blockUpdate "${nowBlock[0]}" 0 "${nowBlock[2]}" "${nowPos[@]}"
	rotationSize=(${shapes[${nowBlock[0]}]})
	while {
		nowBlock[2]="$[(nowBlock[2]+1)%${#rotationSize[@]}]"
		blockInGround "${nowBlock[@]}" "${nowPos[@]}" ||
		! blockUpdate "${nowBlock[@]}" "${nowPos[@]}"
	};do continue
	[ "$CheatBreak" == 1 ] && JoinMap "${nowBlock[0]}" 0 "${nowBlock[2]}" "${nowPos[@]}"
	done
}
function drop {
	[ "$UpdateMapManual" -gt 0 ] && UpdateMapManual="$[UpdateMapManual-1]"
	[ "$speedDrop" -gt 0 ] && speedDrop="$[speedDrop-1]"

	blockInGround "${nowBlock[@]}" "$[nowPos[0]+1]" "${nowPos[1]}" && {
		JoinMap "${nowBlock[0]}" "$[nowBlock[1]*(CheatBreak?0:1)]" "${nowBlock[2]}" "${nowPos[@]}"
		[ "$CheatBreak" == 1 ] && blockUpdate "${nowBlock[0]}" 0 "${nowBlock[2]}" "${nowPos[@]}" 1
		NewBlock
		CheatBreak=0
		return
	}
	[ "$CheatBreak" == 1 ] && JoinMap "${nowBlock[0]}" 0 "${nowBlock[2]}" "${nowPos[@]}"
	blockUpdate "${nowBlock[0]}" 0 "${nowBlock[2]}" "${nowPos[@]}"
	nowPos[0]="$[nowPos[0]+1]"

	[ "$CheatSendBack" -gt 0 ] && {
		[ "$CheatSendBack" == 5 ] && nowPos=(0 "$sp")
		CheatSendBack="$[CheatSendBack-1]"
	}

	blockUpdate "${nowBlock[@]}" "${nowPos[@]}"
}

function _Read {
	for((_Read_i=0;_Read_i<Saveformat_Lines;++_Read_i));do
		read
	done
	read _readVer
	[ "$_readVer" != "$ver" ] && return 1
	read x y sc NowBlockCnt
	unset map nowBlock nowPos nextBlock
	read -a map
	read nowBlock[0] nowBlock[1] nowBlock[2] nowPos[0] nowPos[1] nextBlock[0] nextBlock[1] nextBlock[2] nextPos[0] nextPos[1]
	read CheatBreak CheatBreakTime
	read CheatSendBack CheatSendBackTime
}
function load {
	_Read < "$1"
	return "$?"
}
function _Write {
	OEcho "$Saveformat_Head"
	OEcho "$ver"
	OEcho "$x $y $sc $NowBlockCnt"
	OEcho "${map[*]}"
	OEcho "${nowBlock[*]} ${nowPos[*]} ${nextBlock[*]} ${nextPos[*]}"
	OEcho "$CheatBreak $CheatBreakTime"
	OEcho "$CheatSendBack $CheatSendBackTime"
	OEcho "$Saveformat_Tail"
}
function save {
	saveR="${2:-1}"
	saveFile="$1"
	while [ "$saveR" -gt 0 ] ;do
		echo $'\e''[0m['"$[y+3]"';2HSave File:Input File Name'"$saveR"
		Read_Read Read_File
		echo -n $'\e''[0m['"$[y+4]"';0H[K'
		saveFile="$Read_Result"
		echo -n $'\e''[2147483647A[0m['"$[y+3]"';0H[K'
		resSleep
		[ "$saveFile" == '' ] && return 1
		saveR="$[saveR-1]"
	done
	[ "$saveFile" == '' ] && {
		echo -n $'\e''[0m['"$[y+3]"';2HFailed:Not Opened[K'
		read -N 1
		echo -n $'\e''[0m['"$[y+3]"';0H[K'
		resSleep
	       	return 1
	}
	[ -e "$saveFile" ] && {
	       	[ -f "$saveFile" ] && {
			[ "$File" != "$saveFile" ] && {
				echo -n $'\e''[0m['"$[y+3]"';2HWarning:Trying to save in a file not opened( Yes:[yYaA1] / No:(other) )[K'
				read -N 1 saveOp
				[[ "$saveOp" == [yYaA1] ]] || {
					resSleep
					echo -n $'\e''[0m['"$[y+3]"';0H[K'
					return 2
				}
			}
			true
		} || {
			echo -n $'\e''[0m['"$[y+3]"';2HFailed:Not a file[K'
			read -N 1
			echo -n $'\e''[0m['"$[y+3]"';0H[K'
			resSleep
			return 1
		}
	}
	File="$saveFile"
	echo -n $'\e''[0m['"$[y+3]"';2HSaving File...[K'
	_Write > "$File"
	chmod +x "$File"
	echo -n 'File Saved:'"$File"
	read -N 1
	echo -n $'\e''[0m['"$[y+3]"';0H[K'
	resSleep
}

#Sleep
function sleep {
	sleepUntil="$[sleepLastTime+($1*10000000)]"
	while [ "$(date +%s%N)" -ge "$sleepUntil" ];do
		sleepLastTime="$sleepUntil"
		sleepUntil="$[sleepLastTime+($1*10000000)]"
		$2
	done
}

#Init
function initmap {
	tmp=()
	for((mapI=0;mapI<x;++mapI));do
		tmp[$mapI]=0
	done
	mapEmptyLine="$(connect "${tmp[@]}")"
	[ "$1" != 0 ] && {
		map=()
		for((mapI=0;mapI<=y;++mapI));do
			map[$mapI]="$mapEmptyLine";
		done
	}
}
function init {
	PrintFlag=0
	speedDrop=0 UpdateMapManual=0

	TtyAttr="$(stty -g)"
	UseFileFlag=0
	[ "${#File}" != 0 ] && [ -f "$File" ] && {
		if ! load "$File";then
			echo 'UNMATCHED SAVE VERSION:'"$_readVer"'(Require '"$ver"')'
			read -N 1
		else
			read -re -p 'Input Speed: ' -i "$spd" spd
			echo -n $'\e''[?25l'
			stty -icanon -echo -ixon
			initmap 0
			rb;ClearMap;rnxt;scinit
			scupd "$sc"
			PrintMap 1 1 "$y"
			NewBlock 0
			blockUpdate "${nowBlock[@]}" "${nowPos[@]}" 1
			tip 'Loaded,Press any key to start'
			PrintFlag=0
			read -N 1
			echo -n $'\e''[0m['"$[y+2]"';0H[K'
			UseFileFlag=1
		fi
	}
	[ "$UseFileFlag" == 0 ] && {
		read -re -p 'Input X: ' -i "$x" x
		read -re -p 'Input Y: ' -i "$y" y
		read -re -p 'Input Speed: ' -i "$spd" spd
		stty -icanon -echo -ixon
		echo -n $'\e''[?25l'
		rb;ClearMap;rnxt;scinit
		scupd 0
		sp="$[x/2-1]"
		nextBlock=(0 0 0)
		NowBlockCnt=-1
		initmap
		NewBlock;NewBlock
	}
	resSleep
}
#End
function endp {
	rs
	read -t 0.1
	stty "$TtyAttr"
	echo $'\e''[?25hYou got '"$sc"' score(s)!'
	exit $1
}

#Action:Pause
function pause {
	echo -n $'\e''[0m['"$[y+2]"';2HPaused,press any key to continue.'
	read -N 1
	echo -n $'\e''[0m['"$[y+2]"';0H[K'
	resSleep
}
#Action:Quit
function askq {
	echo -n $'\e''[0m['"$[y+3]"';2HTo quit,press y/END ,  To save&quit,press s'
	read -N 1 op
	[ "$op" == $'\e' ] && {
		read -N 2 -t 0.05 op
		[ "$op" == '[F' ] && op=y;
	}
	echo -n $'\e''[0m['"$[y+3]"';0H[K'
	[[ "$op" == [sS] ]] && save && return
	[[ "$op" == [yY] ]] && return
	resSleep
	return 1
}
#Action:Update Map
function updMap {
	ClearMap;
	PrintMap 1 1 "$y" && UpdateMapManual=5
}

#Main
scexit=0
trap 'schexit=1' SIGINT
{
	File="$2"
	init
	IgnoreCount=''
	while true;do
		op=''
		read -N 1 -t 0.029 op
		[ "$PrintFlag" == 1 ] && {
			echo -n $'\e''[0m['"$[y+2]"';0H[K'
			PrintFlag=0
		}
		[ "$op" == '	' ] && {
			keySwitchKey=(  'w'         'a'         's'         'd'          'f'       ''   ''   'q'    'p'     'u'         '1'              '2' )
			Read_AcReq=( 'rotation' 'move.left' 'speed_drop' 'move.right' 'save.as' 'save' 'open' 'quit' 'pause' 'update_map' 'cheat.breaking' 'cheat.send_back')
			echo -n $'\e''[0m['"$[y+3]"';0H[K'
			Read_Autocomplete Read_None
			for((Maini=0;Maini<${#keySwitchKey[@]};++Maini));do
				[ "$Read_ComRes" == "${Read_AcReq[Maini]}" ] && {
					op="${keySwitchKey[Maini]}"
					break
				}
			done
			resSleep
			echo -n $'\e''[0m['"$[y+3]"';0H[K'
		}
		case "$op" in
			'') Read_Ignore;;
			[wW]) Read_Ignore;rotation ;;
			[aA]) Read_Ignore;move -1 ;;
			[sS]) Read_Ignore;speedDrop=1 ;;
			[dD]) Read_Ignore;move 1 ;;
			[qQ$'\27']) Read_Ignore;askq && break ;;
			[pP]) Read_Ignore;pause ;;
			[uU$'\22']) Read_Ignore;updMap ;;
			$'\23') Read_Ignore;save "$File" 0 ;;
			$'\17') Read_Ignore;askq && endp 3 ;;
			f) Read_Ignore;save "$File";;
			1) Read_Ignore;CheatCheck "$CheatBreakTime" 20 && { CheatBreak=1; CheatBreakTime="$NowBlockCnt"; scupd "$[sc-(y/2)]"; true; } || CheatPrint 'Break' "$CheatBreakTime" 20 ;;
			2) Read_Ignore;CheatCheck "$CheatSendBackTime" 5 && { CheatSendBack=5; CheatSendBackTime="$NowBlockCnt"; scupd "$[sc-(y/5)]"; true; } || CheatPrint 'SendingBack' "$CheatSendBackTime" 5 ;;
			$'\e') read -N 1 -t 0.05 op
				case "$op" in
					\[) read -N 1 -t 0.05 op
						case "$op" in
						\[) read -N 1 -t 0.05 op;Read_Ignore
							[ "$op" == 'E' ] && updMap ;;
						A) Read_Ignore;rotation ;;
						D) Read_Ignore;move -1 ;;
						B) Read_Ignore;speedDrop=1 ;;
						C) Read_Ignore;move 1 ;;
						'') Read_Ignore;askq && break ;;
						*) Read_Ignore;;
					esac ;;
					$'\23') Read_Ignore;save "$File" ;;
					'') Read_Ignore;askq && break ;;
					*) Read_Ignore;;
				esac;;
			*) Read_Ignore;;
		esac

		[ "$UpdateMapManual" -gt 0 ] && {
			tip '[Updated Map.]'
		}
		[ "$speedDrop" -gt 0 ] && {
			tip 'Speed Drop'
		}
		CheatStr=(' CHEAT:')
		[ "$CheatBreak" == 1 ] && CheatStr[1]='Break,'
		[ "$CheatSendBack" -gt 0 ] && CheatStr[2]='SendingBack,'
		[ "${#CheatStr[@]}" -gt 1 ] && {
			[ "$PrintFlag" == 0 ] && echo -n $'\e''[0m['"$[y+2]"';2H'
			CheatStr="$(connect "${CheatStr[@]}")"
			echo -n "${CheatStr:0:0-1}"
		}
		[ "$schexit" == 1 ] && {
			schexit=0
			askq && break
		}
		sleep "$[speedDrop?(100/spd):(300/spd)]" drop
	done
	endp
}

} # GameDir

return "$?"
