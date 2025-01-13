12 constant MAX_BUFFER_SIZE
variable parseBuffer \ Holds the mult(nnn,nnn) string as it is being built
variable parsePos    \ Holds the current position in the buffer
variable shouldUseBonusRules    \ Flag to use the bonus rules
variable includeMult? \ Flag to include the mult(nnn,nnn) strings in the total

\ Default values on the globals
false shouldUseBonusRules !

\ Setup the globals for running the program.
: initialize ( -- )
  MAX_BUFFER_SIZE allocate throw parseBuffer !
  0 parsePos !
  true includeMult? !
;

: cleanup ( -- )
  parseBuffer @ free throw
;

\ Returns true if it's an ASCII printable character
: is-printable? ( x -- f )
  dup 32 >= swap 126 <= and
;


\ Convert a character to a digit and flag if it is a digit
: char->digit? ( c -- n flag )
  dup [char] 0 < if  \ if c < '0'
    drop 0 false exit
  then

  dup [char] 9 > if  \ if c > '9'
    drop 0 false exit
  then

  \ If we get here, '0' <= c <= '9'
  [char] 0 -  \ convert ASCII digit to numeric value
  true
;

: position ( -- idx )
  parsePos @ 
;
: position! ( n -- )
  parsePos !
;
: position+! ( n -- )
  parsePos +!
;

: should-use-bonus? ( -- flag )
  shouldUseBonusRules @
;

: buffer@ ( idx -- char )
  parseBuffer @ + c@ 
;
: buffer! ( char idx -- )
  parseBuffer @ + c!
;

: .buffer ( -- )
  position 0 = if
    ." Buffer is empty" cr
    exit
  then
  position 0 do
    i buffer@ emit
  loop
;

\ Add a character to the parse buffer
: >buffer ( char -- )
  position MAX_BUFFER_SIZE >= if
    ." Error: Buffer overflow" cr
    exit
  then

  dup is-printable? invert if
    cr cr ." >buffer: Invalid character " . cr
    .buffer cr
    exit
  then
  \ Set the char in the buffer[parsePos], then increment parsePos
  position buffer!
  1 position+!
;

\ Put a string into the buffer
: str->buffer ( c-addr len -- )
  { caddr len }
  0 position!
  len 0 do 
    caddr i + c@ >buffer
  loop
;

: reset 
  0 position!
;

: digit? ( char -- flag )
  char->digit? swap drop
;
: comma? ( char -- flag )
  [char] , =
;
\ true if the char is a digit or a comma
: digit-or-comma? ( char -- flag )
  dup digit?
  swap comma?
  or 
;
\ true if char is either a digit or a closing parenthesis
: digit-or-closing? ( char -- flag )
  dup digit?
  swap [char] ) =
  or
;

\ Returns true if a comma has been used in the buffer
\ start at idx -1 and walk backwards until idx 6 or a comma is found
: [did-use-comma]?  ( idx -- flag )
  dup
  \ bounds check
  dup 5 < swap MAX_BUFFER_SIZE > or if
    false exit
  then
  
  \ start at position - 1 and walk backwards until idx 6 or a comma is found
  1- 5 swap do
    i buffer@ [char] , = if
      unloop true exit
    then
  -1 +loop
  false
;
: did-use-comma? ( -- flag )
  position [did-use-comma]?
;

\ Returns true if the ending parenthesis has been used in the buffer
\ start at idx -1 and walk backwards
: [did-use-end-parenthesis]? ( idx -- flag)
  \ idx 7 is the last position that can have a closing parenthesis
  dup 7 < if
    false exit
  then

  \ walk backwards from idx - 1 to idx 7
  1- 7 swap do
    i buffer@ [char] ) = if
      unloop true exit
    then
  -1 +loop
  false
;
: did-use-end-parenthesis? ( -- flag )
  position [did-use-end-parenthesis]?
;

\ mult(nnn,nnn) string
: char-valid-for-mult-string? ( char idx -- flag )
  \ Each position in the buffer has a different set of valid characters
  \ Would be easy in regex, but this is Forth
  case
    0 of [char] m = endof
    1 of [char] u = endof
    2 of [char] l = endof
    3 of [char] ( = endof
    4 of digit? endof
    5 of digit-or-comma? endof
    6 of \ can be either a comma or a digit
      6 [did-use-comma]? if
        digit?
      else \ if the comma was not used last time, it can be either
        digit-or-comma?
      then endof
    7 of \ can be a comma, a digit, or a closing parenthesis
      \ If the comma has been used, then it could be a closing parenthesis or digit.
      7 [did-use-comma]? if 
        digit-or-closing?
      else
        \ If the comma has *NOT* been used, then it *HAS* to be a comma
        [char] , =
      then endof
    8 of \ can be a digit or a closing parenthesis, MUST have a preceding comma
      digit-or-closing? 
      8 [did-use-comma]? 
      8 [did-use-end-parenthesis]? invert
      and and endof
    9 of \ can be a digit or a closing parenthesis, MUST have a preceding comma
      digit-or-closing? 
      9 [did-use-comma]? 
      9 [did-use-end-parenthesis]? invert
      and and endof
    10 of \ can be a digit or a closing parenthesis, MUST have a preceding comma
      digit-or-closing? 
      10 [did-use-comma]? 
      10 [did-use-end-parenthesis]? invert
      and and endof
    11 of [char] ) = did-use-comma? and endof
   \ default is false
    drop false swap
  endcase
;
\ do() string 
: char-valid-for-do-string? ( char ids -- flag )
  case
    0 of [char] d = endof
    1 of [char] o = endof
    2 of [char] ( = endof
    3 of [char] ) = endof
    \ default is false
    drop false swap
  endcase
;
\ don't() string
: char-valid-for-dont-string? ( char ids -- flag )
  case
    0 of [char] d = endof
    1 of [char] o = endof
    2 of [char] n = endof
    3 of [char] ' = endof
    4 of [char] t = endof
    5 of [char] ( = endof
    6 of [char] ) = endof
    \ default is false
    drop false swap
  endcase
;

\ Returns True if the character should be appended to the buffer
: should-append-char? ( char -- flag )
  { c }
  c is-printable? if
    c position char-valid-for-mult-string? 
    should-use-bonus? if
      c position char-valid-for-do-string? or
      c position char-valid-for-dont-string? or
    then
  else
    false
  then
;

: does-buffer-contain-mult? ( -- flag )
  \ Check if there are enough characters in the buffer to be valid
  position 8 < if
    false exit
  then
  \ Check if they used a comma
  did-use-comma? invert if
    false exit
  then
  \ Check if the last character is a closing parenthesis
  [char] ) position 1- buffer@ = invert if
    false exit
  then
  \ Loop and check each character in the buffer
  position 0 do
    i dup buffer@ swap 
    char-valid-for-mult-string? invert if
      unloop false exit
    then
  loop
  true
;
\ do()
: does-buffer-contain-do? ( -- flag )
  \ Check if there are enough characters in the buffer to be valid
  position 3 < if
    false exit
  then
  \ Loop and check each character in the buffer
  4 0 do
    i dup buffer@ swap 
    char-valid-for-do-string? invert if
      unloop false exit
    then
  loop
  true
;
\ don't()
: does-buffer-contain-dont? ( -- flag )
  \ Check if there are enough characters in the buffer to be valid
  position 6 < if
    false exit
  then
  \ Loop and check each character in the buffer
  7 0 do
    i dup buffer@ swap 
    char-valid-for-dont-string? invert if
      unloop false exit
    then
  loop
  true
;


: buffer-values ( -- n1 n2 )
  0 \ start the first number
  \ digits start on idx 4
  position 4 do
    i buffer@ char->digit? if ( n1 -- n1 n2 )
      swap 10 * +
    else
      drop \ drop the failed to convert character
      0 \ start a new number
    then
  loop
  drop \ last character was a ), drop it
;

: main ( c-addr u -- )
  2dup cr ." Reading file " type cr
  ." Bonus is " should-use-bonus? if ." enabled" else ." disabled" then cr
  R/O open-file throw { fileID }
  initialize
  0 s>d \ total in 64 bits
  begin
    \ Read the next char from the file into pad
    pad 1 fileID read-file throw
  while
    pad @ should-append-char? if
      pad @ >buffer 
    else
      reset
    then

    should-use-bonus?
    does-buffer-contain-do? 
    and if
      true includeMult? !
      reset
    then

    should-use-bonus?
    does-buffer-contain-dont?
    and if
      false includeMult? !
      reset
    then

    \ Test if the buffer is a valid mult(nnn,nnn) string yet
    includeMult? @
    does-buffer-contain-mult? 
    and if
      \ Get the values, multiply them, and add them to the total.
      buffer-values * 
      s>d d+ \ convert to 64 bit then do a 64 bit add with the total.
      reset
    then

    includeMult? @ invert
    does-buffer-contain-mult? and
    position 0 > and if
      reset
    then

  repeat

  fileID close-file throw
  ." Total: " swap . . cr
  cleanup
;

: enable-bonus ( -- )
  true shouldUseBonusRules !
;

: run-example ( -- )
  should-use-bonus? if
    s" example2.txt" main 
  else
    s" example.txt" main 
  then
;
: run-input ( -- )
  s" input.txt" main
;
