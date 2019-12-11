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
  ARB = 9     # Adjust relative base.
  END = 99    # Exit program.

# Modes.
type
  Mode {.pure.} = enum position, immediate, relative
  Modes = array[1..3, Mode]

# Computer description.
type Computer* = object
  memory*: seq[int]        # Computer memory.
  ip: int                  # Instruction pointer.
  rb: int                  # Relative base.
  inputAvailable: bool     # True if input is available for IN instruction.
  outputAvailable*: bool   # True if output has been provided by OUT instruction.
  input: int               # Input value to be used by IN.
  output: int              # Last output value provided by OUT.
  halted*: bool            # True if the computer has been halted by END instruction.

## Initialize a computer.
proc init*(computer: var Computer; memory: seq[int]) =
  computer.memory = memory
  computer.ip = 0
  computer.rb = 0
  computer.inputAvailable = false
  computer.outputAvailable = false
  computer.halted = false

## Check addressing space and extend it if needed.
proc checkMemory(computer: var Computer; address: int) =
  if address > computer.memory.high:
    computer.memory.setLen(address + 1)

## Return operand location in an instruction.
proc op(computer: var Computer; address: int; mode: Mode): var int =
  computer.checkMemory(address)
  case mode
  of Mode.position:
    let a = computer.memory[address]
    computer.checkMemory(a)
    result = computer.memory[a]
  of Mode.immediate:
    result = computer.memory[address]
  of Mode.relative:
    let a = computer.memory[address] + computer.rb
    computer.checkMemory(a)
    result = computer.memory[a]

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
proc run*(computer: var Computer) =

  # Templates to access operands.
  template OP1(): var int = computer.op(computer.ip + 1, modes[1])
  template OP2(): var int = computer.op(computer.ip + 2, modes[2])
  template OP3(): var int = computer.op(computer.ip + 3, modes[3])
  # Template to make sure that an operand is accessed in position mode.
  template checkOperandMode(n: int) =
    if modes[n] == Mode.immediate:
      raise newException(ValueError, "Immediate mode forbidden for operand $1" % $n)

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
    of ARB:
      inc computer.rb, OP1
      inc computer.ip, 2
    of END:
      computer.halted = true
      break # Exit program.
    else:
      raise newException(ValueError, "Invalid opcode")

## Provide computer with an input value and resume execution.
proc giveInput*(computer: var Computer; value: int) =
  computer.inputAvailable = true
  computer.input = value
  computer.run()

## Get a value from computer and resume execution.
proc takeOutput*(computer: var Computer): int =
  assert computer.outputAvailable
  computer.outputAvailable = false
  result = computer.output
  computer.run()
