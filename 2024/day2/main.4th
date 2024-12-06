1024 constant MAX-LEN
create buf MAX-LEN 2 + allot

variable #reports
variable report-direction
variable #valid-reports
variable tolerated-range

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

\ Convert the string of reports into a series of numbers 
\ Resets the #reports variable
: s>reports ( c-ddr u -- n1 n2 n3 ... u2 )
  2dup ." s>reports " type 
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


: get-direction ( n1 n2 -- flag )
  - 0 > if
    true
  else
    false
  then
;

: is-same-direction ( n1 n2 -- flag )
  xor 0 >= if
    true
  else
    false
  then
;

: is-safe-change? ( n1 n2 -- flag )
  - 
  \ safe if between 1 and 3 inclusive
  dup abs 0 > swap  \ safe if greater than 0 
  abs 4 < swap      \ safe if less than 4
  and               \ safe if both conditions are met
;

\ Returns a score of how bad the reports is
\ Uses the #reports variable to determine the number of reports on the stack
: bad-score-report ( n1 n2 n3 ... -- badScore )
  2dup get-direction report-direction !
  \ Loop over each pair of reports, keep track of the invalid levels as we go
  0  \ badScore
  begin   \ ( n1 n2 badScore )
    -rot  \ move the flag back ( badScore n1 n2 )
    \ 2dup ." #reports #: " #reports @ . ." val1: " . ." val2: " .  cr

    \ Check that the reports are moving in the same direction  
    2dup get-direction report-direction @ invert = if
      \ ." diff direction " .s cr
      \ ding 100 points for bad direction
      rot 100 + -rot 
    then

    \ Check if the level change is safe
    2dup is-safe-change? invert if
      \ ." not-safe range " .s cr
      \ ding 1 point for bad level change
      rot 1 + -rot 
    then

    \ setup for the next loop.  ( n3 badScore n2 n1 -- n3 n2 badScore )
    drop swap
    \ We processed the report, decrement the number of reports left to process
    -1 #reports +! 
  #reports @ 1 = until

  \ drop the last report and leave the badScore
  swap drop
;

( n1 n2 n3 ... -- flag )
: is-valid-bonus-report?
  2dup - report-direction !
  #reports @ 1- 0 do

  loop
;


\ Print a friendly message letting us know which data we're running
: .title ( c-addr u -- )
  cr cr ." Loading data from ./" type cr
;

: line>buf ( file-id -- flag c-addr u )
  buf MAX-LEN rot read-line throw
  buf rot
;

\ Day 2 Red-Nosed Reports
\ Returns the number of safe reports in the file.
( c-addr u -- n )
: main
  2dup .title
  \ Reset the valid reports counter
  0 #valid-reports !
  \ Open the file for reading and get the file-id
  r/o open-file throw
  { file-id }
  \ Loop over each line in the file.
  begin
    \ Read the next line from the file setup the stack to use the line
    file-id line>buf \ flag c-addr u2
    \ Check if the string is not empty
    dup 0<> if 
      \ Convert the string into a series of reports
      s>reports bad-score-report ( flag c-addr u2 -- flag badScore )
      dup ."  badScore: " . 
      tolerated-range @ <= if
        ."  safe" cr
        1 #valid-reports +!
      else
        ."  unsafe" cr
      then
    else
      2drop \ string was empty, so drop it leaving the flag.
    then
  0= until

  \ Close the file
  file-id close-file throw
  \ Return the number of valid reports
  #valid-reports @
;


\ Day 2 Bonus Problem
\ Returns the number of safe reports in the file.
( c-addr u -- n )
: bonus 
  \ 2dup .title
  \ 0 #valid-reports !
  \ r/o open-file throw
  \ { file-id }
  \ begin
  \   \ Read the next line from the file setup the stack to use the line
  \   file-id line>buf \ flag c-addr u2
  \   \ make sure the string is not empty
  \   dup 0<> if 
  \     \ Convert the string into a series of reports
  \     s>reports
  \     is-valid-bonus-report? if
  \       1 #valid-reports +!
  \     then
  \   then

  \   drop 0 \ DEBUG: drop the flag;
  \ 0= until
  \ \ Close the file and return the number of valid reports
  \ file-id close-file throw
  \ #valid-reports @
;


\ Runs the Exmaple Data
: run-example
  0 tolerated-range !
  s" example.txt" main
;
: run-example-bonus
  1 tolerated-range !
  s" example.txt" main
;

\ Runs the Input Data
: run-input
  0 tolerated-range !
  s" input.txt" main
;
: run-input-bonus
  1 tolerated-range !
  s" input.txt" main
;