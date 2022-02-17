--
--    
--        
--            they/them

local active_preset = 1
local active_output = 1

local button_state = { 0, 0, 0 }
local browsing = 0

local view = 1

local io_map = {
  {
    _input = 'A',
    _outputs = {
      { text = 'A', enabled = 0, data = 102 },
      { text = 'B', enabled = 0, data = 103 },
      { text = 'C', enabled = 0, data = 104 },
      { text = 'D', enabled = 0, data = 105 }
    }
  },
  {
    _input = 'B',
    _outputs = {
      { text = 'A', enabled = 0, data = 106 },
      { text = 'B', enabled = 0, data = 107 },
      { text = 'C', enabled = 0, data = 108 },
      { text = 'D', enabled = 0, data = 109 }
    }
  },
  {
    _input = 'C',
    _outputs = {
      { text = 'A', enabled = 0, data = 110 },
      { text = 'B', enabled = 0, data = 111 },
      { text = 'C', enabled = 0, data = 112 },
      { text = 'D', enabled = 0, data = 113 }
    }
  },
  {
    _input = 'D',
    _outputs = {
      { text = 'A', enabled = 0, data = 114 },
      { text = 'B', enabled = 0, data = 115 },
      { text = 'C', enabled = 0, data = 116 },
      { text = 'D', enabled = 0, data = 117 }
    }
  },
}

local presets = {
  {
    0, 0, 0, 0, 
    0, 0, 0, 0, 
    0, 0, 0, 0, 
    0, 0, 0, 0,
  }, 
  {
    0, 0, 0, 0, 
    0, 0, 0, 0, 
    0, 0, 0, 0, 
    0, 0, 0, 0,
  }, 
  {
    0, 0, 0, 0, 
    0, 0, 0, 0, 
    0, 0, 0, 0, 
    0, 0, 0, 0,
  },
  {
    0, 0, 0, 0, 
    0, 0, 0, 0, 
    0, 0, 0, 0, 
    0, 0, 0, 0,
  }, 
  {
    0, 0, 0, 0, 
    0, 0, 0, 0, 
    0, 0, 0, 0, 
    0, 0, 0, 0,
  }, 
  {
    0, 0, 0, 0, 
    0, 0, 0, 0, 
    0, 0, 0, 0, 
    0, 0, 0, 0,
  },
  {
    0, 0, 0, 0, 
    0, 0, 0, 0, 
    0, 0, 0, 0, 
    0, 0, 0, 0,
  }, 
  {
    0, 0, 0, 0, 
    0, 0, 0, 0, 
    0, 0, 0, 0, 
    0, 0, 0, 0,
  }, 
  {
    0, 0, 0, 0, 
    0, 0, 0, 0, 
    0, 0, 0, 0, 
    0, 0, 0, 0,
  }
}

local shift_map = {
  A = 10,
  B = 11,
  C = 12,
  D = 13,
  E = 14,
  F = 15,
  G = 16,
  H = 17,
  I = 18
}

local m = midi.connect(1)
local o = midi.connect(2)

function init()
  local f = io.open(_path.data .. 'they/them/presets.lua', "r")
  
  if f ~= nil then
    io.close(f)
    load_state()
    load_preset()
  end
     
  redraw()
end

function draw_io()
  screen.clear()
  
  if view == 1 then
    local current_y = 10
    
    screen.move(0, current_y)
    screen.font_face(8)
    screen.font_size(14)
    
    for i = 1, #io_map do
      screen.level(3)
      screen.text(io_map[i]._input .. '  ')
      
      for j = 1, #io_map[i]._outputs do
        local level = io_map[i]._outputs[j].enabled == 1 and 5 or 1
        level = browsing == 0 and j + 4*(i - 1) == active_output and 15 or level
        
        screen.level(level)
        screen.text(io_map[i]._outputs[j].text .. ' ')
        screen.level(1)
      end
      
      current_y = current_y + 15
      screen.move(0, current_y)
    end
  end
  
  screen.update()
end

function draw_presets()
  if view == 1 then
    local current_x = 80
    local current_y = 10
    
    screen.move(current_x, current_y)
    
    for i = 1,3 do
  
      for j = 1,3 do
        local preset = j + 3*(i - 1)
        screen.level(preset == active_preset and 15 or 1)
        screen.text(preset .. ' ')
      end
      
      current_y = current_y + 15
      screen.move(current_x, current_y)
    end
  end
  
  screen.update()
end

function load_preset()
  for i = 1, #presets[active_preset] do 
    local _in = math.ceil(i/4)
    io_map[_in]._outputs[i - 4*(_in - 1)].enabled = presets[active_preset][i]
  end
  
  send_all_data()
  draw_io()
end

function send_data(_in, _out, state)
  local cc = _out.data
  local value = state == 1 and 1 or 127
end

function send_all_data()
  for i = 1, #presets[active_preset] do
    local _in = math.ceil(i/4)
    local _output = io_map[_in]._outputs[i - 4*(_in - 1)]
    send_data(_in, _output, _output.enabled)
  end
end

function redraw()
  draw_io()
  draw_presets()
end

function key(n,z)
  button_state[n] = z
  
  if n == 2 and z == 0 then
    local active_row = math.ceil(active_output / 4)
    local active_col = active_output - 4*(active_row - 1)
    local output_active = io_map[active_row]._outputs[active_col]
    
    output_active.enabled = output_active.enabled == 0 and 1 or 0

    presets[active_preset][active_col] = output_active.enabled
    -- send_data(active_row, active_output, output_active.enabled)
    redraw()
  end
  
  if n == 3 and z == 0 then
    save_state()
  end
end

function enc(n,d)
  if n == 1 then
    view = util.clamp(view + d, 1, 2)
    redraw()
  end
  if n == 2 then
    browsing = 0
    active_output = util.clamp(active_output + d, 1, 16)
    redraw()
  end
  if n == 3 then
    browsing = 1
    active_preset = util.clamp(active_preset + d, 1, 9)
    load_preset()
    redraw()
  end
end

function keyboard.code(code, value)
  browsing = 1
  
  if value == 0 then
    if tonumber(code) ~= nil and tonumber(code) < 10 then
      active_preset = math.floor(code)
      load_preset()
      redraw()
    else 
      print(shift_map[code])
    end
  end
end

function Data(d)
  for k, v in pairs(d) do
    for i = 1, #v do
      presets[tonumber(string.sub(k, 5, 5))][i] = v[i]
    end
  end
end

function save_state()
  print('saving state..')
  saving_state = true
  
  local file = io.open(_path.data .. 'they/them/presets.lua', 'w+')
  io.output(file)
  
  io.write('Data{\n')
  for i = 1, #presets do
    io.write('slot' .. i .. '={')
    for j = 1, #presets[i] do
      io.write(presets[i][j] .. ',')
    end
    io.write('},\n')
  end
  io.write('}')

  io.close(file)
end

function load_state()
  dofile(_path.data .. 'they/them/presets.lua')
end