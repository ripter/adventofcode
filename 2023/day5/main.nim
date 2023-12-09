import std/os
import std/re
import std/sequtils
import std/tables
import std/strutils

import ../day2/fileutils

const DEBUG = false
const filePath = if DEBUG: "./test.txt" else: "./input.txt"
echo "Advent Of Code 2023 - Day 5"

if not fileExists(filePath):
  # Output an error message and exit the program
  stderr.writeLine("Error: input.txt file not found at: ", filePath)
  quit()


type
  EntryMap = TableRef[int, int]
  Almanac = seq[EntryMap]
  Entry = object
    seed: int
    soil: int
    fertilizer: int
    water: int
    light: int
    temperature: int
    humidity: int
    location: int



#
# returns table value at key, or key if it does not exist in table.
proc getOrKey(table: EntryMap, key: int): int =
  table.getOrDefault(key, key)

#
# Adds a range of mapping values to the table.
proc addRange(table: var EntryMap, destStart, sourceStart, rangeLength: int)  =
  let destRange = toSeq(countup(destStart, destStart+rangeLength-1))
  let srcRange = toSeq(countup(sourceStart, sourceStart+rangeLength-1))
  for (src, dest) in zip(srcRange, destRange):
    table[src] = dest



# Pulls out the seed 

#
# initMaps loads a list of maps
let patternMapLabel = re"(\S+) map:"
let patternNumbers = re"(\d+)"
proc initMaps(lines: seq[string]): Almanac =
  var output: Almanac
  var table: TableRef[int, int]

  for line in lines:
    if "" == line:
      continue

    # When it's a label, move to the next map
    if line.match(patternMapLabel):
      table = newTable[int, int]()
      add(output, table)
      # echo line
    
    # When it's a set of numbers, add the range
    if line.match(patternNumbers):
      let args = line.findAll(patternNumbers).mapIt(parseInt(it))
      table.addRange(args[0], args[1], args[2])

  return output


const idxToKey = ["seed", "soil", "fertilizer", "water", "light", "temperature", "humidity", "location"]
proc initEntry(seedId: int, almanac: Almanac): seq[int] =
  var idList: seq[int] = @[seedId]
  var lastId = seedId
  for i in 0..(len(almanac)-1):
    lastId = almanac[i].getOrKey(lastId)
    idList.add(lastId)

  echo "idList ", idList, " zipped: ", zip(idxToKey, idList)
  return idList


#
# Main
# 
let rawTextLines: seq[string] = readFileLines(filePath)
let startingSeedIds = rawTextLines[0].findAll(patternNumbers).map(parseInt)
let almanac = initMaps(rawTextLines[1..^1])

echo "\n--- Part One ---\n"
echo "startingSeedIds ", startingSeedIds
echo "almanac ", almanac.len

let list = startingSeedIds.mapIt(initEntry(it, almanac))
# let one = initEntry(79, almanac)
# let two = initEntry(14, almanac)
# let list = @[one, two]

# Map to a list of location positions and then find the smallest one.
let locationPositions = list.mapIt(it[7])
let partOneValue = min(locationPositions)
echo "Answer ", partOneValue 