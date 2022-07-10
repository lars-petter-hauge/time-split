local player_index = 1
local timestamp_pattern = "(%d%d):(%d%d):(%d%d)"
local DEFAULT_TICK = 2592000
local SETTING_TABLE = {
    { setting_name = "Automation", type = "technology", item_name = "automation" },
    { setting_name = "Chemical Science", type = "technology", item_name = "chemical-science-pack" },
    { setting_name = "Logistic Science", type = "technology", item_name = "logistic-science-pack" },
    { setting_name = "Production Science", type = "technology", item_name = "production-science-pack" },
    { setting_name = "Rocket Silo", type = "technology", item_name = "rocket-silo" },
    { setting_name = "Rocket Launch", type = "achievement", item_name = "there-is-no-spoon" }, }

function padded_to_string(number)
    if number < 10 then
        return "0" .. tostring(number)
    end
    return tostring(number)
end

function tick_to_timestamp(tick)
    local seconds = tick / 60
    local hours = math.floor(seconds / 3600)
    seconds = seconds % (3600)
    local mins = math.floor(seconds / (60))
    seconds = math.floor(seconds % (60))
    return padded_to_string(hours) .. ":" .. padded_to_string(mins) .. ":" .. padded_to_string(seconds)
end

function timestamp_to_tick(timestamp)
    local start, _, hours, minutes, seconds = string.find(timestamp, timestamp_pattern)
    if start == nil then
        return nil
    end
    return hours * 216000 + minutes * 3600 + seconds * 60
end

function contains(table, value)
    for i = 1, #table do
        if table[i] == value then return true end
    end
    return false
end

function contains_name(table, name)
    for _, entry in ipairs(table) do
        if name == entry.name then
            return true
        end
    end
    return false
end

script.on_init(function()
    global.players = {}
end)

function populate_globals()
    global.players[player_index] = { rocket_launched = false, reference_checkpoints = {}, current_checkpoints = {} }
    local player = game.get_player(player_index)

    for _, entry in ipairs(SETTING_TABLE) do
        local setting = game.players[player_index].mod_settings[entry.setting_name]
        local tick = timestamp_to_tick(setting.value)
        if tick == nil then
            tick = DEFAULT_TICK
            player.print("Mod Time-Split: Was not able to parse the timestamp for item <" ..
                entry.setting_name ..
                ">, got: <" .. setting.value ..
                ">, must be of the required pattern 00:00:00. Fallback to " ..
                tick_to_timestamp(tick))
        end
        table.insert(global.players[player_index]["reference_checkpoints"],
            { name = entry.item_name, tick = tick })
    end
end

script.on_event(defines.events.on_player_created, function(event)
    populate_globals()

    local player = game.get_player(player_index)
    local screen_element = player.gui.screen
    local main_frame = screen_element.add {
        type = "frame",
        name = "timesplit_mainframe",
        caption = "Time Split",
        direction = "vertical",
    }
    local current_time_label = main_frame.add { type = "label", name = "current_time",
        caption = "-" }
    current_time_label.style.font = "header"

    main_frame.style.size = { 350, 350 }
    main_frame.add {
        type = "scroll-pane",
        name = "content_frame",
        direction = "vertical"
    }
end)

script.on_event(defines.events.on_player_crafted_item, function(event)
    local item_name = event.item_stack.name
    local player_global = global.players[player_index]
    local reference_checkpoints = player_global["reference_checkpoints"]

    for _, ref_entry in pairs(reference_checkpoints) do
        if (ref_entry.name == item_name) and not contains_name(player_global["current_checkpoints"], item_name) then
            table.insert(player_global["current_checkpoints"], { name = ref_entry.name, tick = game.ticks_played })
        end
    end
end)

script.on_event(defines.events.on_research_finished, function(event)
    local technology_name = event.technology.name
    local player_global = global.players[player_index]
    local reference_checkpoints = player_global["reference_checkpoints"]

    for _, ref_entry in pairs(reference_checkpoints) do
        if ref_entry.name == technology_name then
            table.insert(player_global["current_checkpoints"], { name = ref_entry.name, tick = game.ticks_played })
        end
    end
end)

script.on_event(defines.events.on_rocket_launched, function(event)
    local player_global = global.players[player_index]

    if player_global.rocket_launched == false then
        table.insert(player_global["current_checkpoints"], { name = "there-is-no-spoon", tick = game.ticks_played })
        player_global["rocket_launched"] = false
    end
end)


function find_matching_entry(array, value, key)
    for _, entry in pairs(array) do
        if entry[key] == value then
            return entry
        end
    end
    return nil
end

function set_caption_and_apply_style(label, value)
    local sign = "+"
    local font = "padded_red"
    if value < 0 then
        sign = "-"
        value = value * -1
        font = "padded_green"
    end
    label.caption = sign .. tick_to_timestamp(value)
    label.style.font = font
end

function create_table(frame, ticks)
    local table = frame.add { type = "table", name = "table", column_count = 4, draw_vertical_lines = true }
    local player_global = global.players[player_index]
    local reference_checkpoints = player_global["reference_checkpoints"]
    local current_checkpoints = player_global["current_checkpoints"]
    local timesplit_set = false

    for _, ref_entry in pairs(reference_checkpoints) do
        local setting_entry = find_matching_entry(SETTING_TABLE, ref_entry.name, "item_name")
        local caption = ref_entry.name
        if setting_entry ~= nil then
            caption = "[" .. setting_entry.type .. "=" .. setting_entry.item_name .. "]" .. setting_entry.setting_name
        end

        table.add { type = "label", caption = caption, style = "padded_label" }

        local current_diff_label = table.add { type = "label", caption = "-", style = "padded_label" }
        local diff = 0

        table.add { type = "label", caption = tick_to_timestamp(ref_entry.tick), style = "padded_label" }
        local current_timestamp_label = table.add { type = "label", caption = "-", style = "padded_label" }
        local curr_entry = find_matching_entry(current_checkpoints, ref_entry.name, "name")
        if curr_entry ~= nil then
            diff = curr_entry.tick - ref_entry.tick
            set_caption_and_apply_style(current_diff_label, diff)
            current_timestamp_label.caption = tick_to_timestamp(curr_entry.tick)
        elseif not timesplit_set then
            diff = ticks - ref_entry.tick
            set_caption_and_apply_style(current_diff_label, diff)
            timesplit_set = true
        end
    end
end

function initialized_ui(player)
    -- This mod only makes sense if it is part of the save from the creation of the game.
    if contains(player.gui.screen.children_names, "timesplit_mainframe") then
        return true
    end
    return false
end

function update_table()
    local player = game.get_player(player_index)
    if not initialized_ui(player) then return end

    local content_frame = player.gui.screen.timesplit_mainframe.content_frame
    -- Clear and create new is not the most efficient way..
    content_frame.clear()
    create_table(content_frame, game.ticks_played)
end

function update_runtime()
    local player = game.get_player(player_index)
    if not initialized_ui(player) then return end

    local current_time_label = player.gui.screen.timesplit_mainframe.current_time
    local timestamp = tick_to_timestamp(game.ticks_played)
    current_time_label.caption = "Running time:  " .. timestamp
end

script.on_nth_tick(60, update_table)
script.on_nth_tick(10, update_runtime)
