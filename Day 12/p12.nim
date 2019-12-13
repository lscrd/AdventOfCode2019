from math import lcm
import strscans

const N = 4   # Number of bodies.

# As there is no interaction between axes, we store all coordinates on an axis first,
# i.e. we use a tuple (x, y, z) of vectors rather than a vector of tuples (x, y, z).
# This is slightly more complicated for part 1, but a lot simpler for part 2.

type
  Vector = array[N, int]
  Coordinates = tuple[x, y, z: Vector]

# Read iniial positions.
var p0: Coordinates
let lines = readLines("data", N)
for i, line in lines:
  if not scanf(line, "<x=$i, y=$i, z=$i>", p0.x[i], p0.y[i], p0.z[i]):
    quit("Error while scanning line: " & line)

## Update velocities using positions.
proc applyGravity(p: Vector; v: var Vector) =
  for i in 0..(N - 2):
    for j in (i + 1)..(N - 1):
      let delta = cmp(p[i], p[j])   # "cmp" gives exactly what we need.
      dec v[i], delta
      inc v[j], delta

## Update positions using velocities.
proc applyVelocity(p: var Vector; v: Vector) =
  for i in 0..<N:
    inc p[i], v[i]

## Execute a round, applying gravity then velocity.
template doRound(p, v: Vector) =
  applyGravity(p, v)
  applyVelocity(p, v)


###############################################################################
# Part 1

## Run the simulation and return the total energy.
proc simulate(p0: Coordinates; n: int): int =
  var p = p0
  var v: Coordinates

  # Do 1000 rounds of simulation.
  for n in 1..1000:
    doRound(p.x, v.x)
    doRound(p.y, v.y)
    doRound(p.z, v.z)

  # Compute energy.
  for i in 0..<N:
    let potentialEnergy = abs(p.x[i]) + abs(p.y[i]) + abs(p.z[i])
    let kineticEnergy = abs(v.x[i]) + abs(v.y[i]) + abs(v.z[i])
    inc result, potentialEnergy * kineticEnergy

echo "Part 1: ", p0.simulate(1000)


###############################################################################
# Part 2

const v0 = default(Vector)    # Null velocities.

## Return the cycle length for initial positions "p0" and null velocities.
proc cycleLength(p0: Vector): int =
  var p = p0
  var v = v0
  while true:
    inc result
    doRound(p, v)
    if p == p0 and v == v0:
      break

# The result is the LCM of the three cycle lengths.
echo "Part 2: ", lcm([cycleLength(p0.x), cycleLength(p0.y), cycleLength(p0.z)])
