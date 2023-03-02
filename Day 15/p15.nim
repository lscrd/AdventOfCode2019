import std/[sequtils, sets, strutils, tables]

import ../common/intcode

type
  # Direction type compatible with computer input.
  Direction {.pure.} = enum North = 1, South = 2, West = 3, East = 4
  # State type compatible with computer output. Also used for area description.
  State {.pure.} = enum Wall, Free, Oxygen, Unknown
  # Vector type used for coordinates and displacement.
  Vector = tuple[x, y: int]
  # Table describing the area. "Unknown" is the default value.
  Area = Table[Vector, State]
  # Couple (direction, position).
  DirPos = tuple[dir: Direction, pos: Vector]

const
  # Displacement to use to update position.
  Moves: array[Direction, Vector] = [(0, -1), (0, 1), (-1, 0), (1, 0)]
  # Character codes for drawing.
  Codes: array[State, char] = ['#', '.', 'O', '?']

proc `+`(a, b: Vector): Vector =
  ## Return the sum of two vectors.
  (a.x + b.x, a.y + b.y)

proc draw(area: Area; droidPos: Vector) {.used.} =
  ## Draw a map of the area.
  var xmin, ymin = 1000
  var xmax, ymax = -1000
  for pos in area.keys():
    xmin = min(xmin, pos.x)
    xmax = max(xmax, pos.x)
    ymin = min(ymin, pos.y)
    ymax = max(ymax, pos.y)
  var areaMap = newSeq[string](ymax - ymin + 1)
  for row in areaMap.mitems():
    row = Codes[Unknown].repeat(xmax - xmin + 1)
  for (pos, status) in area.pairs:
    areaMap[pos.y - ymin][pos.x - xmin] = if pos == droidPos: 'D' else: Codes[status]
  for row in areaMap:
    echo row


# Read map.
var area: Area
var oxygenPos: Vector
let data = readFile("p15.data").strip().split(',')
let program = map(data, parseInt)


### Part 1 ###

proc explore(area: var Area; program: seq[int]): Vector =
  ## Explore the area updating its description.

  var computer: Computer
  var pos: Vector = (0, 0)
  var history: CountTable[DirPos]   # History used to choose a direction, avoiding loop.

  proc chooseDirection(area: Area; pos: Vector): DirPos =
    ## Choose a direction to go.
    ## Return the direction and the resulting position.
    var mincount = 1000000
    for dir in North..East:
      let dest = pos + Moves[dir]
      let status = area.getOrDefault(dest, Unknown)
      if status == Unknown:
        # Found an unknow location. Choose it.
        return (dir, dest)
      if status != Wall:
        # Choose the direction less explored from this position.
        let count = history[(dir, pos)]
        if count < mincount:
          mincount = count
          result = (dir, dest)

  area[(0, 0)] = Free
  computer.init(program)
  computer.run()

  while true:
    let (dir, nextpos) = area.chooseDirection(pos)
    computer.giveInput(ord(dir))
    let answer = State computer.takeOutput()
    history.inc (dir, pos)
    if nextpos in area:
      # Already explored. Check consistency.
      if area[nextpos] != answer:
        echo "Inconsistency encountered at $1".format(nextpos)
        echo "Expected $1, got $1".format(area[nextpos], answer)
        quit QuitFailure
    else:
      # Update area.
      area[nextpos] = answer
    if answer != Wall:
      pos = nextpos
    if answer == Oxygen:
      return pos

proc minimalPathLen(area: Area; pos, target: Vector; visited: HashSet[Vector]): int =
  ## Compute the minimal path length from "pos" to "target".

  if pos == target: return 0

  # Update the set of visited positions.
  var visited = visited
  visited.incl pos

  # Try in each direction and keep the minimal length.
  result = 1000
  for dir in North..East:
    let nextpos = pos + Moves[dir]
    if area[nextpos] != Wall and nextpos notin visited:
      let length = area.minimalPathLen(nextpos, target, visited) + 1
      if length < result:
        result = length

## Explore the whole area, doing several rounds if needed.
while true:
  let exploredCount = area.len
  oxygenPos = area.explore(program)
  if area.len == exploredCount:
    break

echo "Part 1: ", area.minimalPathLen((0, 0), oxygenPos, initHashSet[Vector]())


### Part 2 ###

var lastPositions = @[oxygenPos]         # List of last positions filled with oxygen.
var filled = lastPositions.toHashSet     # Set of positions filled with oxygen.

var time = -1
while lastPositions.len != 0:
  inc time
  var newPositions: seq[Vector]   # New positions filled with oxygen.
  for pos in lastPositions:
    for dir in North..East:
      let newPos = pos + Moves[dir]
      if area[newpos] != Wall and newpos notin filled:
        filled.incl newpos
        newPositions.add newpos
  lastPositions = newPositions

echo "Part 2: ", time
