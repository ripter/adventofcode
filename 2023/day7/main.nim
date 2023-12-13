import std/os
import std/[sequtils, strutils]
import std/tables
import std/algorithm
import times

import ../day2/fileutils
import ../day5/formatutils
import ../day6/patterns


const USE_TEST_DATA = true
const filePath = if USE_TEST_DATA: "./test.txt" else: "./input.txt"
echo "Advent Of Code 2023 - Day 7"

if not fileExists(filePath):
  # Output an error message and exit the program
  stderr.writeLine("Error: input.txt file not found at: ", filePath)
  quit()


type
  HandType = enum
    htFive = "Five of a Kind"
    htFour = "Four of a Kind"
    htThree = "Three of a Kind"
    htTwo = "Two Pair"
    htOne = "One Pair"
    htFullHouse = "Full House"
    htHighCard = "High Card"
  Hand = string
  Bet = object
    hand: Hand
    amount: int64
    handType: HandType

# Using index to create a ranking score.
const cardValues = @['2', '3', '4', '5', '6', '7', '8', '9', 'T', 'J', 'Q', 'K', 'A']
const typeRanking = @[htHighCard, htOne, htTwo, htThree, htFullHouse, htFour, htFive]


proc cmpHandType(a: Bet, b: Bet): int =
  ## Compare based on HandType
  let aRankValue = typeRanking.find(a.handType)
  let bRankValue = typeRanking.find(b.handType)
  return bRankValue - aRankValue

proc cmpCardFace(a: Bet, b: Bet): int =
  ## Compare based on Card Face value.
  ## Only sorts Bets with the same HandType
  if a.handType != b.handType:
    return 0

  for idx in (0..4):
    let aFaceValue = cardValues.find(a.hand[idx])
    let bFaceValue = cardValues.find(b.hand[idx])
    if aFaceValue != bFaceValue:
      return bFaceValue - aFaceValue

  return 0

proc initHandType(hand: Hand): HandType =
  ## Finds the HandType for the provided hand
  let letterFreq = toCountTable(hand)
  # Do the easy checks first. We don't need to look at pairs or anything with these.
  let largest = letterFreq.largest
  if largest.val == 1:
    return htHighCard
  if largest.val == 5:
    return htFive
  if largest.val == 4:
    return htFour
  if largest.val == 3:
    return htThree

  # count pairs for the rest of the checks.
  var pairCount: int = 0
  var threeCount: int = 0
  for key, val in letterFreq.pairs:
    if val == 3:
      inc(threeCount)
    elif val == 2:
      inc(pairCount)

  if threeCount == 1 and pairCount == 1:
    return htFullHouse
  elif pairCount == 2:
    return htTwo
  elif pairCount == 1:
    return htOne

  echo "largest ", largest
  return htHighCard


proc loadBets(lines: seq[string]): seq[Bet] =
  # Loads the Bets from file contents
  var hands: seq[Bet] = @[]
  for line in lines:
    let pairs = line.split(' ')
    let bet = Bet(
      hand: pairs[0],
      amount: parseBiggestInt(pairs[1]),
      handType: initHandType(pairs[0]),
    )
    hands.add(bet)

  return hands



#
# Main
# 
let appStartTime = cpuTime()
echo "\n--- Loading Data File ---\n"
let rawTextLines: seq[string] = readFileLines(filePath)
echo "rawTextLines ", rawTextLines

echo "\n--- Part One ---\n"
var bets = loadBets(rawTextLines)
echo "Bets ", bets

sort(bets, cmpHandType)
sort(bets, cmpCardFace)
echo "\nSorted "
for bet in bets:
  echo bet




echo "\n----------------"
let appEndTime = cpuTime()
echo "Total Time taken: ", formatTime(int(appEndTime - appStartTime)), " seconds"