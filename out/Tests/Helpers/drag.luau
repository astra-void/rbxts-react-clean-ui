-- Compiled with roblox-ts v3.0.0
local TS = _G[script]
local React = TS.import(script, TS.getModule(script, "@rbxts", "react"))
local Assert = TS.import(script, TS.getModule(script, "@rbxts", "lunit").out).Assert
local _registry_provider = TS.import(script, script.Parent.Parent.Parent, "Providers", "registry.provider")
local DraggableRegistryKey = _registry_provider.DraggableRegistryKey
local DroppableRegistryKey = _registry_provider.DroppableRegistryKey
local GlobalRegistry = _registry_provider.GlobalRegistry
local RegistryContext = _registry_provider.RegistryContext
local _layout = TS.import(script, script.Parent, "layout")
local waitForGuiObject = _layout.waitForGuiObject
local waitForLayout = _layout.waitForLayout
local dragState = {}
local function resetDragState()
	dragState.registry = nil
	dragState.handleEvents = nil
end
local function RegistryHarness()
	dragState.registry = React.useContext(RegistryContext)
	return nil
end
local DragHandle = React.forwardRef(function(props, ref)
	dragState.handleEvents = props.Event
	return React.createElement("frame", {
		key = "DragHandle",
		ref = ref,
		Active = props.Active,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 24),
		Event = props.Event,
	})
end)
local function pointerInput(position, inputType)
	if inputType == nil then
		inputType = Enum.UserInputType.MouseButton1
	end
	return {
		Position = Vector3.new(position.X, position.Y, 0),
		UserInputType = inputType,
	}
end
local function centerOf(gui)
	local _absolutePosition = gui.AbsolutePosition
	local _arg0 = gui.AbsoluteSize / 2
	return _absolutePosition + _arg0
end
local function waitForDragItem(host, name)
	if name == nil then
		name = "DragItem"
	end
	waitForGuiObject(host, "OverlayProvider")
	return waitForGuiObject(host, name)
end
local function waitForHandleEvents()
	return waitForLayout(function()
		return dragState.handleEvents
	end, "Timed out waiting for Draggable.Handle to inject its Event table")
end
local function waitForDraggableRegistration(dragItem)
	return waitForLayout(function()
		local _result = dragState.registry
		if _result ~= nil then
			_result = _result.get(dragItem, DraggableRegistryKey)
		end
		return _result
	end, "Timed out waiting for Draggable to register its root in the registry")
end
local function waitForDroppableRegistration(dropZone)
	return waitForLayout(function()
		local _result = dragState.registry
		if _result ~= nil then
			_result = _result.get(dropZone, DroppableRegistryKey)
		end
		return _result
	end, `Timed out waiting for Droppable to register {dropZone.Name} in the registry`)
end
local function waitForGlobalDraggable(dragItem)
	return waitForLayout(function()
		return GlobalRegistry.get(dragItem, DraggableRegistryKey)
	end, "Timed out waiting for Draggable to register its root in the GlobalRegistry")
end
local function waitForGlobalDroppable(dropZone)
	return waitForLayout(function()
		return GlobalRegistry.get(dropZone, DroppableRegistryKey)
	end, `Timed out waiting for Droppable to register {dropZone.Name} in the GlobalRegistry`)
end
local function pressHandle(handle, point, inputType)
	if inputType == nil then
		inputType = Enum.UserInputType.MouseButton1
	end
	local events = waitForHandleEvents()
	Assert:notUndefined(events.InputBegan, "Expected Draggable.Handle to inject an InputBegan handler")
	events.InputBegan(handle, pointerInput(point, inputType))
end
local function moveTo(registration, point)
	registration.draggable.updateDrag(pointerInput(point, Enum.UserInputType.MouseMovement))
	task.wait()
end
local function overlapPoint(a, b)
	local left = math.max(a.AbsolutePosition.X, b.AbsolutePosition.X)
	local top = math.max(a.AbsolutePosition.Y, b.AbsolutePosition.Y)
	local right = math.min(a.AbsolutePosition.X + a.AbsoluteSize.X, b.AbsolutePosition.X + b.AbsoluteSize.X)
	local bottom = math.min(a.AbsolutePosition.Y + a.AbsoluteSize.Y, b.AbsolutePosition.Y + b.AbsoluteSize.Y)
	Assert["true"](Assert, right > left and bottom > top, `Expected {a.Name} and {b.Name} to overlap`)
	return Vector2.new((left + right) / 2, (top + bottom) / 2)
end
return {
	resetDragState = resetDragState,
	RegistryHarness = RegistryHarness,
	pointerInput = pointerInput,
	centerOf = centerOf,
	waitForDragItem = waitForDragItem,
	waitForHandleEvents = waitForHandleEvents,
	waitForDraggableRegistration = waitForDraggableRegistration,
	waitForDroppableRegistration = waitForDroppableRegistration,
	waitForGlobalDraggable = waitForGlobalDraggable,
	waitForGlobalDroppable = waitForGlobalDroppable,
	pressHandle = pressHandle,
	moveTo = moveTo,
	overlapPoint = overlapPoint,
	dragState = dragState,
	DragHandle = DragHandle,
}
