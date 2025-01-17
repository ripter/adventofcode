variable shouldUseBonusRules    \ Flag to use the bonus rules

: main ( c-addr u -- )

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