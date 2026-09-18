-- Compiled with roblox-ts v3.0.0
local TS = _G[script]
local React = TS.import(script, TS.getModule(script, "@rbxts", "react"))
local DraggableContext = React.createContext(nil)
local DragStateContext = React.createContext({
	preview = false,
	dragging = false,
})
return {
	DraggableContext = DraggableContext,
	DragStateContext = DragStateContext,
}
