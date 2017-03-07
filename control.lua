cheat_comb = require('cheat_comb');

script.on_event(defines.events.on_tick, function(event)
    cheat_comb.tick(event)
end)
script.on_event(defines.events.on_built_entity, function(event)
    cheat_comb.built(event)
end)
script.on_event(defines.events.on_robot_built_entity, function(event)
    cheat_comb.built(event)
end)

script.on_event(defines.events.on_player_created, function(event)
    local player = game.players[event.player_index]
    player.insert({name="cheat-combinator", count=5})
end)
