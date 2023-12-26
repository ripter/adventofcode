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
  WireID = string
  WirePairHash = string
  WirePair = tuple[a: WireID, b: WireID] 
  WirePairSet = HashSet[WirePairHash]
  WireMap = TableRef[WireID, seq[WireID]]


proc getKey(pair: WirePair): WirePairHash =
  let (a, b) = pair
  if a < b: return &"{a}-{b}"
  return &"{b}-{a}"



proc loadWirePairsFromFile(table: WireMap, lines: seq[string]) =  
  for line in lines:
    let linePair = line.split(":").mapIt(it.strip)
    let lineValues = linePair[1].split(" ").mapIt(it.strip).filterIt(it != "")
    table[linePair[0]] = lineValues
  

proc loadUniqueWirePairs(wirePairSet: var WirePairSet, table: WireMap) =
  for key, vals in table:
    for val in vals:
      wirePairSet.incl(getKey((key, val)))


proc loadWireIds(wireIds: var HashSet[WireID], table: WireMap) =
  for key, vals in table:
    wireIds.incl(key)
    for val in vals:
      wireIds.incl(val)


let appStartTime = cpuTime()
echo "\n--- Loading Data File ---\n"
echo &"Load from file: \"{filePath}\""
let rawTextLines: seq[string] = readFileLines(filePath)


echo "\n--- Part One ---\n"
var wireMap: WireMap = newTable[WireID, seq[WireID]]()
loadWirePairsFromFile(wireMap, rawTextLines)
for wire in wireMap.keys:
  echo &"wireMap[{wire}]: {wireMap[wire]}"

var pairSet: WirePairSet = initHashSet[WirePairHash]()
loadUniqueWirePairs(pairSet, wireMap)
echo &"\nNumber of unique wire pairs: {pairSet.len}"
for pair in pairSet:
  echo &"pair: {pair}"

var wireIds: HashSet[WireID] = initHashSet[WireID]()
loadWireIds(wireIds, wireMap)
echo &"\nNumber of unique wireIds: {wireIds.len}"
for wireId in wireIds:
  echo &"wireId: {wireId}"

echo "\n--- Part One ---\n"



echo "\n----------------"
let appEndTime = cpuTime()
echo &"Total Time taken: {formatTime(int(appEndTime - appStartTime))} ({appEndTime - appStartTime} seconds)"