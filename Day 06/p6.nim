import strutils
import tables

# Description of orbit objects.
type OrbitObject = ref object
  name: string                  # Object name.
  children: seq[OrbitObject]    # List of objects orbiting around it.
  parent: OrbitObject           # Object it is orbiting around.
  depth: int                    # Orbiting depth.

# Mapping from names to orbiting objects.
type ObjectTable = Table[string, OrbitObject]
var objects: ObjectTable

## Get an object from its name, creating it if it doesn't exist.
proc get(objects: var ObjectTable; name: string): OrbitObject =
  if name in objects:
    result = objects[name]
  else:
    result = OrbitObject(name: name)
    objects[name] = result

## Set the orbiting depth of objects starting from "obj".
proc setOrbitingDepths(obj: OrbitObject; depth = 0) =
  obj.depth = depth
  for next in obj.children:
    next.setOrbitingDepths(depth + 1)

# Build the objects and the mapping table.
for line in "data".lines:
  let names = line.split(')')
  let obj1 = objects.get(names[0])
  let obj2 = objects.get(names[1])
  obj1.children.add(obj2)
  obj2.parent = obj1

objects["COM"].setOrbitingDepths()


###############################################################################
# Part 1

# Count of orbits is simply the sum of orbiting depths.
var count = 0
for obj in objects.values():
  count += obj.depth

echo "Part 1: ", count


###############################################################################
# Part 2

## Build the list of objects around which "obj" is orbiting,
## from the nearest to the farthest
proc orbitingList(obj: OrbitObject): seq[OrbitObject] =
  var obj = obj.parent
  while not obj.isNil:
    result.add(obj)
    obj = obj.parent

let olist1 = objects["YOU"].orbitingList()
let olist2 = objects["SAN"].orbitingList()

# Find the first common object in the orbiting lists.
var common: OrbitObject
for obj in olist1:
  if obj in olist2:
    common = obj
    break

# Orbital transfer count is given but difference of orbiting depths, so:
echo "Part 2: ", (olist1[0].depth - common.depth) + (olist2[0].depth - common.depth)
