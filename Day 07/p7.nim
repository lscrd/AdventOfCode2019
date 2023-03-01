import std/[algorithm, sequtils, strutils]

import ../common/intcode

type Phases = array[5, int]

let data = readFile("p7.data").strip().split(',')
let program = map(data, parseInt)


### Part 1 ###

var phases: Phases = [0, 1, 2, 3, 4]
var bestOutput = 0

while true:
  # Run programs.
  var value = 0
  for phase in phases:
    # Initialize a computer, run program, provide arguments and read output.
    var computer: Computer
    computer.init(program)
    computer.run()
    computer.giveInput(phase)
    computer.giveInput(value)
    value = computer.takeOutput()
  # Check output value.
  if value > bestOutput:
    bestOutput = value
  if not phases.nextPermutation():
    break

echo "Part 1: ", bestOutput


############################################################################
# Part 2

phases = [5, 6, 7, 8, 9]
bestOutput = 0
var computers: array[5, Computer]

while true:
  # Initialize computers, launch programs and provide their phase input.
  for i, phase in phases:
    computers[i].init(program)
    computers[i].run()
    computers[i].giveInput(phase)
  # Run computers until the last one is halted.
  var value = 0
  while true:
    for i in 0..4:
      computers[i].giveInput(value)
      value = computers[i].takeOutput()
    if computers[4].halted:
      break
  # Check output value.
  if value > bestOutput:
    bestOutput = value
  if not phases.nextPermutation():
    break

echo "Part 2: ", bestOutput
