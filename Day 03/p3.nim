import std/[sets, strutils, tables]

type
  Point = tuple[x, y: int]
  Points = HashSet[Point]
  Direction {.pure.} = enum Right, Left, Up, Down
  Move = tuple[dir: Direction, dist: Natural]

# Mapping from direction letters to direction values.
const Dirs = {'R': Right, 'L': Left, 'U': Up, 'D': Down}.toTable

func points(path: seq[Move]): Points =
  ## Return the list of points of a path, origin excluded.
  var currx, curry = 0
  for move in path:
    case move.dir:
    of Right:
      for x in (currx + 1)..(currx + move.dist):
        result.incl (x, curry)
      inc currx, move.dist
    of Left:
      for x in (currx - move.dist)..(currx - 1):
        result.incl (x, curry)
      dec currx, move.dist
    of Up:
      for y in (curry + 1)..(curry + move.dist):
        result.incl (currx, y)
      inc curry, move.dist
    of Down:
      for y in (curry - move.dist)..(curry - 1):
        result.incl (currx, y)
      dec curry, move.dist

func distance(p: Point): int =
  ## Return the Manhattan distance of a point from the origin.
  abs(p.x) + abs(p.y)

func stepcount(path: seq[Move]; pt: Point): int =
  ## Return the count of steps for a point in a path.
  var x, y = 0
  for move in path:
    case move.dir
    of Right:
      if y == pt.y and pt.x in x..(x + move.dist):
        inc result, pt.x - x
        return
      inc result, move.dist
      inc x, move.dist
    of Left:
      if y == pt.y and pt.x in (x - move.dist)..x:
        inc result, x - pt.x
        return
      inc result, move.dist
      dec x, move.dist
    of Up:
      if x == pt.x and pt.y in y..(y + move.dist):
        inc result, pt.y - y
        return
      inc result, move.dist
      inc y, move.dist
    of Down:
      if x == pt.x and pt.y in (y - move.dist)..y:
        inc result, y - pt.y
        return
      inc result, move.dist
      dec y, move.dist

# Build the description of the paths.
var paths: array[2, seq[Move]]    # Paths described as sequences of moves.
for i, s in "p3.data".readLines(2):
  for move in s.split(','):
    paths[i].add (Dirs[move[0]], move[1..^1].parseInt.Natural)

# Find the intersections.
let intersections = paths[0].points() * paths[1].points()


### Part 1 ###

var mindist = 1_000_000_000
for pt in intersections:
  mindist = min(mindist, pt.distance())

echo "Part 1: ", mindist


### Part 2 ###

var minsteps = 1_000_000_000
for pt in intersections:
  minsteps = min(minsteps, paths[0].stepcount(pt) + paths[1].stepcount(pt))

echo "Part 2: ", minsteps
