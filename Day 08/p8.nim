import std/[strutils, sugar]

const
  ImageWidth = 25
  ImageHeight = 6
  LayerSize = ImageWidth * ImageHeight

type Color = '0'..'2'

let data = readFile("p8.data").strip()

# Extract layers from data.
let layers = collect:
               for i in countup(0, data.high, LayerSize):
                 data.substr(i, i + (LayerSize - 1))


### Part 1 ###

var counts: array[Color, int]     # Counts of '0', '1' and '2'.
var minCount = 1_000_000_000      # Minimal count of '0'.
var result: int                   # Result for part one.

for i in 0..layers.high:
  counts = [0, 0, 0]
  for c in layers[i]:
    inc counts[c]
  if counts['0'] < minCount:
    minCount = counts['0']
    result = counts['1'] * counts['2']

echo "Part 1: ", result


### Part 2 ###

var image = newString(layers[0].len)

# Build the image.
for i in 0..image.high:
  var color: Color
  for layer in layers:
    color = layer[i]
    if color != '2': break                    # Found white or black.
  image[i] = if color == '1': '#' else: ' '   # Using '#' for better legibility.

# Display the image.
echo "Part 2:\n"
for i in countup(0, image.high, ImageWidth):
  echo image[i..<(i + ImageWidth)]
