import std/sugar
import std/os
import std/re
import std/sequtils
import std/sets
import std/math
import std/tables
import std/strutils

import ../day2/fileutils

const DEBUG = false
const filePath = if DEBUG: "./test.txt" else: "./input.txt"
echo "Advent Of Code 2023 - Day 4"

if not fileExists(filePath):
  # Output an error message and exit the program
  stderr.writeLine("Error: input.txt file not found at: ", filePath)
  quit()


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
#
type
  Card = object
    id: int
    winning: seq[string]
    scratched: seq[string]
    totalMatched: int
    score: int

#
# Creates a Card based on a string
proc initCard(line: string): Card =
  let patternNumber = re"(\d+)"
  let labelData = line.split(re":")
  let dataPair = labelData[1].split(re"\|")
  let winning = dataPair[0].findAll(patternNumber)
  let scratched = dataPair[1].findAll(patternNumber)
  let matchedNumbers: seq[string] = matches(scratched, winning)
  let score = powerOfTwo(matchedNumbers.len)


  Card(
    id: labelData[0].findAll(patternNumber)[0].parseInt,
    winning: winning,
    scratched: scratched,
    score: score,
    totalMatched: matchedNumbers.len,
  )


#
# Main
# 
let rawTextLines: seq[string] = readFileLines(filePath)
let cards = mapIt(rawTextLines, initCard(it))

echo "\n--- Part One ---\n"
# Get the Total by getting the score from each card and summing them.
let partOneTotal = cards.mapIt(it.score).foldl(a + b)
echo "Total Points: ", partOneTotal
if partOneTotal == 21105 and not DEBUG:
  echo "Part 1 Success!"


echo "\n--- Part Two ---\n"

# Create a table to map card to rewards
# This will allow us to cache the cards to add instead of having to calculate it each time.
var rewardTable = initTable[int, seq[int]]()
for card in cards:
  let rewardValue = toSeq(countup(card.id+1, card.id + card.totalMatched))
  rewardTable[card.id] = rewardValue


var queue: seq[int] = cards.mapIt(it.id)
var partTwoTotal = len(queue)

while len(queue) > 0:
  let id = pop(queue)
  let rewards = rewardTable[id]
  # Add each card to the total.
  inc(partTwoTotal, len(rewards))
  # Add the reward cards to the queue for a future loop.
  add(queue, rewards)
  # echo "Pop ", id, " rewards ", rewards

echo "partTwoTotal ", partTwoTotal