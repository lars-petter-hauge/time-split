local timestamp_pattern = "(%d%d):(%d%d):(%d%d)"

function padded_to_string(number)
    if number < 10 then
        return "0" .. tostring(number)
    end
    return tostring(number)
end

function tick_to_timestamp(tick, truncated)
    truncated = truncated or false

    local seconds = tick / 60
    local hours = math.floor(seconds / 3600)
    seconds = seconds % (3600)
    local mins = math.floor(seconds / (60))
    seconds = math.floor(seconds % (60))
    if not truncated or hours > 0 then
        return padded_to_string(hours) .. ":" .. padded_to_string(mins) .. ":" .. padded_to_string(seconds)
    end
    if mins > 0 then
        return padded_to_string(mins) .. ":" .. padded_to_string(seconds)
    end
    return padded_to_string(seconds)
end

function timestamp_to_tick(timestamp)
    local start, _, hours, minutes, seconds = string.find(timestamp, timestamp_pattern)
    if start == nil then
        return nil
    end
    return hours * 216000 + minutes * 3600 + seconds * 60
end

function set_caption_and_apply_style(label, value)
    local sign = "+"
    local font = "padded_red"
    if value < 0 then
        sign = "-"
        value = value * -1
        font = "padded_green"
    end
    label.caption = sign .. tick_to_timestamp(value, true)
    label.style.font = font
end
