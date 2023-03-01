import std/[sequtils, strutils]

import ../common/intcode

type Tile {.pure.} = enum Empty, Wall, Block, Paddle, Ball

let data = readFile("p13.data").strip().split(',')
let program = map(data, parseInt)

var computer: Computer


### Part 1 ###

computer.init(program)
computer.run()

var blocks = 0
while not computer.halted:
  discard computer.takeOutput()
  discard computer.takeOutput()
  if Tile(computer.takeOutput()) == Block:
    inc blocks

echo "Part 1: ", blocks


### Part 2 ###

var xBall, xPaddle: int
var score: int

computer.init(program)
computer.memory[0] = 2
computer.run()
while not computer.halted:
  while computer.outputAvailable:
    let x = computer.takeOutput()
    let y = computer.takeOutput()
    if (x == -1) and (y == 0):
      score = computer.takeOutput()
    else:
      case Tile(computer.takeOutput())
        of Ball: xBall = x
        of Paddle: xPaddle = x
        else: discard
  let delta = cmp(xBall, xPaddle)
  computer.giveInput(delta)         # Make the paddle follow the ball.

echo "Part 2: ", score
