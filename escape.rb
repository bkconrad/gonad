#!/usr/bin/env ruby
=begin
Moves cursor down one line in same column. If cursor is at bottom margin, 
screen performs a scroll-up.
=end
IND = "\x44"

=begin
Moves cursor up one line in same column. If cursor is at top margin, screen 
performs a scroll-down.
=end
RI = "\x4d"

=begin
Reverse linefeed: Moves cursor up one line in same column. If cursor is at 
top margin, screen performs scroll-down.
=end
RLF = "\x49"

=begin
Moves cursor to first position on next line. If cursor is at bottom margin, 
screen performs a scroll-up.
=end
NEL = "\x45"

=begin
Saves cursor position, character attribute (graphic rendition), character 
set, and origin mode selection. (See restore cursor).
=end
DECSC = "\x37"

=begin
Restores previously saved cursor position, character attribute (graphic 
rendition), character set, and origin mode selection. If none were saved, the c
ursor moves to home position.
=end
DECRC = "\x38"

=begin
Moves cursor up n lines in same column. Cursor stops at top margin.
=end
CUU = "\x41"

=begin
Moves cursor down n lines in same column. Cursor stops at bottom margin.
=end
CUD = "\x42"

=begin
Moves cursor right n columns. Cursor stops at right margin.
=end
CUF = "\x43"

=begin
Moves cursor left n columns. Cursor stops at left margin.
=end
CUB = "\x44"

=begin
Moves cursor to line n, column m. If n or m are not selected or 
selected as 0, the cursor moves to first line or column, respectively.
=end
CUP = "\x48"

=begin
Same as CUP.
=end
HVP = "\x66"

=begin
Erase in line.
=end
EL = "\x4b"

=begin
Erase in display.
=end
ED = "\x4a"

=begin
Deletes n characters, starting with the character at cursor position. When 
a character is deleted, all characters to the right of cursor move left. This
creates a space character at right margin.
=end
DCH = "\x50"

=begin
Inserts n lines at line with cursor. Lines displayed below cursor move down. 
Lines moved past the bottom margin are lost.
=end
IL = "\x4c"

=begin
Deletes n lines, starting at line with cursor. As lines are deleted, lines 
displayed below cursor move up. Lines added to bottom of screen have spaces 
with same character attributes as last line moved up.
=end
DL = "\x4d"

=begin
Select graphics rendition. The terminal can display the following character 
attributes that change the character display without changing the character.

    * Underline
    * Reverse video (character background opposite of the screen background)
    * Blink
    * Bold (increased intensity)

=end
SGR = "\x6d"

=begin
Selects top and bottom margins, defining the scrolling region. Pt is line 
number of first line in the scrolling region. Pb is line number of bottom line.
If arguments are not selected, the complete screen is used (no margins).
=end
DECSTBM = "\x72"

=begin
Selects insert mode. New display characters move old display characters to 
the right. Characters moved past the right margin are lost.
=end
IRMI = "\x68"

=begin
Selects replace mode. New display characters replace old display characters 
at cursor position. The old character is erased.
=end
IRMR = "\x6c"

=begin
Backspace: Moves cursor to the left one character position; if cursor is at 
left margin, no action occurs.
=end
BS = "\x08"

=begin
Horizontal tab: Moves cursor to the next tab stop, or right margin if there 
are no more tab stops.
=end
HT = "\x09"

=begin
Linefeed: Causes a linefeed.
=end
LF = "\x0a"

=begin
Vertical tab: Processed as LF.
=end
VT = "\x0b"

=begin
Form feed: Process as LF.
=end
FF = "\x0c"

=begin
Carriage return: Moves cursor to left margin on current line.
=end
CR = "\x0d"

=begin
Device control 1: Processed as XON. DC1 causes terminal to continue 
transmitting characters.
=end
DC1 = "\x11"

=begin
Device control 3: Processed as XOFF. DC3 causes terminal to stop
transmitting all characters except XOFF and XON.
=end
DC3 = "\x13"

=begin
Cancel: If received during an escape or control sequence, cancels the
sequence and displays substitution character
=end
CAN = "\x18"

=begin
Substitute: Processed as CAN
=end
SUB = "\x1a"

=begin
Escape: Processed as a sequence introducer.
=end
ESC = "\x1b"

=begin
Shift in: Switch to the G0 character set.
=end
SI = "\x0f"

=begin
Shift out: Switch to the G1 character set.
=end
SO = "\x0e"
