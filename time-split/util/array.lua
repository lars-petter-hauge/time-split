
function find(array, value, key)
    -- Searches the array for the value and returns the entry if found
    -- If a key is given, the array is indexed with key to search for value
    -- otherwise each item in array is checked against value.
    -- If not found, nil is returned
    if key == nil then
        for i = 1, #array do
            if array[i] == value then return value end
        end
    else
        for _, entry in pairs(array) do
            if entry[key] == value then
                return entry
            end
        end
    end
    return nil
end
