local hexLookup = {}
hexLookup.__index = hexLookup

function hexLookup.new(json_file_path)
    local self = setmetatable({}, hexLookup)
    local symbol_registry_file = fs.open(json_file_path, "r")
    local file_content = symbol_registry_file.readAll()
    local symbol_file_json = textutils.unserialiseJSON(file_content)
    symbol_registry_file.close()
    
    local symbol_registry = {}
    for name, data in pairs(symbol_file_json) do
        if data.pattern then
            symbol_registry[data.pattern] = {
                pattern_name = name,
                start_direction = data.direction
            }
        end
    end
    self.symbol_registry = symbol_registry
    return self
end

function hexLookup:get_pattern_name(pattern)
    if self.symbol_registry[pattern] then
        return self.symbol_registry[pattern].pattern_name
    else
        return ""
    end
end

return hexLookup