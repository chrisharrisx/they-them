--
--    
--        
--            they/them

-- TODO:
-- refactoring screen updating for each draw method

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

local active_preset = 1
local active_output = 1

local button_state = { 0, 0, 0 }
local browsing = 0
local setting_tempo = 0

local view = 1

local m = midi.connect(1)
local o = midi.connect(2)

local _metro
local bpm = 120
local spm = 60
local run_state = 0

function init()
  local f = io.open(_path.data .. 'they/them/presets.lua', "r")
  _metro = metro.init(step, spm/bpm)
  
  if f ~= nil then
    io.close(f)
    load_state()
    load_preset()
  end
     
  redraw()
end

function draw_io()
  screen.clear()
  
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
    
    current_y = current_y + 14
    screen.move(0, current_y)
  end
end

function draw_crow()
  screen.clear()
  
  local current_y = 10
  
  screen.move(0, current_y)
  screen.font_face(8)
  screen.font_size(14)
  
  for i = 1,4 do
    screen.level(3)
    screen.text(i .. '  ')
      
    screen.level(1)
    screen.text('CV' .. ' ' .. '0.1')
    
    current_y = current_y + 14
    screen.move(0, current_y)
  end
end

function draw_presets()
  local current_x = 76
  local current_y = 10
  
  screen.move(current_x, current_y)
  
  for i = 1,3 do
    for j = 1,3 do
      local preset = j + 3*(i - 1)
      screen.level(preset == active_preset and 15 or 1)
      screen.text(preset .. ' ')
    end
    current_y = current_y + 14
    screen.move(current_x, current_y)
  end
end

function draw_playstate()
  local current_x = 76
  local current_y = 64
  
  screen.move(current_x, current_y)
  screen.font_face(1)
  screen.font_size(8)
  screen.level(1)
  screen.text(bpm)
  
  current_x = current_x + 17
  screen.move(current_x, current_y)
  
  if run_state == 0 then
    screen.text('||')
  else
    screen.text('|')
    screen.move(current_x, current_y)
    screen.text('>')
  end
  
  screen.font_face(8)
  screen.font_size(14)
  screen.level(1)
end

function draw_nav()
  local current_x = 120
  local current_y = 4
  
  screen.move(current_x, current_y)
  screen.font_face(1)
  screen.font_size(8)
  
  for i = 1, 4 do
    screen.level(view == i and 15 or 1)
    screen.text('o')
    current_y = current_y + 7
    screen.move(current_x, current_y)
  end
  
  current_x = 1
  current_y = 64
  screen.move(current_x, current_y)
  
  if view == 1 then
    screen.text('MIDI')
  end
  if view == 2 then
    screen.text('CROW')
  end
  
  screen.font_face(8)
  screen.font_size(14)
  screen.level(1)
end

function redraw()
  if view == 1 then
    draw_io()
  end
  if view == 2 then
    draw_crow()
  end
  
  draw_presets()
  draw_playstate()
  draw_nav()
  
  screen.update()
end

function step()
  if active_preset < 9 then
    active_preset = active_preset + 1
  else
    active_preset = 1
  end
  load_preset()
  redraw()
end

function load_preset()
  for i = 1, #presets[active_preset] do 
    local _in = math.ceil(i/4)
    io_map[_in]._outputs[i - 4*(_in - 1)].enabled = presets[active_preset][i]
  end
  send_all_data()
end

function send_data(_out, state)
  local cc = _out.data
  local value = state == 1 and 1 or 127
end

function send_all_data()
  for i = 1, #presets[active_preset] do
    local _in = math.ceil(i/4)
    local _output = io_map[_in]._outputs[i - 4*(_in - 1)]
    send_data(_output, _output.enabled)
  end
end

function enc(n,d)
  if n == 1 then
    view = util.clamp(view + d, 1, 4)
    redraw()
  end
  if n == 2 and run_state == 0 then
    browsing = 0
    active_output = util.clamp(active_output + d, 1, 16)
    redraw()
  end
  if n == 3 and button_state[3] == 0 then
    browsing = 1
    active_preset = util.clamp(active_preset + d, 1, 9)
    load_preset()
    redraw()
  end
  if n == 3 and button_state[3] == 1 then
    setting_tempo = 1
    bpm = util.clamp(bpm + d, 6, 600)
    _metro.time = spm/bpm
    redraw()
  end
end

function key(n,z)
  button_state[n] = z
  
  if n == 2 and z == 0 then
    local _in = math.ceil(active_output / 4)
    local _out = active_output - 4 * (_in - 1)
    local _output = io_map[_in]._outputs[_out]
    
    _output.enabled = _output.enabled == 0 and 1 or 0

    presets[active_preset][active_output] = _output.enabled
    save_state()
    load_preset()
    redraw()
    -- send_data(active_row, active_output, output_active.enabled)
  end
  
  if n == 3 and z == 0 and setting_tempo == 0 then
    if run_state == 0 then
      _metro:start()
      run_state = 1
      browsing = 1
    else
      _metro:stop()
      run_state = 0
    end
    redraw()
  end
  
  if n == 3 and z == 0 and setting_tempo == 1 then
    setting_tempo = 0
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
      presets[tonumber(string.sub(k, 7, 7))][i] = v[i]
    end
  end
end

function save_state()
  local file = io.open(_path.data .. 'they/them/presets.lua', 'w+')
  io.output(file)
  
  io.write('Data{\n')
  for i = 1, #presets do
    io.write('preset' .. i .. '={')
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