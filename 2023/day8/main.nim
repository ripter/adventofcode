import std/os
import std/re
import std/strformat
import std/strutils
import std/sequtils
import std/sugar
import std/tasks
import times
import tables

import ../day2/fileutils
import ../day5/formatutils

const USE_TEST_DATA = true
const RUN_PART_ONE = false
const filePath = if not USE_TEST_DATA: "./input.txt" else:
  if RUN_PART_ONE: "test_part1.txt" else: "test_part2.txt"
echo "Advent Of Code 2023 - Day 8"

if not fileExists(filePath):
  # Output an error message and exit the program
  stderr.writeLine("Error: file not found at: ", filePath)
  quit()



type
  NavigationMap = string
  NodeId = string
  NodePair = tuple[left: NodeId, right: NodeId]
  NodeMap = TableRef[NodeId, NodePair]
  Ghost = tuple[id: NodeId, count: int64]


# proc endsWidth(nodeId: NodeId, suffix: char): bool =
#   let str: string = nodeId
#   str.endsWidth(suffix)


proc get(map: NodeMap, key: NodeId, nav: char): NodeId =
  if nav == 'L':
    return map[key].left
  elif nav == 'R':
    return map[key].right


proc walkMap(map: var NodeMap, startId: NodeId, nav: NavigationMap, stepCount: int64): (NodeId, int64, string) =
  ## Starting from startId, walks the map by following nav
  ## nav is a string of "L" and "R" meaning left and right.
  ## Also stops walking when finding a ZZZ nodeId
  if nav == "":
    return (startId, stepCount, "")

  let navHead = nav[0]
  let nextId = map.get(startId, navHead)


  # If this was the last item in the nav map
  if len(nav) == 1:
    return (nextId, stepCount, "")

  let navTail = nav[1..(len(nav)-1)]

  # Once we find the end, there is no need to continue walking.
  if nextId.endsWith('Z'):
    return (nextId, stepCount, navTail)

  # Try again with the tail
  return walkMap(map, nextId, navTail, stepCount+1)


proc atEnd(ghosts: seq[Ghost]): bool =
  ## All NodeIds end with Z and have the same step count
  let stepCount = ghosts[0].count
  if stepCount >= 7:
    return true

  return ghosts.allIt(
    it.id.endsWith('Z') and 
    it.count == stepCount
  )


proc ghostWalk(map: NodeMap, nav: NavigationMap): int64 =
  ## Performs a "Ghost" walk by starting at all the nodes that end with "A"
  ## and walking until all those ghosts land on a node that ends with "Z" at the same time.
  # var totalSteps: int64 = 0
  var ghosts: seq[Ghost] = collect:
    for nodeId in map.keys:
      if nodeId.endsWith('A'):
        (nodeId, int64(0))

  while not ghosts.atEnd():
    echo &"Taking {ghosts} out for a walk."
    for step in nav:
      ghosts = ghosts.map((ghost: Ghost) => (
        id: map.get(ghost.id, step), 
        count: ghost.count + 1)
      )

  return ghosts[0].count

#
# Main
# 
let appStartTime = cpuTime()
echo "\n--- Loading Data File ---\n"
echo &"Load from file: \"{filePath}\""
let rawTextLines: seq[string] = readFileLines(filePath)
let navMap = rawTextLines[0]
var nodeMap = newTable[NodeId, NodePair]()

for line in rawTextLines[2..(len(rawTextLines)-1)]:
  var matches: array[3, string] 
  discard match(line, re"(\w\w\w) = \((\w\w\w), (\w\w\w)\)", matches)
  nodeMap[matches[0]] = (left: matches[1], right: matches[2])

# echo &"Node Map: {nodeMap}"

if RUN_PART_ONE:
  echo "\n--- Part One ---\n"

  var optimizedNodeMap = newTable[NodeId, (NodeId, int64, string)]()
  for key, val in nodeMap.pairs:
    optimizedNodeMap[key] = walkMap(nodeMap, key, navMap, 1)

  var partOneValue: int64 = 0
  var nodeId: NodeId = "AAA"
  while nodeId != "ZZZ":
    let value = optimizedNodeMap[nodeId]
    inc(partOneValue, value[1])
    nodeId = value[0]

  echo "Answer ", partOneValue

else:
  echo "\n--- Part Two ---\n"

  let partTwoValue = ghostWalk(nodeMap, navMap)
  echo &"Answer: {partTwoValue}"



echo "\n----------------"
let appEndTime = cpuTime()
echo &"Total Time taken: {formatTime(int(appEndTime - appStartTime))} ({appEndTime - appStartTime} seconds)"