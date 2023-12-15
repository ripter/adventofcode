import std/os
import std/[sequtils, strutils]
import std/tables
import std/algorithm
import times

import ../day2/fileutils
import ../day5/formatutils


const USE_TEST_DATA = false
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
const cardValuesPartTwo = @['J', '2', '3', '4', '5', '6', '7', '8', '9', 'T', 'Q', 'K', 'A']


proc cmpHandType(a: Bet, b: Bet): int =
  ## Compare based on HandType
  let aRankValue = typeRanking.find(a.handType)
  let bRankValue = typeRanking.find(b.handType)
  return aRankValue - bRankValue

proc cmpCardFace(a: Bet, b: Bet): int =
  ## Compare based on Card Face value.
  ## Only sorts Bets with the same HandType
  if a.handType != b.handType:
    return 0

  for idx in (0..4):
    let aFaceValue = cardValues.find(a.hand[idx])
    let bFaceValue = cardValues.find(b.hand[idx])
    if aFaceValue != bFaceValue:
      return aFaceValue - bFaceValue

  return 0

proc cmpCardFaceWithJoker(a: Bet, b: Bet): int =
  ## Compare based on Card Face value.
  ## Only sorts Bets with the same HandType
  if a.handType != b.handType:
    return 0

  for idx in (0..4):
    let aFaceValue = cardValuesPartTwo.find(a.hand[idx])
    let bFaceValue = cardValuesPartTwo.find(b.hand[idx])
    if aFaceValue != bFaceValue:
      return aFaceValue - bFaceValue

  return 0

proc initHandType(hand: Hand, hasJokersWild: bool): HandType =
  ## Finds the HandType for the provided hand
  var letterFreq = toCountTable(hand)
  let jokerCount: int = letterFreq['J']

  # Check for the case of all wild cards.
  if hasJokersWild and jokerCount == 5:
    return htFive
  elif hasJokersWild:
    letterFreq.del('J')

  var largest = letterFreq.largest
  # Add wild cards to the count
  if hasJokersWild:
    inc(largest.val, jokerCount)
  
  # Do the easy checks first. We don't need to look at pairs or anything with these.
  if largest.val == 1:
    return htHighCard
  if largest.val == 5:
    return htFive
  if largest.val == 4:
    return htFour

  # count pairs for the rest of the checks.
  var pairCount: int = 0
  for key, val in letterFreq.pairs:
    if val == 2:
      inc(pairCount)

  if pairCount == 2:
    # Check if a wild can turn this into a full house
    if hasJokersWild:
      if jokerCount == 1:
        return htFullHouse

    return htTwo
  elif pairCount == 1:
    if largest.val == 3:
      return htFullHouse
    else:
      return htOne
  elif largest.val == 3:
    return htThree

  return htHighCard


proc loadBets(lines: seq[string], hasJokersWild: bool): seq[Bet] =
  # Loads the Bets from file contents
  var hands: seq[Bet] = @[]
  for line in lines:
    let pairs = line.split(' ')
    let bet = Bet(
      hand: pairs[0],
      amount: parseBiggestInt(pairs[1]),
      handType: initHandType(pairs[0], hasJokersWild),
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
var bets = loadBets(rawTextLines, false)
sort(bets, cmpHandType)
sort(bets, cmpCardFace)

var partOneValue: int64 = 0
for idx, bet in bets.pairs:
  inc(partOneValue, bet.amount * (idx+1))
  echo idx+1, " ", bet, " ", bet.amount * (idx+1), " new value: ", partOneValue

echo "Answer ", partOneValue
if USE_TEST_DATA and partOneValue == 6440:
  echo "Success!"
elif USE_TEST_DATA:
  echo "Uh oh! Something went wrong!"
elif partOneValue == 251106089:
  echo "Success!"
elif partOneValue == 251141154:
  echo "The Value is to high"
else:
  echo "Unknown value! Try it!"


echo "\n--- Part Two ---\n"
bets = loadBets(rawTextLines, true)
sort(bets, cmpHandType)
sort(bets, cmpCardFaceWithJoker)

var partTwoValue: int64 = 0
for idx, bet in bets.pairs:
  inc(partTwoValue, bet.amount * (idx+1))
  echo idx+1, " ", bet, " ", bet.amount * (idx+1), " new value: ", partTwoValue

echo "Answer ", partTwoValue

if USE_TEST_DATA and partTwoValue == 5905:
  echo "Success!"
elif USE_TEST_DATA:
  echo "Uh oh! Something went wrong!"
elif partTwoValue == 250588040:
  echo "Value is too high."
elif partTwoValue == 249802690:
  echo "Value is too high."
elif partTwoValue == 249840916:
  echo "Value is too high."
elif partTwoValue == 249427371:
  echo "Still Wrong"
else:
  echo "Unknown value! Try it!"



echo "\n--- DEBUG ---\n"
# echo initHandType("JJJJJ", false), " : Jack"
# echo initHandType("JJJJJ", true), " : Joker"
echo initHandType("33TTJ", true), " - 33TTJ - Should be a Full House"
echo initHandType("J3749", true), " - J3749 - Should be One Pair"



echo "\n----------------"
let appEndTime = cpuTime()
echo "Total Time taken: ", formatTime(int(appEndTime - appStartTime)), " seconds"