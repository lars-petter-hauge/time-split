require "gui/gui"
require "util/array"
require "util/formatting"
require "constants"

script.on_init(function()
    global.players = {}
end)

function populate_globals()
    global.players[PLAYER_INDEX] = { rocket_launched = false, reference_checkpoints = {},
        current_checkpoints = {}, compact_view = false }
    local player = game.get_player(PLAYER_INDEX)

    for _, entry in ipairs(SETTING_TABLE) do
        local setting = game.players[PLAYER_INDEX].mod_settings[entry.setting_name]
        local tick = timestamp_to_tick(setting.value)
        if tick == nil then
            tick = DEFAULT_TICK
            player.print("Mod Time-Split: Was not able to parse the timestamp for item <" ..
                entry.display_name ..
                ">, got: <" .. setting.value ..
                ">, must be of the required pattern 00:00:00. Fallback to " ..
                tick_to_timestamp(tick))
        end
        table.insert(global.players[PLAYER_INDEX]["reference_checkpoints"],
            { name = entry.setting_name, tick = tick })
    end
end

script.on_event(defines.events.on_player_created, function(event)
    populate_globals()
    local player = game.get_player(PLAYER_INDEX)
    local screen = player.gui.screen
    create_main_ui(screen)
end)

script.on_event(defines.events.on_player_crafted_item, function(event)
    local item_name = event.item_stack.name
    local player_global = global.players[PLAYER_INDEX]
    local reference_checkpoints = player_global["reference_checkpoints"]

    for _, ref_entry in pairs(reference_checkpoints) do
        if (ref_entry.name == item_name) and find(player_global["current_checkpoints"], item_name, "name") == nil then
            table.insert(player_global["current_checkpoints"], { name = ref_entry.name, tick = game.ticks_played })
        end
    end
end)

script.on_event(defines.events.on_research_finished, function(event)
    local technology_name = event.research.name
    local player_global = global.players[PLAYER_INDEX]
    local reference_checkpoints = player_global["reference_checkpoints"]

    for _, ref_entry in pairs(reference_checkpoints) do
        if ref_entry.name == technology_name then
            table.insert(player_global["current_checkpoints"], { name = ref_entry.name, tick = game.ticks_played })
        end
    end
end)

script.on_event(defines.events.on_rocket_launched, function(event)
    local player_global = global.players[PLAYER_INDEX]

    if player_global.rocket_launched == false then
        table.insert(player_global["current_checkpoints"], { name = "there-is-no-spoon", tick = game.ticks_played })
        player_global["rocket_launched"] = false
    end
end)

function cb_compact_button()
    local player_global = global.players[PLAYER_INDEX]
    local player = game.get_player(PLAYER_INDEX)
    if player_global["compact_view"] then
        player_global["compact_view"] = false
        player.gui.screen.timesplit_mainframe.style.size = { 400, 320 }
    else
        player_global["compact_view"] = true
        player.gui.screen.timesplit_mainframe.style.size = { 400, 155 }
    end
    update_table()
end

script.on_event(defines.events.on_gui_click, function(event)
    if event.element.name == "compact_button" then cb_compact_button()
    end

end)

function initialized_ui(player)
    -- This mod only makes sense if it is part of the save from the creation of the game.
    if find(player.gui.screen.children_names, "timesplit_mainframe") then
        return true
    end
    return false
end

function update_table()
    local player = game.get_player(PLAYER_INDEX)
    if not initialized_ui(player) then return end

    local content_frame = player.gui.screen.timesplit_mainframe.content_frame
    -- Clear and create new is not the most efficient way..
    content_frame.clear()
    create_table(content_frame, game.ticks_played)
end

function update_runtime()
    local player = game.get_player(PLAYER_INDEX)
    if not initialized_ui(player) then return end

    local current_time_label = player.gui.screen.timesplit_mainframe.header_frame.current_time
    local timestamp = tick_to_timestamp(game.ticks_played)
    current_time_label.caption = "Running time:  " .. timestamp
end

script.on_nth_tick(60, update_table)
script.on_nth_tick(10, update_runtime)
