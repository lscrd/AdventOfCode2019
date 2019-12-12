import sequtils
import strutils
import tables

import ../common/intcode

let data = readFile("data").strip().split(',')
let program = map(data, parseInt)

type
  Coords = tuple[x, y: int]                     # Panel coordinates.
  Color {.pure.} = enum black, white            # Panel color.
  Dir {.pure.} = enum up, left, down, right     # Robot direction.

const
  # Directions after turning on the left.
  TurnLeft: array[Dir, Dir] = [Dir.left, Dir.down, Dir.right, Dir.up]
  # Directions after turing on the right.
  TurnRight: array[Dir, Dir] = [Dir.right, Dir.up, Dir.left, Dir.down]

# Table of panels, mapping coordinates to a color.
type Panels = Table[Coords, Color]
var panels: Panels

## Update a position after move in current direction.
proc update(pos: var Coords; dir: Dir) =
  case dir
  of Dir.up: dec pos.y
  of Dir.left: dec pos.x
  of Dir.down: inc pos.y
  of Dir.right: inc pos.x

## Run the program.
proc paint(panels: var Panels; program: seq[int]) =
  var
    computer: Computer
    pos = (0, 0)
    dir = Dir.up

  computer.init(program)
  computer.run()
  while not computer.halted:
    let color = panels.getOrDefault(pos, Color.black)
    computer.giveInput(ord(color))
    panels[pos] = Color(computer.takeOutput())
    dir = if computer.takeOutput() == 0: TurnLeft[dir] else: TurnRight[dir]
    pos.update(dir)


###############################################################################
# Part 1

panels.paint(program)
echo "\nPart 1: ", panels.len


###############################################################################
# Part 2

# Run the program.
panels.clear()
panels[(0, 0)] = Color.white    # Start with a white panel.
panels.paint(program)

# Find size of the identifier.
var
  xmin, ymin = 1000
  xmax, ymax = -1000
for p in panels.keys():
  xmin = min(xmin, p.x)
  xmax = max(xmax, p.x)
  ymin = min(ymin, p.y)
  ymax = max(ymax, p.y)

# Allocate and initialize memory for the identifier.
var id = newSeq[string](ymax - ymin + 1)
for line in id.mitems:
  line = repeat(' ', xmax - xmin + 1)

# Build the identifier.
for pos, color in panels.pairs():
  id[(pos.y - ymin)][pos.x - xmin] = if color == Color.black: ' ' else: '#'

echo "\nPart 2:\n"
for line in id:
  echo line
