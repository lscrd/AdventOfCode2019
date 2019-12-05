import sequtils
import strutils

# Opcodes.
const
  ADD = 1     # Add.
  MUL = 2     # Multiply.
  IN  = 3     # Input value.
  OUT = 4     # Output value.
  JIT = 5     # Jump if true.
  JIF = 6     # Jump if false.
  LT  = 7     # Less than.
  EQ  = 8     # Equal.
  END = 99    # Exit program.

# Modes.
type
  Mode {.pure.} = enum position, immediate
  Modes = array[1..3, Mode]

# Return operand location.
proc op(memory: var openarray[int]; address: int; mode: Mode): var int =
  case mode
  of Mode.position: result = memory[memory[address]]
  of Mode.immediate: result = memory[address]

# Decode an instruction, returning op code and op modes.
proc decode(inst: int): tuple[modes: Modes, code: int] =
  result.code = inst mod 100
  var modes = inst div 100
  for i in 1..3:
    result.modes[i] = Mode(modes mod 10)
    modes = modes div 10

## Run the program.
proc run(memory: var seq[int]; inputs: varargs[int]): seq[int] =

  # Templates to access operands.
  template OP1(): var int = memory.op(ip + 1, modes[1])
  template OP2(): var int = memory.op(ip + 2, modes[2])
  template OP3(): var int = memory.op(ip + 3, modes[3])
  # Template to make sure that an operand is accessed in position mode.
  template checkOperandMode(n: int) =
    if modes[n] != Mode.position:
      raise newException(ValueError, "Position mode required for operand $1" % $n)

  # Execution loop.
  var ip = 0            # Instruction pointer.
  var inputIndex = 0    # Index for input values.
  while true:
    let (modes, code) = memory[ip].decode
    case code
    of ADD:
      checkOperandMode(3)
      OP3 = OP1 + OP2
      inc ip, 4
    of MUL:
      checkOperandMode(3)
      OP3 = OP1 * OP2
      inc ip, 4
    of IN:
      checkOperandMode(1)
      OP1 = inputs[inputIndex]
      inc inputIndex
      inc ip, 2
    of OUT:
      result.add(OP1)
      inc ip, 2
    of JIT:
      ip = if OP1 != 0: OP2 else: ip + 3
    of JIF:
      ip = if OP1 == 0: OP2 else: ip + 3
    of LT:
      checkOperandMode(3)
      OP3 = ord(OP1 < OP2)
      inc ip, 4
    of EQ:
      checkOperandMode(3)
      OP3 = ord(OP1 == OP2)
      inc ip, 4
    of END:
      break # Exit program.
    else:
      raise newException(ValueError, "Invalid opcode")


let data = readFile("data").strip().split(',')
let initialMemory = map(data, parseInt)

#####################################################################
# Part 1

var memory = initialMemory
echo "Part 1: ", memory.run(1)

#####################################################################
# Part 2

memory = initialMemory
echo "Part 2: ", memory.run(5)
