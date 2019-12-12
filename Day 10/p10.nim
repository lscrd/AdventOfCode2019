import algorithm
import sets
import math
import strutils

type Coords = tuple[x, y: int]

## Add a vector to a position.
proc `+`(pos, v: Coords): Coords = (pos.x + v.x, pos.y + v.y)

## Substract two positions returning a vector.
proc `-`(a, b: Coords): Coords = (a.x - b.x, a.y - b.y)

## Divide a vector by a number.
proc `div`(v: Coords; b: int): Coords = (v.x div b, v.y div b)

# Build a set of asteroids coordinates.
let data = readFile("data").splitLines()
let XMAX = data[0].high
let YMAX = data.high
var asteroids: HashSet[Coords]
for y, line in data:
  for x, c in line:
    if c == '#':
      asteroids.incl((x, y))


######################################################################################
# Part 1

## Yield positions masked to asteroid at "pos1" by asteroid at "pos2".
iterator maskedPositions(pos1, pos2: Coords): Coords =
  var v = pos2 - pos1
  v = v div gcd(v.x, v.y)
  var pos = pos2 + v
  while pos.x in 0..XMAX and pos.y in 0..YMAX:
    yield pos
    pos = pos + v

var bestCount = 0
var bestPos: Coords
for pos1 in asteroids:
  # Build the list of asteroids visible from "pos1".
  var visibles = asteroids
  visibles.excl(pos1)
  for x in 0..XMAX:
    for y in 0..YMAX:
      let pos2 = (x, y)
      if pos2 in visibles:
        for pos in maskedPositions(pos1, pos2):
          visibles.excl(pos)
  # Keep the best result.
  if visibles.card > bestCount:
    bestCount = visibles.card
    bestPos = pos1

echo "Part 1: ", bestCount, " at ", bestPos


######################################################################################
# Part 2

const EPS = 1e-9    # Used for float equality test (actually not necessary).

type AnglePos = tuple[angle: float, pos: Coords]

let origin = bestPos

## Compute the angle of a vector.
## The angle is 0.0 for (0, -1), PI/2 for (1, 0), PI for (0, 1) and 3PI/2 for (-1, 0).
proc angle(v: Coords): float =
  result = PI / 2 + arctan2(v.y.toFloat, v.x.toFloat)
  if result < 0:
    result += 2 * PI

## Compute the distance between two positions.
## As this is used for asteroids in same direction, Manhattan distance is OK.
proc distance(pos1, pos2: Coords): int =
  abs(pos1.x - pos2.x) + abs(pos1.y - pos2.y)

## Compare two "AnglePos".
## Compare angles first and, for same angles, compare distances to origin.
proc cmp(a1, a2: AnglePos): int =
  if abs(a1.angle - a2.angle) <= EPS:
    result = cmp(distance(a1.pos, origin), distance(a2.pos, origin))
  else:
    result = cmp(a1.angle, a2.angle)

# Build a sorted list of (angle, pos), excluding the origin.
var angles: seq[tuple[angle: float, pos: Coords]]
for pos in asteroids:
  if pos != origin:
    angles.add((angle(pos - origin), pos))
angles.sort(cmp)

# Proceed to destruction of asteroids.
var n = 0
var result: int
var idx = 0
while angles.len > 0:
  inc n
  let (angle, pos) = angles[idx]
  # Compute result if needed.
  if n == 200:
    result = pos.x * 100 + pos.y
  # Destroy the asteroid.
  angles.delete(idx)  # Now "idx" points to next candidate.
  # Skip asteroids with same angle.
  while idx < angles.len and abs(angles[idx].angle - angle) <= EPS:
    inc idx
  if idx == angles.len:
    # Start a new round.
    idx = 0

echo "Part 2: ", result
