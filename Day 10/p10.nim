import std/[math, algorithm, sets, strutils]

type Coords = tuple[x, y: int]

proc `+`(pos, v: Coords): Coords =
  ## Add a vector to a position.
  (pos.x + v.x, pos.y + v.y)

proc `-`(a, b: Coords): Coords =
  ## Substract two positions returning a vector.
  (a.x - b.x, a.y - b.y)

proc `div`(v: Coords; b: int): Coords =
  ## Divide a vector by a number.
  (v.x div b, v.y div b)

# Build a set of asteroids coordinates.
let data = readFile("p10.data").splitLines()
let xmax = data[0].high
let ymax = data.high
var asteroids: HashSet[Coords]
for y, line in data:
  for x, c in line:
    if c == '#':
      asteroids.incl (x, y)


### Part 1 ###

iterator maskedPositions(pos1, pos2: Coords): Coords =
  ## Yield positions masked to asteroid at "pos1" by asteroid at "pos2".
  var v = pos2 - pos1
  v = v div gcd(v.x, v.y)
  var pos = pos2 + v
  while pos.x in 0..xmax and pos.y in 0..ymax:
    yield pos
    pos = pos + v

var bestCount = 0
var bestPos: Coords
for pos1 in asteroids:
  # Build the list of asteroids visible from "pos1".
  var visibles = asteroids
  visibles.excl pos1
  for x in 0..xmax:
    for y in 0..ymax:
      let pos2 = (x, y)
      if pos2 in visibles:
        for pos in maskedPositions(pos1, pos2):
          visibles.excl pos
  # Keep the best result.
  if visibles.card > bestCount:
    bestCount = visibles.card
    bestPos = pos1

echo "Part 1: ", bestCount


### Part 2 ###

const Eps = 1e-9    # Used for float equality test (actually not necessary).

type AnglePos = tuple[angle: float, pos: Coords]

let origin = bestPos

proc angle(v: Coords): float =
  ## Compute the angle of a vector.
  ## The angle is 0.0 for (0, -1), PI/2 for (1, 0), PI for (0, 1) and 3PI/2 for (-1, 0).
  result = PI / 2 + arctan2(v.y.toFloat, v.x.toFloat)
  if result < 0:
    result += 2 * PI

proc distance(pos1, pos2: Coords): int =
  ## Compute the distance between two positions.
  ## As this is used for asteroids in same direction, Manhattan distance is OK.
  abs(pos1.x - pos2.x) + abs(pos1.y - pos2.y)

proc cmp(a1, a2: AnglePos): int =
  ## Compare two "AnglePos".
  ## Compare angles first and, for same angles, compare distances to origin.
  if abs(a1.angle - a2.angle) <= Eps:
    cmp(distance(a1.pos, origin), distance(a2.pos, origin))
  else:
    cmp(a1.angle, a2.angle)

# Build a sorted list of (angle, pos), excluding the origin.
var angles: seq[tuple[angle: float, pos: Coords]]
for pos in asteroids:
  if pos != origin:
    angles.add (angle(pos - origin), pos)
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
  angles.delete idx   # Now "idx" points to next candidate.
  # Skip asteroids with same angle.
  while idx < angles.len and abs(angles[idx].angle - angle) <= Eps:
    inc idx
  if idx == angles.len:
    # Start a new round.
    idx = 0

echo "Part 2: ", result
