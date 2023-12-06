import macros
import re 
import sequtils 
import std/json
import std/os
import strutils


const inputPath = "./input.json"

echo "Advent Of Code 2023 - Day 1"

if not fileExists(inputPath):
  # Output an error message and exit the program
  stderr.writeLine("Error: JSON file not found at: ", inputPath)
  quit()


# Pipe Operator, calls map(input, func)
macro `|>`(seqExpr, funcExpr: untyped): untyped =
  # Construct a call to the map function
  result = newCall(bindSym"map", seqExpr, funcExpr)


# Regex to replace number string with number value
proc convertNumberNames(inputStr: string): string =
  let replacements = [
    (re"oneight", "18"), (re"threeight", "38"), (re"fiveight", "58"), (re"nineight", "98"), 
    (re"twone", "21"), (re"sevenine", "79"), 
    (re"eightwo", "82"), (re"eighthree", "83"), 
    (re"one", "1"), (re"two", "2"), (re"three", "3"),
    (re"four", "4"), (re"five", "5"), (re"six", "6"),
    (re"seven", "7"), (re"eight", "8"), (re"nine", "9"),
  ]
  return multiReplace(inputStr, replacements)

# Regex to pull out number digits.
proc extractNumbers(inputStr: string): seq[int] =
  let pattern = re"\d"
  let matches = findAll(inputStr, pattern)
  var numbers = newSeq[int](len(matches))
  for i, match in matches:
    numbers[i] = parseInt(match)

  return numbers

# Creates the calibration value from a seq of numbers
proc findCalibrationValue(numbers: seq[int]): int =
  let firstValue = numbers[0]
  let lastValue = numbers[len(numbers)-1]
  let calibrationValue = $firstValue & $lastValue
  return parseInt(calibrationValue)


# let data = @[
  # "1abc2",
  # "pqr3stu8vwx",
  # "a1b2c3d4e5f",
  # "treb7uchet",
  # "two1nine",
  # "eightwothree",
  # "abcone2threexyz",
  # "xtwone3four",
  # "4nineeightseven2",
  # "zoneight234",
  # "7pqrstsixteen",
  # "nineeight4seight",
  # "abc2x3oneight",
  # "sevenine",
# ]


let jsonData = parseFile("./input.json")
var data: seq[string] = @[]
for str in jsonData:
  data.add(str.getStr())

var total = 0;
for str in data:
  let strWithNamesConverted = convertNumberNames(str)
  let extractedNumbers = extractNumbers(strWithNamesConverted) 
  let calibrationValue = findCalibrationValue(extractedNumbers)

  total += calibrationValue
  echo str, " ",  strWithNamesConverted, " ", calibrationValue

echo "Total Value: ", total

if total <= 54412:
  echo "Total is too low"
else:
  echo "Winner Winnder Chicken Dinner!"