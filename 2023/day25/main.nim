import std/os
import std/times
import std/strformat

import ../day2/fileutils
import ../day5/formatutils

const USE_TEST_DATA = false
const filePath = if USE_TEST_DATA: "test.txt" else: "input.txt"
echo "Advent Of Code 2023 - Day 25 - MERRY CHRISTMAS"

if not fileExists(filePath):
  # Output an error message and exit the program
  stderr.writeLine("Error: file not found at: ", filePath)
  quit()



let appStartTime = cpuTime()
echo "\n--- Loading Data File ---\n"
echo &"Load from file: \"{filePath}\""
let rawTextLines: seq[string] = readFileLines(filePath)


echo "\n--- Part One ---\n"


echo "\n--- Part One ---\n"



echo "\n----------------"
let appEndTime = cpuTime()
echo &"Total Time taken: {formatTime(int(appEndTime - appStartTime))} ({appEndTime - appStartTime} seconds)"