local DataStoreService = game:GetService("DataStoreService")
local NexusStore = DataStoreService:GetDataStore("NexusAdmin_Data_v1")

local DataStore = {}

function DataStore.Save(key, data)
    local success, err = pcall(function()
        NexusStore:SetAsync(key, data)
    end)
    return success, err
end

function DataStore.Get(key)
    local data
    local success, err = pcall(function()
        data = NexusStore:GetAsync(key)
    end)
    return data, success, err
end

return DataStore
