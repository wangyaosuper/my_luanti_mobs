local esc = core.formspec_escape
local S = pixelart.mod.translator
local privileges = pixelart.settings.privileges
local error_id = pixelart.ids.error
local modname = pixelart.mod.name


-- Show an error formspec
--
-- When called, this function shows a formspec meant as error dialog. The
-- provided title and data are shown. Both need to be strings and are
-- formspec-escaped in the resulting code.
--
-- The `title` should not be too long. It is shown in a 9 formspec units wide
-- field. The `data` can be as long as needed. It is shown in an automatically
-- scrollable non-interactive textarea.
--
-- A shorthand for insufficient privileges exists. When providing `'privs'`
-- as title, `data` needs to be a table of missing privileges. This then is
-- automatically parsed into an error message about missing privileges.
--
-- @param playername Name of the player to show the formspec to
-- @param title      Short title of the message
-- @param data       An arbitrary long error message
pixelart.show_error = function (playername, title, data)

    -- Short-hand for insufficient privileges
    if title == 'privs' then
        local pl = ''
        -- @TRANSLATORS: This is a single unordered list entry
        for _,priv in pairs(data) do pl = pl..S('* @1', priv)..'\n' end
        title = S('Insufficient privileges')
        data = S('In order to interact with the pixelart mod you need to '
            ..'have the following player privileges set.')..'\n\n'..pl
    end

    local error = (table.concat({
        'formspec_version[10]',
        'size[10,8]',
        'bgcolor[#2e3436;false;]',

        -- Title
        'container[0.25,0.25]',
        '  box[0,0;9.5,1;+color]',
        '  style_type[label;font=bold]',
        '  label[0.25,0.50;+title]',
        'container_end[]',

        -- Body
        'container[0.25,1.5]',
        '  box[0,0;9.5,5;+color]',
        '  textarea[0.25,0.25;9,4.5;;;+data]',
        'container_end[]',

        -- Navigation
        'container[0.25,6.75]',
        '  box[0,0;9.5,1;+color]',
        '  button_exit[0.25,0.25;2.5,0.5;close;+close]',
        'container_end[]'

    }, ' ')):gsub('%+%w+', {
        ['+color'] = '#888a8550',
        ['+close'] = esc(S('Close')),
        ['+title'] = esc(title),
        ['+data'] = esc(data)
    })

    core.show_formspec(playername, error_id, error)
end
