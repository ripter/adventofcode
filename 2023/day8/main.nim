import std/os
import std/strformat
import times

import ../day2/fileutils
import ../day5/formatutils

const USE_TEST_DATA = true
const filePath = if USE_TEST_DATA: "./test.txt" else: "./input.txt"
echo "Advent Of Code 2023 - Day 8"

if not fileExists(filePath):
  # Output an error message and exit the program
  stderr.writeLine("Error: file not found at: ", filePath)
  quit()


#
# idea: Use the pattern as a token length. like LLR is 3
# For each starting point, find the end result after applying the full token.
# AAA = BBB, AAA, BBB
# BBB = AAA, BBB, ZZZ
# ZZZ = ZZZ, ZZZ, ZZZ
#


#
# Main
# 
let appStartTime = cpuTime()
echo "\n--- Loading Data File ---\n"
let rawTextLines: seq[string] = readFileLines(filePath)

echo "\n--- Part One ---\n"


echo "\n--- Part Two ---\n"


echo "\n----------------"
let appEndTime = cpuTime()
echo &"Total Time taken: {formatTime(int(appEndTime - appStartTime))} ({appEndTime - appStartTime} seconds)"