import sequtils
import strutils

# Opcodes.
const
  ADD = 1
  MUL = 2
  END = 99

# Operands.
template op1(ip: int): int = memory[memory[ip + 1]]
template op2(ip: int): int = memory[memory[ip + 2]]
template op3(ip: int): int = memory[memory[ip + 3]]

proc update(memory: var seq[int]; noun, verb: int) =
  # Set addresses 1 and 2.
  memory[1] = noun
  memory[2] = verb
  # Run the program.
  var ip = 0
  while true:
    case  memory[ip]
    of ADD:
      op3(ip) = op1(ip) + op2(ip)
    of MUL:
      op3(ip) = op1(ip) * op2(ip)
    of END:
      break # Exit program.
    else:
      raise newException(ValueError, "Invalid opcode")
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
