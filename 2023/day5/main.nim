import std/sugar
import std/os
import std/re
import std/sequtils
import std/sets
import std/math
import std/tables
import std/strutils

import ../day2/fileutils

const DEBUG = true
const RUN_TEST = true
const filePath = if DEBUG: "./test.txt" else: "./input.txt"
echo "Advent Of Code 2023 - Day 5"

if not fileExists(filePath):
  # Output an error message and exit the program
  stderr.writeLine("Error: input.txt file not found at: ", filePath)
  quit()


#
# returns table value at key, or key if it does not exist in table.
proc getOrKey(table: Table[int, int], key: int): int =
  table.getOrDefault(key, key)

#
# Adds a range of mapping values to the table.
proc addRange(table: var Table[int, int], destStart, sourceStart, rangeLength: int)  =
  let destRange = toSeq(countup(destStart, destStart+rangeLength-1))
  let srcRange = toSeq(countup(sourceStart, sourceStart+rangeLength-1))
  for (src, dest) in zip(srcRange, destRange):
    table[src] = dest

#
# Test addRange with getOrKey
if RUN_TEST:
  var addRangeTestValue = initTable[int, int]()
  addRangeTestValue.addRange(50, 98, 2) 
  addRangeTestValue.addRange(52, 50, 48)
  assert addRangeTestValue.getOrKey(79) == 81
  assert addRangeTestValue.getOrKey(14) == 14
  assert addRangeTestValue.getOrKey(55) == 57 
  assert addRangeTestValue.getOrKey(13) == 13 






#
# Main
# 
let rawTextLines: seq[string] = readFileLines(filePath)
echo "\n--- Part One ---\n"

var output = initTable[int, int]()
output.addRange(50, 98, 2) 
output.addRange(52, 50, 48)
echo output.getOrDefault(79, 0)

var partOneValue = 0
echo "Answer ", partOneValue 