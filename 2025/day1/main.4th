\ Create a buffer hold each line
\ Spec says we need to allocate 2 more bytes than the max line length
1024 constant MAX-LEN
create buf MAX-LEN 2 + allot
\ Define a dial to hold the current rotation position
\ The dial holds a value between 0-99
variable dial 
50 dial !  \ Initialize the dial to 50

variable include-bonus
false include-bonus !


\ Rotate the combination Left by u
: L ( u -- )
  100 mod \ ensure u is within 0-99
  negate dial +!
  \ Dial wraps around at 0
  dial @ 0< if
    dial @ 100 + dial !
  then
;

\ Rotate the combination Right by u
: R ( u -- )
  100 mod \ ensure u is within 0-99
  dial +!
  \ Dial wraps around at 99
  dial @ 99 > if
    dial @ -100 + dial !
  then
;

\ Returns the correct direction defined by the buffer
: direction ( -- c )
  buf c@
;

\ Increments the first value on the stack by 1
: +1b ( a b -- a+1 b )
  swap 1+ swap
;

: calc-bonus ( u -- u count )
  \ If the number is greater than 100, then it will pass 0 and should get a bonus.
  \ If the remainder will pass 0, also add a bonus.
  dup 100 /mod swap  ( u quo rem )

  direction [char] L =  \ Direction is Left
  dial @ 0 <> AND if    \ AND Dial is not at 0
    dup dial @ swap - 0< if
      +1b
    then
  else
    direction [char] R =  \ Direction is Right
    dial @ 0 <> AND if    \ AND Dial is not at 0
      dup dial @ + 100 > if
        +1b
      then
    then
  then

  drop \ drop rem
;


\ Process the file.
: process-file ( fileid -- u fileid )
  0     \ Initialize the count of times the dial reads 0
  swap  \ put the counter behind the fileid so read-line can use it.
  \ Read each line until EOF
  begin
    dup                 \ duplicate file id for read-line, leaving the orignal as the return value from the word.
    buf MAX-LEN erase   \ clear the buffer, we don't want any leftover data from previous reads.
    buf MAX-LEN rot     \ move the file id after the buffer and length.
    read-line throw     \ read the line into the buffer, if it fails, throw an error.
  while ( count fileid u2 )
    \ The first char in the buffer is the word to run,
    \ Everything else is the number to pass to that word.
    buf char+ swap s>number drop  \ convert the number string to a number, drop the conversion flag

    include-bonus if
      calc-bonus
      3 roll + -rot \ and the bonus to the count.
    then
    buf 1 evaluate  \ Runs the word at buf[0] with the number on the stack (either L or R)

    \ When the dial reads 0, we increase the count.
    dial @ 0 = if
      +1b
    then
  repeat
  drop \ drop u2 from the last read-line
;

: with-bonus ( -- )
  true include-bonus !
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