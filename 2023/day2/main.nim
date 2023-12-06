import std/os
import std/strbasics
import strutils
import sequtils
import re

import fileutils

const inputPath = "./input.txt"
echo "Advent Of Code 2023 - Day 2"

if not fileExists(inputPath):
  # Output an error message and exit the program
  stderr.writeLine("Error: input.txt file not found at: ", inputPath)
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
    redRange: minmax(hands.mapIt(it.red)),
    greenRange: minmax(hands.mapIt(it.green)),
    blueRange: minmax(hands.mapIt(it.blue)) 
    )
  return game



#
# Main
# 
let rawTextLines: seq[string] = readFileLines(inputPath)
let data = rawTextLines[0..1]
let games = data.map(lineToGame)

echo games