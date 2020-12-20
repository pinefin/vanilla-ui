local Renderer = {}
local UI = {
    error = false,
    hovered = {},
    cache = {},
}
UI.style = {
    logColor = "5",
    Background = {r = 0, g = 0, b = 0, a = 175},
    Background_Border = {r = 255, g = 0, b = 95, a = 255},
    Checkbox_Text = {r = 255, g = 255, b = 255, a = 255},
    Button_Text = {r = 20, g = 20, b = 20, a = 255},
    Item_Background = {r = 255, g = 255, b = 255, a = 200},
    Item_Hovered = {r = 0, g = 0, b = 0, a = 75},
    Item_Hold = {r = 255, g = 255, b = 255, a = 100},
    Item_Toggled = {r = 255, g = 0, b = 95, a = 255},
}
UI.natives = {}
local GUI = {
    nextSize = nil,
    active = true,
    position = {x = 200, y = 200, w = 600, h = 500},
    item = {x = 0, y = 0, w = 0, h = 0, name = ""},
    prev_item = {x = 0, y = 0, w = 0, h = 0, name = ""},
    cursor = {x = 0, y = 0, old_x = 0, old_y = 0},
    dragging = {Should_Drag = false, Should_Move = false},
    screen = {w = 0, h = 0},
    vars = {sameline = false, menuKey = -1},
    config = {},
}

GUI.screen.w, GUI.screen.h = Citizen.InvokeNative(0x873C9F3104101DD3, Citizen.PointerValueInt(), Citizen.PointerValueInt())

function UI.natives.GetNuiCursorPosition()
    return Citizen.InvokeNative(0xbdba226f, Citizen.PointerValueInt(), Citizen.PointerValueInt())
end
function UI.natives.IsDisabledControlJustPressed(inputGroup, control)
    return Citizen.InvokeNative(0x91AEF906BCA88877, inputGroup, control, Citizen.ReturnResultAnyway())
end
function UI.natives.IsDisabledControlJustReleased(inputGroup, control)
    return Citizen.InvokeNative(0x305C8DCD79DA8B0F, inputGroup, control, Citizen.ReturnResultAnyway())
end
function UI.natives.IsDisabledControlPressed(inputGroup, control)
    return Citizen.InvokeNative(0xE2587F8CBBD87B1D, inputGroup, control, Citizen.ReturnResultAnyway())
end
function UI.natives.IsDisabledControlReleased(inputGroup, control)
    return Citizen.InvokeNative(0xFB6C4072E9A32E92, inputGroup, control, Citizen.ReturnResultAnyway())
end

local function log(error, ...)
    if error then
        UI.error = true
    end
    print(error and "^9[Error]" .. string.format(...) or "^3[Vanilla UI] ^" .. UI.style.logColor .. string.format(...))
end

function Renderer.DrawRect(x, y, w, h, r, g, b, a)
    local _w, _h = w / GUI.screen.w, h / GUI.screen.h
    local _x, _y = x / GUI.screen.w + _w / 2, y / GUI.screen.h + _h / 2
    Citizen.InvokeNative(0x3A618A217E5154F0,_x, _y, _w, _h, r, g, b, a)
end

function Renderer.DrawBorderedRect(x, y, w, h, r, g, b, a)
	Renderer.DrawRect(x, y, 1, h, r, g, b, a)
	Renderer.DrawRect(x, y, w, 1, r, g, b, a)
	Renderer.DrawRect(x + (w - 1), y, 1, h, r, g, b, a)
	Renderer.DrawRect(x, (y - 1) + h, w, 1, r, g, b, a)
end

function Renderer.DrawCursor()
    GUI.cursor.x, GUI.cursor.y = UI.natives.GetNuiCursorPosition()
	Renderer.DrawRect(GUI.cursor.x - 2, GUI.cursor.y - 7, 3, 13, 0, 0, 0, 255)
	Renderer.DrawRect(GUI.cursor.x - 7, GUI.cursor.y - 2, 13, 3, 0, 0, 0, 255)
	Renderer.DrawRect(GUI.cursor.x - 1, GUI.cursor.y - 6, 1, 11, 255, 255, 255, 255)
	Renderer.DrawRect(GUI.cursor.x - 6, GUI.cursor.y - 1, 11, 1, 255, 255, 255, 255)
end

function Renderer.DrawText(x, y, r, g, b, a, text, font, centered, scale)
	Citizen.InvokeNative(0x66E0276CC5F6B9DA, font) --SetTextFont
	Citizen.InvokeNative(0x07C837F9A01C34C9, scale, scale) --SetTextScale
    Citizen.InvokeNative(0xC02F4DBFB51D988B, centered) --SetTextCentre
	Citizen.InvokeNative(0xBE6B23FFA53FB442, r, g, b, a) --SetTextColour
	Citizen.InvokeNative(0x25FBB336DF1804CB, "STRING")
	Citizen.InvokeNative(0x6C188BE134E074AA, text)
	Citizen.InvokeNative(0xCD015E5BB0D96A57, x / GUI.screen.w, y / GUI.screen.h)
end

function Renderer.GetTextWidthS(string, font, scale)
	font = font or 4
	scale = scale or 0.35
	UI.cache[font] = UI.cache[font] or {}
	UI.cache[font][scale] = UI.cache[font][scale] or {}
	if UI.cache[font][scale][string] then return UI.cache[font][scale][string].length end
	Citizen.InvokeNative(0x54CE8AC98E120CAB, "STRING")
	Citizen.InvokeNative(0x6C188BE134E074AA, string)
	Citizen.InvokeNative(0x66E0276CC5F6B9DA, font or 4)
	Citizen.InvokeNative(0x07C837F9A01C34C9, scale or 0.35, scale or 0.35)
	local length = Citizen.InvokeNative(0x85F061DA64ED2F67, 1, Citizen.ReturnResultAnyway(), Citizen.ResultAsFloat())

	UI.cache[font][scale][string] = {length = length}
	return length
end

local function Vec2(x, y)
    return {x, y}
end

function Renderer.GetTextWidth(string, font, scale)
    return Renderer.GetTextWidthS(string, font, scale)*GUI.screen.w
end

function Renderer.mouseInBounds(x, y, w, h)
    GUI.cursor.x, GUI.cursor.y = UI.natives.GetNuiCursorPosition()
    if GUI.cursor.x > x and GUI.cursor.y > y and GUI.cursor.x < x + w and GUI.cursor.y < y + h then
        return true 
    end
    return false
end

function UI.PushNextWindowSize(w, h)
    GUI.nextSize = {w = w, h = h}
end

function UI.DisableActions() 	DisableControlAction(1, 36, true) 	DisableControlAction(1, 37, true) 	DisableControlAction(1, 38, true) 	DisableControlAction(1, 44, true) 	DisableControlAction(1, 45, true) 	DisableControlAction(1, 69, true) 	DisableControlAction(1, 70, true) 	DisableControlAction(0, 63, true) 	DisableControlAction(0, 64, true) 	DisableControlAction(0, 278, true) 	DisableControlAction(0, 279, true) 	DisableControlAction(0, 280, true) 	DisableControlAction(0, 281, true) 	DisableControlAction(0, 91, true) 	DisableControlAction(0, 92, true) 	DisablePlayerFiring(PlayerId(), true) 	DisableControlAction(0, 24, true) 	DisableControlAction(0, 25, true) 	DisableControlAction(1, 37, true) 	DisableControlAction(0, 47, true) 	DisableControlAction(0, 58, true) 	DisableControlAction(0, 140, true) 	DisableControlAction(0, 141, true) 	DisableControlAction(0, 81, true) 	DisableControlAction(0, 82, true) 	DisableControlAction(0, 83, true) 	DisableControlAction(0, 84, true) 	DisableControlAction(0, 12, true) 	DisableControlAction(0, 13, true) 	DisableControlAction(0, 14, true) 	DisableControlAction(0, 15, true) 	DisableControlAction(0, 24, true) 	DisableControlAction(0, 16, true) 	DisableControlAction(0, 17, true) 	DisableControlAction(0, 96, true) 	DisableControlAction(0, 97, true) 	DisableControlAction(0, 98, true) 	DisableControlAction(0, 96, true) 	DisableControlAction(0, 99, true) 	DisableControlAction(0, 100, true) 	DisableControlAction(0, 142, true) 	DisableControlAction(0, 143, true) 	DisableControlAction(0, 263, true) 	DisableControlAction(0, 264, true) 	DisableControlAction(0, 257, true) 	DisableControlAction(1, 26, true) 	DisableControlAction(1, 23, true) 	DisableControlAction(1, 24, true) 	DisableControlAction(1, 25, true) 	DisableControlAction(1, 45, true) 	DisableControlAction(1, 45, true) 	DisableControlAction(1, 80, true) 	DisableControlAction(1, 140, true) 	DisableControlAction(1, 250, true) 	DisableControlAction(1, 263, true) 	DisableControlAction(1, 310, true) 	DisableControlAction(1, 37, true) 	DisableControlAction(1, 73, true) 	DisableControlAction(1, 1, true) 	DisableControlAction(1, 2, true) 	DisableControlAction(1, 335, true) 	DisableControlAction(1, 336, true) 	DisableControlAction(1, 106, true) end 

-- Name : String (Name of the window)
--[[ Flags : Table (ex. {NoDragging = true})
- NoDragging
- NoBorder]]
function UI.Begin(name, flags)
    GUI.cursor.x, GUI.cursor.y = UI.natives.GetNuiCursorPosition()
    if name == nil then
        return log(true, "Please provide a GUI name when calling 'GUI.Begin()'")
    else
        if GUI.nextSize then
            GUI.position.w, GUI.position.h = GUI.nextSize.w, GUI.nextSize.h
        end
        Renderer.DrawRect(GUI.position.x, GUI.position.y, GUI.position.w, GUI.position.h, UI.style.Background.r, UI.style.Background.g, UI.style.Background.b, UI.style.Background.a)
        if not flags or not flags.NoBorder then
            Renderer.DrawBorderedRect(GUI.position.x-1, GUI.position.y-1, GUI.position.w+2, GUI.position.h+2, UI.style.Background_Border.r, UI.style.Background_Border.g, UI.style.Background_Border.b, UI.style.Background_Border.a)
        end
    end
    if not flags or not flags.NoDragging then

    end
    UI.DisableActions()
end

-- Runs the end function for the menu.
function UI.End()
    Renderer.DrawCursor()
    GUI.item = {x = 0, y = 0, w = 0, h = 0, name = ""}
    GUI.prev_item = {x = 0, y = 0, w = 0, h = 0, name = ""}
end

-- Sets the next item in the UI to be on the same line as the previous item.
function UI.SameLine()
    GUI.vars.sameline = true
end

-- Sets the menu key (prefered to not run in a loop)
function UI.SetMenuKey(key)
    GUI.vars.menuKey = key
end

-- Checks for menu key pressed
function UI.CheckOpen()
    if UI.natives.IsDisabledControlJustPressed(0, GUI.vars.menuKey) then
        GUI.active = not GUI.active
    end
end

-- displayName : String (Name of the checkbox)
-- configName : String (Name in the config)
-- clickFunc : Function (Called on click)
function UI.Checkbox(displayName, configName, clickFunc)
    if GUI.config[configName] == nil then
        GUI.config[configName] = false
        log(false, "Creating config variable for: " .. configName)
    end
    local hoveredItem = "h"..configName
    GUI.cursor.x, GUI.cursor.y = UI.natives.GetNuiCursorPosition()
    GUI.prev_item = GUI.item
    if not GUI.vars.sameline then
        if GUI.prev_item.y ~= 0 then
            GUI.item = {x = GUI.position.x + 10, y = GUI.prev_item.y + GUI.prev_item.h + 10, w = 20, h = 20, name = displayName}
        else
            GUI.item = {x = GUI.position.x + 10, y = GUI.position.y + GUI.prev_item.y + GUI.prev_item.h + 10, w = 20, h = 20, name = displayName}
        end
    else
        GUI.item = {x = GUI.prev_item.x + GUI.prev_item.w + 10, y = GUI.prev_item.y, w = 20, h = 20, name = displayName}
        GUI.vars.sameline = false
    end
    GUI.item.w = Renderer.GetTextWidth(displayName, 4, 0.3)+GUI.item.w
    Renderer.DrawText(GUI.item.x+22, GUI.item.y-2, UI.style.Checkbox_Text.r, UI.style.Checkbox_Text.g, UI.style.Checkbox_Text.b, UI.style.Checkbox_Text.a, tostring(displayName), 4, false, 0.30)
    Renderer.DrawRect(GUI.item.x, GUI.item.y, 20, 20, UI.style.Item_Background.r, UI.style.Item_Background.g, UI.style.Item_Background.b, UI.style.Item_Background.a)
    if GUI.config[configName] == true then
        Renderer.DrawRect(GUI.item.x+1, GUI.item.y+1, 18, 18, UI.style.Item_Toggled.r, UI.style.Item_Toggled.g, UI.style.Item_Toggled.b, UI.style.Item_Toggled.a)
    end
    if Renderer.mouseInBounds(GUI.item.x, GUI.item.y, GUI.item.w, GUI.item.h) then
        Renderer.DrawRect(GUI.item.x+1, GUI.item.y+1, 18, 18, UI.style.Item_Hovered.r, UI.style.Item_Hovered.g, UI.style.Item_Hovered.b, UI.style.Item_Hovered.a)
        if UI.natives.IsDisabledControlJustReleased(0, 24) then
            GUI.config[configName] = not GUI.config[configName]
            if clickFunc then
                clickFunc()
            end
        end
        if UI.natives.IsDisabledControlPressed(0, 24) then
            Renderer.DrawRect(GUI.item.x+1, GUI.item.y+1, 18, 18, UI.style.Item_Hold.r, UI.style.Item_Hold.g, UI.style.Item_Hold.b, UI.style.Item_Hold.a)
        end
    end
end

function UI.Button(displayName, size, clickFunc)
    GUI.cursor.x, GUI.cursor.y = UI.natives.GetNuiCursorPosition()
    GUI.prev_item = GUI.item
    if not GUI.vars.sameline then
        if GUI.prev_item.y ~= 0 then
            GUI.item = {x = GUI.position.x + 10, y = GUI.prev_item.y + GUI.prev_item.h + 10, w = size[1], h = size[2], name = displayName}
        else
            GUI.item = {x = GUI.position.x + 10, y = GUI.position.y + GUI.prev_item.y + GUI.prev_item.h + 10, w = size[1], h = size[2], name = displayName}
        end
    else
        GUI.item = {x = GUI.prev_item.x + GUI.prev_item.w + 10, y = GUI.prev_item.y, w = size[1], h = size[2], name = displayName}
        GUI.vars.sameline = false
    end
    Renderer.DrawRect(GUI.item.x, GUI.item.y, GUI.item.w, GUI.item.h, UI.style.Item_Background.r, UI.style.Item_Background.g, UI.style.Item_Background.b, UI.style.Item_Background.a)
    Renderer.DrawText(GUI.item.x+(GUI.item.w/2), GUI.item.y-2, UI.style.Button_Text.r, UI.style.Button_Text.g, UI.style.Button_Text.b, UI.style.Button_Text.a, tostring(displayName), 4, true, 0.30)
    if Renderer.mouseInBounds(GUI.item.x, GUI.item.y, GUI.item.w, GUI.item.h) then
        Renderer.DrawRect(GUI.item.x, GUI.item.y, GUI.item.w, GUI.item.h, UI.style.Item_Hovered.r, UI.style.Item_Hovered.g, UI.style.Item_Hovered.b, UI.style.Item_Hovered.a)
        if UI.natives.IsDisabledControlJustReleased(0, 24) then
            if clickFunc then
                clickFunc()
            end
        end
        if UI.natives.IsDisabledControlPressed(0, 24) then
            Renderer.DrawRect(GUI.item.x, GUI.item.y, GUI.item.w, GUI.item.h, UI.style.Item_Hold.r, UI.style.Item_Hold.g, UI.style.Item_Hold.b, UI.style.Item_Hold.a)
        end
    end
end

local function buttonDemonstration() 
    log(false, "TEST")
end

UI.SetMenuKey(121)

Citizen.CreateThread(function()
    while UI.error == false do
        Wait(0)
        UI.CheckOpen()
        if GUI.active then
            UI.Begin("Vanilla UI Demo", {NoBorder = false, NoDragging = false})
            UI.Checkbox("e", "cTest", function() 
                print("test") 
            end)
            UI.SameLine()
            UI.Checkbox("Tes", "cTestf")
            UI.SameLine()
            UI.Checkbox("Test Checkbo", "cTestb")
            UI.Checkbox("Test Check", "cTeste")
            UI.Checkbox("Test C", "cTesth")
            UI.SameLine()
            UI.Button("Test Button", Vec2(100, 20), function() 
                log(false, "BUTTON1 PRESSED") 
            end)
            UI.Button("Test Button", Vec2(100, 20), buttonDemonstration)
            UI.End()
        end
    end
end)
