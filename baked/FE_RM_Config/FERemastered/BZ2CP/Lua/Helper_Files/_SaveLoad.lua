-- _saveload.lua

local SaveFunctions = {}
local LoadFunctions = {}
local M = {}

-- Convert variable return values into {values}, count
local function box(...)
    return { ... }, select('#', ...)
end

function M.RegisterSave(name, f)
    SaveFunctions[name] = f
end

function M.RegisterLoad(name, f)
    LoadFunctions[name] = f
end

function M.Save()
    local data = {}

    for name, saveFunc in pairs(SaveFunctions) do
        -- store as: { {values...}, count }
        local arr, size = box(saveFunc())
        data[name] = { arr, size }
    end

    return data
end

function M.Load(data)
    for name, packed in pairs(data) do
        local loadFunc = LoadFunctions[name]
        if loadFunc then
            local arr = packed[1]
            local size = packed[2]
            -- Pass the values back into the Load function
            loadFunc(table.unpack(arr, 1, size))
        end
    end
end

return M
