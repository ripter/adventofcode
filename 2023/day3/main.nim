import std/sugar
import std/os
import std/enumerate
# import std/strbasics
import strutils
import sequtils
import re

import ../day2/fileutils

const DEBUG = false
const filePath = if DEBUG: "./test.txt" else: "./input.txt"
echo "Advent Of Code 2023 - Day 3"

if not fileExists(filePath):
  # Output an error message and exit the program
  stderr.writeLine("Error: input.txt file not found at: ", filePath)
  quit()


type
  WalkDirection = enum
    wdLeft = -1
    wdRight = 1
  Grid = ref object
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


# Extract numers from the grid on the x-axis
proc extractNumbers(seqNumbers: var seq[string], grid: Grid, startIdx: int, direction: WalkDirection) =
  var (x, y) = startIdx.indexToPos(grid.width)
  var currentIndex: int = startIdx

  while true:
    # Bail when we move off the x-axis
    if (x < 0 or x > grid.width-1):
      break

    let cellValue = grid.cells[currentIndex]
    # echo "extract ", cellValue, " from idx ", currentIndex, " pos ", x, ",", y
    # Bail if the cell is not a number
    if not cellValue.isNumber:
      break

    if direction == wdLeft:
      seqNumbers.insert(cellValue, 0)
      x -= 1
    else:
      seqNumbers.add(cellValue)
      x += 1

    # Get the cell at index
    currentIndex = posToIndex((x, y), grid.width)


# If string at index isNumber, it will move left and right to get the full number and return it.
proc extractFullNumber(index: int, grid: Grid): int =
  let currentValue: string = grid.cells[index]
  # If the current value is not a number, bail.
  if not currentValue.isNumber:
    return 0

  var seqExtractedNumbers: seq[string] = @[]
  # Walk the x-axis getting any touching numbers.
  seqExtractedNumbers.extractNumbers(grid, index, wdLeft) # Walk Left
  seqExtractedNumbers.extractNumbers(grid, index+1, wdRight) # Walk Right
  # each cell is a digit in the number.
  return seqExtractedNumbers.foldl(a & b).parseInt


proc addTouchingNumbers(nums: var seq[int], symbolIndex: Natural, grid: Grid) =
  let neighbors = neighborsIndexes(symbolIndex, grid.width)

  # Test the top 3 cells.
  # If the center cell is a number, then we don't need to check the edges.
  if grid.cells[neighbors[1]].isNumber:
    nums.add(extractFullNumber(neighbors[1], grid))
  else:
    if grid.cells[neighbors[0]].isNumber:
      nums.add(extractFullNumber(neighbors[0], grid))
    if grid.cells[neighbors[2]].isNumber:
      nums.add(extractFullNumber(neighbors[2], grid))

  # Test Left and Right
  if grid.cells[neighbors[3]].isNumber:
    nums.add(extractFullNumber(neighbors[3], grid))
  if grid.cells[neighbors[4]].isNumber:
    nums.add(extractFullNumber(neighbors[4], grid))
  
  # Test the bottom 3 cells.
  # If the center cell is a number, then we don't need to check the edges.
  if grid.cells[neighbors[6]].isNumber:
    nums.add(extractFullNumber(neighbors[6], grid))
  else:
    if grid.cells[neighbors[5]].isNumber:
      nums.add(extractFullNumber(neighbors[5], grid))
    if grid.cells[neighbors[7]].isNumber:
      nums.add(extractFullNumber(neighbors[7], grid))
  # return nums



#
# Main
# 
let rawTextLines: seq[string] = readFileLines(filePath)
let data = loadData(rawTextLines)
# let data = rawTextLines

echo "\n--- Part One ---\n"

# echo "Debug"
# var test: seq[int] = @[]
# test.addTouchingNumbers(47, data)
# echo "test ", test
# echo "\n"

# echo findTouchingNumbers(43, data)

var seqNumbers: seq[int] = @[]
for idx, cell in enumerate(data.cells):
  if not cell.isSymbol:
    continue

  seqNumbers.addTouchingNumbers(idx, data)


echo "seqNumbers ", seqNumbers

let total = seqNumbers.foldl(a+b)
echo "sum: ", total
if total >= 526994:
  echo "Nope, that is not the right answer"
else:
  echo "Check that answer!"