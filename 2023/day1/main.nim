import std/os
import std/json
import re, strutils
import strformat


const inputPath = "./input.json"

echo "Advent Of Code 2023 - Day 1"

if not fileExists(inputPath):
  # Output an error message and exit the program
  stderr.writeLine("Error: JSON file not found at: ", inputPath)
  quit()


# Finds and returns all the numbers in a given string as a sequence of integers.
# The function searches for all occurrences of numeric digits in the input string
# and converts each found number into an integer.
#
# Args:
#   inputStr: A string potentially containing numeric values.
#
# Returns:
#   A sequence of integers representing all the numbers found in the input string.
#   If no numbers are found, returns an empty sequence.
proc findNumbers(inputStr: string): seq[int] =
  let pattern = re"\d"
  let matches = findAll(inputStr, pattern)
  var numbers = newSeq[int](len(matches))
  for i, match in matches:
    numbers[i] = parseInt(match)

  return numbers


proc findCalibrationValue(numbers: seq[int]): int =
  let firstValue = numbers[0]
  let lastValue = numbers[len(numbers)-1]
  let calibrationValue = $firstValue & $lastValue
  return parseInt(calibrationValue)


let test_list = @[
  "1abc2",
  "pqr3stu8vwx",
  "a1b2c3d4e5f",
  "treb7uchet",
]

let jsonData = parseFile("./input.json")
# echo jsonData

var total = 0;
for str in jsonData:
  let numbers = findNumbers($str)
  let calibrationValue = findCalibrationValue(numbers)
  total += calibrationValue
  echo calibrationValue 

echo "Total Value: ", total

