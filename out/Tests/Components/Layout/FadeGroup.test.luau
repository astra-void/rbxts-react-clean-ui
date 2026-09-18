-- Compiled with roblox-ts v3.0.0
local TS = _G[script]
local React = TS.import(script, TS.getModule(script, "@rbxts", "react"))
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
local FadeGroup = TS.import(script, script.Parent.Parent.Parent.Parent, "Components", "Layout", "FadeGroup").FadeGroup
local _layout = TS.import(script, script.Parent.Parent.Parent, "Helpers", "layout")
local STUDIO_SKIP_MESSAGE = _layout.STUDIO_SKIP_MESSAGE
local assertSizeApprox = _layout.assertSizeApprox
local waitForGuiObject = _layout.waitForGuiObject
local waitForLayout = _layout.waitForLayout
local withMounted = _layout.withMounted
local HOST_WIDTH = 400
local HOST_HEIGHT = 300
local CONTENT_WIDTH = 120
local CONTENT_HEIGHT = 50
local function content()
	return React.createElement("frame", {
		key = "Inner",
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(CONTENT_WIDTH, CONTENT_HEIGHT),
	})
end
local function waitForFadeGroup(host, name)
	if name == nil then
		name = "FadeGroup"
	end
	return waitForGuiObject(host, name)
end
local FadeGroupMountValidation
do
	FadeGroupMountValidation = setmetatable({}, {
		__tostring = function()
			return "FadeGroupMountValidation"
		end,
	})
	FadeGroupMountValidation.__index = FadeGroupMountValidation
	function FadeGroupMountValidation.new(...)
		local self = setmetatable({}, FadeGroupMountValidation)
		return self:constructor(...) or self
	end
	function FadeGroupMountValidation:constructor()
	end
	function FadeGroupMountValidation:defaultsApplied()
		withMounted(HOST_WIDTH, HOST_HEIGHT, React.createElement(FadeGroup, nil, content()), function(mounted)
			local group = waitForFadeGroup(mounted.host)
			Assert["true"](Assert, group:IsA("CanvasGroup"), `Expected FadeGroup to be a CanvasGroup, got {group.ClassName}`)
			Assert:equal(group.GroupTransparency, 0)
			Assert:equal(group.GroupColor3, Color3.new(1, 1, 1))
			Assert:equal(group.BackgroundTransparency, 1)
			Assert:equal(group.BorderSizePixel, 0)
		end)
	end
	function FadeGroupMountValidation:customName()
		withMounted(HOST_WIDTH, HOST_HEIGHT, React.createElement(FadeGroup, {
			name = "InventorySlot",
		}, content()), function(mounted)
			local group = waitForFadeGroup(mounted.host, "InventorySlot")
			Assert["true"](Assert, group:IsA("CanvasGroup"), `Expected InventorySlot to be a CanvasGroup, got {group.ClassName}`)
			Assert:undefined(mounted.host:FindFirstChild("FadeGroup", true))
		end)
	end
	function FadeGroupMountValidation:transparencyPassesThrough(transparency)
		withMounted(HOST_WIDTH, HOST_HEIGHT, React.createElement(FadeGroup, {
			GroupTransparency = transparency,
		}, content()), function(mounted)
			Assert:equal(waitForFadeGroup(mounted.host).GroupTransparency, transparency)
		end)
	end
	function FadeGroupMountValidation:bindingDrivesTransparency()
		local transparency, setTransparency = React.createBinding(0.25)
		withMounted(HOST_WIDTH, HOST_HEIGHT, React.createElement(FadeGroup, {
			GroupTransparency = transparency,
		}, content()), function(mounted)
			local group = waitForFadeGroup(mounted.host)
			Assert:equal(group.GroupTransparency, 0.25)
			setTransparency(0.75)
			waitForLayout(function()
				return if group.GroupTransparency == 0.75 then true else nil
			end, `Timed out waiting for the binding to set GroupTransparency to 0.75 (is {group.GroupTransparency})`)
		end)
	end
	function FadeGroupMountValidation:groupColorPassesThrough()
		local tint = Color3.new(0.5, 0.25, 0.75)
		withMounted(HOST_WIDTH, HOST_HEIGHT, React.createElement(FadeGroup, {
			GroupColor3 = tint,
		}, content()), function(mounted)
			Assert:equal(waitForFadeGroup(mounted.host).GroupColor3, tint)
		end)
	end
	function FadeGroupMountValidation:autoSizesToContent()
		withMounted(HOST_WIDTH, HOST_HEIGHT, React.createElement(FadeGroup, nil, content()), function(mounted)
			local group = waitForFadeGroup(mounted.host)
			Assert:equal(group.AutomaticSize, Enum.AutomaticSize.XY)
			assertSizeApprox(group, CONTENT_WIDTH, CONTENT_HEIGHT, 1, "auto-sized FadeGroup")
		end)
	end
	function FadeGroupMountValidation:explicitSizeFixed()
		withMounted(HOST_WIDTH, HOST_HEIGHT, React.createElement(FadeGroup, {
			Size = UDim2.fromOffset(200, 80),
		}, content()), function(mounted)
			local group = waitForFadeGroup(mounted.host)
			Assert:equal(group.AutomaticSize, Enum.AutomaticSize.None)
			Assert:equal(group.Size, UDim2.fromOffset(200, 80))
			assertSizeApprox(group, 200, 80, 1, "explicitly sized FadeGroup")
		end)
	end
	function FadeGroupMountValidation:orderAndZIndex()
		withMounted(HOST_WIDTH, HOST_HEIGHT, React.createElement(FadeGroup, {
			LayoutOrder = 3,
			ZIndex = 4,
		}, content()), function(mounted)
			local group = waitForFadeGroup(mounted.host)
			Assert:equal(group.LayoutOrder, 3)
			Assert:equal(group.ZIndex, 4)
		end)
	end
	function FadeGroupMountValidation:childrenAreDirect()
		withMounted(HOST_WIDTH, HOST_HEIGHT, React.createElement(FadeGroup, nil, React.createElement("uilistlayout", {
			key = "Layout",
		}), content()), function(mounted)
			local group = waitForFadeGroup(mounted.host)
			local inner = waitForGuiObject(group, "Inner")
			local layout = group:FindFirstChild("Layout")
			Assert:equal(inner.Parent, group, "Expected Inner to be a direct child of the CanvasGroup")
			Assert:notUndefined(layout, "Expected the UIListLayout to be a direct child of the CanvasGroup")
			Assert["true"](Assert, layout:IsA("UIListLayout"), "Expected Layout to be the UIListLayout child")
		end)
	end
	function FadeGroupMountValidation:refIsCanvasGroup()
		local ref = React.createRef()
		withMounted(HOST_WIDTH, HOST_HEIGHT, React.createElement(FadeGroup, {
			ref = ref,
		}, content()), function(mounted)
			local group = waitForFadeGroup(mounted.host)
			Assert:equal(ref.current, group)
		end)
	end
	local _decorator = Skip(not Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	local _decorator_1 = DisplayName("With no props the root is a CanvasGroup named FadeGroup that is fully visible, untinted and borderless")
	local _descriptor = Test(FadeGroupMountValidation, "defaultsApplied", {
		value = FadeGroupMountValidation.defaultsApplied,
	})
	if _descriptor then
		FadeGroupMountValidation.defaultsApplied = _descriptor.value
	end
	local _descriptor_1 = _decorator_1(FadeGroupMountValidation, "defaultsApplied", {
		value = FadeGroupMountValidation.defaultsApplied,
	})
	if _descriptor_1 then
		FadeGroupMountValidation.defaultsApplied = _descriptor_1.value
	end
	local _descriptor_2 = _decorator(FadeGroupMountValidation, "defaultsApplied", {
		value = FadeGroupMountValidation.defaultsApplied,
	})
	if _descriptor_2 then
		FadeGroupMountValidation.defaultsApplied = _descriptor_2.value
	end
	local _decorator_2 = Skip(not Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	local _decorator_3 = DisplayName("The name prop replaces the default FadeGroup instance name")
	local _descriptor_3 = Test(FadeGroupMountValidation, "customName", {
		value = FadeGroupMountValidation.customName,
	})
	if _descriptor_3 then
		FadeGroupMountValidation.customName = _descriptor_3.value
	end
	local _descriptor_4 = _decorator_3(FadeGroupMountValidation, "customName", {
		value = FadeGroupMountValidation.customName,
	})
	if _descriptor_4 then
		FadeGroupMountValidation.customName = _descriptor_4.value
	end
	local _descriptor_5 = _decorator_2(FadeGroupMountValidation, "customName", {
		value = FadeGroupMountValidation.customName,
	})
	if _descriptor_5 then
		FadeGroupMountValidation.customName = _descriptor_5.value
	end
	local _decorator_4 = Skip(not Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	local _decorator_5 = Each({ { 0.25 }, { 0.5 }, { 0.75 } })
	local _decorator_6 = DisplayName("A numeric GroupTransparency is applied to the CanvasGroup as given")
	local _descriptor_6 = Test(FadeGroupMountValidation, "transparencyPassesThrough", {
		value = FadeGroupMountValidation.transparencyPassesThrough,
	})
	if _descriptor_6 then
		FadeGroupMountValidation.transparencyPassesThrough = _descriptor_6.value
	end
	local _descriptor_7 = _decorator_6(FadeGroupMountValidation, "transparencyPassesThrough", {
		value = FadeGroupMountValidation.transparencyPassesThrough,
	})
	if _descriptor_7 then
		FadeGroupMountValidation.transparencyPassesThrough = _descriptor_7.value
	end
	local _descriptor_8 = _decorator_5(FadeGroupMountValidation, "transparencyPassesThrough", {
		value = FadeGroupMountValidation.transparencyPassesThrough,
	})
	if _descriptor_8 then
		FadeGroupMountValidation.transparencyPassesThrough = _descriptor_8.value
	end
	local _descriptor_9 = _decorator_4(FadeGroupMountValidation, "transparencyPassesThrough", {
		value = FadeGroupMountValidation.transparencyPassesThrough,
	})
	if _descriptor_9 then
		FadeGroupMountValidation.transparencyPassesThrough = _descriptor_9.value
	end
	local _decorator_7 = Skip(not Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	local _decorator_8 = DisplayName("A GroupTransparency binding sets the initial value and updating the binding updates the CanvasGroup")
	local _descriptor_10 = Test(FadeGroupMountValidation, "bindingDrivesTransparency", {
		value = FadeGroupMountValidation.bindingDrivesTransparency,
	})
	if _descriptor_10 then
		FadeGroupMountValidation.bindingDrivesTransparency = _descriptor_10.value
	end
	local _descriptor_11 = _decorator_8(FadeGroupMountValidation, "bindingDrivesTransparency", {
		value = FadeGroupMountValidation.bindingDrivesTransparency,
	})
	if _descriptor_11 then
		FadeGroupMountValidation.bindingDrivesTransparency = _descriptor_11.value
	end
	local _descriptor_12 = _decorator_7(FadeGroupMountValidation, "bindingDrivesTransparency", {
		value = FadeGroupMountValidation.bindingDrivesTransparency,
	})
	if _descriptor_12 then
		FadeGroupMountValidation.bindingDrivesTransparency = _descriptor_12.value
	end
	local _decorator_9 = Skip(not Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	local _decorator_10 = DisplayName("GroupColor3 is applied to the CanvasGroup as the tint colour")
	local _descriptor_13 = Test(FadeGroupMountValidation, "groupColorPassesThrough", {
		value = FadeGroupMountValidation.groupColorPassesThrough,
	})
	if _descriptor_13 then
		FadeGroupMountValidation.groupColorPassesThrough = _descriptor_13.value
	end
	local _descriptor_14 = _decorator_10(FadeGroupMountValidation, "groupColorPassesThrough", {
		value = FadeGroupMountValidation.groupColorPassesThrough,
	})
	if _descriptor_14 then
		FadeGroupMountValidation.groupColorPassesThrough = _descriptor_14.value
	end
	local _descriptor_15 = _decorator_9(FadeGroupMountValidation, "groupColorPassesThrough", {
		value = FadeGroupMountValidation.groupColorPassesThrough,
	})
	if _descriptor_15 then
		FadeGroupMountValidation.groupColorPassesThrough = _descriptor_15.value
	end
	local _decorator_11 = Skip(not Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	local _decorator_12 = DisplayName("Without Size, width or height the group uses AutomaticSize XY and hugs its content")
	local _descriptor_16 = Test(FadeGroupMountValidation, "autoSizesToContent", {
		value = FadeGroupMountValidation.autoSizesToContent,
	})
	if _descriptor_16 then
		FadeGroupMountValidation.autoSizesToContent = _descriptor_16.value
	end
	local _descriptor_17 = _decorator_12(FadeGroupMountValidation, "autoSizesToContent", {
		value = FadeGroupMountValidation.autoSizesToContent,
	})
	if _descriptor_17 then
		FadeGroupMountValidation.autoSizesToContent = _descriptor_17.value
	end
	local _descriptor_18 = _decorator_11(FadeGroupMountValidation, "autoSizesToContent", {
		value = FadeGroupMountValidation.autoSizesToContent,
	})
	if _descriptor_18 then
		FadeGroupMountValidation.autoSizesToContent = _descriptor_18.value
	end
	local _decorator_13 = Skip(not Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	local _decorator_14 = DisplayName("An explicit Size turns AutomaticSize off and pins the group to that size regardless of content")
	local _descriptor_19 = Test(FadeGroupMountValidation, "explicitSizeFixed", {
		value = FadeGroupMountValidation.explicitSizeFixed,
	})
	if _descriptor_19 then
		FadeGroupMountValidation.explicitSizeFixed = _descriptor_19.value
	end
	local _descriptor_20 = _decorator_14(FadeGroupMountValidation, "explicitSizeFixed", {
		value = FadeGroupMountValidation.explicitSizeFixed,
	})
	if _descriptor_20 then
		FadeGroupMountValidation.explicitSizeFixed = _descriptor_20.value
	end
	local _descriptor_21 = _decorator_13(FadeGroupMountValidation, "explicitSizeFixed", {
		value = FadeGroupMountValidation.explicitSizeFixed,
	})
	if _descriptor_21 then
		FadeGroupMountValidation.explicitSizeFixed = _descriptor_21.value
	end
	local _decorator_15 = Skip(not Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	local _decorator_16 = DisplayName("LayoutOrder and ZIndex are forwarded to the CanvasGroup")
	local _descriptor_22 = Test(FadeGroupMountValidation, "orderAndZIndex", {
		value = FadeGroupMountValidation.orderAndZIndex,
	})
	if _descriptor_22 then
		FadeGroupMountValidation.orderAndZIndex = _descriptor_22.value
	end
	local _descriptor_23 = _decorator_16(FadeGroupMountValidation, "orderAndZIndex", {
		value = FadeGroupMountValidation.orderAndZIndex,
	})
	if _descriptor_23 then
		FadeGroupMountValidation.orderAndZIndex = _descriptor_23.value
	end
	local _descriptor_24 = _decorator_15(FadeGroupMountValidation, "orderAndZIndex", {
		value = FadeGroupMountValidation.orderAndZIndex,
	})
	if _descriptor_24 then
		FadeGroupMountValidation.orderAndZIndex = _descriptor_24.value
	end
	local _decorator_17 = Skip(not Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	local _decorator_18 = DisplayName("Children, including layout objects, are parented directly to the CanvasGroup with no wrapper frame")
	local _descriptor_25 = Test(FadeGroupMountValidation, "childrenAreDirect", {
		value = FadeGroupMountValidation.childrenAreDirect,
	})
	if _descriptor_25 then
		FadeGroupMountValidation.childrenAreDirect = _descriptor_25.value
	end
	local _descriptor_26 = _decorator_18(FadeGroupMountValidation, "childrenAreDirect", {
		value = FadeGroupMountValidation.childrenAreDirect,
	})
	if _descriptor_26 then
		FadeGroupMountValidation.childrenAreDirect = _descriptor_26.value
	end
	local _descriptor_27 = _decorator_17(FadeGroupMountValidation, "childrenAreDirect", {
		value = FadeGroupMountValidation.childrenAreDirect,
	})
	if _descriptor_27 then
		FadeGroupMountValidation.childrenAreDirect = _descriptor_27.value
	end
	local _decorator_19 = Skip(not Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	local _decorator_20 = DisplayName("A forwarded ref resolves to the rendered CanvasGroup instance")
	local _descriptor_28 = Test(FadeGroupMountValidation, "refIsCanvasGroup", {
		value = FadeGroupMountValidation.refIsCanvasGroup,
	})
	if _descriptor_28 then
		FadeGroupMountValidation.refIsCanvasGroup = _descriptor_28.value
	end
	local _descriptor_29 = _decorator_20(FadeGroupMountValidation, "refIsCanvasGroup", {
		value = FadeGroupMountValidation.refIsCanvasGroup,
	})
	if _descriptor_29 then
		FadeGroupMountValidation.refIsCanvasGroup = _descriptor_29.value
	end
	local _descriptor_30 = _decorator_19(FadeGroupMountValidation, "refIsCanvasGroup", {
		value = FadeGroupMountValidation.refIsCanvasGroup,
	})
	if _descriptor_30 then
		FadeGroupMountValidation.refIsCanvasGroup = _descriptor_30.value
	end
	FadeGroupMountValidation = Tag("Studio")(FadeGroupMountValidation) or FadeGroupMountValidation
end
return FadeGroupMountValidation
