# Vanilla UI

Vanilla UI is an open sourced UI. You are able to edit it to your desire.
I made this UI to give people an open sourced click gui for mod menus

At the moment this only supports one window.

### Planed Updates
------------
- Dragging. (Next update SOON&trade;)
- Multiple window support.
- Sliders
- Textbox

### Documentation
------------
#### UI.Begin
```lua
function UI.Begin(name, flags)

--Example:
UI.Begin("Vanilla UI Demo", {NoBorder = true})
```

#### UI.Begin
```lua
function UI.Begin(name, flags)

--Example:
UI.Begin("Vanilla UI Demo", {NoBorder = true})
```

#### UI.End
Runs the end function for the menu.
```lua
function UI.End()

--Example:
UI.End() --PLACE THIS AT THE END OF THE GUI
```

#### UI.Checkbox
```lua
UI.Checkbox(displayName, configName, clickFunc)

--Example:
UI.Checkbox("Test Checkbox", "cTestCheckbox", function() log(false, "Checkbox Toggled") end)
```

#### UI.Button
```lua
UI.Button(displayName, size, clickFunc)

--Example:
UI.Button("Test Button", Vec2(100, 20), function() log(false, "Button Pressed") end)
```

#### UI.SameLine
Sets the next item in the UI to be on the same line as the previous item.
```lua
function UI.SameLine()

--Example:
UI.Checkbox("Test Checkbox 1", "cTestCheckbox")
UI.SameLine()
UI.Button("Test Button", Vec2(100, 20), function() log(false, "Button Pressed") end)
```

#### UI.PushNextWindowSize
Set the next window size
```lua
UI.PushNextWindowSize(w, h)

--Example:
UI.PushNextWindowSize(600, 500)
```

#### UI.SetMenuKey
Sets the menu key (prefered to not run in a loop)
```lua
UI.SetMenuKey(key)

--Example:
UI.SetMenuKey(121)
```
