require 'util.formatting'
require 'util.array'
require 'constants'


function create_main_ui(screen)
    local main_frame = screen.add {
        type = "frame",
        name = "timesplit_mainframe",
        caption = "Time Split",
        direction = "vertical",
    }
    local header_frame = main_frame.add {
        type = "frame",
        name = "header_frame",
        direction = "horizontal",
    }
    local current_time_label = header_frame.add { type = "label", name = "current_time",
        caption = "-" }
    current_time_label.style.font = "header"

    local compact_button = header_frame.add { type = "sprite-button", name = "compact_button",
        sprite = "compress" }
    compact_button.style.size = { 24, 24 }

    local icon_only_button = header_frame.add { type = "sprite-button", name = "icon_only_button",
        sprite = "icons_only" }
    icon_only_button.style.size = { 24, 24 }

    main_frame.add {
        type = "scroll-pane",
        name = "content_frame",
        direction = "vertical"
    }

    main_frame.style.size = { 400, 320 }
end

function create_table(frame, ticks)
    local table = frame.add { type = "table", name = "table", column_count = 4, draw_vertical_lines = true }
    local player_global = global.players[PLAYER_INDEX]
    local reference_checkpoints = player_global["reference_checkpoints"]
    local current_checkpoints = player_global["current_checkpoints"]
    local compact_view = player_global["compact_view"]
    local timesplit_set = false
    local diff = 0

    for _, ref_entry in pairs(reference_checkpoints) do
        local curr_entry = find(current_checkpoints, ref_entry.name, "name")

        local is_goal_entry = ref_entry.name == "there-is-no-spoon"
        local is_at_timesplit = curr_entry == nil and not timesplit_set
        -- Make sure to include next entry to beat and final entry
        -- All other entries are discarded
        if compact_view and (not is_at_timesplit and not is_goal_entry) then
            goto continue
        end

        table.add { type = "label", caption = { "mod-setting-name." .. ref_entry.name }, style = "padded_label" }
        local current_diff_label = table.add { type = "label", caption = "-", style = "padded_label" }
        table.add { type = "label", caption = tick_to_timestamp(ref_entry.tick), style = "padded_label" }
        local current_timestamp_label = table.add { type = "label", caption = "-", style = "padded_label" }

        if curr_entry ~= nil then
            diff = curr_entry.tick - ref_entry.tick
            set_caption_and_apply_style(current_diff_label, diff)
            current_timestamp_label.caption = tick_to_timestamp(curr_entry.tick)
        elseif not timesplit_set then
            diff = ticks - ref_entry.tick
            set_caption_and_apply_style(current_diff_label, diff)
            timesplit_set = true
        end

        ::continue::
    end
end
