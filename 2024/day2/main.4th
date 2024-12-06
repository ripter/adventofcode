1024 constant MAX-LEN
create buf MAX-LEN 2 + allot

variable #reports
variable report-direction
variable #valid-reports

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
  2dup - report-direction !
  #reports @ 1- 0 do
    \ Get the difference between the two numbers
    2dup - 
    nip  \  drop the number we are comparing
    \ safe if between 1 and 3 inclusive
    dup abs 0 > swap  \ safe if greater than 0 
    dup abs 4 < swap  \ safe if less than 4
    -rot and      \ safe if both conditions are met
    0= if 
      \ not safe, so we can leave
      #reports @ i - 0 do drop loop
      false leave
    then

    \ Check the direction of the report    
    report-direction @ is-same-direction 0= if
      \ not safe, so we can leave
      i 0 do drop loop
      false leave
    then
  loop
;

\ Day 2 Red-Nosed Reports
\ Returns the number of safe reports in the file.
( c-addr u -- n )
: main
  \ Print a friendly message letting us know which data we're running
  2dup cr cr ." Loading data from ./" type cr
  \ Reset the valid reports counter
  0 #valid-reports !
  \ Open the file for reading and get the file-id
  r/o open-file throw
  { file-id }
  \ Loop over each line in the file.
  begin
    \ Read the next line from the file setup the stack to use the line
    buf MAX-LEN file-id read-line throw   \ u2 flag
    buf rot                              \ flag c-addr u2
    \ Check if the string is not empty
    dup 0<> if 
      \ Convert the string into a series of reports
      s>reports
      is-valid-report? if
        1 #valid-reports +!
      then
    else
      2drop
    then
  0= until

  \ Close the file
  file-id close-file throw
  \ Return the number of valid reports
  #valid-reports @
;

\ Runs the Exmaple Data
: run-example
  s" example.txt" main
;

\ Runs the Input Data
: run-input
  s" input.txt" main
;