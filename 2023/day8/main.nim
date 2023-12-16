import std/os
import std/strformat
import std/re
import times
import tables

import ../day2/fileutils
import ../day5/formatutils

const USE_TEST_DATA = true
const filePath = if USE_TEST_DATA: "./test.txt" else: "./input.txt"
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


proc walkMap(map: var NodeMap, startId: NodeID, nav: NavigationMap): NodeID =
  let endID = map.get(startId, nav[0])

  if nav.len > 1:
    return walkMap(map, endID, nav[1..len(nav)-1])

  return endID

#
# Main
# 
let appStartTime = cpuTime()
echo "\n--- Loading Data File ---\n"
let rawTextLines: seq[string] = readFileLines(filePath)
let navMap = rawTextLines[0]
var nodeMap = newTable[NodeID, NodePair]()

for line in rawTextLines[2..(len(rawTextLines)-1)]:
  var matches: array[3, string] 
  discard match(line, re"(\w\w\w) = \((\w\w\w), (\w\w\w)\)", matches)
  nodeMap[matches[0]] = (left: matches[1], right: matches[2])

echo &"Node Map: {nodeMap}"

echo "\n--- Part One ---\n"
echo &"Nav Map: {navMap}"

var optimizedNodeMap = newTable[NodeID, NodeID]()
for key, val in nodeMap.pairs:
  echo &"Key: {key}, Value: {val}"
  echo walkMap(nodeMap, "AAA", navMap)

#TODO: Load the raw map from file into a table[NodeID, NodePair]
#      Then create an optimized table[NodeID, NodeID]
#      Start at AAA, count the steps to ZZZ


echo "\n--- Part Two ---\n"


echo "\n----------------"
let appEndTime = cpuTime()
echo &"Total Time taken: {formatTime(int(appEndTime - appStartTime))} ({appEndTime - appStartTime} seconds)"