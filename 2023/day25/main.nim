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


proc disconnect(table: WireIdToSet, a, b: WireId) =
  var aSet = table[a]
  var bSet = table[b]
  aSet.excl(b)
  bSet.excl(a)
  table[a] = aSet
  table[b] = bSet

proc canMerge(a, b: WireIdsUnique): bool =
  ## Can the two groups be merged?
  ## If any wireId in a is in b, then they can be merged.
  for wireId in a:
    if wireId in b:
      return true

  return false


proc createGroups(table: WireIdToSet): WireGroupsConnected =
  ## Each key, value pair in the table is connected with wires.
  ## This will reduce the table to the smallest number of groups
  ## where each wireId is connected to every to another wireId in the group.
  for key, vals in table:
    # the key is wired to all the values.
    var group: WireIdsUnique = vals
    group.incl(key)
    for val in vals:
      group.incl(val)
    # echo &"group: {group}"
    result.add(group)

  echo &"result: {result}"
  var LIMIT = 20
  while len(result) > 2 and LIMIT > 0:
    let a: WireIdsUnique = result.pop()
    let b: WireIdsUnique = result.pop()
    let c: WireIdsUnique = result.pop()

    echo "\nmerging groups:"
    echo &"a: {a}"
    echo &"b: {b}"
    echo &"c: {c}"

    if canMerge(c, a):
      let group = a + c
      echo &"can merge a, c into: {group}"
      result.add(group)
      result.add(b)
    elif canMerge(c, b):
      let group = b + c
      echo &"can merge b, c into: {group}"
      result.add(group)
      result.add(a)


    dec(LIMIT)
    echo &"LIMIT: {LIMIT}"
  




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
for pair in pairSet:
  echo &"pair: {pair}"

var wireIds: HashSet[WireId] = initHashSet[WireId]()
loadWireIds(wireIds, wireMap)
echo &"\nNumber of unique wireIds: {wireIds.len}"
# for wireId in wireIds:
#   echo &"wireId: {wireId}"

echo "\nFilling in missing wireIds"
fillMissingMapValues(wireMap, wireIds, pairSet)
for wire in wireMap.keys:
  echo &"[{wire}]: {wireMap[wire]}"


echo "\nSnipping Connections"
wireMap.disconnect("hfx", "pzl")
wireMap.disconnect("bvb", "cmg")
wireMap.disconnect("nvd", "jqt")
for wire in wireMap.keys:
  echo &"wireMap[{wire}]: {wireMap[wire]}"



let groups = createGroups(wireMap)
echo &"\nNumber of groups: {groups.len}"
for idx, group in groups.pairs:
  echo &"group {idx}: {group.len} wires: {group}"



echo "\n--- Part Two ---\n"



echo "\n----------------"
let appEndTime = cpuTime()
echo &"Total Time taken: {formatTime(int(appEndTime - appStartTime))} ({appEndTime - appStartTime} seconds)"