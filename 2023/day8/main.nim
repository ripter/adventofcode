import std/os
import std/re
import std/strformat
import std/strutils
import std/sequtils
import std/sugar
import times
import tables

import ../day2/fileutils
import ../day5/formatutils

const USE_TEST_DATA = false
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
  MapStop = tuple[id: NodeId, count: int64, remainingNav: string]



proc get(map: NodeMap, key: NodeId, nav: char): NodeId =
  if nav == 'L':
    return map[key].left
  elif nav == 'R':
    return map[key].right


proc walkMap(map: var NodeMap, startId: NodeId, nav: NavigationMap, stepCount: int64): MapStop =
  ## Starting from startId, walks the map by following nav
  ## nav is a string of "L" and "R" meaning left and right.
  ## Also stops walking when finding a ZZZ nodeId
  if nav == "":
    return (startId, stepCount, "")

  let navHead = nav[0]
  let nextId = map.get(startId, navHead)

  # echo &"{startId} turned {navHead} resulted in {nextId} giving a total step count of {stepCount}"
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

  return ghosts.allIt(
    it.id.endsWith('Z') and 
    it.count == stepCount
  )

proc walkFullNav(map: var NodeMap, startId: NodeId, nav: NavigationMap, stepCount: int64): seq[Ghost] =
  ## Walks the NodeMap, following the NavigationMap until the end.
  ## When it reaches a NodeID that ends in 'Z', it logs it as a ghost.
  var pathWalked = walkMap(map, startId, nav, stepCount)

  # walk the entire nav, adding a node each time walkMap stops at a Z.
  while pathWalked.remainingNav != "":
    result.add((id: pathWalked[0], count: pathWalked[1]))
    pathWalked = walkMap(map, pathWalked[0], pathWalked[2], pathWalked[1]+1)

  # Add the last node found by walking the nav  
  result.add((id: pathWalked[0], count: pathWalked[1]))

  # If the last node is a Z, then we are done.
  let lastNode = result[len(result)-1]
  if lastNode.id.endsWith('Z'):
    return result

  # last node is not a Z, so walk the map again
  result.add(walkFullNav(map, lastNode.id, nav, lastNode.count+1))
  return result



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
    partOneValue += value[1]
    nodeId = value[0]

  echo "Answer ", partOneValue

else:
  echo "\n--- Part Two ---\n"
  let partTwoValue = -1

  # echo &"Node Map: {{keys[NodeId, NodePair](nodeMap)}}"
  echo &"Node Map: {{keys(nodeMap)}}"
  # Find all the nodes that end in A
  let startIds = toSeq(keys(nodeMap)).filterIt(it.endsWith('A'))
  echo &"Start Ids: {startIds}"

  var nodeStopMap = newTable[NodeId, seq[Ghost]]()
  for startId in startIds:
    let walkedPath = walkFullNav(nodeMap, startId, navMap, 1)
    nodeStopMap[startId] = walkedPath


  for stopIdx in 0..nodeStopMap[startIds[0]].len-1:
    var row = ""
    for key in startIds:
      let stop = nodeStopMap[key][stopIdx]
      row.add(&"{stop.count} {stop.id}  ")
    echo row

  # let nodeLength = nodeStopMap.len
  # var stepCount: int64 = nodeStopMap[startIds[0]][0].count
  # Log for debugging
  # for idx, stop in nodeStopMap[startIds[0]]:
    # echo &"  {idx} - {stop}"
  # for key, val in nodeStopMap.pairs:
  #   echo &"{key} - "
  #   for idx, stop in val:
  #     # let allMatch = nodeStopMap[key][idx].allIt(it == stepCount)
  #     echo &"  {idx} - {stop}"



  if partTwoValue == 269:
    echo "Too Low!"
  elif partTwoValue == 12643:
    echo "Too Low!"
  else:
    echo "Unknown value, try it out!"



echo "\n----------------"
let appEndTime = cpuTime()
echo &"Total Time taken: {formatTime(int(appEndTime - appStartTime))} ({appEndTime - appStartTime} seconds)"