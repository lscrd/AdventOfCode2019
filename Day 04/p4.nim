# Not the most elegant, but very fast.

import std/[strscans, strutils]

type Digit = 0..9

func number(digits: varargs[Digit]): int =
  ## Compute a number from a list of digits.
  for d in digits:
    result = 10 * result + d

# Read minimum and maximum allowed passwords.
var minval, maxval: int
let input = readFile("p4.data").strip()
discard input.scanf("$i-$i", minval, maxval)


### Part 1 ###

var count1 = 0

block loop1:
  for d1 in Digit(1)..Digit(9):
    for d2 in d1..9:
      for d3 in d2..9:
        for d4 in d3..9:
          for d5 in d4..9:
            for d6 in d5..9:
              let n = number(d1, d2, d3, d4, d5, d6)
              if n < minval: continue
              if n > maxval: break loop1
              if d1 == d2 or d2 == d3 or d3 == d4 or d4 == d5 or d5 == d6:
                inc count1

echo "Part 1: ", count1


### Part 2 ###

var count2 = 0

block loop2:
  for d1 in 1.Digit..9:
    for d2 in d1..9:
      for d3 in d2..9:
        for d4 in d3..9:
          for d5 in d4..9:
            for d6 in d5..9:
              let n = number(d1, d2, d3, d4, d5, d6)
              if n < minval: continue
              if n > maxval: break loop2
              if (d2 == d1 and d2 != d3) or
                 (d3 == d2 and d3 notin {d1, d4}) or
                 (d4 == d3 and d4 notin {d2, d5}) or
                 (d5 == d4 and d5 notin {d3, d6}) or
                 (d6 == d5 and d6 != d4):
                inc count2

echo "Part 2: ", count2
