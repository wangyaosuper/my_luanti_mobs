local modname   = core.get_current_modname()
local modpath   = core.get_modpath(modname)..DIR_DELIM
local worldpath = core.get_worldpath()..DIR_DELIM
local syspath   = modpath..'system'..DIR_DELIM
local S = core.get_translator(modname)

-- World-specific configuration
--
-- * `world_path` is not the `worldpath` but the path that is used for the
--    mod’s settings for that world: `./worlds/worldname/_pixelart/`.
--
-- * `world_settings` is the actual file in `world_path` that holds the parsed
--   settings for that world
--
-- * The settings file in that directory can either be `pixelart_settings.ini`
--   or `pixelart_settings.conf`. If the ini file is empty or nonexistent the
--   conf file will be loaded instead.
--
-- @see Luanti API documentation for `Settings()
local world_path     = worldpath..'_'..modname..DIR_DELIM
local world_settings = Settings(world_path..'pixelart_settings.ini')
if next(world_settings:to_table()) == nil then
    world_settings = Settings(world_path..'pixelart_settings.conf')
end


-- Initialize global table
--
-- Functions are directly registered on top-level of the table. All predefined
-- values are placed in sub-tables.
pixelart = {
    mod = {
        translator = S,
        name = modname,
        title = S('Pixelart'),
        description = S('Colored blocks for pixelart and voxel sculptures.')
    },
    paths = {
        modpath = modpath,
        world_path = world_path
    },
    ids = {
        selector = modname..':selector',
        error = modname..':error',
        palette_meta = modname..':palette',
        access_node = modname..':selector_access_node',
    },
    palettes = {
        registered = {},
        ordered_ids = {},
    },
    settings = {
        access_node = world_settings:get_bool('pixelart_access_node', true),
        chat_command = world_settings:get_bool('pixelart_chat_command', true),
        fast_digging = world_settings:get_bool('pixelart_fast_digging', false),
        hide_nodes = world_settings:get_bool('pixelart_hide_nodes', true),
        load_builtin = world_settings:get_bool('pixelart_load_builtin', true),
        max_pixels = world_settings:get('pixelart_max_pixels') or 128,
        noise_opacity = world_settings:get('pixelart_noise_opacity') or 32,
        privileges = {}
    }
}


-- Parse privileges
--
-- Privileges are taken form the `pixelart_privileges` world-specific setting
-- and are parsed into a privileges table. If not present, `interact` is used
-- as default privilege.
--
-- The individual privileges can be strings containing uppercase and lowercase
-- letters, punctuation characters, and numbers.
--
-- Example:
--
-- pixelart_privileges = interact, foo.bar, my_cool_priv
--
-- This results in `interact`, `foo.bar` and `my_cool_priv` being checked when
-- a player wants to interact with parts of the mod.
--
-- The commas are optional, there needs to be at least one space character
-- between individual definitions. The parsing is deliberately very simple to
-- allow even “weird” privileges like `my_cool_mod:my_privilege` which is a
-- super uncommon but unambiguous privilege name.
local privileges = world_settings:get('pixelart_privileges') or 'interact'
for priv in string.gmatch(privileges, '[^%s,]+') do
    pixelart.settings.privileges[(priv:gsub('[^%w%d%p]+',''))] = true
end


-- Load functionality
--
-- The order is relevant. Some functions localize definitions from previous
-- functions (i.e. the node registration needs access to the error formspec
-- definition, because it is used there).
dofile(syspath..'register_palettes.lua')   -- Validate all palette types
dofile(syspath..'register_error.lua')      -- Error message formspec
dofile(syspath..'register_selector.lua')   -- Selector dialog formspec
dofile(syspath..'register_fields.lua')     -- “Server-side” for the formspecs
dofile(syspath..'register_interfaces.lua') -- Access node and chat command
dofile(syspath..'register_nodes.lua')      -- Convert palettes into the nodes


-- Clean up global table
--
-- The mod is not intended to be used as an API, so the global table that was
-- used to exchange information and functions is removed to not clutter the
-- global namespace with mod-specific tables.
pixelart = nil
