# Read the saveformat file

#Values
function Read_Saveformat_Replaceing {
	Read_Saveformat_Rep="${1//#Path_d/$Read_Saveformat_RepPath_d}"
	Read_Saveformat_Rep="${Read_Saveformat_Rep//#Path_s/$Read_Saveformat_RepPath_s}"
	Read_Saveformat_Rep="${Read_Saveformat_Rep//#Path/$Read_Saveformat_RepPath}"
	echo -n "$Read_Saveformat_Rep"
}

#Reading from fd 0
function Read_Saveformat___Read {
	read Saveformat_Lines
	Saveformat_Head="$(Read_Saveformat_Replaceing "$(head -n "$Saveformat_Lines")")"
	Saveformat_Tail="$(Read_Saveformat_Replaceing "$(cat)")"
}
#Read
function Read_Saveformat_Read {
	Read_Saveformat___Read < "$1"
}

#Init
function Read_Saveformat_Init {
	Read_Saveformat_RepPath="$1"
	Read_Saveformat_RepPath_s="'${1//'/\\'}'"
	Read_Saveformat_RepPath_d='"'"${1//"/\\"}"'"'
}
