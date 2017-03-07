-- cache the circuit networks to speed up performance
function update_net_cache(ent)
  if not net_cache then
    net_cache = {}
  end

  local ent_cache = net_cache[ent.unit_number]
  if not ent_cache then
    ent_cache = {last_update=-1}
    net_cache[ent.unit_number] = ent_cache
  end

  -- get the circuit networks at most once per tick per entity
  if game.tick > ent_cache.last_update then

    if not ent_cache.red_network or not ent_cache.red_network.valid then
      ent_cache.red_network = ent.get_circuit_network(defines.wire_type.red)
    end

    if not ent_cache.green_network or not ent_cache.green_network.valid then
      ent_cache.green_network = ent.get_circuit_network(defines.wire_type.green)
    end

    ent_cache.last_update = game.tick
  end
  return ent_cache;
end

-- Return integer value for given Signal: {type=, name=}
function get_signal_value(ent,signal)
  if signal == nil or signal.name == nil then return(0) end
  local ent_cache = update_net_cache(ent)

  local signal_val = 0

  if ent_cache.red_network then
    signal_val = signal_val + ent_cache.red_network.get_signal(signal)
  end

  if ent_cache.green_network then
    signal_val = signal_val + ent_cache.green_network.get_signal(signal)
  end

  -- correctly handle under/overflow, thanks to DaveMcW
  if signal_val > 2147483647 then signal_val = signal_val - 4294967296 end
  if signal_val < -2147483648 then signal_val = signal_val + 4294967296 end

  return signal_val;
end

-- Return array of signal groups. Each signal group is an array of Signal: {signal={type=, name=}, count=}
function get_all_signals(ent)
  local ent_cache = update_net_cache(ent)

  local signal_groups = {}
  if ent_cache.red_network then
    signal_groups[#signal_groups+1] = ent_cache.red_network.signals
  end

  if ent_cache.green_network then
    signal_groups[#signal_groups+1] = ent_cache.green_network.signals
  end

  return signal_groups
end

return {
    get_signal_value=get_signal_value,
    get_all_signals=get_all_signals
}
