import std/os
import std/[sequtils, strutils]
import times
import re

import ../day2/fileutils
import ../day5/formatutils
import patterns

const USE_TEST_DATA = false
const filePath = if USE_TEST_DATA: "./test.txt" else: "./input.txt"
echo "Advent Of Code 2023 - Day 6"

if not fileExists(filePath):
  # Output an error message and exit the program
  stderr.writeLine("Error: input.txt file not found at: ", filePath)
  quit()


type
  Race = tuple[time: int64, distance: int64]


proc calcDistance(chargeTime: int, totalTime: int): int =
  ## Calculates the distance that would be traveled.
  if chargeTime == 0 or chargeTime == totalTime:
    return 0

  return chargeTime * (totalTime - chargeTime)


proc countWinCases(race: Race): int =
  var count: int = 0
  for chargeTime in (1..(race.time-1)):
    let distance = calcDistance(chargeTime, race.time)
    if distance > race.distance:
      inc(count)

  return count


proc initRaceList(lines: seq[string]): seq[Race] =
  ## Creates a Race list from a file.
  let textNums = lines.mapIt(it.findAll(patternNumbers))
  return zip(textNums[0], textNums[1]).mapIt((time: parseBiggestInt(it[0]), distance: parseBiggestInt(it[1])))

proc initRaceListPartTwo(lines: seq[string]): Race =
  let textNums = lines.mapIt(it.findAll(patternNumbers))
  let nums = textNums.mapIt(it.foldl(a & b)).mapIt(parseBiggestInt(it))
  return (time: nums[0], distance: nums[1])


#
# Main
# 
let appStartTime = cpuTime()

echo "\n--- Loading Data File ---\n"
let rawTextLines: seq[string] = readFileLines(filePath)
let raceList = initRaceList(rawTextLines)
let race2 = initRaceListPartTwo(rawTextLines)



echo "\n--- Part One ---\n"
echo "raceList ", raceList
var partOneValue: int64 = 1
for race in raceList:
  partOneValue = partOneValue * countWinCases(race) 

echo "partOneValue ", partOneValue
if USE_TEST_DATA and partOneValue == 288:
  echo "Success!"
if not USE_TEST_DATA and partOneValue == 4568778:
  echo "Success!"
else:
  echo "Unknown! Try it out!"



echo "\n--- Part Two ---\n"
echo "race: ", race2

let partTwoValue: int64 = countWinCases(race2)
echo "partTwoValue ", partTwoValue




echo "\n----------------"
let appEndTime = cpuTime()
echo "Total Time taken: ", formatTime(int(appEndTime - appStartTime)), " seconds"