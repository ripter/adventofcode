import std/os
import std/re
import std/sequtils
import std/strutils
import std/times

import ../day2/fileutils

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
  SeedRange = tuple[start: int, length: int]
  AlmanacRange = tuple[dest: int, src: int, length: int]
  AlmanacEntry = tuple[label: string,  ranges: seq[AlmanacRange]]
  Almanac = seq[AlmanacEntry]



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
      let args = line.findAll(patternNumbers).mapIt(parseInt(it))
      let range = (dest: args[0], src: args[1], length: args[2])
      entry.ranges.add(range)

  # Add the last entry after the loop
  if entry.label != "":
    output.add(entry)

  let endTime = cpuTime()
  echo endTime - startTime, " seconds.\tinitAlmanac()" 
  return output


proc isInRange(num: int, start: int, length: int): bool =
  ## Returns true when num in inside the range
  let max = start + length
  if (num >= start) and (num < max):
    return true

proc isInRange(num: int, range: AlmanacRange): bool =
  ## Shorthand when using the src from AlmanacRange
  isInRange(num, range.src, range.length)



#
# Converts num to a mapped id based on entry
proc toMappedId(num: int, entry: AlmanacEntry): int =
  var rangeIdx: int = -1

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




proc toSeedId(locationId: int, almanac: Almanac): int =
  var resultId: int = locationId
  ## Starting from the locationId, finds the matching seedId
  ## It does this by walking backward
  
  # Walk backwards, starting from location so we end up at seeds.
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



proc toLocationId(seedId: int, almanac: Almanac): int =
  ## Calculates the final ID by iterating through each AlmanacEntry in the provided Almanac.
  ## In each iteration, the current ID is transformed based on the AlmanacEntry using `toMappedId`.
  var resultId: int = seedId
  for entry in almanac:
    resultId = resultId.toMappedId(entry)

  return resultId



#
# Main
# 
let appStartTime = cpuTime()
let rawTextLines: seq[string] = readFileLines(filePath)
let startingSeedIds = rawTextLines[0].findAll(patternNumbers).map(parseInt)
let almanac = initAlmanac(rawTextLines[1..^1])




echo "\n--- Part One ---\n"
echo "startingSeedIds ", startingSeedIds
let partOneStartTime = cpuTime()
# echo "almanac ", almanac
echo "-"

var results: seq[int] = @[]
for seedId in startingSeedIds:
  var resultId: int = seedId.toLocationId(almanac)
  results.add(resultId)

echo "results: ", results
let partOneValue = results.min
echo "Answer ", partOneValue 

if USE_TEST_DATA and partOneValue == 35:
  echo "Success!"
elif partOneValue == 196167384:
  echo "Success!"

let partOneEndTime = cpuTime()
echo "Part One - Time taken: ", partOneEndTime - partOneStartTime, " seconds"



echo "\n--- Part Two ---\n"
let partTwoStartTime = cpuTime()
# grab two nums, convert to tuple, return as seq
var seedGroups: seq[SeedRange] = startingSeedIds.distribute(2).mapIt((it[0], it[1]))
echo "seedGroups ", seedGroups

var partTwoValue: int = -1
var partTwoLocationNum: int = 0
while partTwoLocationNum <= high(int):
  let seedId = partTwoLocationNum.toSeedId(almanac)
  if seedGroups.anyIt((seedId >= it.start) and (seedId < (it.start + it.length))):
    partTwoValue = partTwoLocationNum
    break;
  inc(partTwoLocationNum)
  


# for seedRange in seedGroups:
#   let maxSeedId: int = seedRange.start + (seedRange.length-1)
#   var seedid: int = seedRange.start
#   echo "Checking seedRange: ", seedRange

#   while seedId <= maxSeedId:
#     let locationId = seedId.toLocationId(almanac)
#     if (partTwoValue > locationId) or (partTwoValue == -1):
#       partTwoValue = locationId
#     inc(seedId)



echo "Answer ", partTwoValue 
if USE_TEST_DATA and partTwoValue == 46:
  echo "Success!"
else:
  if partTwoValue == 702443113:
    echo "Oops, Wrong Answer. Too high."
  else:
    echo "New Answer! Try it!"

let partTwoEndTime = cpuTime()
echo "Part Two - Time taken: ", partTwoEndTime - partTwoStartTime, " seconds"

let appEndTime = cpuTime()
echo "Total Time taken: ", appEndTime - appStartTime, " seconds"

echo "\n--- toSeedId ---\n"
echo 46, " <- ", toSeedId(46, almanac)
echo 47, " <- ", toSeedId(47, almanac)
echo "\n----------------\n"