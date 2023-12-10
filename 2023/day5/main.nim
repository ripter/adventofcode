import std/os
import std/re
import std/sequtils
import std/tables
import std/strutils

import ../day2/fileutils

const DEBUG = true
const filePath = if DEBUG: "./test.txt" else: "./input.txt"
echo "Advent Of Code 2023 - Day 5"

if not fileExists(filePath):
  # Output an error message and exit the program
  stderr.writeLine("Error: input.txt file not found at: ", filePath)
  quit()

# const idxToCatgory = ["seed", "soil", "fertilizer", "water", "light", "temperature", "humidity", "location"]

#
# Regex Patterns
let patternMapLabel = re".* map:"
let patternNumbers = re"(\d+)"
let patternSpace = re" "


#
# Types!! Strict Types Yo! It's like, a mean dad or something.
type
  AlmanacRange = tuple[dest: int, src: int, length: int]
  AlmanacEntry = tuple[label: string,  ranges: seq[AlmanacRange]]
  Almanac = seq[AlmanacEntry]



#
# Load from the file
proc initAlmanac(lines: seq[string]): Almanac =
  var output: Almanac
  var entry: AlmanacEntry = (label: "", ranges: @[])

  for line in lines:
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

  return output


#
# Returns true when num is inside
proc isInRange(num: int, range: AlmanacRange): bool =
  let min = range.src
  let max = range.src + (range.length)
  if (num >= min) and (num < max):
    return true


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


#
# Main
# 
let rawTextLines: seq[string] = readFileLines(filePath)
let startingSeedIds = rawTextLines[0].findAll(patternNumbers).map(parseInt)
let almanac = initAlmanac(rawTextLines[1..^1])

echo "\n--- Part One ---\n"
echo "startingSeedIds ", startingSeedIds
# echo "almanac ", almanac
echo "-"

var results: seq[int] = @[]
for seedId in startingSeedIds:
  var resultId: int = seedId
  for entry in almanac:
    resultId = resultId.toMappedId(entry)
  results.add(resultId)

echo "results: ", results
let partOneValue = results.min
echo "Answer ", partOneValue 