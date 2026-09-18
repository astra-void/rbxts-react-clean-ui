-- Compiled with roblox-ts v3.0.0
local TS = _G[script]
local React = TS.import(script, TS.getModule(script, "@rbxts", "react"))
local createPortal = TS.import(script, TS.getModule(script, "@rbxts", "react-roblox")).createPortal
local _lunit = TS.import(script, TS.getModule(script, "@rbxts", "lunit").out)
local Test = _lunit.Test
local Assert = _lunit.Assert
local Decorators = _lunit.Decorators
local Runtime = _lunit.Runtime
local Tag = _lunit.Tag
local DisplayName = _lunit.DisplayName
local _binding = Decorators
local Skip = _binding.Skip
local Each = _binding.Each
local Draggable = TS.import(script, script.Parent.Parent.Parent.Parent, "Components", "Layout", "Draggable").Draggable
local Droppable = TS.import(script, script.Parent.Parent.Parent.Parent, "Components", "Layout", "Droppable").Droppable
local Tooltip = TS.import(script, script.Parent.Parent.Parent.Parent, "Components", "Interaction", "Tooltip").Tooltip
local OverlayProvider = TS.import(script, script.Parent.Parent.Parent.Parent, "Providers", "overlay.provider").OverlayProvider
local RegistryProvider = TS.import(script, script.Parent.Parent.Parent.Parent, "Providers", "registry.provider").RegistryProvider
local _layout = TS.import(script, script.Parent.Parent.Parent, "Helpers", "layout")
local STUDIO_SKIP_MESSAGE = _layout.STUDIO_SKIP_MESSAGE
local assertContained = _layout.assertContained
local assertSizeApprox = _layout.assertSizeApprox
local findDescendant = _layout.findDescendant
local settleFrames = _layout.settleFrames
local waitForGuiObject = _layout.waitForGuiObject
local waitForLayout = _layout.waitForLayout
local waitForRemoval = _layout.waitForRemoval
local withMounted = _layout.withMounted
local _drag = TS.import(script, script.Parent.Parent.Parent, "Helpers", "drag")
local DragHandle = _drag.DragHandle
local RegistryHarness = _drag.RegistryHarness
local centerOf = _drag.centerOf
local moveTo = _drag.moveTo
local pointerInput = _drag.pointerInput
local pressHandle = _drag.pressHandle
local resetDragState = _drag.resetDragState
local waitForDragItem = _drag.waitForDragItem
local waitForDraggableRegistration = _drag.waitForDraggableRegistration
local waitForDroppableRegistration = _drag.waitForDroppableRegistration
local waitForHandleEvents = _drag.waitForHandleEvents
local findHostFiber = TS.import(script, script.Parent.Parent.Parent, "Helpers", "fiber").findHostFiber
local DRAG_ID = "item"
local SIBLING_ID = "sibling"
local ZONE_ID = "zone"
local TOOLTIP_TEXT = "Item details"
local tooltipTargetEvents = {}
local TooltipTarget = React.forwardRef(function(props, ref)
	local events = props.Event
	local captureRef = function(instance)
		local _ref = ref
		if type(_ref) == "function" then
			ref(instance)
		elseif ref ~= nil then
			ref.current = instance
		end
		if instance ~= nil and events ~= nil then
			local _instance = instance
			tooltipTargetEvents[_instance] = events
		end
	end
	return React.createElement("frame", {
		key = "TooltipTarget",
		ref = captureRef,
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Event = props.Event,
	})
end)
local function draggableFixture(onStartDrag, onDropped)
	return React.createElement(RegistryProvider, nil, React.createElement(OverlayProvider, nil, React.createElement(RegistryHarness), React.createElement(Draggable, {
		id = DRAG_ID,
		onStartDrag = onStartDrag,
		onDropped = onDropped,
	}, React.createElement("frame", {
		key = "DragItem",
		Size = UDim2.fromOffset(160, 90),
		BackgroundTransparency = 1,
	}, React.createElement(Draggable.Handle, nil, React.createElement(DragHandle))))))
end
local function optionsFixture(options)
	return React.createElement(RegistryProvider, nil, React.createElement(OverlayProvider, nil, React.createElement(RegistryHarness), React.createElement(Draggable, {
		id = DRAG_ID,
		inputTypes = options.inputTypes,
		renderOverlay = options.renderOverlay,
		onStartDrag = options.onStartDrag,
		onDropped = options.onDropped,
	}, React.createElement("frame", {
		key = "DragItem",
		Size = UDim2.fromOffset(160, 90),
		BackgroundTransparency = 1,
	}, React.createElement(Draggable.Handle, nil, React.createElement(DragHandle)))), React.createElement(Droppable, {
		id = ZONE_ID,
		onDrop = options.onDrop,
	}, React.createElement("frame", {
		key = "DropZone",
		Position = UDim2.fromOffset(200, 150),
		Size = UDim2.fromOffset(150, 120),
		BackgroundTransparency = 1,
	}))))
end
local function nativeHandleFixture(onStartDrag)
	return React.createElement(RegistryProvider, nil, React.createElement(OverlayProvider, nil, React.createElement(RegistryHarness), React.createElement(Draggable, {
		id = DRAG_ID,
		onStartDrag = onStartDrag,
	}, React.createElement("frame", {
		key = "DragItem",
		Size = UDim2.fromOffset(160, 90),
		BackgroundTransparency = 1,
	}, React.createElement(Draggable.Handle, nil, React.createElement("frame", {
		key = "NativeHandle",
		Size = UDim2.new(1, 0, 0, 24),
		BackgroundTransparency = 1,
	}))))))
end
local function siblingTreeFixture(siblingRoot, onDropped, onDrop)
	return React.createElement(RegistryProvider, nil, React.createElement(OverlayProvider, nil, React.createElement(RegistryHarness), React.createElement(Draggable, {
		id = DRAG_ID,
		onDropped = onDropped,
	}, React.createElement("frame", {
		key = "DragItem",
		Size = UDim2.fromOffset(160, 90),
		BackgroundTransparency = 1,
	}, React.createElement(Draggable.Handle, nil, React.createElement(DragHandle)))), createPortal(React.createElement(Droppable, {
		id = SIBLING_ID,
		onDrop = onDrop,
	}, React.createElement("frame", {
		key = "SiblingZone",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
	})), siblingRoot)))
end
local function tooltipFixture(open)
	return React.createElement(RegistryProvider, nil, React.createElement(OverlayProvider, nil, React.createElement(RegistryHarness), React.createElement(Draggable, {
		id = DRAG_ID,
	}, React.createElement("frame", {
		key = "DragItem",
		Size = UDim2.fromOffset(160, 90),
		BackgroundTransparency = 1,
	}, React.createElement(Tooltip, {
		content = TOOLTIP_TEXT,
		open = open,
	}, React.createElement(TooltipTarget)), React.createElement(Draggable.Handle, nil, React.createElement(DragHandle))))))
end
local function emptyFixture()
	return React.createElement("frame", {
		key = "Empty",
		Size = UDim2.fromOffset(10, 10),
		BackgroundTransparency = 1,
	})
end
local function inputTypesFor(label)
	return if label == "rightOnly" then { Enum.UserInputType.MouseButton2 } else nil
end
local DraggableMountValidation
do
	DraggableMountValidation = setmetatable({}, {
		__tostring = function()
			return "DraggableMountValidation"
		end,
	})
	DraggableMountValidation.__index = DraggableMountValidation
	function DraggableMountValidation.new(...)
		local self = setmetatable({}, DraggableMountValidation)
		return self:constructor(...) or self
	end
	function DraggableMountValidation:constructor()
	end
	function DraggableMountValidation:rendersChildInPlace()
		resetDragState()
		withMounted(400, 300, draggableFixture(), function(mounted)
			local dragItem = waitForDragItem(mounted.host)
			Assert:equal(dragItem.Parent, mounted.host, "Expected the dragged element to be a direct child of the host (no wrapper)")
			Assert["true"](Assert, dragItem.Visible, "Expected the original to be visible while not dragging")
			Assert:undefined(mounted.host:FindFirstChild("DraggablePlaceholder", true), "Expected no placeholder while not dragging")
			assertSizeApprox(dragItem, 160, 90, 1, "drag item")
			assertContained(dragItem, mounted.host, "drag item vs host")
		end)
	end
	function DraggableMountValidation:handleIsActive()
		resetDragState()
		withMounted(400, 300, draggableFixture(), function(mounted)
			local dragItem = waitForDragItem(mounted.host)
			local handle = findDescendant(dragItem, "DragHandle")
			Assert:equal(handle.Parent, dragItem, "Expected the handle to stay a direct child of the drag item")
			Assert["true"](Assert, handle.Active, "Expected Draggable.Handle to clone its child with Active=true")
			Assert["false"](Assert, dragItem.Active, "Expected the root element's own Active to be left at its default")
			local events = waitForHandleEvents()
			Assert:notUndefined(events.InputBegan, "Expected Draggable.Handle to inject an InputBegan handler")
			assertContained(handle, dragItem, "handle vs drag item")
		end)
	end
	function DraggableMountValidation:registersInRegistry()
		resetDragState()
		withMounted(400, 300, draggableFixture(), function(mounted)
			local dragItem = waitForDragItem(mounted.host)
			local registration = waitForDraggableRegistration(dragItem)
			Assert:equal(registration.id, DRAG_ID)
			Assert:equal(registration.guiObject, dragItem, "Expected the registration to point at the cloned root instance")
			Assert["false"](Assert, registration.draggable.isDragging, "Expected a freshly mounted Draggable not to report itself as dragging")
		end)
	end
	function DraggableMountValidation:dragLifecycle()
		resetDragState()
		local startCount = 0
		local dropCount = 0
		withMounted(400, 300, draggableFixture(function()
			startCount += 1
		end, function()
			dropCount += 1
		end), function(mounted)
			local dragItem = waitForDragItem(mounted.host)
			local registration = waitForDraggableRegistration(dragItem)
			local handle = findDescendant(dragItem, "DragHandle")
			local overlay = findDescendant(mounted.host, "OverlayProvider")
			local pressPoint = centerOf(handle)
			pressHandle(handle, pressPoint)
			Assert:equal(startCount, 1, "Expected onStartDrag to fire once when the drag begins")
			Assert["true"](Assert, registration.draggable.isDragging, "Expected the registration to report an active drag")
			local placeholder = waitForGuiObject(mounted.host, "DraggablePlaceholder")
			waitForLayout(function()
				return if not dragItem.Visible then true else nil
			end, "Timed out waiting for the original to hide while dragging")
			local preview = waitForLayout(function()
				return overlay:FindFirstChild("DragItem")
			end, "Timed out waiting for the drag preview to be portalled into the overlay")
			Assert:equal(placeholder.Parent, mounted.host, "Expected the placeholder to sit where the original does")
			assertSizeApprox(placeholder, 160, 90, 1, "placeholder")
			Assert["true"](Assert, preview.Visible, "Expected the preview clone to be visible")
			assertSizeApprox(preview, 160, 90, 1, "drag preview")
			local _draggable = registration.draggable
			local _vector2 = Vector2.new(30, 20)
			_draggable.endDrag(pointerInput(pressPoint + _vector2))
			Assert:equal(dropCount, 1, "Expected onDropped to fire once when the drag ends")
			Assert["false"](Assert, registration.draggable.isDragging, "Expected the registration to report the drag as over")
			waitForLayout(function()
				return if dragItem.Visible then true else nil
			end, "Timed out waiting for the original to reappear after the drop")
			waitForLayout(function()
				return if mounted.host:FindFirstChild("DraggablePlaceholder", true) == nil then true else nil
			end, "Timed out waiting for the placeholder to be removed after the drop")
			waitForLayout(function()
				return if overlay:FindFirstChild("DragItem") == nil then true else nil
			end, "Timed out waiting for the preview to leave the overlay after the drop")
			Assert:equal(dragItem.Position, UDim2.fromOffset(0, 0), "Expected the original to keep its Position without retainPosition")
		end)
	end
	function DraggableMountValidation:nativeHandleMounts()
		resetDragState()
		withMounted(400, 300, nativeHandleFixture(), function(mounted)
			local handle = waitForGuiObject(mounted.host, "NativeHandle", nil, "Timed out waiting for the native <frame> inside Draggable.Handle to mount - the tree failed to render (see the Studio output for the React error)")
			Assert["true"](Assert, handle.Active, "Expected Draggable.Handle to set Active=true on the native frame")
		end)
	end
	function DraggableMountValidation:nativeHandleStartsDrag()
		resetDragState()
		local startCount = 0
		withMounted(400, 300, nativeHandleFixture(function()
			startCount += 1
		end), function(mounted)
			local handle = waitForGuiObject(mounted.host, "NativeHandle", nil, "Timed out waiting for the native <frame> inside Draggable.Handle to mount - the tree failed to render (see the Studio output for the React error)")
			local dragItem = waitForDragItem(mounted.host)
			local registration = waitForDraggableRegistration(dragItem)
			local inputBeganKey = React.Event.InputBegan
			local _result = findHostFiber(mounted, handle).memoizedProps
			if _result ~= nil then
				_result = _result[inputBeganKey]
			end
			local handler = _result
			Assert:notUndefined(handler, "Expected the native handle to carry an InputBegan handler under React.Event.InputBegan")
			handler(handle, pointerInput(centerOf(handle)))
			Assert:equal(startCount, 1, "Expected onStartDrag to fire once when the native handle is pressed")
			Assert["true"](Assert, registration.draggable.isDragging, "Expected the registration to report an active drag")
			registration.draggable.endDrag(pointerInput(centerOf(handle)))
		end)
	end
	function DraggableMountValidation:siblingTreeDrop(kind)
		resetDragState()
		local dropped
		local droppedCalls = 0
		local dropCount = 0
		withMounted(400, 300, emptyFixture(), function(mounted)
			local screenGui = mounted.host.Parent
			local siblingGui
			if kind == "ScreenGui" then
				siblingGui = Instance.new("ScreenGui")
				siblingGui.Name = "SiblingGui"
				siblingGui.DisplayOrder = 10
				siblingGui.Parent = screenGui.Parent
			end
			local siblingRoot = Instance.new("Frame")
			siblingRoot.Name = "SiblingRoot"
			siblingRoot.BackgroundTransparency = 1
			siblingRoot.Position = UDim2.fromOffset(220, 150)
			siblingRoot.Size = UDim2.fromOffset(150, 120)
			siblingRoot.ZIndex = 2
			siblingRoot.Parent = siblingGui or screenGui
			TS.try(function()
				mounted.update(siblingTreeFixture(siblingRoot, function(droppable)
					droppedCalls += 1
					dropped = droppable
				end, function()
					dropCount += 1
				end))
				local dragItem = waitForDragItem(mounted.host)
				local registration = waitForDraggableRegistration(dragItem)
				local zone = waitForGuiObject(siblingRoot, "SiblingZone")
				waitForDroppableRegistration(zone)
				local handle = findDescendant(dragItem, "DragHandle")
				pressHandle(handle, centerOf(handle))
				waitForLayout(function()
					return if not dragItem.Visible then true else nil
				end, "Timed out waiting for the original to hide while dragging")
				registration.draggable.endDrag(pointerInput(centerOf(zone)))
				Assert:equal(droppedCalls, 1, "Expected onDropped to fire once on release")
				Assert:notUndefined(dropped, `Expected onDropped to report the Droppable in the sibling {kind} under the pointer, but it reported none`)
				Assert:equal(dropped.id, SIBLING_ID)
				Assert:equal(dropCount, 1, `Expected the sibling {kind}'s Droppable onDrop to fire once on release`)
			end, nil, function()
				mounted.update(emptyFixture())
				siblingRoot:Destroy()
				local _result = siblingGui
				if _result ~= nil then
					_result:Destroy()
				end
			end)
		end)
	end
	function DraggableMountValidation:rightButtonOptIn()
		resetDragState()
		local started = {}
		withMounted(400, 300, optionsFixture({
			inputTypes = { Enum.UserInputType.MouseButton1, Enum.UserInputType.MouseButton2 },
			onStartDrag = function(info)
				local _info = info
				table.insert(started, _info)
				return #started
			end,
		}), function(mounted)
			local dragItem = waitForDragItem(mounted.host)
			local registration = waitForDraggableRegistration(dragItem)
			local handle = findDescendant(dragItem, "DragHandle")
			local pressPoint = centerOf(handle)
			pressHandle(handle, pressPoint, Enum.UserInputType.MouseButton2)
			TS.try(function()
				Assert:equal(#started, 1, `Expected a right-button press to start one drag, got {#started}`)
				Assert:equal(started[1].inputType, Enum.UserInputType.MouseButton2)
				Assert:equal(started[1].id, DRAG_ID)
				Assert["true"](Assert, registration.draggable.isDragging, "Expected the registration to report an active drag")
				waitForGuiObject(mounted.host, "DraggablePlaceholder")
			end, nil, function()
				registration.draggable.endDrag(pointerInput(pressPoint, Enum.UserInputType.MouseButton2))
			end)
		end)
	end
	function DraggableMountValidation:unlistedInputIgnored(label, pressType)
		resetDragState()
		local startCount = 0
		withMounted(400, 300, optionsFixture({
			inputTypes = inputTypesFor(label),
			onStartDrag = function()
				startCount += 1
			end,
		}), function(mounted)
			local dragItem = waitForDragItem(mounted.host)
			local registration = waitForDraggableRegistration(dragItem)
			local handle = findDescendant(dragItem, "DragHandle")
			pressHandle(handle, centerOf(handle), pressType)
			settleFrames(3)
			Assert:equal(startCount, 0, `Expected a {pressType.Name} press not to start a {label} drag`)
			Assert["false"](Assert, registration.draggable.isDragging, "Expected the registration to stay idle")
			Assert["true"](Assert, dragItem.Visible, "Expected the original to stay visible")
			Assert:undefined(mounted.host:FindFirstChild("DraggablePlaceholder", true), "Expected no placeholder")
		end)
	end
	function DraggableMountValidation:releaseMustMatch()
		resetDragState()
		local droppedCalls = 0
		local dropCount = 0
		withMounted(400, 300, optionsFixture({
			inputTypes = { Enum.UserInputType.MouseButton2 },
			onDropped = function()
				droppedCalls += 1
			end,
			onDrop = function()
				dropCount += 1
			end,
		}), function(mounted)
			local dragItem = waitForDragItem(mounted.host)
			local registration = waitForDraggableRegistration(dragItem)
			local zone = waitForGuiObject(mounted.host, "DropZone")
			waitForDroppableRegistration(zone)
			local handle = findDescendant(dragItem, "DragHandle")
			pressHandle(handle, centerOf(handle), Enum.UserInputType.MouseButton2)
			waitForLayout(function()
				return if not dragItem.Visible then true else nil
			end, "Timed out waiting for the original to hide while dragging")
			registration.draggable.endDrag(pointerInput(centerOf(zone), Enum.UserInputType.MouseButton1))
			Assert:equal(droppedCalls, 0, "Expected a left-button release not to end a right-button drag")
			Assert:equal(dropCount, 0, "Expected no drop on a mismatched release")
			Assert["true"](Assert, registration.draggable.isDragging, "Expected the drag to still be active")
			registration.draggable.endDrag(pointerInput(centerOf(zone), Enum.UserInputType.MouseButton2))
			Assert:equal(droppedCalls, 1, "Expected the right-button release to end the drag")
			Assert:equal(dropCount, 1, "Expected the right-button release to drop on the target once")
			Assert["false"](Assert, registration.draggable.isDragging, "Expected the drag to be over")
		end)
	end
	function DraggableMountValidation:inputTypeReachesDrop()
		resetDragState()
		local dropInfo
		local droppedInfo
		local droppedTarget
		withMounted(400, 300, optionsFixture({
			inputTypes = { Enum.UserInputType.MouseButton1, Enum.UserInputType.MouseButton2 },
			onDropped = function(droppable, info)
				droppedTarget = droppable
				droppedInfo = info
			end,
			onDrop = function(_dragged, info)
				dropInfo = info
			end,
		}), function(mounted)
			local dragItem = waitForDragItem(mounted.host)
			local registration = waitForDraggableRegistration(dragItem)
			local zone = waitForGuiObject(mounted.host, "DropZone")
			waitForDroppableRegistration(zone)
			local handle = findDescendant(dragItem, "DragHandle")
			local releasePoint = centerOf(zone)
			pressHandle(handle, centerOf(handle), Enum.UserInputType.MouseButton2)
			moveTo(registration, releasePoint)
			registration.draggable.endDrag(pointerInput(releasePoint, Enum.UserInputType.MouseButton2))
			Assert:notUndefined(dropInfo, "Expected Droppable.onDrop to receive a DragEventInfo from a real drop")
			Assert:equal(dropInfo.inputType, Enum.UserInputType.MouseButton2)
			Assert:equal(dropInfo.id, DRAG_ID)
			Assert:equal(dropInfo.position, releasePoint, "Expected info.position to be the release point")
			Assert:notUndefined(droppedInfo, "Expected onDropped to receive a DragEventInfo")
			Assert:equal(droppedInfo.inputType, Enum.UserInputType.MouseButton2)
			local _result = droppedTarget
			if _result ~= nil then
				_result = _result.id
			end
			Assert:equal(_result, ZONE_ID)
		end)
	end
	function DraggableMountValidation:renderOverlayContent()
		resetDragState()
		withMounted(400, 300, optionsFixture({
			renderOverlay = function()
				return React.createElement("frame", {
					key = "OverlayIcon",
					Size = UDim2.fromScale(1, 1),
					BackgroundTransparency = 1,
				})
			end,
		}), function(mounted)
			local dragItem = waitForDragItem(mounted.host)
			local registration = waitForDraggableRegistration(dragItem)
			local handle = findDescendant(dragItem, "DragHandle")
			local overlay = findDescendant(mounted.host, "OverlayProvider")
			local pressPoint = centerOf(handle)
			pressHandle(handle, pressPoint)
			TS.try(function()
				local dragOverlay = waitForLayout(function()
					return overlay:FindFirstChild("DragOverlay")
				end, "Timed out waiting for the DragOverlay frame to be portalled into the overlay")
				local icon = waitForGuiObject(dragOverlay, "OverlayIcon")
				Assert:equal(icon.Parent, dragOverlay, "Expected the renderOverlay content to be a direct child of DragOverlay")
				Assert:undefined(overlay:FindFirstChild("DragItem", true), "Expected no clone of the child in the overlay")
				Assert["true"](Assert, dragOverlay.Visible, "Expected DragOverlay to be visible")
				assertSizeApprox(dragOverlay, 160, 90, 1, "DragOverlay")
				assertSizeApprox(icon, 160, 90, 1, "renderOverlay content")
			end, nil, function()
				registration.draggable.endDrag(pointerInput(pressPoint))
			end)
			waitForRemoval(overlay, "DragOverlay", 30)
		end)
	end
	function DraggableMountValidation:previewSkipsTooltip()
		resetDragState()
		table.clear(tooltipTargetEvents)
		withMounted(400, 300, tooltipFixture(), function(mounted)
			local dragItem = waitForDragItem(mounted.host)
			local registration = waitForDraggableRegistration(dragItem)
			local handle = findDescendant(dragItem, "DragHandle")
			local overlay = findDescendant(mounted.host, "OverlayProvider")
			local pressPoint = centerOf(handle)
			pressHandle(handle, pressPoint)
			TS.try(function()
				local preview = waitForLayout(function()
					return overlay:FindFirstChild("DragItem")
				end, "Timed out waiting for the drag preview to be portalled into the overlay")
				settleFrames(2)
				local previewTarget = preview:FindFirstChild("TooltipTarget", true)
				Assert:notUndefined(previewTarget, "Expected the preview clone to contain the TooltipTarget")
				local previewEvents = tooltipTargetEvents[previewTarget]
				local _result = previewEvents
				if _result ~= nil then
					_result = _result.MouseEnter
				end
				Assert:notUndefined(_result, "Expected the preview's Tooltip to inject a MouseEnter handler")
				previewEvents.MouseEnter(previewTarget, pressPoint.X, pressPoint.Y)
				settleFrames(10)
				Assert:undefined(overlay:FindFirstChild("Tooltip", true), "Expected no Tooltip popup in the overlay while dragging, but hovering the drag preview opened one")
				Assert:undefined(overlay:FindFirstChild("TooltipText", true), "Expected no tooltip content in the overlay while dragging")
			end, nil, function()
				registration.draggable.endDrag(pointerInput(pressPoint))
			end)
		end)
	end
	function DraggableMountValidation:dragClosesTooltip()
		resetDragState()
		table.clear(tooltipTargetEvents)
		withMounted(400, 300, tooltipFixture(), function(mounted)
			local dragItem = waitForDragItem(mounted.host)
			local registration = waitForDraggableRegistration(dragItem)
			local handle = findDescendant(dragItem, "DragHandle")
			local overlay = findDescendant(mounted.host, "OverlayProvider")
			local target = findDescendant(dragItem, "TooltipTarget")
			local pressPoint = centerOf(handle)
			local events = waitForLayout(function()
				return tooltipTargetEvents[target]
			end, "Timed out waiting for Tooltip to inject hover handlers into TooltipTarget")
			Assert:notUndefined(events.MouseEnter, "Expected Tooltip to inject a MouseEnter handler")
			events.MouseEnter(target, pressPoint.X, pressPoint.Y)
			waitForGuiObject(overlay, "Tooltip")
			pressHandle(handle, pressPoint)
			TS.try(function()
				waitForRemoval(overlay, "Tooltip")
			end, nil, function()
				registration.draggable.endDrag(pointerInput(pressPoint))
			end)
			waitForLayout(function()
				return if dragItem.Visible then true else nil
			end, "Timed out waiting for the original to reappear after the drop")
			settleFrames(10)
			Assert:undefined(overlay:FindFirstChild("Tooltip", true), "Expected the Tooltip to stay closed after the drop, since the hover was forgotten when the drag hid the original")
		end)
	end
	function DraggableMountValidation:openTooltipSuppressed()
		resetDragState()
		table.clear(tooltipTargetEvents)
		withMounted(400, 300, tooltipFixture(true), function(mounted)
			local dragItem = waitForDragItem(mounted.host)
			local registration = waitForDraggableRegistration(dragItem)
			local handle = findDescendant(dragItem, "DragHandle")
			local overlay = findDescendant(mounted.host, "OverlayProvider")
			local pressPoint = centerOf(handle)
			waitForGuiObject(overlay, "Tooltip")
			pressHandle(handle, pressPoint)
			TS.try(function()
				waitForLayout(function()
					return overlay:FindFirstChild("DragItem")
				end, "Timed out waiting for the drag preview to be portalled into the overlay")
				waitForRemoval(overlay, "Tooltip")
				settleFrames(10)
				Assert:undefined(overlay:FindFirstChild("Tooltip", true), "Expected no Tooltip popup during the drag, but an open={true} Tooltip (original or preview) showed one")
			end, nil, function()
				registration.draggable.endDrag(pointerInput(pressPoint))
			end)
			waitForGuiObject(overlay, "Tooltip")
		end)
	end
	local _decorator = Skip(not Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	local _decorator_1 = DisplayName("Idle, the child renders in place with no wrapper or placeholder, visible, at its own size, inside the host")
	local _descriptor = Test(DraggableMountValidation, "rendersChildInPlace", {
		value = DraggableMountValidation.rendersChildInPlace,
	})
	if _descriptor then
		DraggableMountValidation.rendersChildInPlace = _descriptor.value
	end
	local _descriptor_1 = _decorator_1(DraggableMountValidation, "rendersChildInPlace", {
		value = DraggableMountValidation.rendersChildInPlace,
	})
	if _descriptor_1 then
		DraggableMountValidation.rendersChildInPlace = _descriptor_1.value
	end
	local _descriptor_2 = _decorator(DraggableMountValidation, "rendersChildInPlace", {
		value = DraggableMountValidation.rendersChildInPlace,
	})
	if _descriptor_2 then
		DraggableMountValidation.rendersChildInPlace = _descriptor_2.value
	end
	local _decorator_2 = Skip(not Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	local _decorator_3 = DisplayName("Draggable.Handle marks its child Active and injects an InputBegan handler, without touching the root element")
	local _descriptor_3 = Test(DraggableMountValidation, "handleIsActive", {
		value = DraggableMountValidation.handleIsActive,
	})
	if _descriptor_3 then
		DraggableMountValidation.handleIsActive = _descriptor_3.value
	end
	local _descriptor_4 = _decorator_3(DraggableMountValidation, "handleIsActive", {
		value = DraggableMountValidation.handleIsActive,
	})
	if _descriptor_4 then
		DraggableMountValidation.handleIsActive = _descriptor_4.value
	end
	local _descriptor_5 = _decorator_2(DraggableMountValidation, "handleIsActive", {
		value = DraggableMountValidation.handleIsActive,
	})
	if _descriptor_5 then
		DraggableMountValidation.handleIsActive = _descriptor_5.value
	end
	local _decorator_4 = Skip(not Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	local _decorator_5 = DisplayName("Registers its root under DraggableRegistryKey with its id and an idle (not dragging) draggable")
	local _descriptor_6 = Test(DraggableMountValidation, "registersInRegistry", {
		value = DraggableMountValidation.registersInRegistry,
	})
	if _descriptor_6 then
		DraggableMountValidation.registersInRegistry = _descriptor_6.value
	end
	local _descriptor_7 = _decorator_5(DraggableMountValidation, "registersInRegistry", {
		value = DraggableMountValidation.registersInRegistry,
	})
	if _descriptor_7 then
		DraggableMountValidation.registersInRegistry = _descriptor_7.value
	end
	local _descriptor_8 = _decorator_4(DraggableMountValidation, "registersInRegistry", {
		value = DraggableMountValidation.registersInRegistry,
	})
	if _descriptor_8 then
		DraggableMountValidation.registersInRegistry = _descriptor_8.value
	end
	local _decorator_6 = Skip(not Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	local _decorator_7 = DisplayName("A press on the handle starts a drag (placeholder shown, original hidden, preview in the overlay) and releasing ends it")
	local _descriptor_9 = Test(DraggableMountValidation, "dragLifecycle", {
		value = DraggableMountValidation.dragLifecycle,
	})
	if _descriptor_9 then
		DraggableMountValidation.dragLifecycle = _descriptor_9.value
	end
	local _descriptor_10 = _decorator_7(DraggableMountValidation, "dragLifecycle", {
		value = DraggableMountValidation.dragLifecycle,
	})
	if _descriptor_10 then
		DraggableMountValidation.dragLifecycle = _descriptor_10.value
	end
	local _descriptor_11 = _decorator_6(DraggableMountValidation, "dragLifecycle", {
		value = DraggableMountValidation.dragLifecycle,
	})
	if _descriptor_11 then
		DraggableMountValidation.dragLifecycle = _descriptor_11.value
	end
	local _decorator_8 = Skip(not Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	local _decorator_9 = DisplayName("Draggable.Handle wrapping a native <frame> mounts without error and marks that frame Active")
	local _descriptor_12 = Test(DraggableMountValidation, "nativeHandleMounts", {
		value = DraggableMountValidation.nativeHandleMounts,
	})
	if _descriptor_12 then
		DraggableMountValidation.nativeHandleMounts = _descriptor_12.value
	end
	local _descriptor_13 = _decorator_9(DraggableMountValidation, "nativeHandleMounts", {
		value = DraggableMountValidation.nativeHandleMounts,
	})
	if _descriptor_13 then
		DraggableMountValidation.nativeHandleMounts = _descriptor_13.value
	end
	local _descriptor_14 = _decorator_8(DraggableMountValidation, "nativeHandleMounts", {
		value = DraggableMountValidation.nativeHandleMounts,
	})
	if _descriptor_14 then
		DraggableMountValidation.nativeHandleMounts = _descriptor_14.value
	end
	local _decorator_10 = Skip(not Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	local _decorator_11 = DisplayName("A press on a native <frame> handle reaches the frame's real InputBegan event and starts the drag")
	local _descriptor_15 = Test(DraggableMountValidation, "nativeHandleStartsDrag", {
		value = DraggableMountValidation.nativeHandleStartsDrag,
	})
	if _descriptor_15 then
		DraggableMountValidation.nativeHandleStartsDrag = _descriptor_15.value
	end
	local _descriptor_16 = _decorator_11(DraggableMountValidation, "nativeHandleStartsDrag", {
		value = DraggableMountValidation.nativeHandleStartsDrag,
	})
	if _descriptor_16 then
		DraggableMountValidation.nativeHandleStartsDrag = _descriptor_16.value
	end
	local _descriptor_17 = _decorator_10(DraggableMountValidation, "nativeHandleStartsDrag", {
		value = DraggableMountValidation.nativeHandleStartsDrag,
	})
	if _descriptor_17 then
		DraggableMountValidation.nativeHandleStartsDrag = _descriptor_17.value
	end
	local _decorator_12 = Skip(not Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	local _decorator_13 = DisplayName("A drop lands on a Droppable that lives in a sibling tree (another root Frame or another ScreenGui) rather than under the Draggable's own root Frame")
	local _decorator_14 = Each({ { "Frame" }, { "ScreenGui" } })
	local _descriptor_18 = Test(DraggableMountValidation, "siblingTreeDrop", {
		value = DraggableMountValidation.siblingTreeDrop,
	})
	if _descriptor_18 then
		DraggableMountValidation.siblingTreeDrop = _descriptor_18.value
	end
	local _descriptor_19 = _decorator_14(DraggableMountValidation, "siblingTreeDrop", {
		value = DraggableMountValidation.siblingTreeDrop,
	})
	if _descriptor_19 then
		DraggableMountValidation.siblingTreeDrop = _descriptor_19.value
	end
	local _descriptor_20 = _decorator_13(DraggableMountValidation, "siblingTreeDrop", {
		value = DraggableMountValidation.siblingTreeDrop,
	})
	if _descriptor_20 then
		DraggableMountValidation.siblingTreeDrop = _descriptor_20.value
	end
	local _descriptor_21 = _decorator_12(DraggableMountValidation, "siblingTreeDrop", {
		value = DraggableMountValidation.siblingTreeDrop,
	})
	if _descriptor_21 then
		DraggableMountValidation.siblingTreeDrop = _descriptor_21.value
	end
	local _decorator_15 = Skip(not Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	local _decorator_16 = DisplayName("With inputTypes including MouseButton2, a right-button press starts the drag and onStartDrag reports MouseButton2")
	local _descriptor_22 = Test(DraggableMountValidation, "rightButtonOptIn", {
		value = DraggableMountValidation.rightButtonOptIn,
	})
	if _descriptor_22 then
		DraggableMountValidation.rightButtonOptIn = _descriptor_22.value
	end
	local _descriptor_23 = _decorator_16(DraggableMountValidation, "rightButtonOptIn", {
		value = DraggableMountValidation.rightButtonOptIn,
	})
	if _descriptor_23 then
		DraggableMountValidation.rightButtonOptIn = _descriptor_23.value
	end
	local _descriptor_24 = _decorator_15(DraggableMountValidation, "rightButtonOptIn", {
		value = DraggableMountValidation.rightButtonOptIn,
	})
	if _descriptor_24 then
		DraggableMountValidation.rightButtonOptIn = _descriptor_24.value
	end
	local _decorator_17 = Skip(not Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	local _decorator_18 = DisplayName("A press whose input type is not in inputTypes starts nothing: right button with the default, left button with a right-only list")
	local _decorator_19 = Each({ { "default", Enum.UserInputType.MouseButton2 }, { "rightOnly", Enum.UserInputType.MouseButton1 } })
	local _descriptor_25 = Test(DraggableMountValidation, "unlistedInputIgnored", {
		value = DraggableMountValidation.unlistedInputIgnored,
	})
	if _descriptor_25 then
		DraggableMountValidation.unlistedInputIgnored = _descriptor_25.value
	end
	local _descriptor_26 = _decorator_19(DraggableMountValidation, "unlistedInputIgnored", {
		value = DraggableMountValidation.unlistedInputIgnored,
	})
	if _descriptor_26 then
		DraggableMountValidation.unlistedInputIgnored = _descriptor_26.value
	end
	local _descriptor_27 = _decorator_18(DraggableMountValidation, "unlistedInputIgnored", {
		value = DraggableMountValidation.unlistedInputIgnored,
	})
	if _descriptor_27 then
		DraggableMountValidation.unlistedInputIgnored = _descriptor_27.value
	end
	local _descriptor_28 = _decorator_17(DraggableMountValidation, "unlistedInputIgnored", {
		value = DraggableMountValidation.unlistedInputIgnored,
	})
	if _descriptor_28 then
		DraggableMountValidation.unlistedInputIgnored = _descriptor_28.value
	end
	local _decorator_20 = Skip(not Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	local _decorator_21 = DisplayName("A right-button drag ignores a left-button release over the target and only drops on the right-button release")
	local _descriptor_29 = Test(DraggableMountValidation, "releaseMustMatch", {
		value = DraggableMountValidation.releaseMustMatch,
	})
	if _descriptor_29 then
		DraggableMountValidation.releaseMustMatch = _descriptor_29.value
	end
	local _descriptor_30 = _decorator_21(DraggableMountValidation, "releaseMustMatch", {
		value = DraggableMountValidation.releaseMustMatch,
	})
	if _descriptor_30 then
		DraggableMountValidation.releaseMustMatch = _descriptor_30.value
	end
	local _descriptor_31 = _decorator_20(DraggableMountValidation, "releaseMustMatch", {
		value = DraggableMountValidation.releaseMustMatch,
	})
	if _descriptor_31 then
		DraggableMountValidation.releaseMustMatch = _descriptor_31.value
	end
	local _decorator_22 = Skip(not Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	local _decorator_23 = DisplayName("The drag's starting input type, the Draggable id and the release point reach both Droppable.onDrop and onDropped")
	local _descriptor_32 = Test(DraggableMountValidation, "inputTypeReachesDrop", {
		value = DraggableMountValidation.inputTypeReachesDrop,
	})
	if _descriptor_32 then
		DraggableMountValidation.inputTypeReachesDrop = _descriptor_32.value
	end
	local _descriptor_33 = _decorator_23(DraggableMountValidation, "inputTypeReachesDrop", {
		value = DraggableMountValidation.inputTypeReachesDrop,
	})
	if _descriptor_33 then
		DraggableMountValidation.inputTypeReachesDrop = _descriptor_33.value
	end
	local _descriptor_34 = _decorator_22(DraggableMountValidation, "inputTypeReachesDrop", {
		value = DraggableMountValidation.inputTypeReachesDrop,
	})
	if _descriptor_34 then
		DraggableMountValidation.inputTypeReachesDrop = _descriptor_34.value
	end
	local _decorator_24 = Skip(not Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	local _decorator_25 = DisplayName("With renderOverlay, the preview is a DragOverlay frame at the item's size holding the custom content, with no clone of the child")
	local _descriptor_35 = Test(DraggableMountValidation, "renderOverlayContent", {
		value = DraggableMountValidation.renderOverlayContent,
	})
	if _descriptor_35 then
		DraggableMountValidation.renderOverlayContent = _descriptor_35.value
	end
	local _descriptor_36 = _decorator_25(DraggableMountValidation, "renderOverlayContent", {
		value = DraggableMountValidation.renderOverlayContent,
	})
	if _descriptor_36 then
		DraggableMountValidation.renderOverlayContent = _descriptor_36.value
	end
	local _descriptor_37 = _decorator_24(DraggableMountValidation, "renderOverlayContent", {
		value = DraggableMountValidation.renderOverlayContent,
	})
	if _descriptor_37 then
		DraggableMountValidation.renderOverlayContent = _descriptor_37.value
	end
	local _decorator_26 = Skip(not Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	local _decorator_27 = DisplayName("While dragging, hovering the preview in the overlay never opens a Tooltip that sits inside the dragged content")
	local _descriptor_38 = Test(DraggableMountValidation, "previewSkipsTooltip", {
		value = DraggableMountValidation.previewSkipsTooltip,
	})
	if _descriptor_38 then
		DraggableMountValidation.previewSkipsTooltip = _descriptor_38.value
	end
	local _descriptor_39 = _decorator_27(DraggableMountValidation, "previewSkipsTooltip", {
		value = DraggableMountValidation.previewSkipsTooltip,
	})
	if _descriptor_39 then
		DraggableMountValidation.previewSkipsTooltip = _descriptor_39.value
	end
	local _descriptor_40 = _decorator_26(DraggableMountValidation, "previewSkipsTooltip", {
		value = DraggableMountValidation.previewSkipsTooltip,
	})
	if _descriptor_40 then
		DraggableMountValidation.previewSkipsTooltip = _descriptor_40.value
	end
	local _decorator_28 = Skip(not Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	local _decorator_29 = DisplayName("A hovered Tooltip inside the item closes when the drag starts and stays closed after the drop until hovered again")
	local _descriptor_41 = Test(DraggableMountValidation, "dragClosesTooltip", {
		value = DraggableMountValidation.dragClosesTooltip,
	})
	if _descriptor_41 then
		DraggableMountValidation.dragClosesTooltip = _descriptor_41.value
	end
	local _descriptor_42 = _decorator_29(DraggableMountValidation, "dragClosesTooltip", {
		value = DraggableMountValidation.dragClosesTooltip,
	})
	if _descriptor_42 then
		DraggableMountValidation.dragClosesTooltip = _descriptor_42.value
	end
	local _descriptor_43 = _decorator_28(DraggableMountValidation, "dragClosesTooltip", {
		value = DraggableMountValidation.dragClosesTooltip,
	})
	if _descriptor_43 then
		DraggableMountValidation.dragClosesTooltip = _descriptor_43.value
	end
	local _decorator_30 = Skip(not Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	local _decorator_31 = DisplayName("A controlled open Tooltip in the item closes for the whole drag (original and preview) and reopens after the drop")
	local _descriptor_44 = Test(DraggableMountValidation, "openTooltipSuppressed", {
		value = DraggableMountValidation.openTooltipSuppressed,
	})
	if _descriptor_44 then
		DraggableMountValidation.openTooltipSuppressed = _descriptor_44.value
	end
	local _descriptor_45 = _decorator_31(DraggableMountValidation, "openTooltipSuppressed", {
		value = DraggableMountValidation.openTooltipSuppressed,
	})
	if _descriptor_45 then
		DraggableMountValidation.openTooltipSuppressed = _descriptor_45.value
	end
	local _descriptor_46 = _decorator_30(DraggableMountValidation, "openTooltipSuppressed", {
		value = DraggableMountValidation.openTooltipSuppressed,
	})
	if _descriptor_46 then
		DraggableMountValidation.openTooltipSuppressed = _descriptor_46.value
	end
	DraggableMountValidation = Tag("Studio")(DraggableMountValidation) or DraggableMountValidation
end
return DraggableMountValidation
