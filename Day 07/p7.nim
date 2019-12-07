import algorithm
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

# Computer description.
type Computer = object
  memory: seq[int]        # Computer memory.
  ip: int                 # Instruction pointer.
  inputAvailable: bool    # True if input is available for IN instruction.
  outputAvailable: bool   # True if output has been provided by OUT instruction.
  input: int              # Input value to be used by IN.
  output: int             # Last output value provided by OUT.
  halted: bool            # True if the computer has been halted by END instruction.

## Initialize a computer.
proc initComputer(computer: var Computer; memory: seq[int]) =
  computer.memory = memory
  computer.ip = 0
  computer.inputAvailable = false
  computer.outputAvailable = false
  computer.halted = false

## Return operand location in an instruction.
proc op(memory: var openarray[int]; address: int; mode: Mode): var int =
  case mode
  of Mode.position: result = memory[memory[address]]
  of Mode.immediate: result = memory[address]

## Decode an instruction, returning op code and op modes.
proc decode(inst: int): tuple[modes: Modes, code: int] =
  result.code = inst mod 100
  var modes = inst div 100
  for i in 1..3:
    result.modes[i] = Mode(modes mod 10)
    modes = modes div 10

## Run the program.
## If the computer encounters an IN instruction, it pauses until an input
## value is available. If it encounters an OUT instruction, it pauses
## until the value is read.
proc run(computer: var Computer) =

  # Templates to access operands.
  template OP1(): var int = computer.memory.op(computer.ip + 1, modes[1])
  template OP2(): var int = computer.memory.op(computer.ip + 2, modes[2])
  template OP3(): var int = computer.memory.op(computer.ip + 3, modes[3])
  # Template to make sure that an operand is accessed in position mode.
  template checkOperandMode(n: int) =
    if modes[n] != Mode.position:
      raise newException(ValueError, "Position mode required for operand $1" % $n)

  # Execution loop.
  while true:
    let (modes, code) = computer.memory[computer.ip].decode
    case code
    of ADD:
      checkOperandMode(3)
      OP3 = OP1 + OP2
      inc computer.ip, 4
    of MUL:
      checkOperandMode(3)
      OP3 = OP1 * OP2
      inc computer.ip, 4
    of IN:
      if computer.inputAvailable:
        checkOperandMode(1)
        OP1 = computer.input
        computer.inputAvailable = false
        inc computer.ip, 2
      else:
        # Pause until an input is available.
        return
    of OUT:
      computer.outputAvailable = true
      computer.output = OP1
      inc computer.ip, 2
      # Pause until the value is read.
      return
    of JIT:
      computer.ip = if OP1 != 0: OP2 else: computer.ip + 3
    of JIF:
      computer.ip = if OP1 == 0: OP2 else: computer.ip + 3
    of LT:
      checkOperandMode(3)
      OP3 = ord(OP1 < OP2)
      inc computer.ip, 4
    of EQ:
      checkOperandMode(3)
      OP3 = ord(OP1 == OP2)
      inc computer.ip, 4
    of END:
      computer.halted = true
      break # Exit program.
    else:
      raise newException(ValueError, "Invalid opcode")

## Provide computer with an input value and continue execution.
proc giveInput(computer: var Computer; value: int) =
  computer.inputAvailable = true
  computer.input = value
  computer.run()

## Get a value from computer an continue execution.
proc takeOutput(computer: var Computer): int =
  assert computer.outputAvailable
  computer.outputAvailable = false
  result = computer.output
  computer.run()


let data = readFile("data").strip().split(',')
let initialMemory = map(data, parseInt)


############################################################################
# Part 1

var settings = @[0, 1, 2, 3, 4]
var bestOutput = 0
var bestInput: seq[int]
while true:
  # Run programs.
  var value = 0
  for phase in settings:
    # Initialize a computer, run program, provide arguments and read output.
    var computer: Computer
    computer.initComputer(initialMemory)
    computer.run()
    computer.giveInput(phase)
    computer.giveInput(value)
    value = computer.takeOutput()
  # Check output value.
  if value > bestOutput:
    bestOutput = value
    bestInput = settings
  if not settings.nextPermutation():
    break

echo "Part 1: ", bestInput, " -> ", bestOutput

############################################################################
# Part 2

settings = @[5, 6, 7, 8, 9]
bestOutput = 0
var computers: array[5, Computer]
while true:
  # Initialize computers, launch programs and provide their phase input.
  for i, phase in settings:
    computers[i].initComputer(initialMemory)
    computers[i].run()
    computers[i].giveInput(phase)
  # Run computers until the last one is halted.
  var value = 0
  while true:
    for i in 0..4:
      computers[i].giveInput(value)
      value = computers[i].takeOutput()
    if computers[4].halted:
      break
  if value > bestOutput:
    bestOutput = value
  if not settings.nextPermutation():
    break

echo "Part 2: ", bestInput, " -> ", bestOutput
