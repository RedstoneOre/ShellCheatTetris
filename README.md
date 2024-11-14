# CHEAT-TETRIS
### Now Version:alpha-2.2 N.6

## Running
> **First** time:
> 
> Please run the follow commands in the game folder:
> ```sh
> chmod +x './Cheat Tetris.run'
> ```

> Executing:
> 
> Please run the follow commands in the game folder:
> ```sh
> './Cheat Tetris.run' [save-path]
> ```

#### Require
+ A console with enough columns and lines
+ Installed `bash`,`date` and `python3`

## Gameplay
The following text will show you **when you start a game**,
and it shows the **keys and arguments**.
```txt
Control
	Press a(left arrow),d(right arrow) to move left or right
	Press w(up arrow) to rotate anticlockwise
		to the first avalible rotation
	Hold s(down arrow) to make the block drop faster
Game
	Press q to save and quit
	Press Ctrl-s to save
	Press f or Alt-Ctrl-s to input file path and save in the file
	Add a path argument or use Ctrl-O to open a save
	Press u or Ctrl-r or F5 to refresh the map
Cheat
	Press 1 to destroy blocks while dropping and
		disapper when touch the ground
		(cooldown 20 blocks,use (GameHeight/2) scores)
	Press 2 to send the block back to the spawn
		(cooldown 10 blocks,Use (GameHeight/5) scores)
```

#### Scores
1. Clear a line: $+{GameWidth}$
2. Cheat 1: $-\frac {GameHeight} 2$
3. Cheat 2: $-\frac {GameHeight} 5$

#### Ticks
+ The game update 1 time per tick
+ You can operate by keyboard many times in 1 tick
+ Tick update delay:
$$TickDelay=\frac { \Big \{ \begin{matrix} 1s(SpeedDrop \  on) \\ 3s(SpeedDrop \  off) \end{matrix} } {GameSpeed}$$

#### Playing
1. Placing:When a falling block touch the ground,it will been placed in next tick
2. Clearing:When a line is **been filled by placed blocks**,the line will **been cleared** and
	the lines up will **drop down**.

#### Inputing
You need to input something in the game,and you can input like this:
> Press `Insert` to insert special chars
> Press `Tab` to trig `Autocomplete`
> Press `Enter` to confirm
> In `Autocomplete`:
>> Press `Tab` to show next choice
>> Press `Shift-Tab` to show prev choice
>> Press `Ctrl-H` to return to the first choice
>> Press `Espace` to espace `Autocomplete`
>> Press `Enter` to confirm
>> Press *another key* to show the option which 
>>  first letter is that the given key inputted

## Display
| Object       | Char | Width | 
|-------------:|------|-------|
| Border(side) | #    | 1     |
|Border(bottom)| #    | 2     |
|Falling Block | !    | 2     |
| Placed Block | @    | 2     |
|    Empty     | .    | 2     |
