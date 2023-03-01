import std/[sequtils, strutils]

import ../common/intcode

let data = readFile("p9.data").strip().split(',')
let program = map(data, parseInt)

var computer: Computer


### Part 1 ###

computer.init(program)
computer.run()
computer.giveInput(1)

echo "Part 1: ", computer.takeOutput()


### Part 2 ###

computer.init(program)
computer.run()
computer.giveInput(2)

echo "Part 2: ", computer.takeOutput()
