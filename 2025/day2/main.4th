\ Create a buffer to hold each line we read from the file
\ I read that we should allocate 2 more bytes than the max line length
1024 constant MAX-LEN
create buf MAX-LEN 2 + allot
variable buf-length
0 buf-length !

create pattern MAX-LEN 2 + allot
variable pattern-length
0 pattern-length !

: reset-buf ( -- )
  buf MAX-LEN erase
  0 buf-length !
;
\ Get the buf and buf-length
: buf> ( -- addr u )
  buf buf-length @
;
\ Sets buf and buf-length
: >buf ( addr u -- )
  dup buf-length !
  buf swap move
;
\ Load buf with a number
: num>buf ( n -- )
  reset-buf
  s>d <# #s #>
  >buf
;
\ Convert the buffer back to a number
: buf>num
  buf> s>number throw
;


: reset-pattern ( -- )
  pattern MAX-LEN erase
  0 pattern-length !
;
\ Get Pattern & Length
: pattern> ( -- addr u )
  pattern pattern-length @
;
\ Set Pattern & Length
: >pattern ( addr u -- )
  dup pattern-length !
  pattern swap move
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

\ Debug helper
: print-ranges ( -- )
  s" Start: " type start-range @ .
  s" End: " type end-range @ .
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
  buf-length @ 1 - buf-length !
  buf>num
;



\ Returns true if the value in buf is made from a repeating pattern.
\ E.g. 11, 1010, 38593859, 1188511885
: is-repeating-pattern? ( -- flag )
  \ Cut the string in buf in half and repeat it.
  buf> 2 / dup -rot >pattern    \ Load the first half of the string into pattern.
  dup pattern swap chars +      \ Get address after the first half
  pattern swap rot move         \ Copy the same half after the first
  buf-length @ pattern-length ! \ Update pattern length
  buf> pattern> compare 0=
;


\ Process the file, return the result
: process-file ( fileid -- result fileid )
  0 swap  \ initialize result to 0
  BEGIN 
    append-next-from-file
  WHILE
    ends-with-dash? if
      get-range-number start-range !
      reset-buf
    then

    ends-with-comma if
      get-range-number end-range !
      reset-buf
    then

   has-range? if
      end-range @ 1 + start-range @ do
        i num>buf

        \ If we find a repeating number, add it to the result
        is-repeating-pattern? if
          swap buf>num + swap 
        then
      loop
      \ Reset the ranges and buffers for the next set
      reset-ranges
      reset-buf
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
