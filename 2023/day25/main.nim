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
  WireIdsUnique = HashSet[WireId]
  WirePairHash = string
  WirePair = tuple[a: WireId, b: WireId] 
  WirePairSet = HashSet[WirePairHash]
  WireIdToSet = TableRef[WireId, WireIdsUnique]
  WireGroupsConnected = seq[WireIdsUnique]


proc hash(pair: WirePair): WirePairHash =
  let (a, b) = pair
  if a < b: return &"{a}-{b}"
  return &"{b}-{a}"

proc unhash(hash: WirePairHash): WirePair =
  let parts = hash.split("-")
  return (parts[0], parts[1])



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


proc findEither(groups: WireGroupsConnected, wireA: WireId, wireB: WireId): WireIdsUnique =
  ## Find the group that contains either wireA or wireB
  for group in groups:
    if wireA in group or wireB in group:
      return group


proc createGroups(table: WireIdToSet, pairSet: WirePairSet): WireGroupsConnected =
  for pair in pairSet:
    let (a, b) = unhash(pair)
    echo &"\npair: {pair} -> {a}, {b}"

    var group = result.findEither(a, b)
    if len(group) == 0:
      group = initHashSet[WireId]()
      result.add(group)
    echo &"group ({group.len}): {group}"

    # Each wireId in the pair goes into the same group.
    group.incl(a)
    group.incl(b)
    echo &"result: {result}"





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


let groups = createGroups(wireMap, pairSet)
echo &"\nNumber of groups: {groups.len}"
for group in groups:
  echo &"group: {group}"



echo "\n--- Part Two ---\n"



echo "\n----------------"
let appEndTime = cpuTime()
echo &"Total Time taken: {formatTime(int(appEndTime - appStartTime))} ({appEndTime - appStartTime} seconds)"