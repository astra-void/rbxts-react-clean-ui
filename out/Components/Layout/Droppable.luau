-- Compiled with roblox-ts v3.0.0
local TS = _G[script]
local React = TS.import(script, TS.getModule(script, "@rbxts", "react"))
local _ = TS.import(script, script.Parent.Parent.Parent, "Providers")
local DroppableRegistryKey = _.DroppableRegistryKey
local GlobalRegistry = _.GlobalRegistry
local RegistryContext = _.RegistryContext
local _Contexts = TS.import(script, script.Parent.Parent.Parent, "Contexts")
local DragStateContext = _Contexts.DragStateContext
local DroppableContext = _Contexts.DroppableContext
local function Droppable(props)
	local registry = React.useContext(RegistryContext)
	local dragState = React.useContext(DragStateContext)
	local guiObject, setGuiObject = React.useState()
	local propsRef = React.useRef(props)
	propsRef.current = props
	local registration = React.useMemo(function()
		if guiObject == nil then
			return nil
		end
		return {
			guiObject = guiObject,
			id = props.id,
			drop = function(draggedObject, info)
				local _result = propsRef.current.onDrop
				if _result ~= nil then
					_result(draggedObject, info)
				end
			end,
			dragEnter = function(draggedObject, info)
				local _result = propsRef.current.onDragEnter
				if _result ~= nil then
					_result(draggedObject, info)
				end
			end,
			dragLeave = function(draggedObject, info)
				local _result = propsRef.current.onDragLeave
				if _result ~= nil then
					_result(draggedObject, info)
				end
			end,
		}
	end, { guiObject, props.id })
	React.useEffect(function()
		if registration == nil or dragState.preview then
			return nil
		end
		local _result = registry
		if _result ~= nil then
			_result.register(registration.guiObject, DroppableRegistryKey, registration)
		end
		GlobalRegistry.register(registration.guiObject, DroppableRegistryKey, registration)
		return function()
			local _result_1 = registry
			if _result_1 ~= nil then
				_result_1.unregister(registration.guiObject, DroppableRegistryKey)
			end
			if GlobalRegistry.get(registration.guiObject, DroppableRegistryKey) == registration then
				GlobalRegistry.unregister(registration.guiObject, DroppableRegistryKey)
			end
		end
	end, { registry, registration, dragState.preview })
	local child = React.cloneElement(props.children, {
		ref = setGuiObject,
	})
	return React.createElement(DroppableContext.Provider, {
		value = {
			registration = registration,
		},
	}, child)
end
return {
	Droppable = Droppable,
}
