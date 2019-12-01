import strutils

proc fuelMass(moduleMass: int): int =
  var mass = moduleMass
  while true:
    mass = mass div 3 - 2
    if mass <= 0:
      break
    result += mass

var fuel = 0
for line in "data".lines:
  fuel += fuelMass(line.parseInt)
echo fuel
