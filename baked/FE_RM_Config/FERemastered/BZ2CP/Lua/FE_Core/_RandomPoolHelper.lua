--[[ FE:Remastered Random Pool Helper
Written by AI Unit
Version 1.0 7-31-2023 --]]

-- Helper Luas.
require('_GlobalHandler');
require('_GlobalVariables');

local _RandomPools = {}

function _RandomPools.SetupRandomPools(pathNames) 

    -- Use this to store unique numbers for each x value.
    local totalXPathNumbers = 0;
    -- This will be a 2D table. Each entry here will be an X value, the X value will be stored as a table with all of the relevant Y values.
    local xPaths = {};

    -- STEP 1: GET ALL DISTINCT X VALUES.
    for index, label in ipairs(pathNames) do
        -- We are following the format of RandomPool_X_Y_ODF, so we only care about paths starting with RandomPool.
        if (string.sub(label, 1, 10) == "RandomPool") then
            -- Get the length of the path string.
            local length = string.len(label);
            
            -- If we're missing any format, bail.
            local Underscore = string.find(label, "_");
            if (Underscore == nil) then
                return;
            end
    
            local Underscore2 = string.find(label, "_", Underscore + 1);
            if (Underscore2 == nil) then
                return;
            end
            
            local x = tonumber(string.sub(label, Underscore + 1, Underscore2 - 1));

            if (x > totalXPathNumbers) then
                totalXPathNumbers = x;
            end
        end
    end
    -- END STEP 1

    -- STEP 2: GET ALL Y VALUES FOR THAT PATH.
    for i = 1, totalXPathNumbers do
        local xPathYValues = {};

        for index, path in ipairs(pathNames) do
            if (string.sub(path, 1, 12) == "RandomPool_" .. i) then
                table.insert(xPathYValues, path);
            end
        end

        table.insert(xPaths, xPathYValues);
    end

    -- STEP 3: FOR EACH X SET, PICK A RANDOM Y, SPAWN ODF.
    for index, xTable in ipairs(xPaths) do
        local selectedPath = xTable[math.ceil(GetRandomFloat(1, #xTable))];
        BuildObject(string.sub(selectedPath, 16, string.len(selectedPath)), 0, selectedPath);
    end
end

return _RandomPools;