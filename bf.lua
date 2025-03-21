--[[
TODO: configuration file for some brainfuck behavior like tape size
]]

INC = 0
RIGHT = 1
LEFT = 2
OPENLOOP = 3
CLOSELOOP = 4
OUTPUT = 5
INPUT = 6
DEC = 7

function tape(size)
  local cells = {}

  local pointer = 1

  for i = 1, size do
    table.insert(cells, 0)
  end

  return {
    cells = cells,
    pointer = pointer
  }
end

---@param code string
function brainfuck_parse(code)
  local parsed_code = {}

  for i = 1, string.len(code) do
    local c = code:sub(i, i)

    if c == "+" then
      table.insert(parsed_code, INC)
    elseif c == "-" then
      table.insert(parsed_code, DEC)
    elseif c == ">" then
      table.insert(parsed_code, RIGHT)
    elseif c == "<" then
      table.insert(parsed_code, LEFT)
    elseif c == "." then
      table.insert(parsed_code, OUTPUT)
    elseif c == "," then
      table.insert(parsed_code, INPUT)
    elseif c == "[" then
      table.insert(parsed_code, OPENLOOP)
    elseif c == "]" then
      table.insert(parsed_code, CLOSELOOP)
    end
  end

  return parsed_code
end

function brainfuck_eval(program)
  local tp = tape(10000)
  local memory = tp.cells
  local ptr = tp.pointer
  local stack = {}
  local pc = 1

  while pc <= #program do
    local cmd = program[pc]

    if cmd == RIGHT then
      ptr = ptr + 1
    elseif cmd == LEFT then
      ptr = ptr - 1
    elseif cmd == INC then
      if memory[ptr] > 256 then
        print("Cell overflow.")
        os.exit(1)
      end
      memory[ptr] = (memory[ptr] + 1)
    elseif cmd == DEC then
      memory[ptr] = (memory[ptr] - 1)
    elseif cmd == OUTPUT then
      io.write(string.char(memory[ptr]))
    elseif cmd == OPENLOOP then
      if memory[ptr] == 0 then
        local open_brackets = 0 -- in total we have currently 1, but somehow with the number 1 as initial it doesn't works
        for i=1, #program do
          if program[pc] == OPENLOOP then open_brackets = open_brackets + 1 end
          if program[pc] == CLOSELOOP then open_brackets = open_brackets - 1 end
          pc = pc + 1
        end
        if open_brackets > 0 then
          error("unbalanced loop "..open_brackets)
        end
      else
        table.insert(stack, pc)
      end
    elseif cmd == CLOSELOOP then
      if memory[ptr] ~= 0 then
        pc = stack[#stack]
      else
        table.remove(stack)
      end
    elseif cmd == INPUT then
      memory[ptr] = tonumber(io.read(1))
      if memory[ptr] >= 256 then
        print("Cell overflow.")
        os.exit(1)
      end
    end

    pc = pc + 1
  end
end

assert(#arg > 0, "Expected input file.")

for i=1, #arg do
  local file = io.open(arg[i], "r")
  if file then
    local txt = file:read("a")
    local program = brainfuck_parse(txt)
    brainfuck_eval(program)
    file:close()
  end
end