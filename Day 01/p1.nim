import std/strutils

var moduleMasses: seq[int]
for line in "data".lines:
  moduleMasses.add line.parseInt()


### Part 1 ###

var fuelMass1 = 0
for moduleMass in moduleMasses:
  fuelMass1 += moduleMass div 3 - 2

echo "Part 1: ", fuelMass1


### Part 2 ###

## Compute the fuel mass needed for a module, including the fuel itself.
proc fuelMass(moduleMass: int): int =
  var mass = moduleMass div 3 - 2
  while mass > 0:
    result += mass
    mass = mass div 3 - 2

var fuelMass2 = 0
for moduleMass in moduleMasses:
  fuelMass2 += fuelMass(moduleMass)

echo "Part 2: ", fuelMass2
