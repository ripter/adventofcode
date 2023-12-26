import std/os
import std/times
import std/[strformat, strutils]
import std/sequtils
import std/sets
import std/tables

import ../day2/fileutils
import ../day5/formatutils

const USE_TEST_DATA = true
const filePath = if USE_TEST_DATA: "test.txt" else: "input.txt"
echo "Advent Of Code 2023 - Day 25 - MERRY CHRISTMAS"

if not fileExists(filePath):
  # Output an error message and exit the program
  stderr.writeLine("Error: file not found at: ", filePath)
  quit()


type
  WireId = string
  WirePairHash = string
  WirePair = tuple[a: WireId, b: WireId] 
  WirePairSet = HashSet[WirePairHash]
  WireIdToSet = TableRef[WireId, HashSet[WireId]]


proc hash(pair: WirePair): WirePairHash =
  let (a, b) = pair
  if a < b: return &"{a}-{b}"
  return &"{b}-{a}"



proc loadWirePairsFromFile(table: WireIdToSet, lines: seq[string]) =  
  for line in lines:
    let linePair = line.split(":").mapIt(it.strip)
    let lineValues = linePair[1].split(" ").mapIt(it.strip).filterIt(it != "")
    table[linePair[0]] = toHashSet(lineValues)
  

proc loadUniqueWirePairs(wirePairSet: var WirePairSet, table: WireIdToSet) =
  for key, vals in table:
    for val in vals:
      wirePairSet.incl(hash((key, val)))
      if key == val:
        echo &"Duplicate key/val: {key} == {val}"


proc loadWireIds(wireIds: var HashSet[WireId], table: WireIdToSet) =
  for key, vals in table:
    wireIds.incl(key)
    for val in vals:
      wireIds.incl(val)


proc fillMissingMapValues(table: WireIdToSet, wireIds: HashSet[WireId], wirePairs: WirePairSet) =
  for wireA in wireIds:
    for wireB in wireIds:
      let wireHash = hash((wireA, wireB))
      if wireHash in wirePairs:
        var wireSet = table.getOrDefault(wireA, initHashSet[WireId]())
        wireSet.incl(wireB)
        table[wireA] = wireSet


proc createGroups(table: WireIdToSet): seq[HashSet[WireId]] =
  # var groups: seq[seq[WireId]] = @[]
  for key, vals in table:
    echo &"key: {key}"
    let existingGroups = result.filterIt(it.contains(key))
    if len(existingGroups) == 0:
      echo "New Group Needed"
      var newGroup: HashSet[string] = toHashSet([key])
      for valId in vals:
        newGroup.incl(valId)
      result.add(newGroup)
    elif len(existingGroups) == 1:
      echo "Add to existing group"
      # let group: seq[string] = existingGroups[0]
      # group.add(key)
    else:
      echo &"ERROR: Multiple groups found for key: {key}"

    # var foundGroup = false
    # for group in groups:
    #   if key in group:
    #     foundGroup = true
    #     for val in vals:
    #       if val notin group:
    #         group.add(val)
    
    # if not foundGroup:
    #   groups.add(@[key] & vals)


let appStartTime = cpuTime()
echo "\n--- Loading Data File ---\n"
echo &"Load from file: \"{filePath}\""
let rawTextLines: seq[string] = readFileLines(filePath)


echo "\n--- Part One ---\n"
var wireMap: WireIdToSet = newTable[WireId, initHashSet[WireId]()]()
loadWirePairsFromFile(wireMap, rawTextLines)
# for wire in wireMap.keys:
#   echo &"wireMap[{wire}]: {wireMap[wire]}"

var pairSet: WirePairSet = initHashSet[WirePairHash]()
loadUniqueWirePairs(pairSet, wireMap)
echo &"\nNumber of unique wire pairs: {pairSet.len}"
# for pair in pairSet:
#   echo &"pair: {pair}"

var wireIds: HashSet[WireId] = initHashSet[WireId]()
loadWireIds(wireIds, wireMap)
echo &"\nNumber of unique wireIds: {wireIds.len}"
# for wireId in wireIds:
#   echo &"wireId: {wireId}"

echo "\nFilling in missing wireIds"
fillMissingMapValues(wireMap, wireIds, pairSet)
for wire in wireMap.keys:
  echo &"[{wire}]: {wireMap[wire]}"


let groups = createGroups(wireMap)
echo &"\nNumber of groups: {groups.len}"
for group in groups:
  echo &"group: {group}"



echo "\n--- Part Two ---\n"



echo "\n----------------"
let appEndTime = cpuTime()
echo &"Total Time taken: {formatTime(int(appEndTime - appStartTime))} ({appEndTime - appStartTime} seconds)"