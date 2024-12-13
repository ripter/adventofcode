1024 constant MAX-LEN
create buf MAX-LEN 2 + allot

variable #reports
variable report-direction
variable #valid-reports
variable tolerated-range
variable drop-count

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
: s>reports ( c-ddr u -- n1 n2 n3 ... )
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

: mark-as-processed
  -1 #reports +! 
  #reports @ 1 = 
;

: get-direction ( n1 n2 -- flag )
  - 0 > if
    true
  else
    false
  then
;

: is-safe-change? ( n1 n2 -- n1 n2 flag )
  2dup - 
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
    \ Check that the reports are moving in the same direction  
    2dup get-direction report-direction @ invert = if
      \ ding 100 points for bad direction
      rot 100 + -rot 
    then

    \ Check if the level change is safe
    is-safe-change? invert if
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

: save-report-direction ( n1 n2 -- )
  get-direction report-direction ! 
;
: is-bad-direction? ( n1 n2 -- n1 n2 flag )
  2dup get-direction report-direction @ invert =
;

\ Bonus Problem allows removing one value if it makes the rest valid.
( n1 n2 n3 ... -- isValid )
: is-valid-bonus-report?
  0 drop-count ! \  defauled to false
  2dup save-report-direction \ save the direction of the report
  begin  
    \ 2dup swap cr ." Checking " . ."  " . cr
    is-bad-direction? if
      \ ."  bad direction " .s cr
      1 drop-count +! \ increment the drop count
      drop-count @ 1 = if
        \ ." dropping so we can try again " cr
        \ swap dup swap \ keep dummy value so we can drop it
        swap
        \ ." Post reorder for drop " .s cr
      then
    else
      is-safe-change? invert if
        \ ."  bad level change " .s cr
        1 drop-count +! \ increment the drop count
        drop-count @ 1 = if
          \ ." dropping so we can try again " cr
          \ ." PRE " .s cr
          \ swap dup swap \ keep dummy value so we can drop it
          swap
          \ ." POST " .s cr
        then
      then
    then

    drop \ finished with the report
    \ ." post finish " .s cr
  mark-as-processed until

  drop \ drop the last report
  drop-count @ 1 > if
    \ ."  FAILED " .s cr
    false
  else
    \ ."  PASSED " .s cr
    true
  then
  \ ." end of is-valid-bonus-report " .s cr
;





: verify-it
  depth #reports !
  ." Testing " .s cr
  is-valid-bonus-report? if
    ."  PASSED " .s cr
  else
    ."  FAILED " .s cr
  then
;






\ Print a friendly message letting us know which data we're running
: .title ( c-addr u -- )
  cr cr ." Loading data from ./" type cr
;
\ Read the line from the file into the buffer
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
      s>reports 
      is-valid-bonus-report? if
        1 #valid-reports +!
        ."  safe" cr
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




\
\ My 3rd attempt at the bonus problem
\
2variable array1
2variable array2

\ Sets a value at the index in the array
: a-set ( val idx 2var -- )
  { val idx var }
  val var @ idx cells + !
  \ TODO: add bounds checking
;
\ Gets a value from the index in the array
: a-get ( idx 2var -- val )
  { idx var }
  var @ idx cells + @
  \ TODO: add bounds checking
;
: a-len ( 2var -- len )
  2@ drop \ get both, drop the pointer leaving the length
;

\ loads len number of values from the stack into the array
: a-load-from-stack ( ... n1 len 2var -- )
  { len 2var1 }
  \ allocate len cells of memory for the array
  len cells allocate throw ( ... n1 addr )
  \ store the address and the length into the 2var
  \ then loop and fill the array from the stack.
  len swap 2var1 2!
  len 0 do
    i 2var1 a-set
  loop
;

: a-get-pair ( idx 2var -- n1 n2 )
  { idx 2var }
  idx 2var a-get
  idx 1+ 2var a-get
;

: a-is-valid-report ( 2var -- errorIndex | -1 )
  { 2var }
  2var a-len { len }
  -1 \ errorIndex default to -1
  \ save the direction of the report
  0 2var a-get-pair save-report-direction 
  len 1- 0 do \ ( -- )
    i 2var a-get-pair \ ( -- n1 n2 )
    2dup i cr ." Checking " . . . 
    is-safe-change? invert if
      cr ."  bad level change " cr
      2drop i leave \ drop the numbers and leave the index of the error
    then
    is-bad-direction? if
      cr ."  bad direction " cr
      2drop i leave \ drop the numbers and leave the index of the error
    then
    2drop \ drop the numbers, they are good
  loop
  \ clean-up return
  dup -1 <> if
    swap drop \ drop the -1 and leave the error index
  then
;

\ Bonus Problem allows removing one value if it makes the rest valid.
: a-is-valid-bonus-report ( 2var -- flag )
  { 2var }
  ." a-is-valid-bonus-report " cr
  
;

\ Returns the number of safe reports in the file.
( c-addr u -- n )
: bonus-attempt-3
  \ Reset the valid reports counter
  0 #valid-reports !
  \ Open the file for reading and get the file-id
  r/o open-file throw
  { file-id }
  
  begin
    file-id line>buf  ( flag c-addr u2 )
    dup 0<> if  \ Check if the string is not empty
      \ Convert the string into a series of reports
      \ Setting the #reports variable
      \ The reports are then pulled off the stack and stored in the array
      s>reports #reports @ array1 a-load-from-stack
      \ If the array holds a valid report, increment the #valid-reports
      array1 a-is-valid-bonus-report if
        1 #valid-reports +!
        ."  safe" cr
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




\
\
\ Runs the Exmaple Data
: run-example
  0 tolerated-range !
  s" example.txt" main
;
: run-example-bonus
  s" example.txt" bonus-attempt-3
  dup ." Safe Reports: " . cr
  4 = if
    ."  PASSED " cr
  else
    ."  FAILED " cr
  then
;

\ Runs the Input Data
: run-input
  0 tolerated-range !
  s" input.txt" main
;
: run-input-bonus
  s" input.txt" bonus-attempt-3
  ." Safe Reports: " . cr
;


: test
  56 59 60 61 62 65 69 7 array1 a-load-from-stack
;
: test2
  7 6 4 2 1 5 array1 a-load-from-stack
;