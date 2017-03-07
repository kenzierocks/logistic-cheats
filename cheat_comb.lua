local function directionX(dir)
    if dir == defines.direction.east then
        return 1
    elseif dir == defines.direction.west then
        return -1
    else
        return 0
    end
end

local function directionY(dir)
    if dir == defines.direction.north then
        return -1
    elseif dir == defines.direction.south then
        return 1
    else
        return 0
    end
end

local function getConnectedContainer(ent)
    local xOff = directionX(ent.direction)
    local yOff = directionY(ent.direction)
    local position = {x=ent.position.x + xOff, y=ent.position.y + yOff}
    local connectedEntities = ent.surface.find_entities_filtered({
        position = position,
        type = "container"
    })
    for _,entity in pairs(connectedEntities) do
        if entity.valid then
            return entity
        end
    end
end

local function tickCombinator(comb)
    local b = comb.get_or_create_control_behavior()
    if not b.enabled then return end

    local params = b.parameters.parameters
    local cont = getConnectedContainer(comb)

    if not cont then return end

    -- take all the signals that are items
    for _,sig in pairs(params) do
        if sig.signal.type == "item" then
            -- empty name means no signal
            if sig.signal.name then
                -- insert missing items
                local name = sig.signal.name
                local cnt = sig.count
                local current = cont.get_item_count(name)
                local add = cnt - current
                local s = {name=name, count=math.abs(add)}

                if add > 0 then cont.insert(s)
                elseif add < 0 then cont.remove_item(s)
                end
            end
        end
    end
end

local function tickCombinators(event)
    if global.cheat_combs then
        for _,comb in pairs(global.cheat_combs) do
            if comb.valid and comb.name == "cheat-combinator" then
                tickCombinator(comb)
            else
                global.cheat_combs[_]=nil
            end
        end
    end
end

local function builtCombinator(event)
    local ent = event.created_entity
    if not ent or not ent.valid then return end
    if ent.name == "cheat-combinator" then
        if not global.cheat_combs then global.cheat_combs={} end
        table.insert(global.cheat_combs, ent)
    end
end

return {
    tick=tickCombinators,
    built=builtCombinator
}
