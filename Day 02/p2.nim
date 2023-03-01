import std/[sequtils, strutils]

import ../common/intcode

proc update(computer: var Computer; noun, verb: int) =
  computer.memory[1] = noun
  computer.memory[2] = verb

let data = readFile("p2.data").strip().split(',')
let program = map(data, parseInt)


### Part 1 ###

var computer: Computer
computer.init(program)
computer.update(12, 2)
computer.run()

echo "Part 1: ", computer.memory[0]


### Part 2 ###

const ValRange = 0..99
const Target = 19690720

var result: int
block search:
  for verb in ValRange:
    for noun in ValRange:
      computer.init(program)
      computer.update(noun, verb)
      computer.run()
      if computer.memory[0] == Target:
        result = 100 * noun + verb
        break search

echo "Part 2: ", result
