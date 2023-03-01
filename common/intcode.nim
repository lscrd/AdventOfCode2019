# Intcode computer. Used by several puzzles.

import std/strutils

# Opcodes.
const
  Add = 1     # Add.
  Mul = 2     # Multiply.
  In  = 3     # Input value.
  Out = 4     # Output value.
  Jit = 5     # Jump if true.
  Jif = 6     # Jump if false.
  Lt  = 7     # Less than.
  Eq  = 8     # Equal.
  Arb = 9     # Adjust relative base.
  End = 99    # Exit program.

# Modes.
type
  Mode {.pure.} = enum Position, Immediate, Relative
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

proc init*(computer: var Computer; memory: seq[int]) =
  ## Initialize a computer.
  computer.memory = memory
  computer.ip = 0
  computer.rb = 0
  computer.inputAvailable = false
  computer.outputAvailable = false
  computer.halted = false

proc checkMemory(computer: var Computer; address: int) =
  ## Check addressing space and extend it if needed.
  if address > computer.memory.high:
    computer.memory.setLen(address + 1)

proc op(computer: var Computer; address: int; mode: Mode): var int =
  ## Return operand location in an instruction.
  computer.checkMemory(address)
  case mode
  of Position:
    let a = computer.memory[address]
    computer.checkMemory(a)
    result = computer.memory[a]
  of Immediate:
    result = computer.memory[address]
  of Relative:
    let a = computer.memory[address] + computer.rb
    computer.checkMemory(a)
    result = computer.memory[a]

proc decode(inst: int): tuple[modes: Modes, code: int] =
  ## Decode an instruction, returning op code and op modes.
  result.code = inst mod 100
  var modes = inst div 100
  for i in 1..3:
    result.modes[i] = Mode(modes mod 10)
    modes = modes div 10


proc run*(computer: var Computer) =
  ## Run the program.
  ## If the computer encounters an "In" instruction, it pauses until an input
  ## value is available. If it encounters an "Out" instruction, it pauses
  ## until the value is read.

  # Templates to access operands.
  template op1(): var int = computer.op(computer.ip + 1, modes[1])
  template op2(): var int = computer.op(computer.ip + 2, modes[2])
  template op3(): var int = computer.op(computer.ip + 3, modes[3])

  template checkOperandMode(n: int) =
    ## Template to make sure that an operand is accessed in position mode.
    if modes[n] == Immediate:
      raise newException(ValueError, "Immediate mode forbidden for operand $1" % $n)

  # Execution loop.
  while true:
    let (modes, code) = computer.memory[computer.ip].decode()
    case code
    of Add:
      checkOperandMode(3)
      op3 = op1 + op2
      inc computer.ip, 4
    of Mul:
      checkOperandMode(3)
      op3 = op1 * op2
      inc computer.ip, 4
    of In:
      if computer.inputAvailable:
        checkOperandMode(1)
        op1 = computer.input
        computer.inputAvailable = false
        inc computer.ip, 2
      else:
        # Pause until an input is available.
        return
    of Out:
      computer.outputAvailable = true
      computer.output = op1
      inc computer.ip, 2
      # Pause until the value is read.
      return
    of Jit:
      computer.ip = if op1 != 0: op2 else: computer.ip + 3
    of Jif:
      computer.ip = if op1 == 0: op2 else: computer.ip + 3
    of Lt:
      checkOperandMode(3)
      op3 = ord(op1 < op2)
      inc computer.ip, 4
    of Eq:
      checkOperandMode(3)
      op3 = ord(op1 == op2)
      inc computer.ip, 4
    of Arb:
      inc computer.rb, op1
      inc computer.ip, 2
    of End:
      computer.halted = true
      break # Exit program.
    else:
      raise newException(ValueError, "Invalid opcode")

proc giveInput*(computer: var Computer; value: int) =
  ## Provide computer with an input value and resume execution.
  computer.inputAvailable = true
  computer.input = value
  computer.run()

proc takeOutput*(computer: var Computer): int =
  ## Get a value from computer and resume execution.
  assert computer.outputAvailable
  computer.outputAvailable = false
  result = computer.output
  computer.run()
