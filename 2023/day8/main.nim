import std/os
import std/strformat
import std/re
import times
import tables

import ../day2/fileutils
import ../day5/formatutils

const USE_TEST_DATA = true
const RUN_PART_ONE = false
const filePath = if not USE_TEST_DATA: "./input.txt" else:
  if RUN_PART_ONE: "test_day1.txt" else: "test_day2.txt"
echo "Advent Of Code 2023 - Day 8"

if not fileExists(filePath):
  # Output an error message and exit the program
  stderr.writeLine("Error: file not found at: ", filePath)
  quit()


#
# idea: Use the pattern as a token length. like LLR is 3
# For each starting point, find the end result after applying the full token.
# AAA = BBB, AAA, BBB
# BBB = AAA, BBB, ZZZ
# ZZZ = ZZZ, ZZZ, ZZZ
#

type
  NavigationMap = string
  NodeID = string
  NodePair = tuple[left: NodeID, right: NodeID]
  NodeMap = TableRef[NodeID, NodePair]

proc get(map: NodeMap, key: NodeID, nav: char): NodeID =
  if nav == 'L':
    return map[key].left
  elif nav == 'R':
    return map[key].right


proc walkMap(map: var NodeMap, startId: NodeID, nav: NavigationMap, stepCount: int64): (NodeID, int64) =
  ## Starting from startId, walks the map by following nav
  ## nav is a string of "L" and "R" meaning left and right.
  let navHead = nav[0]
  let nextId = map.get(startId, navHead)

  # If this was the last item in the nav map
  if len(nav) == 1:
    return (nextId, stepCount)

  # Once we find the end, there is no need to continue walking.
  if nextId == "ZZZ":
    return (nextId, stepCount)

  # Try again with the tail
  let navTail = nav[1..(len(nav)-1)]
  return walkMap(map, nextId, navTail, stepCount+1)


#
# Main
# 
let appStartTime = cpuTime()
echo "\n--- Loading Data File ---\n"
echo &"Load from file: \"{filePath}\""
let rawTextLines: seq[string] = readFileLines(filePath)
let navMap = rawTextLines[0]
var nodeMap = newTable[NodeID, NodePair]()

for line in rawTextLines[2..(len(rawTextLines)-1)]:
  var matches: array[3, string] 
  discard match(line, re"(\w\w\w) = \((\w\w\w), (\w\w\w)\)", matches)
  nodeMap[matches[0]] = (left: matches[1], right: matches[2])

# echo &"Node Map: {nodeMap}"

if RUN_PART_ONE:
  echo "\n--- Part One ---\n"

  var optimizedNodeMap = newTable[NodeID, (NodeID, int64)]()
  for key, val in nodeMap.pairs:
    optimizedNodeMap[key] = walkMap(nodeMap, key, navMap, 1)

  var partOneValue: int64 = 0
  var nodeId: NodeID = "AAA"
  while nodeId != "ZZZ":
    let value = optimizedNodeMap[nodeId]
    inc(partOneValue, value[1])
    nodeId = value[0]

  echo "Answer ", partOneValue

else:
  echo "\n--- Part Two ---\n"



echo "\n----------------"
let appEndTime = cpuTime()
echo &"Total Time taken: {formatTime(int(appEndTime - appStartTime))} ({appEndTime - appStartTime} seconds)"