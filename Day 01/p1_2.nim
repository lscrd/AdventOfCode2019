import strutils

proc fuelMass(moduleMass: int): int =
  var mass = moduleMass
  while true:
    mass = mass div 3 - 2
    result += mass

var fuel = 0
for line in "data".lines:
  fuel += fullMass(line.parseInt)
echo fuel
