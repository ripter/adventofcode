import std/sugar
import std/os
import std/re
import std/sequtils
import std/sets
import std/math

import ../day2/fileutils

const DEBUG = false
const filePath = if DEBUG: "./test.txt" else: "./input.txt"
echo "Advent Of Code 2023 - Day 4"

if not fileExists(filePath):
  # Output an error message and exit the program
  stderr.writeLine("Error: input.txt file not found at: ", filePath)
  quit()


type
  Card = object
    id: string
    winning: seq[string]
    scracted: seq[string]

#
# Creates a Card based on a string
proc initCard(line: string): Card =
  let patternNumber = re"(\d+)"
  let labelData = line.split(re":")
  let dataPair = labelData[1].split(re"\|")

  Card(
    id: labelData[0].findAll(patternNumber)[0],
    winning: dataPair[0].findAll(patternNumber),
    scracted: dataPair[1].findAll(patternNumber),
  )

#
# Returns a list of all items in a that also exist in b
proc matches(a: seq[string], b: seq[string]): seq[string] =
  let bSet = toHashSet(b)
  return a.filterIt(bSet.contains(it))


#
# get the power of 2 for n
proc powerOfTwo(n: int): int =
  return int(pow(2.0, float(n - 1)))

#
# Main
# 
let rawTextLines: seq[string] = readFileLines(filePath)

echo "\n--- Part One ---\n"

echo "total of empty ", powerOfTwo(len(@[]))

var total: int = 0
for line in rawTextLines:
  let card = initCard(line)
  let matchedNumbers: seq[string] = matches(card.scracted, card.winning)
  let score = powerOfTwo(matchedNumbers.len)
  total += score
  # echo card
  # echo "matches ", matchedNumbers
  echo card.id, " score ", score
  # echo ""

echo "Total Points: ", total

