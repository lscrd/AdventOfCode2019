import sets
import strutils
import tables

type
  Point = tuple[x, y: int]
  Points = HashSet[Point]
  Direction = enum RIGHT, LEFT, UP, DOWN
  Move = tuple[dir: Direction, dist: Natural]

# Mapping from direction letters to direction values.
const DIRS = {'R': RIGHT, 'L': LEFT, 'U': UP, 'D': DOWN}.toTable()

## Return the list of points of a path, origin excluded.
func points(path: seq[Move]): Points =
  var currx, curry = 0
  for move in path:
    case move.dir:
    of RIGHT:
      for x in (currx + 1)..(currx + move.dist):
        result.incl((x, curry))
      inc currx, move.dist
    of LEFT:
      for x in (currx - move.dist)..(currx - 1):
        result.incl((x, curry))
      dec currx, move.dist
    of UP:
      for y in (curry + 1)..(curry + move.dist):
        result.incl((currx, y))
      inc curry, move.dist
    of DOWN:
      for y in (curry - move.dist)..(curry - 1):
        result.incl((currx, y))
      dec curry, move.dist

## Return the Manhattan distance of a point from the origin.
func distance(p: Point): int = abs(p.x) + abs(p.y)

## Return the count of steps for a point in a path.
func stepcount(path: seq[Move]; pt: Point): int =
  var x, y = 0
  for move in path:
    case move.dir
    of RIGHT:
      if y == pt.y and pt.x in x..(x + move.dist):
        inc result, pt.x - x
        return
      inc result, move.dist
      inc x, move.dist
    of LEFT:
      if y == pt.y and pt.x in (x - move.dist)..x:
        inc result, x - pt.x
        return
      inc result, move.dist
      dec x, move.dist
    of UP:
      if x == pt.x and pt.y in y..(y + move.dist):
        inc result, pt.y - y
        return
      inc result, move.dist
      inc y, move.dist
    of DOWN:
      if x == pt.x and pt.y in (y - move.dist)..y:
        inc result, y - pt.y
        return
      inc result, move.dist
      dec y, move.dist

# Build the description of the paths.
var paths: array[2, seq[Move]]    # Paths described as sequences of moves.
for i, s in readLines("data", 2):
  for move in s.split(','):
    paths[i].add((DIRS[move[0]], move[1..^1].parseInt.Natural))

# Find the intersections.
let intersections = paths[0].points() * paths[1].points()

##########################################################################
# Part 1

var mindist = 1_000_000_000
for pt in intersections:
  mindist = min(mindist, pt.distance())

echo "Part 1: ", mindist


##########################################################################
# Part 2

var minsteps = 1_000_000_000
for pt in intersections:
  minsteps = min(minsteps, paths[0].stepcount(pt) + paths[1].stepcount(pt))

echo "Part 2: ", minsteps
