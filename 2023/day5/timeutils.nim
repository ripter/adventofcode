
proc formatTime*(totalSeconds: int): string =
  ## Formats seconds into a human friendly format.
  let
    hours = totalSeconds div 3600
    minutes = (totalSeconds mod 3600) div 60
    seconds = totalSeconds mod 60
  result = $hours & "h " & $minutes & "m " & $seconds & "s"