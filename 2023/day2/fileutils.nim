import streams

proc readFileLines*(filePath: string): seq[string] =
  let fileStream = newFileStream(filePath, fmRead)
  if fileStream == nil:
    raise newException(IOError, "Unable to open file: " & filePath)
  
  result = @[]
  for line in lines(fileStream):
    result.add(line)
  
  fileStream.close()
