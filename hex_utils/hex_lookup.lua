local hexLookup = {}

function hexLookup.new(json_file_path)
    local hexLookup = {}
    local symbol_registry_file = fs.open(json_file_path, "r")
    local symbol_file_json = textutils.unserialiseJSON(symbol_registry_file.readAll())
    if not symbol_registry_file then
        error("Could not find symbol-registry.json in the current directory")
        return
    end
    local symbol_registry = {}
    for name, data in pairs(symbol_file_json) do
        symbol_registry[data["angles"]] = {
            ["pattern_name"] = name,
            ["start_direction"] = data["direction"],
        }
    end
    hexLookup.symbol_registry = symbol_registry
    return hexLookup
end

function hexLookup:get_pattern_data(pattern)
    if self.symbol_registry[pattern] == nil then
        return false
    else
        return self.symbol_registry[pattern]
    end
end

return hexLookup