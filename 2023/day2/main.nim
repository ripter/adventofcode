import sequtils, macros
import re
import strutils
import std/json

# Pipe Operator, calls map(input, func)
macro `|>`(seqExpr, funcExpr: untyped): untyped =
  # Construct a call to the map function
  result = newCall(bindSym"map", seqExpr, funcExpr)


# Regex to replace number string with number value
proc convertNumberNames(inputStr: string): string =
  let replacements = [
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
#   "two1nine",
#   "eightwothree",
#   "abcone2threexyz",
#   "xtwone3four",
#   "4nineeightseven2",
#   "zoneight234",
#   "7pqrstsixteen",
# ]
let data = parseFile("./input.json")

# echo map(data.toSeq(), (a: int): int -> a * 2)
echo data.map((a: int): int => a * 2)
# var total = 0;
# let result = data |> 
#   convertNumberNames |>
#   extractNumbers |>
#   findCalibrationValue 

# echo "Total:", foldl(result, a + b)

# let numbers = @[1, 2, 3, 4]
# let addOne = proc(x: int): int = x + 1
# let square = proc(x: int): int = x * x
# let result = numbers |> addOne |> square
# # let result = map(numbers, addOne)
# echo result
# # result is @[4, 9, 16, 25]