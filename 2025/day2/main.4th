\ Create a buffer hold each line
\ Spec says we need to allocate 2 more bytes than the max line length
1024 constant MAX-LEN
create buf MAX-LEN 2 + allot
variable buf-length
0 buf-length !
\ Variables to hold the start and ending ranges
variable start-range
variable end-range

\ Append the next character from the file to the buffer
: append-next-from-file ( fileid -- fileid char-read )
  dup                 \ dup the fileid so we can return it
  buf buf-length @ +  \ calculate the address to append the character
  1 rot               \ read one character and rotate everything into position.
  read-file throw      \ Read a single character from the file
  dup buf-length @ + buf-length !  \ Update buf-length with the number of characters read
;

\ Process the file.
: process-file ( fileid -- value fileid )
  0 swap  ( fileid -- value fileid )  
  BEGIN 
    append-next-from-file
  WHILE
    s" Processing line: " type buf buf-length @ type cr
    \ .s cr
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
