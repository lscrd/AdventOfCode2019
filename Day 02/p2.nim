import sequtils
import strutils

proc update(memory: var seq[int]; noun, verb: int) =
  # Set addresses 1 and 2.
  memory[1] = noun
  memory[2] = verb
  # Run the program.
  var ip = 0
  while true:
    let op = memory[ip]
    if op == 99:
      break # Exit program.
    let op1 = memory[memory[ip + 1]]
    let op2 = memory[memory[ip + 2]]
    if op notin {1, 2}:
      raise newException(ValueError, "Invalid opcode")
    memory[memory[ip + 3]] = if op == 1: op1 + op2 else: op1 * op2
    inc ip, 4

let data = readFile("data").strip().split(',')
let initialMemory = map(data, parseInt)

#####################################################################
# Part 1

var memory = initialMemory
memory.update(12, 2)
echo "Part 1: ", memory[0]

#####################################################################
# Part 2

const target = 19690720
var noun, verb = 0

# First, find the noun which works by large steps.
memory = initialMemory
while true:
  memory.update(noun, verb)
  if memory[0] > target:
    dec noun
    break
  memory = initialMemory
  inc noun

# Second, using the noun previously found, find the verb which works by small steps.
memory = initialMemory
while true:
  memory.update(noun, verb)
  if memory[0] == target:
    break
  memory = initialMemory
  inc verb

echo "Part 2: ", 100 * noun + verb
