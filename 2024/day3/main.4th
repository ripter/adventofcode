13 constant MAX_BUFFER_SIZE
variable total        \ Holds the total of all the mult(nnn,nnn) values
variable parseBuffer \ Holds the mult(nnn,nnn) string as it is being built
variable parsePos    \ Holds the current position in the buffer

\ Setup the globals for running the program.
: initialize ( -- )
  MAX_BUFFER_SIZE allocate throw parseBuffer !
  0 parsePos !
;

\ Add a character to the parse buffer
: append ( char -- )
  parsePos @ ( char -- char idx )
  \ Bounds checking
  dup MAX_BUFFER_SIZE >  
  dup 0 <  
  or if
    cr ." Buffer overflow " .s cr
    drop exit
  then
  \ Set the char in the buffer[parsePos], then increment parsePos
  parseBuffer + c! ( char idx -- )
  1 parsePos +!
;

: test
  initialize
  [char] m append
  [char] u append
;


\ Resets the parse buffer to 0 the appends char to it
: reset ( char -- )
  0 parsePos !
  append
;


: should-append-char? ( char -- flag )
  parsePos @
  \ the first 5 characters of the string we are looking for
  dup 5 < if
    case
      0 of [char] m = endof
      1 of [char] u = endof
      2 of [char] l = endof
      3 of [char] t = endof
      4 of [char] ( = endof
      \ default is false
      drop false swap
    endcase
  else
    cr ." greater than or equal to 5 " .s cr

    \ Can the character be converted into a number?
    \ if so, add it to the buffer
    \ check for comma
    \ Ceck for the second converted number
    \ add it to the second number

    \ check if it's the last character
    drop [char] ) =
  then
;

: is-valid-buffer? ( addr -- flag )
  cr ." is-valid-buffer? called "
  drop
  false
;

: extract-values ( addr -- n1 n2 )
  cr ." extract-values called "
  drop
  0 0
;

: main ( c-addr u -- )
  R/O open-file throw { fileID }
  initialize
  0 total !
  begin
    \ Read the next char from the file
    pad 1 fileID read-file throw   ( flag c-addr u2 )
  while
    \ is the char in pad one we are looking for?
    pad @ should-append-char? if
      \ Add it to the array and move on.
      pad @ parseBuffer append 
    else
      \ reset the buffer with pad as the only character
      pad @ parseBuffer reset
    then

    \ Test if the buffer is a valid mult(nnn,nnn) string yet
    parseBuffer is-valid-buffer? if
      \ Get the values, multiply them, and add them to the total.
      parseBuffer extract-values * total +!
    then
  repeat

  fileID close-file throw
  total @ ." Total: " .
;

: run-example ( -- )
  s" example.txt" main 
;
: run-input ( -- )
  s" input.txt" main
;
