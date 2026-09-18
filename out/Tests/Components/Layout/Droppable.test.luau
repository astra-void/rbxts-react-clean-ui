-- Compiled with roblox-ts v3.0.0
local TS = _G[script]
local React = TS.import(script, TS.getModule(script, "@rbxts", "react"))
local _react_roblox = TS.import(script, TS.getModule(script, "@rbxts", "react-roblox"))
local ReactRoblox = _react_roblox
local createPortal = _react_roblox.createPortal
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
local OverlayProvider = TS.import(script, script.Parent.Parent.Parent.Parent, "Providers", "overlay.provider").OverlayProvider
local _registry_provider = TS.import(script, script.Parent.Parent.Parent.Parent, "Providers", "registry.provider")
local DroppableRegistryKey = _registry_provider.DroppableRegistryKey
local RegistryProvider = _registry_provider.RegistryProvider
local _layout = TS.import(script, script.Parent.Parent.Parent, "Helpers", "layout")
local STUDIO_SKIP_MESSAGE = _layout.STUDIO_SKIP_MESSAGE
local assertContained = _layout.assertContained
local assertSizeApprox = _layout.assertSizeApprox
local findDescendant = _layout.findDescendant
local settleFrames = _layout.settleFrames
local waitForDescendant = _layout.waitForDescendant
local waitForGuiObject = _layout.waitForGuiObject
local waitForLayout = _layout.waitForLayout
local withMounted = _layout.withMounted
local _drag = TS.import(script, script.Parent.Parent.Parent, "Helpers", "drag")
local DragHandle = _drag.DragHandle
local RegistryHarness = _drag.RegistryHarness
local centerOf = _drag.centerOf
local dragState = _drag.dragState
local moveTo = _drag.moveTo
local overlapPoint = _drag.overlapPoint
local pointerInput = _drag.pointerInput
local pressHandle = _drag.pressHandle
local resetDragState = _drag.resetDragState
local waitForDragItem = _drag.waitForDragItem
local waitForDraggableRegistration = _drag.waitForDraggableRegistration
local waitForDroppableRegistration = _drag.waitForDroppableRegistration
local waitForGlobalDraggable = _drag.waitForGlobalDraggable
local waitForGlobalDroppable = _drag.waitForGlobalDroppable
local DROP_ID = "target"
local DRAG_ID = "item"
local function droppableFixture(onDrop)
	return React.createElement(RegistryProvider, nil, React.createElement(RegistryHarness), React.createElement(Droppable, {
		id = DROP_ID,
		onDrop = onDrop,
	}, React.createElement("frame", {
		key = "DropZone",
		Size = UDim2.fromOffset(120, 80),
		BackgroundTransparency = 1,
	})))
end
local function dragSource(onDropped)
	return React.createElement(Draggable, {
		id = DRAG_ID,
		onDropped = onDropped,
	}, React.createElement("frame", {
		key = "DragItem",
		Size = UDim2.fromOffset(160, 90),
		BackgroundTransparency = 1,
	}, React.createElement(Draggable.Handle, nil, React.createElement(DragHandle))))
end
local function reporter(reported)
	return function(droppable)
		reported.droppable = droppable
	end
end
local function dropZone(spec)
	return React.createElement(Droppable, {
		id = spec.id,
		onDrop = spec.onDrop,
	}, React.createElement("frame", {
		key = spec.name,
		Position = UDim2.fromOffset(200, 150),
		Size = UDim2.fromOffset(150, 120),
		ZIndex = spec.zIndex,
		BackgroundTransparency = 1,
	}))
end
local function dragToZonesFixture(zones, onDropped)
	local _exp = React.createElement(RegistryHarness)
	local _exp_1 = dragSource(onDropped)
	-- ▼ ReadonlyArray.map ▼
	local _newValue = table.create(#zones)
	local _callback = function(zone)
		return dropZone(zone)
	end
	for _k, _v in zones do
		_newValue[_k] = _callback(_v, _k - 1, zones)
	end
	-- ▲ ReadonlyArray.map ▲
	return React.createElement(RegistryProvider, nil, React.createElement(OverlayProvider, nil, _exp, _exp_1, _newValue))
end
local function loggedZone(spec, log)
	return React.createElement(Droppable, {
		id = spec.id,
		onDrop = function()
			local _log = log
			local _arg0 = `drop:{spec.id}`
			table.insert(_log, _arg0)
			return #_log
		end,
		onDragEnter = function()
			local _log = log
			local _arg0 = `enter:{spec.id}`
			table.insert(_log, _arg0)
			return #_log
		end,
		onDragLeave = function()
			local _log = log
			local _arg0 = `leave:{spec.id}`
			table.insert(_log, _arg0)
			return #_log
		end,
	}, React.createElement("frame", {
		key = spec.name,
		Position = spec.position,
		Size = UDim2.fromOffset(150, 120),
		ZIndex = spec.zIndex,
		BackgroundTransparency = 1,
	}))
end
local function loggedZonesFixture(zones, log, withDraggable)
	if withDraggable == nil then
		withDraggable = true
	end
	local _exp = React.createElement(RegistryHarness)
	local _exp_1 = withDraggable and dragSource()
	-- ▼ ReadonlyArray.map ▼
	local _newValue = table.create(#zones)
	local _callback = function(zone)
		return loggedZone(zone, log)
	end
	for _k, _v in zones do
		_newValue[_k] = _callback(_v, _k - 1, zones)
	end
	-- ▲ ReadonlyArray.map ▲
	return React.createElement(RegistryProvider, nil, React.createElement(OverlayProvider, nil, _exp, _exp_1, _newValue))
end
local function noProviderFixture(withZone, onDropped, onDrop)
	return React.createElement(OverlayProvider, nil, dragSource(onDropped), withZone and (React.createElement(Droppable, {
		id = DROP_ID,
		onDrop = onDrop,
	}, React.createElement("frame", {
		key = "DropZone",
		Position = UDim2.fromOffset(200, 150),
		Size = UDim2.fromOffset(150, 120),
		BackgroundTransparency = 1,
	}))))
end
local function ineligibleFixture(mode, onDropped)
	local clipped = mode == "clipped"
	return React.createElement(RegistryProvider, nil, React.createElement(OverlayProvider, nil, React.createElement(RegistryHarness), dragSource(onDropped), React.createElement(Droppable, {
		id = "back",
	}, React.createElement("frame", {
		key = "BackZone",
		Position = UDim2.fromOffset(200, 150),
		Size = UDim2.fromOffset(150, 120),
		ZIndex = 1,
		BackgroundTransparency = 1,
	})), React.createElement("frame", {
		key = "FrontWrapper",
		Position = UDim2.fromOffset(200, 150),
		Size = if clipped then UDim2.fromOffset(40, 40) else UDim2.fromOffset(150, 120),
		ClipsDescendants = clipped,
		Visible = mode ~= "hiddenAncestor",
		ZIndex = 2,
		BackgroundTransparency = 1,
	}, React.createElement(Droppable, {
		id = "front",
	}, React.createElement("frame", {
		key = "FrontZone",
		Size = UDim2.fromOffset(150, 120),
		Visible = mode ~= "hidden",
		ZIndex = 2,
		BackgroundTransparency = 1,
	})))))
end
local function crossGuiFixture(secondRoot, onDropped)
	return React.createElement(RegistryProvider, nil, React.createElement(OverlayProvider, nil, React.createElement(RegistryHarness), dragSource(onDropped), React.createElement(Droppable, {
		id = "local",
	}, React.createElement("frame", {
		key = "LocalZone",
		Position = UDim2.fromOffset(200, 150),
		Size = UDim2.fromOffset(150, 120),
		ZIndex = 50,
		BackgroundTransparency = 1,
	})), createPortal(React.createElement(Droppable, {
		id = "other",
	}, React.createElement("frame", {
		key = "OtherZone",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
	})), secondRoot)))
end
local function zIndexBehaviorFixture(onDropped)
	return React.createElement(RegistryProvider, nil, React.createElement(OverlayProvider, nil, React.createElement(RegistryHarness), dragSource(onDropped), React.createElement(Droppable, {
		id = "shallow",
	}, React.createElement("frame", {
		key = "ShallowZone",
		Position = UDim2.fromOffset(200, 150),
		Size = UDim2.fromOffset(150, 120),
		ZIndex = 5,
		BackgroundTransparency = 1,
	})), React.createElement("frame", {
		key = "LowParent",
		Position = UDim2.fromOffset(200, 150),
		Size = UDim2.fromOffset(150, 120),
		ZIndex = 1,
		BackgroundTransparency = 1,
	}, React.createElement(Droppable, {
		id = "deep",
	}, React.createElement("frame", {
		key = "DeepZone",
		Size = UDim2.fromScale(1, 1),
		ZIndex = 10,
		BackgroundTransparency = 1,
	})))))
end
local function emptyFixture()
	return React.createElement("frame", {
		key = "Empty",
		Size = UDim2.fromOffset(10, 10),
		BackgroundTransparency = 1,
	})
end
local function waitForDropZone(host)
	return waitForGuiObject(host, "DropZone")
end
local function waitForZone(host, name)
	local zone = waitForDescendant(host, name, function()
		return true
	end)
	waitForDroppableRegistration(zone)
	return zone
end
local function startDrag(host)
	local dragItem = waitForDragItem(host)
	local registration = waitForDraggableRegistration(dragItem)
	local handle = findDescendant(dragItem, "DragHandle")
	pressHandle(handle, centerOf(handle))
	waitForLayout(function()
		return if not dragItem.Visible then true else nil
	end, "Timed out waiting for the original to hide while dragging")
	return registration
end
local function hostPoint(host, x, y)
	local _absolutePosition = host.AbsolutePosition
	local _vector2 = Vector2.new(x, y)
	return _absolutePosition + _vector2
end
local function withSecondGui(mounted, displayOrder, fn)
	local screenGui = mounted.host.Parent
	local gui = Instance.new("ScreenGui")
	gui.Name = "SecondGui"
	gui.DisplayOrder = displayOrder
	gui.Parent = screenGui.Parent
	local root = Instance.new("Frame")
	root.Name = "SecondRoot"
	root.BackgroundTransparency = 1
	root.Position = UDim2.fromOffset(220, 170)
	root.Size = UDim2.fromOffset(150, 120)
	root.Parent = gui
	TS.try(function()
		fn(gui, root)
	end, nil, function()
		mounted.update(emptyFixture())
		root:Destroy()
		gui:Destroy()
	end)
end
local DroppableMountValidation
do
	DroppableMountValidation = setmetatable({}, {
		__tostring = function()
			return "DroppableMountValidation"
		end,
	})
	DroppableMountValidation.__index = DroppableMountValidation
	function DroppableMountValidation.new(...)
		local self = setmetatable({}, DroppableMountValidation)
		return self:constructor(...) or self
	end
	function DroppableMountValidation:constructor()
	end
	function DroppableMountValidation:rendersChildUnwrapped()
		resetDragState()
		withMounted(400, 300, droppableFixture(), function(mounted)
			local zone = waitForDropZone(mounted.host)
			Assert:equal(zone.Parent, mounted.host, "Expected the drop zone to be a direct child of the host (no wrapper)")
			assertSizeApprox(zone, 120, 80, 1, "drop zone")
			assertContained(zone, mounted.host, "drop zone vs host")
		end)
	end
	function DroppableMountValidation:registersAndForwardsDrop()
		resetDragState()
		local dropped = {}
		withMounted(400, 300, droppableFixture(function(dragged)
			local _dragged = dragged
			table.insert(dropped, _dragged)
			return #dropped
		end), function(mounted)
			local zone = waitForDropZone(mounted.host)
			local registration = waitForDroppableRegistration(zone)
			Assert:equal(registration.id, DROP_ID)
			Assert:equal(registration.guiObject, zone, "Expected the registration to point at the cloned child instance")
			local dragged = Instance.new("Frame")
			registration.drop(dragged)
			Assert:equal(#dropped, 1, "Expected onDrop to fire exactly once")
			Assert:equal(dropped[1], dragged, "Expected onDrop to receive the dragged GuiObject unchanged")
			dragged:Destroy()
		end)
	end
	function DroppableMountValidation:unregistersOnUnmount()
		resetDragState()
		withMounted(400, 300, droppableFixture(), function(mounted)
			local zone = waitForDropZone(mounted.host)
			waitForDroppableRegistration(zone)
			local registry = dragState.registry
			mounted.update(React.createElement(RegistryProvider, nil, React.createElement(RegistryHarness), React.createElement("frame", {
				key = "Placeholder",
				Size = UDim2.fromOffset(10, 10),
				BackgroundTransparency = 1,
			})))
			waitForLayout(function()
				return if registry.get(zone, DroppableRegistryKey) == nil then true else nil
			end, "Timed out waiting for the Droppable's registry entry to be removed after unmount")
		end)
	end
	function DroppableMountValidation:dropFiresOnceOnRelease()
		resetDragState()
		local dropped = {}
		local zones = { {
			id = DROP_ID,
			name = "DropZone",
			zIndex = 1,
			onDrop = function(dragged)
				local _dragged = dragged
				table.insert(dropped, _dragged)
				return #dropped
			end,
		} }
		withMounted(400, 300, dragToZonesFixture(zones), function(mounted)
			local zone = waitForDropZone(mounted.host)
			waitForDroppableRegistration(zone)
			local registration = startDrag(mounted.host)
			local target = centerOf(zone)
			for step = 1, 3 do
				local _draggable = registration.draggable
				local _vector2 = Vector2.new(step * 4, 0)
				_draggable.updateDrag(pointerInput(target + _vector2, Enum.UserInputType.MouseMovement))
				task.wait()
			end
			Assert:equal(#dropped, 0, `Expected onDrop not to fire while the pointer only moves over the target, but it fired {#dropped} time(s) during 3 moves`)
			registration.draggable.endDrag(pointerInput(target))
			Assert:equal(#dropped, 1, `Expected onDrop to fire exactly once on release, got {#dropped}`)
			Assert:equal(dropped[1], registration.guiObject, "Expected onDrop to receive the dragged root GuiObject")
		end)
	end
	function DroppableMountValidation:topmostZIndexReported()
		resetDragState()
		local reported
		local zones = { {
			id = "top",
			name = "TopZone",
			zIndex = 2,
			onDrop = function() end,
		}, {
			id = "bottom",
			name = "BottomZone",
			zIndex = 1,
			onDrop = function() end,
		} }
		withMounted(400, 300, dragToZonesFixture(zones, function(droppable)
			reported = droppable
		end), function(mounted)
			local top = waitForGuiObject(mounted.host, "TopZone")
			waitForDroppableRegistration(top)
			waitForDroppableRegistration(waitForGuiObject(mounted.host, "BottomZone"))
			local registration = startDrag(mounted.host)
			registration.draggable.endDrag(pointerInput(centerOf(top)))
			Assert:notUndefined(reported, "Expected onDropped to report a droppable under the pointer")
			Assert:equal(reported.id, "top", `Expected the higher-ZIndex target "top" to win the drop, but "{reported.id}" did`)
		end)
	end
	function DroppableMountValidation:onlyTopmostReceivesDrop()
		resetDragState()
		local topDrops = 0
		local bottomDrops = 0
		local zones = { {
			id = "top",
			name = "TopZone",
			zIndex = 2,
			onDrop = function()
				topDrops += 1
			end,
		}, {
			id = "bottom",
			name = "BottomZone",
			zIndex = 1,
			onDrop = function()
				bottomDrops += 1
			end,
		} }
		withMounted(400, 300, dragToZonesFixture(zones), function(mounted)
			local top = waitForGuiObject(mounted.host, "TopZone")
			waitForDroppableRegistration(top)
			waitForDroppableRegistration(waitForGuiObject(mounted.host, "BottomZone"))
			local registration = startDrag(mounted.host)
			registration.draggable.endDrag(pointerInput(centerOf(top)))
			Assert:equal(topDrops, 1, `Expected the top target's onDrop to fire once, got {topDrops}`)
			Assert:equal(bottomDrops, 0, `Expected the covered target's onDrop not to fire, but it fired {bottomDrops} time(s)`)
		end)
	end
	function DroppableMountValidation:laterSiblingReported()
		resetDragState()
		local reported
		local zones = { {
			id = "earlier",
			name = "EarlierZone",
			zIndex = 1,
			onDrop = function() end,
		}, {
			id = "later",
			name = "LaterZone",
			zIndex = 1,
			onDrop = function() end,
		} }
		withMounted(400, 300, dragToZonesFixture(zones, function(droppable)
			reported = droppable
		end), function(mounted)
			local later = waitForGuiObject(mounted.host, "LaterZone")
			waitForDroppableRegistration(later)
			waitForDroppableRegistration(waitForGuiObject(mounted.host, "EarlierZone"))
			local registration = startDrag(mounted.host)
			registration.draggable.endDrag(pointerInput(centerOf(later)))
			Assert:notUndefined(reported, "Expected onDropped to report a droppable under the pointer")
			Assert:equal(reported.id, "later", `Expected the later sibling "later" to win the drop, but "{reported.id}" did`)
		end)
	end
	function DroppableMountValidation:enterLeaveSequence()
		resetDragState()
		local log = {}
		local zones = { {
			id = "left",
			name = "LeftZone",
			position = UDim2.fromOffset(20, 150),
			zIndex = 1,
		}, {
			id = "right",
			name = "RightZone",
			position = UDim2.fromOffset(230, 150),
			zIndex = 1,
		} }
		withMounted(400, 300, loggedZonesFixture(zones, log), function(mounted)
			local left = waitForZone(mounted.host, "LeftZone")
			local right = waitForZone(mounted.host, "RightZone")
			local registration = startDrag(mounted.host)
			moveTo(registration, centerOf(left))
			local _exp = centerOf(left)
			local _vector2 = Vector2.new(5, 0)
			moveTo(registration, _exp + _vector2)
			moveTo(registration, centerOf(right))
			moveTo(registration, hostPoint(mounted.host, 200, 210))
			moveTo(registration, centerOf(left))
			registration.draggable.endDrag(pointerInput(centerOf(left)))
			Assert:equal(table.concat(log, ","), "enter:left,leave:left,enter:right,leave:right,enter:left,drop:left,leave:left", "Expected the enter/leave/drop sequence to pair every enter with exactly one leave")
		end)
	end
	function DroppableMountValidation:enterFollowsTopmost()
		resetDragState()
		local log = {}
		local zones = { {
			id = "top",
			name = "TopZone",
			position = UDim2.fromOffset(200, 150),
			zIndex = 2,
		}, {
			id = "bottom",
			name = "BottomZone",
			position = UDim2.fromOffset(100, 100),
			zIndex = 1,
		} }
		withMounted(400, 300, loggedZonesFixture(zones, log), function(mounted)
			local top = waitForZone(mounted.host, "TopZone")
			local bottom = waitForZone(mounted.host, "BottomZone")
			local registration = startDrag(mounted.host)
			local bottomOnly = hostPoint(mounted.host, 120, 120)
			moveTo(registration, overlapPoint(top, bottom))
			moveTo(registration, bottomOnly)
			registration.draggable.endDrag(pointerInput(bottomOnly))
			Assert:equal(table.concat(log, ","), "enter:top,leave:top,enter:bottom,drop:bottom,leave:bottom", "Expected the covered target to receive nothing while the top target is hovered")
		end)
	end
	function DroppableMountValidation:leaveOnUnmount()
		resetDragState()
		local log = {}
		local zones = { {
			id = "left",
			name = "LeftZone",
			position = UDim2.fromOffset(20, 150),
			zIndex = 1,
		} }
		withMounted(400, 300, loggedZonesFixture(zones, log), function(mounted)
			local left = waitForZone(mounted.host, "LeftZone")
			local registration = startDrag(mounted.host)
			moveTo(registration, centerOf(left))
			Assert:equal(table.concat(log, ","), "enter:left", "Expected one enter before the Draggable unmounts")
			mounted.update(loggedZonesFixture(zones, log, false))
			settleFrames(3)
			Assert:equal(table.concat(log, ","), "enter:left,leave:left", "Expected the hovered target to get exactly one leave when the dragging Draggable unmounts")
			Assert:equal(findDescendant(mounted.host, "LeftZone"), left, "Expected the Droppable to stay mounted")
		end)
	end
	function DroppableMountValidation:noProviderDrop(kind)
		resetDragState()
		local reported = {}
		local dropInfo
		local dropCount = 0
		local onDrop = function(_dragged, info)
			dropCount += 1
			dropInfo = info
		end
		withMounted(400, 300, noProviderFixture(kind == "sameRoot", reporter(reported), onDrop), function(mounted)
			local otherHost
			local otherRoot
			if kind == "separateRoot" then
				otherHost = Instance.new("Frame")
				otherHost.Name = "OtherRoot"
				otherHost.BackgroundTransparency = 1
				otherHost.Position = UDim2.fromOffset(200, 150)
				otherHost.Size = UDim2.fromOffset(150, 120)
				otherHost.Parent = mounted.host.Parent
				otherRoot = ReactRoblox.createRoot(otherHost)
				otherRoot:render(React.createElement(Droppable, {
					id = DROP_ID,
					onDrop = onDrop,
				}, React.createElement("frame", {
					key = "DropZone",
					Size = UDim2.fromScale(1, 1),
					BackgroundTransparency = 1,
				})))
			end
			TS.try(function()
				local zone = waitForDropZone(otherHost or mounted.host)
				waitForGlobalDroppable(zone)
				local dragItem = waitForDragItem(mounted.host)
				local registration = waitForGlobalDraggable(dragItem)
				local handle = findDescendant(dragItem, "DragHandle")
				pressHandle(handle, centerOf(handle))
				waitForLayout(function()
					return if not dragItem.Visible then true else nil
				end, "Timed out waiting for the original to hide while dragging")
				registration.draggable.endDrag(pointerInput(centerOf(zone)))
				Assert:equal(dropCount, 1, `Expected the {kind} Droppable's onDrop to fire once without a RegistryProvider`)
				local _result = dropInfo
				if _result ~= nil then
					_result = _result.id
				end
				Assert:equal(_result, DRAG_ID)
				local _result_1 = reported.droppable
				if _result_1 ~= nil then
					_result_1 = _result_1.id
				end
				Assert:equal(_result_1, DROP_ID, "Expected onDropped to report the provider-less Droppable")
			end, nil, function()
				local _result = otherRoot
				if _result ~= nil then
					_result:unmount()
				end
				local _result_1 = otherHost
				if _result_1 ~= nil then
					_result_1:Destroy()
				end
			end)
		end)
	end
	function DroppableMountValidation:ineligibleTargetSkipped(mode, expected)
		resetDragState()
		local reported = {}
		withMounted(400, 300, ineligibleFixture(mode, reporter(reported)), function(mounted)
			local back = waitForZone(mounted.host, "BackZone")
			waitForZone(mounted.host, "FrontZone")
			local registration = startDrag(mounted.host)
			registration.draggable.endDrag(pointerInput(centerOf(back)))
			Assert:notUndefined(reported.droppable, `Expected a droppable to be reported for mode {mode}`)
			Assert:equal(reported.droppable.id, expected, `Expected "{expected}" to win with the front target {mode}, but "{reported.droppable.id}" did`)
		end)
	end
	function DroppableMountValidation:displayOrderWins(displayOrder, expected)
		resetDragState()
		local reported = {}
		withMounted(400, 300, emptyFixture(), function(mounted)
			withSecondGui(mounted, displayOrder, function(_gui, root)
				mounted.update(crossGuiFixture(root, reporter(reported)))
				local localZone = waitForZone(mounted.host, "LocalZone")
				local other = waitForZone(root, "OtherZone")
				local registration = startDrag(mounted.host)
				registration.draggable.endDrag(pointerInput(overlapPoint(localZone, other)))
				local _result = reported.droppable
				if _result ~= nil then
					_result = _result.id
				end
				Assert:equal(_result, expected, `Expected "{expected}" to win with the second ScreenGui at DisplayOrder {displayOrder}`)
			end)
		end)
	end
	function DroppableMountValidation:disabledGuiSkipped(enabled, expected)
		resetDragState()
		local reported = {}
		withMounted(400, 300, emptyFixture(), function(mounted)
			withSecondGui(mounted, 10, function(gui, root)
				mounted.update(crossGuiFixture(root, reporter(reported)))
				local localZone = waitForZone(mounted.host, "LocalZone")
				local other = waitForZone(root, "OtherZone")
				local point = overlapPoint(localZone, other)
				gui.Enabled = enabled
				local registration = startDrag(mounted.host)
				registration.draggable.endDrag(pointerInput(point))
				local _result = reported.droppable
				if _result ~= nil then
					_result = _result.id
				end
				Assert:equal(_result, expected, `Expected "{expected}" to win with the second ScreenGui Enabled={enabled}`)
			end)
		end)
	end
	function DroppableMountValidation:zIndexBehavior(behavior, expected)
		resetDragState()
		local reported = {}
		withMounted(400, 300, zIndexBehaviorFixture(reporter(reported)), function(mounted)
			(mounted.host.Parent).ZIndexBehavior = if behavior == "Global" then Enum.ZIndexBehavior.Global else Enum.ZIndexBehavior.Sibling
			local shallow = waitForZone(mounted.host, "ShallowZone")
			local deep = waitForZone(mounted.host, "DeepZone")
			local registration = startDrag(mounted.host)
			registration.draggable.endDrag(pointerInput(overlapPoint(shallow, deep)))
			local _result = reported.droppable
			if _result ~= nil then
				_result = _result.id
			end
			Assert:equal(_result, expected, `Expected "{expected}" to win under ZIndexBehavior.{behavior}`)
		end)
	end
	local _decorator = Skip(not Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	local _decorator_1 = DisplayName("Renders its child in place with no wrapper, at the child's own size, inside the host")
	local _descriptor = Test(DroppableMountValidation, "rendersChildUnwrapped", {
		value = DroppableMountValidation.rendersChildUnwrapped,
	})
	if _descriptor then
		DroppableMountValidation.rendersChildUnwrapped = _descriptor.value
	end
	local _descriptor_1 = _decorator_1(DroppableMountValidation, "rendersChildUnwrapped", {
		value = DroppableMountValidation.rendersChildUnwrapped,
	})
	if _descriptor_1 then
		DroppableMountValidation.rendersChildUnwrapped = _descriptor_1.value
	end
	local _descriptor_2 = _decorator(DroppableMountValidation, "rendersChildUnwrapped", {
		value = DroppableMountValidation.rendersChildUnwrapped,
	})
	if _descriptor_2 then
		DroppableMountValidation.rendersChildUnwrapped = _descriptor_2.value
	end
	local _decorator_2 = Skip(not Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	local _decorator_3 = DisplayName("Registers its child under DroppableRegistryKey with its id, and the registration's drop() forwards the dragged object to onDrop")
	local _descriptor_3 = Test(DroppableMountValidation, "registersAndForwardsDrop", {
		value = DroppableMountValidation.registersAndForwardsDrop,
	})
	if _descriptor_3 then
		DroppableMountValidation.registersAndForwardsDrop = _descriptor_3.value
	end
	local _descriptor_4 = _decorator_3(DroppableMountValidation, "registersAndForwardsDrop", {
		value = DroppableMountValidation.registersAndForwardsDrop,
	})
	if _descriptor_4 then
		DroppableMountValidation.registersAndForwardsDrop = _descriptor_4.value
	end
	local _descriptor_5 = _decorator_2(DroppableMountValidation, "registersAndForwardsDrop", {
		value = DroppableMountValidation.registersAndForwardsDrop,
	})
	if _descriptor_5 then
		DroppableMountValidation.registersAndForwardsDrop = _descriptor_5.value
	end
	local _decorator_4 = Skip(not Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	local _decorator_5 = DisplayName("Unmounting the Droppable removes its registry entry")
	local _descriptor_6 = Test(DroppableMountValidation, "unregistersOnUnmount", {
		value = DroppableMountValidation.unregistersOnUnmount,
	})
	if _descriptor_6 then
		DroppableMountValidation.unregistersOnUnmount = _descriptor_6.value
	end
	local _descriptor_7 = _decorator_5(DroppableMountValidation, "unregistersOnUnmount", {
		value = DroppableMountValidation.unregistersOnUnmount,
	})
	if _descriptor_7 then
		DroppableMountValidation.unregistersOnUnmount = _descriptor_7.value
	end
	local _descriptor_8 = _decorator_4(DroppableMountValidation, "unregistersOnUnmount", {
		value = DroppableMountValidation.unregistersOnUnmount,
	})
	if _descriptor_8 then
		DroppableMountValidation.unregistersOnUnmount = _descriptor_8.value
	end
	local _decorator_6 = Skip(not Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	local _decorator_7 = DisplayName("Moving a drag across the target several times fires onDrop zero times, then exactly once on release")
	local _descriptor_9 = Test(DroppableMountValidation, "dropFiresOnceOnRelease", {
		value = DroppableMountValidation.dropFiresOnceOnRelease,
	})
	if _descriptor_9 then
		DroppableMountValidation.dropFiresOnceOnRelease = _descriptor_9.value
	end
	local _descriptor_10 = _decorator_7(DroppableMountValidation, "dropFiresOnceOnRelease", {
		value = DroppableMountValidation.dropFiresOnceOnRelease,
	})
	if _descriptor_10 then
		DroppableMountValidation.dropFiresOnceOnRelease = _descriptor_10.value
	end
	local _descriptor_11 = _decorator_6(DroppableMountValidation, "dropFiresOnceOnRelease", {
		value = DroppableMountValidation.dropFiresOnceOnRelease,
	})
	if _descriptor_11 then
		DroppableMountValidation.dropFiresOnceOnRelease = _descriptor_11.value
	end
	local _decorator_8 = Skip(not Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	local _decorator_9 = DisplayName("With two overlapping targets, onDropped reports the one with the higher ZIndex even when it is declared first")
	local _descriptor_12 = Test(DroppableMountValidation, "topmostZIndexReported", {
		value = DroppableMountValidation.topmostZIndexReported,
	})
	if _descriptor_12 then
		DroppableMountValidation.topmostZIndexReported = _descriptor_12.value
	end
	local _descriptor_13 = _decorator_9(DroppableMountValidation, "topmostZIndexReported", {
		value = DroppableMountValidation.topmostZIndexReported,
	})
	if _descriptor_13 then
		DroppableMountValidation.topmostZIndexReported = _descriptor_13.value
	end
	local _descriptor_14 = _decorator_8(DroppableMountValidation, "topmostZIndexReported", {
		value = DroppableMountValidation.topmostZIndexReported,
	})
	if _descriptor_14 then
		DroppableMountValidation.topmostZIndexReported = _descriptor_14.value
	end
	local _decorator_10 = Skip(not Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	local _decorator_11 = DisplayName("With two overlapping targets, only the one drawn on top has onDrop fired; the target underneath gets nothing")
	local _descriptor_15 = Test(DroppableMountValidation, "onlyTopmostReceivesDrop", {
		value = DroppableMountValidation.onlyTopmostReceivesDrop,
	})
	if _descriptor_15 then
		DroppableMountValidation.onlyTopmostReceivesDrop = _descriptor_15.value
	end
	local _descriptor_16 = _decorator_11(DroppableMountValidation, "onlyTopmostReceivesDrop", {
		value = DroppableMountValidation.onlyTopmostReceivesDrop,
	})
	if _descriptor_16 then
		DroppableMountValidation.onlyTopmostReceivesDrop = _descriptor_16.value
	end
	local _descriptor_17 = _decorator_10(DroppableMountValidation, "onlyTopmostReceivesDrop", {
		value = DroppableMountValidation.onlyTopmostReceivesDrop,
	})
	if _descriptor_17 then
		DroppableMountValidation.onlyTopmostReceivesDrop = _descriptor_17.value
	end
	local _decorator_12 = Skip(not Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	local _decorator_13 = DisplayName("With two overlapping targets at the same ZIndex, the later sibling (drawn on top) wins the drop")
	local _descriptor_18 = Test(DroppableMountValidation, "laterSiblingReported", {
		value = DroppableMountValidation.laterSiblingReported,
	})
	if _descriptor_18 then
		DroppableMountValidation.laterSiblingReported = _descriptor_18.value
	end
	local _descriptor_19 = _decorator_13(DroppableMountValidation, "laterSiblingReported", {
		value = DroppableMountValidation.laterSiblingReported,
	})
	if _descriptor_19 then
		DroppableMountValidation.laterSiblingReported = _descriptor_19.value
	end
	local _descriptor_20 = _decorator_12(DroppableMountValidation, "laterSiblingReported", {
		value = DroppableMountValidation.laterSiblingReported,
	})
	if _descriptor_20 then
		DroppableMountValidation.laterSiblingReported = _descriptor_20.value
	end
	local _decorator_14 = Skip(not Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	local _decorator_15 = DisplayName("Moving on, within, across, off and back onto targets pairs every enter with one leave, and release drops then leaves")
	local _descriptor_21 = Test(DroppableMountValidation, "enterLeaveSequence", {
		value = DroppableMountValidation.enterLeaveSequence,
	})
	if _descriptor_21 then
		DroppableMountValidation.enterLeaveSequence = _descriptor_21.value
	end
	local _descriptor_22 = _decorator_15(DroppableMountValidation, "enterLeaveSequence", {
		value = DroppableMountValidation.enterLeaveSequence,
	})
	if _descriptor_22 then
		DroppableMountValidation.enterLeaveSequence = _descriptor_22.value
	end
	local _descriptor_23 = _decorator_14(DroppableMountValidation, "enterLeaveSequence", {
		value = DroppableMountValidation.enterLeaveSequence,
	})
	if _descriptor_23 then
		DroppableMountValidation.enterLeaveSequence = _descriptor_23.value
	end
	local _decorator_16 = Skip(not Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	local _decorator_17 = DisplayName("Over two overlapping targets only the top one is entered; moving to the uncovered part of the lower one hands over")
	local _descriptor_24 = Test(DroppableMountValidation, "enterFollowsTopmost", {
		value = DroppableMountValidation.enterFollowsTopmost,
	})
	if _descriptor_24 then
		DroppableMountValidation.enterFollowsTopmost = _descriptor_24.value
	end
	local _descriptor_25 = _decorator_17(DroppableMountValidation, "enterFollowsTopmost", {
		value = DroppableMountValidation.enterFollowsTopmost,
	})
	if _descriptor_25 then
		DroppableMountValidation.enterFollowsTopmost = _descriptor_25.value
	end
	local _descriptor_26 = _decorator_16(DroppableMountValidation, "enterFollowsTopmost", {
		value = DroppableMountValidation.enterFollowsTopmost,
	})
	if _descriptor_26 then
		DroppableMountValidation.enterFollowsTopmost = _descriptor_26.value
	end
	local _decorator_18 = Skip(not Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	local _decorator_19 = DisplayName("Unmounting the Draggable while it hovers a target sends that target exactly one leave")
	local _descriptor_27 = Test(DroppableMountValidation, "leaveOnUnmount", {
		value = DroppableMountValidation.leaveOnUnmount,
	})
	if _descriptor_27 then
		DroppableMountValidation.leaveOnUnmount = _descriptor_27.value
	end
	local _descriptor_28 = _decorator_19(DroppableMountValidation, "leaveOnUnmount", {
		value = DroppableMountValidation.leaveOnUnmount,
	})
	if _descriptor_28 then
		DroppableMountValidation.leaveOnUnmount = _descriptor_28.value
	end
	local _descriptor_29 = _decorator_18(DroppableMountValidation, "leaveOnUnmount", {
		value = DroppableMountValidation.leaveOnUnmount,
	})
	if _descriptor_29 then
		DroppableMountValidation.leaveOnUnmount = _descriptor_29.value
	end
	local _decorator_20 = Skip(not Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	local _decorator_21 = DisplayName("With no RegistryProvider anywhere, a drop reaches a Droppable in the same React root or in a separate root")
	local _decorator_22 = Each({ { "sameRoot" }, { "separateRoot" } })
	local _descriptor_30 = Test(DroppableMountValidation, "noProviderDrop", {
		value = DroppableMountValidation.noProviderDrop,
	})
	if _descriptor_30 then
		DroppableMountValidation.noProviderDrop = _descriptor_30.value
	end
	local _descriptor_31 = _decorator_22(DroppableMountValidation, "noProviderDrop", {
		value = DroppableMountValidation.noProviderDrop,
	})
	if _descriptor_31 then
		DroppableMountValidation.noProviderDrop = _descriptor_31.value
	end
	local _descriptor_32 = _decorator_21(DroppableMountValidation, "noProviderDrop", {
		value = DroppableMountValidation.noProviderDrop,
	})
	if _descriptor_32 then
		DroppableMountValidation.noProviderDrop = _descriptor_32.value
	end
	local _descriptor_33 = _decorator_20(DroppableMountValidation, "noProviderDrop", {
		value = DroppableMountValidation.noProviderDrop,
	})
	if _descriptor_33 then
		DroppableMountValidation.noProviderDrop = _descriptor_33.value
	end
	local _decorator_23 = Skip(not Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	local _decorator_24 = DisplayName("A higher target that is hidden, has a hidden ancestor, or is clipped away at the pointer is skipped for the one beneath")
	local _decorator_25 = Each({ { "visible", "front" }, { "hidden", "back" }, { "hiddenAncestor", "back" }, { "clipped", "back" } })
	local _descriptor_34 = Test(DroppableMountValidation, "ineligibleTargetSkipped", {
		value = DroppableMountValidation.ineligibleTargetSkipped,
	})
	if _descriptor_34 then
		DroppableMountValidation.ineligibleTargetSkipped = _descriptor_34.value
	end
	local _descriptor_35 = _decorator_25(DroppableMountValidation, "ineligibleTargetSkipped", {
		value = DroppableMountValidation.ineligibleTargetSkipped,
	})
	if _descriptor_35 then
		DroppableMountValidation.ineligibleTargetSkipped = _descriptor_35.value
	end
	local _descriptor_36 = _decorator_24(DroppableMountValidation, "ineligibleTargetSkipped", {
		value = DroppableMountValidation.ineligibleTargetSkipped,
	})
	if _descriptor_36 then
		DroppableMountValidation.ineligibleTargetSkipped = _descriptor_36.value
	end
	local _descriptor_37 = _decorator_23(DroppableMountValidation, "ineligibleTargetSkipped", {
		value = DroppableMountValidation.ineligibleTargetSkipped,
	})
	if _descriptor_37 then
		DroppableMountValidation.ineligibleTargetSkipped = _descriptor_37.value
	end
	local _decorator_26 = Skip(not Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	local _decorator_27 = DisplayName("Across ScreenGuis the higher DisplayOrder wins, even over a target with a much larger ZIndex")
	local _decorator_28 = Each({ { 10, "other" }, { -10, "local" } })
	local _descriptor_38 = Test(DroppableMountValidation, "displayOrderWins", {
		value = DroppableMountValidation.displayOrderWins,
	})
	if _descriptor_38 then
		DroppableMountValidation.displayOrderWins = _descriptor_38.value
	end
	local _descriptor_39 = _decorator_28(DroppableMountValidation, "displayOrderWins", {
		value = DroppableMountValidation.displayOrderWins,
	})
	if _descriptor_39 then
		DroppableMountValidation.displayOrderWins = _descriptor_39.value
	end
	local _descriptor_40 = _decorator_27(DroppableMountValidation, "displayOrderWins", {
		value = DroppableMountValidation.displayOrderWins,
	})
	if _descriptor_40 then
		DroppableMountValidation.displayOrderWins = _descriptor_40.value
	end
	local _descriptor_41 = _decorator_26(DroppableMountValidation, "displayOrderWins", {
		value = DroppableMountValidation.displayOrderWins,
	})
	if _descriptor_41 then
		DroppableMountValidation.displayOrderWins = _descriptor_41.value
	end
	local _decorator_29 = Skip(not Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	local _decorator_30 = DisplayName("A target in a ScreenGui that is disabled at drag time is skipped, even with the higher DisplayOrder")
	local _decorator_31 = Each({ { true, "other" }, { false, "local" } })
	local _descriptor_42 = Test(DroppableMountValidation, "disabledGuiSkipped", {
		value = DroppableMountValidation.disabledGuiSkipped,
	})
	if _descriptor_42 then
		DroppableMountValidation.disabledGuiSkipped = _descriptor_42.value
	end
	local _descriptor_43 = _decorator_31(DroppableMountValidation, "disabledGuiSkipped", {
		value = DroppableMountValidation.disabledGuiSkipped,
	})
	if _descriptor_43 then
		DroppableMountValidation.disabledGuiSkipped = _descriptor_43.value
	end
	local _descriptor_44 = _decorator_30(DroppableMountValidation, "disabledGuiSkipped", {
		value = DroppableMountValidation.disabledGuiSkipped,
	})
	if _descriptor_44 then
		DroppableMountValidation.disabledGuiSkipped = _descriptor_44.value
	end
	local _descriptor_45 = _decorator_29(DroppableMountValidation, "disabledGuiSkipped", {
		value = DroppableMountValidation.disabledGuiSkipped,
	})
	if _descriptor_45 then
		DroppableMountValidation.disabledGuiSkipped = _descriptor_45.value
	end
	local _decorator_32 = Skip(not Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	local _decorator_33 = DisplayName("Sibling ZIndexBehavior compares the top-level branches' ZIndex, Global compares each target's own ZIndex")
	local _decorator_34 = Each({ { "Sibling", "shallow" }, { "Global", "deep" } })
	local _descriptor_46 = Test(DroppableMountValidation, "zIndexBehavior", {
		value = DroppableMountValidation.zIndexBehavior,
	})
	if _descriptor_46 then
		DroppableMountValidation.zIndexBehavior = _descriptor_46.value
	end
	local _descriptor_47 = _decorator_34(DroppableMountValidation, "zIndexBehavior", {
		value = DroppableMountValidation.zIndexBehavior,
	})
	if _descriptor_47 then
		DroppableMountValidation.zIndexBehavior = _descriptor_47.value
	end
	local _descriptor_48 = _decorator_33(DroppableMountValidation, "zIndexBehavior", {
		value = DroppableMountValidation.zIndexBehavior,
	})
	if _descriptor_48 then
		DroppableMountValidation.zIndexBehavior = _descriptor_48.value
	end
	local _descriptor_49 = _decorator_32(DroppableMountValidation, "zIndexBehavior", {
		value = DroppableMountValidation.zIndexBehavior,
	})
	if _descriptor_49 then
		DroppableMountValidation.zIndexBehavior = _descriptor_49.value
	end
	DroppableMountValidation = Tag("Studio")(DroppableMountValidation) or DroppableMountValidation
end
return DroppableMountValidation
