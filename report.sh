# Report
__Title_Game='Report to the developer
* if you found a bug,please share the way to trigger and your save if possible
* if you want to give an advice:
	To add sth:make sure it won'"'"'t break the balance
	To merge sth:show your purpose
Report Here:
'
__Links=( 'https://github.com/RedstoneOre/ShellCheatTetris/issues/new?title=[BUG/ADVICE]%20&description=#%20Type:BUG%0a#%20Trigger' )

function __Report {
	echo -n "$1"
	for((__Report_i=0;__Report_i<${#__Links[@]};++__Report_i));do
		echo "$__Report_i. ${__Links[__Report_i]}"
	done
}
