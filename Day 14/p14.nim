
import std/[math, strmisc, strutils, tables]

# A reaction is described by a product name, a quantity and a list of reagents.
# Reactions are stored in a table indexed by the product name.
# The reagents of a reaction are themselves stored in a table indexed by the
# reagent name and giving the required quantity.

type
  # Table of reagents mapping reagent name to required quantity.
  Reagents = Table[string, float]
  # Description of a reaction.
  Reaction = object
    quantity: float       # Quantity produced (as a float for computations).
    reagents: Reagents    # Table of reagents.

var
  # Table mapping a product name to a reaction.
  reactions: Table[string, Reaction]
  # Table used to define an order to apply reverse reactions.
  depths: Table[string, int]

# Read the data and build the table of reactions.
for line in "p14.data".lines:
  var quantity, name, sep: string
  var reagents: Reagents
  let (reagentString, _, productString) = line.partition(" => ")
  # Parse list of reagents and store in reagent table.
  for oneReagentString in reagentString.split(", "):
    (quantity, sep, name) = oneReagentString.partition(" ")
    reagents[name] = quantity.parseFloat()
  # Parse product part and store un reaction table.
  (quantity, sep, name) = productString.partition(" ")
  reactions[name] = Reaction(quantity: quantity.parseFloat(), reagents: reagents)

proc compute(depths: var Table[string, int]; name: string; depth: int) =
  ## Compute depths.
  depths[name] = max(depths.getOrDefault(name), depth)
  if name != "ORE":
    for reagentName in reactions[name].reagents.keys:
      depths.compute(reagentName, depth + 1)

depths.compute("FUEL", 0)

proc oreQuantity(reactions: Table[string, Reaction]; intQuantities: bool): float =
  ## Compute the quantity of ORE.
  ## If "intQuantities" is true, the computation is done using integer multiples
  ## of quantities. If it is false, computation is done using fractional
  ## quantities which is necessary for part 2.

  # Start with the reaction to produce FUEL and apply reactions in reverse order.
  var fullReagents = reactions["FUEL"].reagents
  while fullReagents.len > 1:

    # Find a reagent whose depth is minimal.
    var reagentName: string
    var minDepth = depths["ORE"] + 1
    for name in fullReagents.keys:
      if depths[name] < minDepth:
        minDepth = depths[name]
        reagentName = name

    # Replace it by the reagents used for its production.
    var multiplier = fullReagents[reagentName] / reactions[reagentName].quantity
    if intQuantities:
      multiplier = ceil(multiplier)
    for r, q  in reactions[reagentName].reagents.pairs:
      fullReagents[r] = fullReagents.getOrDefault(r) + q * multiplier
    fullReagents.del reagentName

  result = fullReagents["ORE"]


### Part 1 ###

let quantity1 = reactions.oreQuantity(true)

echo "Part 1: ", quantity1.int


### Part 2 ###

let quantity2 = reactions.oreQuantity(false)

var remaining = 1_000_000_000_000.0
var total = 0.0
# Loop until there is not enough ORE to produce more FUEL.
while remaining >= quantity1:
  let n = floor(remaining / quantity1)  # Number of units of FUEL produced during this round.
  total += n
  remaining -= n * quantity2            # Subtract the number of ORE actually used.

echo "Part 2: ", total.toInt
