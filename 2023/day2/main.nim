import std/sugar
import std/os
# import std/strbasics
import strutils
import sequtils
import re

import fileutils

const DEBUG = false
const filePath = if DEBUG: "./test.txt" else: "./input.txt"
echo "Advent Of Code 2023 - Day 2"

if not fileExists(filePath):
  # Output an error message and exit the program
  stderr.writeLine("Error: input.txt file not found at: ", filePath)
  quit()


type
  Hand = object
    red: int
    green: int
    blue: int
  Game = object
    id: int
    rounds: seq[Hand]
    redRange: (int, int)
    greenRange: (int, int)
    blueRange: (int, int)



# Convert a game string into a Game object.
proc lineToGame(line: string): Game =
  # Get the Game ID and all the rounds
  let reg = re"Game (\d+):(.*)"
  var matchOutput: array[2, string]
  discard match(line, reg, matchOutput)
  # Get the ID 
  let id = parseInt(matchOutput[0])

  # Convert the string of rounds seprated by ; into Hands
  var hands: seq[Hand] = @[]
  let rawRounds = split(matchOutput[1], re";")
  for round in rawRounds:
    # red green, blue in each round is seprated by ,
    let rawHands = split(round, re",")
    var hand = Hand()
    for rawHand in rawHands:
      # extract the number and label in the hand.
      var matchHand: array[2, string]
      discard match(rawHand.strip(), re"(\d+).*(red|green|blue)", matchHand)
      let value = parseInt(matchHand[0])
      if "red" == matchHand[1]:
        hand.red = value 
      if "green" == matchHand[1]:
        hand.green = value
      if "blue" == matchHand[1]:
        hand.blue = value

    hands.add(hand)

  # Create the Game
  let game = Game(
    id: id, 
    rounds: hands,
    redRange: minmax(hands.filterIt(it.red > 0).mapIt(it.red)),
    greenRange: minmax(hands.filterIt(it.green > 0).mapIt(it.green)),
    blueRange: minmax(hands.filterIt(it.blue > 0).mapIt(it.blue)) 
    )
  return game


# Returns true if the hand is possible in the current game.
proc isPossible(hand: Hand, game: Game): bool =
  return game.redRange[1] <= hand.red and
    game.greenRange[1] <= hand.green and
    game.blueRange[1] <= hand.blue


proc minHand(game: Game): Hand =
  return Hand(
    red: game.redRange[1],
    green: game.greenRange[1],
    blue: game.blueRange[1],
  )

proc power(hand: Hand): int =
  hand.red * hand.green * hand.blue

#
# Main
# 
let rawTextLines: seq[string] = readFileLines(filePath)
let data = rawTextLines
let games = data.map(lineToGame)

echo "\n--- Part One ---\n"
let possibleHand = Hand(red: 12, green: 13, blue: 14)
echo "Hand of ", possibleHand

let possibleGames = collect:
  for game in games:
    if isPossible(possibleHand, game):
      game

echo "Possible Games: ", possibleGames.mapIt(it.id)
echo "Total ", possibleGames.mapIt(it.id).foldl(a + b)

echo "\n--- Part Two ---\n"
var sumOfPower: int = 0
for game in games:
  let hand = game.minHand
  sumOfPower += hand.power
  # echo "Min Hand ", hand
  # echo "Power ", hand.power
echo "Sum of Power ", sumOfPower