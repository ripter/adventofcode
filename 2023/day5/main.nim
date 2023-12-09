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
proc addRange(table: var TableRef[int, int], destStart, sourceStart, rangeLength: int)  =
  let destRange = toSeq(countup(destStart, destStart+rangeLength-1))
  let srcRange = toSeq(countup(sourceStart, sourceStart+rangeLength-1))
  for (src, dest) in zip(srcRange, destRange):
    table[src] = dest





#
# initMaps loads a list of maps
let patternMapLabel = re"(\S+) map:"
let patternNumbers = re"(\d+)"
proc initMaps(lines: seq[string]): seq[TableRef[int, int]] =
  var output: seq[TableRef[int, int]]
  var table: TableRef[int, int]

  for line in lines:
    if "" == line:
      continue

    # When it's a label, move to the next map
    if line.match(patternMapLabel):
      table = newTable[int, int]()
      add(output, table)
    
    # When it's a set of numbers, add the range
    if line.match(patternNumbers):
      let args = line.findAll(patternNumbers).mapIt(parseInt(it))
      table.addRange(args[0], args[1], args[2])

  return output




#
# Main
# 
let rawTextLines: seq[string] = readFileLines(filePath)
let almanac = initMaps(rawTextLines[1..^1])
echo "almanac ", almanac.len, "\n", almanac

echo "\n--- Part One ---\n"


var partOneValue = 0
echo "Answer ", partOneValue 