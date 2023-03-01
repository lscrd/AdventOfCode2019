import std/[sequtils, strutils, tables]

import ../common/intcode

let data = readFile("p11.data").strip().split(',')
let program = map(data, parseInt)

type
  Coords = tuple[x, y: int]                     # Panel coordinates.
  Color {.pure.} = enum Black, White            # Panel color.
  Dir {.pure.} = enum Up, Left, Down, Right     # Robot direction.

const
  # Directions after turning on the left.
  TurnLeft: array[Dir, Dir] = [Left, Down, Right, Up]
  # Directions after turing on the right.
  TurnRight: array[Dir, Dir] = [Right, Up, Left, Down]

# Table of panels, mapping coordinates to a color.
type Panels = Table[Coords, Color]
var panels: Panels

proc update(pos: var Coords; dir: Dir) =
  ## Update a position after move in current direction.
  case dir
  of Up: dec pos.y
  of Left: dec pos.x
  of Down: inc pos.y
  of Right: inc pos.x

proc paint(panels: var Panels; program: seq[int]) =
  ## Run the program.
  var
    computer: Computer
    pos = (0, 0)
    dir = Up

  computer.init(program)
  computer.run()
  while not computer.halted:
    let color = panels.getOrDefault(pos, Black)
    computer.giveInput(ord(color))
    panels[pos] = Color(computer.takeOutput())
    dir = if computer.takeOutput() == 0: TurnLeft[dir] else: TurnRight[dir]
    pos.update(dir)


### Part 1 ###

panels.paint(program)
echo "Part 1: ", panels.len


### Part 2 ###

# Run the program.
panels.clear()
panels[(0, 0)] = White    # Start with a white panel.
panels.paint(program)

# Find size of the identifier.
var
  xmin, ymin = 1000
  xmax, ymax = -1000
for p in panels.keys:
  xmin = min(xmin, p.x)
  xmax = max(xmax, p.x)
  ymin = min(ymin, p.y)
  ymax = max(ymax, p.y)

# Allocate and initialize memory for the identifier.
var id = newSeq[string](ymax - ymin + 1)
for line in id.mitems:
  line = ' '.repeat(xmax - xmin + 1)

# Build the identifier.
for pos, color in panels.pairs:
  id[(pos.y - ymin)][pos.x - xmin] = if color == Black: ' ' else: '#'

echo "Part 2:\n"
for line in id:
  echo line
