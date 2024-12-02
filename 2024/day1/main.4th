1024 constant MAX-LEN
\ Create a buffer to hold each line
\ Spec says we need to allocate 2 more bytes than the max line length
create buffer MAX-LEN 2 + allot

2variable file-name
variable list1
variable list2

\ Removes the leading and trailing spaces from a string
: trim ( c-addr u -- c-addr2 u2 )
  { addr1 u1 }
  0 \ counter
  u1 0 do
    addr1 i + c@ bl = if
      1+ \ increment the counter
    else
      leave
    then
  loop
  { counter }
  addr1 counter + \ get the new address by adding the leading spaces
  u1 counter - \ get the new length by subtracting the leading spaces
  -TRAILING \ remove the trailing spaces
;

\ Returns the number of lines in a file
: #lines-in-file ( c-addr1 u1 -- n )
  \ Open the file and get the file-id
  r/o open-file throw 
  { file-id }
  \ Initialize the line count
  0 >r
  \ Read each line until we reach the end of the file
  \ incrementing the line count each time
  begin
    buffer MAX-LEN file-id read-line throw  \ u2 flag
    swap drop \ flag
    \ flag is false when we reach the end of the file, don't count that line
    dup true = if
      r> 1+ >r
    then
  0= until
  \ close the file
  file-id close-file throw
  r>
;

\ Convert the line from the file into two numbers
: parse-line ( c-addr u -- n1 n2 )
  { addr1 u1 }
  \ Convert the first number
  0 0 addr1 u1 >number    
  { num1 flag1 addr2 u2 }
  num1 ." Num1: " . 
  \ Convert the second number
  0 0 addr2 u2 trim >number
  { num2 flag2 addr3 u3 }
  num2 ."     Num2: " . cr
;

\ Allocates memory for the two lists
: allocate-lists ( u -- )
  2dup cells allocate throw list1 !
  cells allocate throw list2 !
;

: fill-lists
  file-name 2@ r/o open-file throw
  { file-id }
  do
    buffer MAX-LEN file-id read-line throw \ u2 flag
    \ flag is false when we reach the end of the file
    0= if leave then
    \ the buffer has the 2 numbers separated by a spaces
    buffer swap  \ c-addr u2
    parse-line  \ n1 n2
    \ 2drop
  loop

  \ close the file.
  file-id close-file throw
;



\ Entry point for the program
\ Use one of the run-* words to run the example or input data
: main
  \ Print a friendly message letting us know which data we're running
  cr cr ." Loading data from ./" file-name 2@ type cr
  file-name 2@ #lines-in-file
  dup ." Number of lines in file: " . cr
  allocate-lists
  fill-lists
;

\ Runs the Exmaple Data
: run-example
  s" example.txt" file-name 2!
  main
;

\ Runs the Input Data
: run-input
  s" input.txt" file-name 2!
  main
;
