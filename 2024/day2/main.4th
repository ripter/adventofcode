1024 constant MAX-LEN
create buf MAX-LEN 2 + allot

variable #reports
variable report-direction


: trim-start ( c-addr1 u1 -- c-addr2 u2 )
  begin
    \ check if the first character is a space
    2dup drop c@ bl = if
      \ decrement the length and increment the address
      1- swap 1+ swap
    else
      0 \ stop the loop
    then
  dup 0= until
  drop \ drop the flag
;

\ helps me out because I keep forgetting to add 0 0 before the string while debugging.
: to-number ( c-addr u -- n c-addr2 u2 )
  2>r 0 0 2r> >number
;

: is-same-direction ( n1 n2 -- flag )
  xor 0 >= if
    true
  else
    false
  then
;

\ Convert the string of reports into a series of numbers 
\ Resets the #reports variable
: s>reports ( c-ddr u -- n1 n2 n3 ... u2 )
  2dup ." s>reports " type cr
  0 #reports !
  \ the number conversion word requires double 0 0 before the address.
  0 0 2swap \ 0 0 c-addr u
  begin
    trim-start >number  \ convert the number 
    0 -rot \ insert a fresh 0 for the next converted number to occupy
    1 #reports +! \ increment the number of reports
  dup 0= until
  2drop 2drop \ drop the address and the placeholder
;

\ Returns true if the report is valid
\ Uses the #reports variable to determine the number of reports on the stack
: is-valid-report? ( n1 n2 n3 ... -- flag )
  ." is valid? " .s cr
  \ true for postive, false for negative
  2dup - report-direction !
  #reports @ 1- 0 do
  \ 1 0 do
    ." Checking " i . ." : " 2dup . . cr
    \ i . ." : " dup . cr
    \ Get the difference between the two numbers
    2dup - 
    \ safe if between 1 and 3 inclusive
    dup abs 0 > swap  \ safe if greater than 0 
    dup abs 4 < swap  \ safe if less than 4
    -rot and      \ safe if both conditions are met
    0= if 
      ." Not Safe " 
      drop false  \ not safe, so we can leave
      leave
    else
      ." Safe " 
    then
    cr ." Checking direction " .s cr
    \ Check the direction of the report    
    \ matches the direction of the result.
    report-direction @ is-same-direction if
      ." matches direction " cr
    else
      ." Error, does not match" cr
      drop false leave
    then
    drop
  loop
;

\ Day 2 Red-Nosed Reports
\ Returns the number of safe reports in the file.
( c-addr u -- n )
: main
  \ Print a friendly message letting us know which data we're running
  2dup cr cr ." Loading data from ./" type cr
  \ Open the file for reading and get the file-id
  r/o open-file throw
  { file-id }

  begin
    \ Read the next line from the file setup the stack to use the line
    buf MAX-LEN file-id read-line throw   \ u2 flag
    buf rot                              \ flag c-addr u2
    \ Convert the string into a series of numbers
    s>reports
    is-valid-report? if
      ." Valid Report" cr
    else
      ." Invalid Report" cr
    then

    drop 0 \ debugging end early
  0= until
;

\ Runs the Exmaple Data
: run-example
  s" example.txt" main
;

\ Runs the Input Data
: run-input
  s" input.txt" main
;