import std/[sequtils, strutils]

import ../common/intcode

let data = readFile("p5.data").strip().split(',')
let program = map(data, parseInt)


### Part 1 ###

var computer: Computer
var output: int

computer.init(program)
computer.run()
computer.giveInput(1)
while not computer.halted:
  output = computer.takeOutput()
  if output != 0:
    break   # Non null output is either the final output or a diagnostic error.

if not computer.halted:
  raise newException(ValueError, "Diagnostic failed")

echo "Part 1: ", output


### Part 2 ###

computer.init(program)
computer.run()
computer.giveInput(5)

echo "Part 2: ", computer.takeOutput()
