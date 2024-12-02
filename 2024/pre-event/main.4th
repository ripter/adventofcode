
s" Sup" 2constant SUP
s" Dawg" 2constant DAWG

\ Combines the lengths of two strings
: combined-string-lengths ( addr1 len1 addr2 len2 -- addr1 len1 addr2 len2 len3 )
  0 pick \ len2
  3 pick \ len1
  + \ len2 + len1
;

: combined-string ( addr1 len1 addr2 len2 -- addr3 len3 )
  \ Allocate space for the combined string
  combined-string-lengths   \ addr1 len1 addr2 len2 len3
  dup allocate throw        \ addr1 len1 addr2 len2 len3 addr3
  swap                      \ addr1 len1 addr2 len2 addr3 len3
  \ Save the new address and length
  >r >r                     \ addr1 len1 addr2 len2  --  R: len3 addr3  
  \ add4 is add3 + len1 so the copy will start at the end of the first string
  2 pick r> dup >r +        \ addr1 len1 addr2 len2 addr4  -- R: len3 addr3
  \ Copy the second string
  swap cmove                \ addr1 len1  -- R: len3 addr3
  \ Copy the first string
  r> dup >r                 \ addr1 len1 addr3  -- R: len3 addr3
  swap cmove                \ --  R: len3 addr3
  r> r>                     \ addr3 len3 
;

: concat-string ( addr1 len1 addr2 len2 -- addr3 len3 )
  { addr1 len1 addr2 len2 } 
  \ Allocate space for the combined string
  len1 len2 + allocate throw 
  { addr3 }
  \ Copy the first string
  addr1 addr3 len1 cmove
  \ Copy the second string
  addr2 addr3 len1 + len2 cmove
  \ Return the new string
  addr3 len1 len2 +
;

: print-file-contents ( addr len -- )
  r/o open-file throw   \ open file and get the file id 
  { file-id }
  1024 allocate throw  \ allocate a buffer
  { buffer }
  begin
    buffer 1024 file-id read-line throw    \ read the line into the buffer
    buffer 1024 type cr                   \ print the buffer
    buffer 1024 erase                     \ clear the buffer
    swap drop                             \ drop the number of bytes read
  dup 0= until                            \ until we reach the end of the file

  file-id close-file
;
