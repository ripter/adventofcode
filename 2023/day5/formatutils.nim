
proc formatTime*(totalSeconds: int): string =
  ## Formats seconds into a human friendly format.
  let
    hours = totalSeconds div 3600
    minutes = (totalSeconds mod 3600) div 60
    seconds = totalSeconds mod 60
  result = $hours & "h " & $minutes & "m " & $seconds & "s"

proc formatNumberHuman*(n: int64): string =
  let
    numStr = $n
    len = numStr.len
  # var result = ""
  for i in 0..<len:
    if i > 0 and (len - i) mod 3 == 0:
      result.add(',')
    result.add(numStr[i])
  result