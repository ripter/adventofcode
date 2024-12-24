

: main ( c-addr u -- )
  R/O open-file throw { fileID }
  
  begin
    \ Read the next char from the file
    pad 1 fileID read-file throw   ( flag c-addr u2 )
  while
    \ Print the char
    pad 1 type
  repeat

  fileID close-file throw
;

: run-example ( -- )
  s" example.txt" main 
;
: run-input ( -- )
  s" input.txt" main
;
