import std/sugar
import std/os
# import std/strbasics
import strutils
import sequtils
import re

import ../day2/fileutils

const DEBUG = true
const filePath = if DEBUG: "./test.txt" else: "./input.txt"
echo "Advent Of Code 2023 - Day 3"

if not fileExists(filePath):
  # Output an error message and exit the program
  stderr.writeLine("Error: input.txt file not found at: ", filePath)
  quit()


type
  Grid = object
    width: int = 0
    height: int = 0
    cells: seq[string] = @[]
    

# Loads a seq of strings into a Grid
proc loadData(lines: seq[string]): Grid =
  let width = lines[0].len
  let height = lines.len
  var cells: seq[string] = @[]
  for line in lines:
    for cell in line:
      cells.add($cell)

  return Grid(width:width, height:height, cells:cells)


proc indexToPos(index, width: int): (int, int) =
  let
    x = index mod width  # Column
    y = index div width  # Row
  (x, y)

proc posToIndex(pos: (int, int), width: int): int =
  pos[1] * width + pos[0]

# Returns the index for the neighbor cells
proc neighborsIndexes(index: int, width: int): array[8, int] =
  # var result: array[8, int] = [-1, -1, -1, -1, -1, -1, -1, -1]
  var result: array[8, int]
  let pos = indexToPos(index, width)
  let
    dx = [-1, 0, 1, -1, 1, -1, 0, 1]
    dy = [-1, -1, -1, 0, 0, 1, 1, 1]
  for i in 0..<8:
    let
      nx = pos[0] + dx[i]
      ny = pos[1] + dy[i]
      deltaIdx = posToIndex((nx, ny), width)
    
    result[i] = deltaIdx

  return result

proc isEmpty(inputStr: string): bool =
  inputStr == "."

proc isNumber(inputStr: string): bool =
  let numberPattern = re"(\d)"
  match(inputStr, numberPattern)

proc isSymbol(inputStr: string): bool =
  not isEmpty(inputStr) and not isNumber(inputStr)


# If string at index isNumber, it will move left and right to get the full number and return it.
proc extractFullNumber(index: int, grid: Grid): int =
  let currentValue: string = grid.cells[index]
  var numStr: seq[string] = @[currentValue]
  var cellValue: string

  echo "currentValue ", currentValue, " from ", index, " creating ", numStr
  # If the current value is not a number, bail.
  if not currentValue.isNumber:
    return 420

  # Walk left, prepending each number
  var prevIndex: int = index - 1
  while true:
    # bail when we hit negatives
    if prevIndex < 0:
      break
    # Bail if the cell is not a number
    cellValue = grid.cells[prevIndex]
    if not cellValue.isNumber:
      break
    # preprend the cellValue
    numStr.insert(cellValue, 0)
    # subtract to move to the previous cell
    prevIndex -= 1

  echo "numStr ", numStr
  return parseInt foldl(numStr, a & b)

#
# Main
# 
let rawTextLines: seq[string] = readFileLines(filePath)
let data = loadData(rawTextLines)
# let data = rawTextLines

echo "\n--- Part One ---\n"
echo posToIndex((1, 1), data.width)
echo data
echo neighborsIndexes(11, data.width)

echo "extractFullNumber: ", extractFullNumber(1, data), " to be 467"

# for cell in data.cells:
#   echo cell, " isEmpty: ", isEmpty(cell), " isNumber: ", isNumber(cell), " isSymbol: ", isSymbol(cell)