Goal-Oriented Nethack Ascension Demonstration
===

Hopefully this will be an intelligent nethack-playing bot. For now, it is
simply a rudimentary VT102 parser hooked up to a rough screen-scraper. It
currently:

 - starts a local game (in wizard mode with --wizard)
 - chooses a character
 - presses space when it sees --More-- on the screen
 - wanders around until it dies
 - makes a primitive map of the dungeon (run `puts Knowledge.dungeon_map.dump`
   in the debugger to see it)

to see it in action, clone it, install the 'pry' gem (and nethack). Then run
`./gonad.rb`. You can press (backtick) to drop to the pry debugger, `quit` to
return to the bot.  `^]` (control + right square brace) toggles human input
on/off.
