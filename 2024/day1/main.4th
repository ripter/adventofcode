1024 constant MAX-LEN
\ Create a buffer hold each line
\ Spec says we need to allocate 2 more bytes than the max line length
create buf MAX-LEN 2 + allot

2variable file-name
variable list1
variable list2

: set-list ( val idx var -- ) @ swap cells + ! ;
: get-list ( idx var -- ) @ swap cells + @ ;

: >list1 ( val idx ) list1 set-list ;
: list1> ( idx ) list1 get-list ; 
: >list2 ( val idx ) list2 set-list ;
: list2> ( idx ) list2 get-list ; 


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
    buf MAX-LEN file-id read-line throw  \ u2 flag
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
  \ Convert the second number
  0 0 addr2 u2 trim >number
  { num2 flag2 addr3 u3 }
  num1 num2
;

\ Allocates memory for the two lists
: allocate-lists ( u -- )
  dup cells allocate throw list1 !
  cells allocate throw list2 !
  cr ." Allocating memory for the lists" cr
  list1 @ . ." list1 address after allocation" cr
  list2 @ . ." list2 address after allocation" cr
;

: free-lists ( -- )
  list1 free throw
  list2 free throw
;

: fill-lists ( u -- )
  file-name 2@ r/o open-file throw
  { file-id }
  0 do  \ Loop from 0 to u
    buf MAX-LEN file-id read-line throw \ u2 flag
    \ flag is false when we reach the end of the file
    0= if leave then
    \ the buf has the 2 numbers separated by a spaces
    buf swap  \ c-addr u2
    parse-line  \ n1 n2
    i >list2
    i >list1
  loop

  \ close the file.
  file-id close-file throw
;


\ Sorts the list in decreasing order
: bubble-sort-list ( u1 var -- )
  { len var }
  begin
    0 \ flag-no-swap
    len 1- 0 do           \ loop from 0 to len - 1
      i var get-list      \ get the first number       ( flag val1 )
      i 1+ var get-list   \ get the second number     ( flag val1 val2 ) 
      \ if the first number is greater than the second number, swap them
      2dup > if           \ val1 > val2               ( flag val1 val2 )
        i var set-list    \ val2 to i                 ( flag val1 )
        i 1+ var set-list \ val1 to i + 1             ( flag )
        drop 1            \ set the flag to 1          ( flag-swapped )
      else
        \ drop the numbers, they are already in order
        2drop             \                           ( flag ) 
      then
    loop
  0 = until \ repeat until we don't swap any numbers
;


\ Entry point for the program
\ Use one of the run-* words to run the example or input data
: main
  \ Print a friendly message letting us know which data we're running
  cr cr ." Loading data from ./" file-name 2@ type cr
  file-name 2@ #lines-in-file
  dup ." Number of lines in file: " . cr
  dup allocate-lists
  dup fill-lists
  dup list1 bubble-sort-list
  dup list2 bubble-sort-list

  0 \ sum
  swap 0 do \ get the diff of from each number
    i list1> i list2> - abs + \ add the diff to the sum
  loop
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
