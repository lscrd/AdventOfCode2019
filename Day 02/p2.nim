import sequtils
import strutils

import ../common/intcode

proc update(computer: var Computer; noun, verb: int) =
  computer.memory[1] = noun
  computer.memory[2] = verb

let data = readFile("data").strip().split(',')
let program = map(data, parseInt)


#####################################################################
# Part 1

var computer: Computer

computer.init(program)
computer.update(12, 2)
computer.run()

echo "Part 1: ", computer.memory[0]


#####################################################################
# Part 2

const VALRANGE = 0..99
const TARGET = 19690720

var result: int
block search:
  for verb in VALRANGE:
    for noun in VALRANGE:
      computer.init(program)
      computer.update(noun, verb)
      computer.run()
      if computer.memory[0] == TARGET:
        result = 100 * noun + verb
        break search

echo "Part 2: ", result
