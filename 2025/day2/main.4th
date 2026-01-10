\ Create a buffer hold each line
\ Spec says we need to allocate 2 more bytes than the max line length
1024 constant MAX-LEN
create buf MAX-LEN 2 + allot

\ Process the file.
: process-file ( fileid -- value fileid )
   0 swap
  s" Do The thing" type cr
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
