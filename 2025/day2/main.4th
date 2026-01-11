\ Create a buffer to hold each line we read from the file
\ I read that we should allocate 2 more bytes than the max line length
1024 constant MAX-LEN
create buf MAX-LEN 2 + allot
variable buf-length
0 buf-length !

: reset-buf ( -- )
  buf MAX-LEN erase
  0 buf-length !
;

\ Variables to hold the start and ending ranges
variable start-range
variable end-range

: reset-ranges ( -- )
  0 start-range !
  0 end-range !
;

: has-range? ( -- flag )
  start-range @ 0<> end-range @ 0<> and
;


\ Append the next character from the file to the buffer
: append-next-from-file ( fileid -- fileid char-read )
  dup                 \ dup the fileid so we can return it
  buf buf-length @ +  \ calculate the address to append the character
  1 rot               \ read one character and rotate everything into position.
  read-file throw      \ Read a single character from the file
  dup buf-length @ + buf-length !  \ Update buf-length with the number of characters read
;

\ Returns the last character in the buffer
: last-char ( -- char )
  buf buf-length @ 1- chars + c@
;

\ Returns true if the last character in the buffer is a dash
: ends-with-dash? ( -- flag )
  last-char [char] - =
;

\ Returns true if the last character in the buffer is a comma
: ends-with-comma ( -- flag )
  last-char [char] , =
;

\ Gets the number from the buffer, last char is a dash or comma
: get-range-number ( -- n )
  buf-length @ 1 - chars
  buf swap s>number throw 
;


\ Process the file, return the result
: process-file ( fileid -- result fileid )
  0 swap  \ initialize result to 0
  BEGIN 
    append-next-from-file
  WHILE
    \ s" Start of loop: " type .s cr
    \ s" Processing line: " type buf buf-length @ type cr
    ends-with-dash? if
      get-range-number start-range !
      reset-buf
      \ s" Start range: " type start-range @ . cr
    else 
      ends-with-comma if
        get-range-number end-range !
        reset-buf
        \ s" End range: " type end-range @ . cr
      then
    then

    has-range? if
      s" Range loaded: " type start-range @ . s" - " type end-range @ . cr
      reset-ranges
    then
    \ s" End of loop:" type .s cr
  REPEAT
;


\ Runs the program with the example input
: run-example ( -- )
  s" Running example..." type cr
  s" example.txt" r/o open-file abort" Failed to open example.txt" process-file close-file throw
  s" Result: " type . cr
;

\ Runs the program with the actual input
: run-input ( -- )
  s" Running input..." type cr
  s" input.txt" r/o open-file abort" Failed to open input.txt" process-file close-file throw
  s" Result: " type . cr
;
