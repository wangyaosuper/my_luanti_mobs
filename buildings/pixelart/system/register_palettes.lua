local S = pixelart.mod.translator
local load_builtin = pixelart.settings.load_builtin
local builtin_path = pixelart.paths.modpath..'palettes'..DIR_DELIM
local world_path = pixelart.paths.world_path..'palettes'..DIR_DELIM


-- Usable palette definition table
--
-- Fetch and sanitize the palette data and PixelSpecs from the raw loaded
-- palette file and return it as a reusable table.
--
-- @param palette Raw palette data
-- @param id      Palette ID
-- @param builtin Whether the palette is built-in (`true`) or not (`false`)
--
-- @return table Parsed/Sanitized palette table for registration
local get_data = function (palette, id, builtin)
    local PixelSpecs = {}
    local palette_name = palette.name or S('Unnamed (@1)', id)
    local palette_description = palette.description or palette_name

    for _,PixelSpec in pairs(palette.pixels or {}) do
        local color = PixelSpec.color or PixelSpec
        local name = PixelSpec.name or color
        table.insert(PixelSpecs, { color = color, name = name })
    end

    return {
        id = id,
        pixels = PixelSpecs,
        builtin = builtin,
        name = palette_name,
        curator = palette.curator,
        description = palette_description
     }
end


-- Optionally register built-in palettes
--
-- The palettes are loaded fromt he built-in location. Administrators can
-- disable built-in palettes loading by setting `pixelart_load_builtin = false`
-- in the world-specific configuration.
--
-- @see The mod’s documentation on how to set that
if pixelart.settings.load_builtin == true then
    for _,palette_file in pairs(core.get_dir_list(builtin_path, false)) do
        local id = palette_file:gsub('%.lua', '')
        local def = dofile(builtin_path..palette_file)
        pixelart.palettes.registered[id] = get_data(def, id, true)
    end
end


-- Register world-specific palettes
--
-- Palettes are loaded from `./worlds/worldname/_pixelart/palettes/*.lua` if
-- the path exists. Otherwise this iteration does nothing.
--
-- @see core.get_dir_list() Luanti API documentation
for _,palette_file in pairs(core.get_dir_list(world_path, false)) do
    local id = palette_file:gsub('%.lua', '')
    local def = dofile(world_path..palette_file)
    pixelart.palettes.registered[id] = get_data(def, id, false)
end


-- Validate for pixels
--
-- Palette is removed if it has no pixels, otherwise the ID is stored
-- for sorting.
for _, palette in pairs(pixelart.palettes.registered) do
    if #palette.pixels > 0 then
        table.insert(pixelart.palettes.ordered_ids, palette.id)
    else
        pixelart.palettes.registered[palette.id] = nil
    end
end


-- Sort valid/registered palettes
table.sort(pixelart.palettes.ordered_ids)
