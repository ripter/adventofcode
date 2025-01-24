\ Flag to use the bonus rules
variable shouldUseBonusRules
: should-use-bonus? ( -- flag ) shouldUseBonusRules @ ;
\ Default value
false shouldUseBonusRules !

\ 2D array to store the file contents
variable fileData
: alloc-array ( ud -- ) allocate throw fileData ! ;
: free-array ( -- ) fileData @ free throw ;

\ Holds the width of the 2D array
variable arrayWidth
: .width ( -- ) arrayWidth @ . ;
: width0 ( -- ) 0 arrayWidth ! ;
: width+1 ( -- ) 1 arrayWidth +! ;
: need-width? ( -- f ) arrayWidth @ 0= ;

: is-newline? ( c -- f ) 10 = ;

: file->array ( file-id -- )
  { fileID }
  free-array \ Free the array if it exists
  fileID file-size throw 
  .s cr
  alloc-array \ Allocate space to hold the entire file.
  begin
    pad 1 fileID read-file throw \ Read the char into PAD
  while
    pad @  ( char )
    dup emit \ Print the char

    \ If it's not a newline, increment the width
    \ if it is a newline, reset the width
    \ this works because there is no newline at the end of the file
    \ if there was, this would fail becuase the last line would have a width of 0
    dup is-newline? invert if
      width+1
    else
      width0
    then

  repeat
;



: main ( c-addr u -- )
  2dup cr ." Reading file " type cr
  ." Bonus is " should-use-bonus? if ." enabled" else ." disabled" then cr
  R/O open-file throw { fileID }
  \ 0 \ accumulator
  \ Read the file into the array
  fileID file->array 


  fileID close-file throw
  \ ." Total: " . cr
;


: enable-bonus ( -- )
  true shouldUseBonusRules !
;
: run-example ( -- )
  s" example.txt" main 
;
: run-input ( -- )
  s" input.txt" main
;