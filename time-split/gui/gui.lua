require 'util.formatting'
require 'util.array'
require 'constants'


function create_table(frame, ticks)
    local table = frame.add { type = "table", name = "table", column_count = 4, draw_vertical_lines = true }
    local player_global = global.players[PLAYER_INDEX]
    local reference_checkpoints = player_global["reference_checkpoints"]
    local current_checkpoints = player_global["current_checkpoints"]
    local timesplit_set = false

    for _, ref_entry in pairs(reference_checkpoints) do
        table.add { type = "label", caption = { "mod-setting-name." .. ref_entry.name }, style = "padded_label" }

        local current_diff_label = table.add { type = "label", caption = "-", style = "padded_label" }
        local diff = 0

        table.add { type = "label", caption = tick_to_timestamp(ref_entry.tick), style = "padded_label" }
        local current_timestamp_label = table.add { type = "label", caption = "-", style = "padded_label" }
        local curr_entry = find(current_checkpoints, ref_entry.name, "name")
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
