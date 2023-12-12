import std/os
import std/re
import std/sequtils
import std/strutils
import std/times

import ../day2/fileutils
import formatutils

when compileOption("profiler"):
  import nimprof

const USE_TEST_DATA = true
const filePath = if USE_TEST_DATA: "./test.txt" else: "./input.txt"
echo "Advent Of Code 2023 - Day 5"

if not fileExists(filePath):
  # Output an error message and exit the program
  stderr.writeLine("Error: input.txt file not found at: ", filePath)
  quit()

#
# Regex Patterns
let patternMapLabel = re".* map:"
let patternNumbers = re"(\d+)"
let patternSpace = re" "


#
# Types!! Strict Types Yo! It's like, a mean dad or something.
type
  SeedRange = tuple[start: int64, length: int64]
  SeedList = seq[SeedRange]
  AlmanacRange = tuple[dest: int64, src: int64, length: int64]
  AlmanacEntry = tuple[label: string,  ranges: seq[AlmanacRange]]
  Almanac = seq[AlmanacEntry]



proc initSeedRange(inputStr: string): SeedRange =
  ## Creates a SeedRange from a number string
  let nums = inputStr.findAll(patternNumbers).map(parseBiggestInt)
  return (start: nums[0], length: nums[1])


proc initSeedList(inputStr: string): SeedList =
  let rawSeedNumbers = inputStr.findAll(patternNumbers).map(parseBiggestInt)
  var seedList: SeedList = @[]
  var i = 0
  while (i < len(rawSeedNumbers)):
    add(seedList, (start: rawSeedNumbers[i], length: rawSeedNumbers[i+1]))
    inc(i, 2)

  return seedList


#
# Load from the file
proc initAlmanac(lines: seq[string]): Almanac =
  let startTime = cpuTime()
  ## Converts the lines from the file into an Almanac
  var output: Almanac
  var entry: AlmanacEntry = (label: "", ranges: @[])

  for line in lines:
    # Skip Empty Lines
    if line == "":
      continue

    # When it's a label, finalize the previous entry and start a new one
    if line.match(patternMapLabel):
      if entry.label != "":
        output.add(entry)  # Add the completed entry to output
      let label = line.split(patternSpace)[0]
      entry = (label: label, ranges: @[])  # Start a new entry

    # When it's a set of numbers, add the range
    elif line.match(patternNumbers):
      let args = line.findAll(patternNumbers).mapIt(parseBiggestInt(it))
      let range = (dest: args[0], src: args[1], length: args[2])
      entry.ranges.add(range)

  # Add the last entry after the loop
  if entry.label != "":
    output.add(entry)

  let endTime = cpuTime()
  echo endTime - startTime, " seconds.\tinitAlmanac()" 
  return output


proc isInRange(num: int64, start: int64, length: int64): bool =
  ## Returns true when num in inside the range
  let max = start + length
  if (num >= start) and (num < max):
    return true

proc isInRange(num: int64, range: AlmanacRange): bool =
  ## Shorthand when using the src from AlmanacRange
  isInRange(num, range.src, range.length)

proc isInRange(num: int64, range: SeedRange): bool =
  isInRange(num, range.start, range.length)



#
# Converts num to a mapped id based on entry
proc toMappedId(num: int64, entry: AlmanacEntry): int64 =
  var rangeIdx: int64 = -1

  # Find the first range than contains num
  for idx, range in entry.ranges:
    if num.isInRange(range):
      rangeIdx = idx 
      break

  let isInNumInRange = rangeIdx != -1

  if not isInNumInRange:
    # Not in any range. num maps to num.
    return num

  # num is in range, convert the value
  let mapRange = entry.ranges[rangeIdx]
  let offset = num - mapRange.src

  return mapRange.dest + offset




proc toSeedId(locationId: int64, almanac: Almanac): int64 =
  var resultId: int64 = locationId
  ## Starting from the locationId, finds the matching seedId
  ## It does this by walking backward
  var entryIdx = almanac.len - 1
  while entryIdx >= 0:
    let entry = almanac[entryIdx]
    for range in entry.ranges:
      if isInRange(resultId, range.dest, range.length):
        let offset = resultId - range.dest
        resultId = range.src + offset
        break
    dec(entryIdx)

  return resultId



proc toLocationId(seedId: int64, almanac: Almanac): int64 =
  ## Calculates the final ID by iterating through each AlmanacEntry in the provided Almanac.
  ## In each iteration, the current ID is transformed based on the AlmanacEntry using `toMappedId`.
  var resultId: int64 = seedId
  for entry in almanac:
    resultId = resultId.toMappedId(entry)

  return resultId



#
# Main
# 
let appStartTime = cpuTime()
let rawTextLines: seq[string] = readFileLines(filePath)
let startingSeedIds: seq[int64] = rawTextLines[0].findAll(patternNumbers).map(parseBiggestInt)
let almanac = initAlmanac(rawTextLines[1..^1])
let seedGroup: SeedList = initSeedList(rawTextLines[0])




echo "\n--- Part One ---\n"
echo "startingSeedIds ", startingSeedIds
let partOneStartTime = cpuTime()
# echo "almanac ", almanac
echo "-"

var results: seq[int64] = @[]
for seedId in startingSeedIds:
  var resultId: int64 = seedId.toLocationId(almanac)
  results.add(resultId)

echo "results: ", results
let partOneValue = results.min
echo "Answer ", partOneValue 

if USE_TEST_DATA and partOneValue == 35:
  echo "Success!"
elif partOneValue == 196167384:
  echo "Success!"

let partOneEndTime = cpuTime()
echo "Part One - Time taken: ", formatTime(int(partOneEndTime - partOneStartTime)), " seconds"



echo "\n--- Part Two ---\n"
let partTwoStartTime = cpuTime()
echo "seedGroup ", seedGroup

var partTwoLocationId: int64 = 0
while partTwoLocationId <= high(int64):
  let seedId = partTwoLocationId.toSeedId(almanac)
  if seedGroup.anyIt(isInRange(seedId, it)):
    # We found it! Exit out
    echo "Found It! ", seedId, " is in SeedGroup ", seedGroup.filterIt(isInRange(seedId, it))
    break;
  else:
    inc(partTwoLocationId)
  

echo "Answer ", partTwoLocationId 
if USE_TEST_DATA and partTwoLocationId == 46:
  echo "Success!"
else:
  if partTwoLocationId == 702443113:
    echo "Oops, Wrong Answer. Too high."
  else:
    echo "New Answer! Try it!"

let partTwoEndTime = cpuTime()
echo "Part Two - Time taken: ", formatTime(int(partTwoEndTime - partTwoStartTime)), " seconds"

let appEndTime = cpuTime()
echo "Total Time taken: ", formatTime(int(appEndTime - appStartTime)), " seconds"



# echo "\n--- Debuging ---\n"
# const seedLine = "seeds: 950527520 85181200 546703948 123777711 63627802 279111951 1141059215 246466925 1655973293 98210926 3948361820 92804510 2424412143 247735408 4140139679 82572647 2009732824 325159757 3575518161 370114248"
# let groupList = initSeedList(seedLine)
# echo "groupList ", groupList