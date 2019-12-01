import strutils

proc fuelMass(moduleMass: int): int =
  moduleMass div 3 - 2

var fuel = 0
for line in "data".lines:
  fuel += fuelMass(line.parseInt)
echo fuel
