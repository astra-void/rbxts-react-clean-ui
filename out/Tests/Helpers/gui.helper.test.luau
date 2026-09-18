-- Compiled with roblox-ts v3.0.0
local TS = _G[script]
local _lunit = TS.import(script, TS.getModule(script, "@rbxts", "lunit").out)
local Test = _lunit.Test
local Assert = _lunit.Assert
local Decorators = _lunit.Decorators
local Runtime = _lunit.Runtime
local Tag = _lunit.Tag
local DisplayName = _lunit.DisplayName
local GuiHelper = TS.import(script, script.Parent.Parent.Parent, "Helpers", "gui.helper").GuiHelper
local STUDIO_SKIP_MESSAGE = TS.import(script, script.Parent, "layout").STUDIO_SKIP_MESSAGE
local _binding = Decorators
local Skip = _binding.Skip
local Each = _binding.Each
local function makeGui(parent, name, displayOrder)
	if displayOrder == nil then
		displayOrder = 0
	end
	local gui = Instance.new("ScreenGui")
	gui.Name = name
	gui.DisplayOrder = displayOrder
	gui.Parent = parent
	return gui
end
local function makeFrame(parent, name, zIndex)
	if zIndex == nil then
		zIndex = 1
	end
	local frame = Instance.new("Frame")
	frame.Name = name
	frame.ZIndex = zIndex
	frame.Parent = parent
	return frame
end
local function withTree(fn)
	local root = Instance.new("Folder")
	root.Name = "RenderOrderTree"
	TS.try(function()
		fn(root)
	end, nil, function()
		root:Destroy()
	end)
end
local function assertAbove(a, b, message)
	Assert["true"](Assert, GuiHelper:isRenderedAbove(a, b), `{message}: expected {a.Name} above {b.Name}`)
	Assert["false"](Assert, GuiHelper:isRenderedAbove(b, a), `{message}: expected {b.Name} not above {a.Name}`)
end
local GuiHelperRenderOrder
do
	GuiHelperRenderOrder = setmetatable({}, {
		__tostring = function()
			return "GuiHelperRenderOrder"
		end,
	})
	GuiHelperRenderOrder.__index = GuiHelperRenderOrder
	function GuiHelperRenderOrder.new(...)
		local self = setmetatable({}, GuiHelperRenderOrder)
		return self:constructor(...) or self
	end
	function GuiHelperRenderOrder:constructor()
	end
	function GuiHelperRenderOrder:notAboveSelf()
		withTree(function(root)
			local frame = makeFrame(makeGui(root, "Gui"), "Frame")
			Assert["false"](Assert, GuiHelper:isRenderedAbove(frame, frame))
		end)
	end
	function GuiHelperRenderOrder:displayOrderFirst()
		withTree(function(root)
			local high = makeFrame(makeGui(root, "HighGui", 5), "HighFrame", 1)
			local low = makeFrame(makeGui(root, "LowGui", 0), "LowFrame", 1000)
			assertAbove(high, low, "DisplayOrder 5 vs 0")
		end)
	end
	function GuiHelperRenderOrder:equalDisplayOrderTreeOrder()
		withTree(function(root)
			local earlier = makeFrame(makeGui(root, "EarlierGui"), "EarlierFrame", 50)
			local later = makeFrame(makeGui(root, "LaterGui"), "LaterFrame", 1)
			assertAbove(later, earlier, "equal DisplayOrder")
		end)
	end
	function GuiHelperRenderOrder:zIndexBehaviorOrder(behavior, expected)
		withTree(function(root)
			local gui = makeGui(root, "Gui")
			gui.ZIndexBehavior = if behavior == "Global" then Enum.ZIndexBehavior.Global else Enum.ZIndexBehavior.Sibling
			local shallow = makeFrame(gui, "Shallow", 5)
			local lowParent = makeFrame(gui, "LowParent", 1)
			local deep = makeFrame(lowParent, "Deep", 10)
			if expected == "Deep" then
				assertAbove(deep, shallow, `ZIndexBehavior.{behavior}`)
			else
				assertAbove(shallow, deep, `ZIndexBehavior.{behavior}`)
			end
		end)
	end
	function GuiHelperRenderOrder:descendantAboveAncestor(behavior)
		withTree(function(root)
			local gui = makeGui(root, "Gui")
			gui.ZIndexBehavior = if behavior == "Global" then Enum.ZIndexBehavior.Global else Enum.ZIndexBehavior.Sibling
			local parent = makeFrame(gui, "Parent")
			local child = makeFrame(parent, "Child")
			assertAbove(child, parent, `ZIndexBehavior.{behavior}`)
		end)
	end
	function GuiHelperRenderOrder:laterSiblingBranch()
		withTree(function(root)
			local gui = makeGui(root, "Gui")
			gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
			local earlier = makeFrame(gui, "EarlierBranch", 1)
			local deep = makeFrame(earlier, "DeepChild", 99)
			local later = makeFrame(gui, "LaterBranch", 1)
			assertAbove(later, deep, "Sibling tie")
		end)
	end
	local _decorator = Skip(not Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	local _decorator_1 = DisplayName("An object is never reported as rendered above itself")
	local _descriptor = Test(GuiHelperRenderOrder, "notAboveSelf", {
		value = GuiHelperRenderOrder.notAboveSelf,
	})
	if _descriptor then
		GuiHelperRenderOrder.notAboveSelf = _descriptor.value
	end
	local _descriptor_1 = _decorator_1(GuiHelperRenderOrder, "notAboveSelf", {
		value = GuiHelperRenderOrder.notAboveSelf,
	})
	if _descriptor_1 then
		GuiHelperRenderOrder.notAboveSelf = _descriptor_1.value
	end
	local _descriptor_2 = _decorator(GuiHelperRenderOrder, "notAboveSelf", {
		value = GuiHelperRenderOrder.notAboveSelf,
	})
	if _descriptor_2 then
		GuiHelperRenderOrder.notAboveSelf = _descriptor_2.value
	end
	local _decorator_2 = Skip(not Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	local _decorator_3 = DisplayName("Across ScreenGuis the higher DisplayOrder wins regardless of ZIndex or which ScreenGui comes first")
	local _descriptor_3 = Test(GuiHelperRenderOrder, "displayOrderFirst", {
		value = GuiHelperRenderOrder.displayOrderFirst,
	})
	if _descriptor_3 then
		GuiHelperRenderOrder.displayOrderFirst = _descriptor_3.value
	end
	local _descriptor_4 = _decorator_3(GuiHelperRenderOrder, "displayOrderFirst", {
		value = GuiHelperRenderOrder.displayOrderFirst,
	})
	if _descriptor_4 then
		GuiHelperRenderOrder.displayOrderFirst = _descriptor_4.value
	end
	local _descriptor_5 = _decorator_2(GuiHelperRenderOrder, "displayOrderFirst", {
		value = GuiHelperRenderOrder.displayOrderFirst,
	})
	if _descriptor_5 then
		GuiHelperRenderOrder.displayOrderFirst = _descriptor_5.value
	end
	local _decorator_4 = Skip(not Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	local _decorator_5 = DisplayName("Across ScreenGuis with equal DisplayOrder the later ScreenGui in the tree is on top")
	local _descriptor_6 = Test(GuiHelperRenderOrder, "equalDisplayOrderTreeOrder", {
		value = GuiHelperRenderOrder.equalDisplayOrderTreeOrder,
	})
	if _descriptor_6 then
		GuiHelperRenderOrder.equalDisplayOrderTreeOrder = _descriptor_6.value
	end
	local _descriptor_7 = _decorator_5(GuiHelperRenderOrder, "equalDisplayOrderTreeOrder", {
		value = GuiHelperRenderOrder.equalDisplayOrderTreeOrder,
	})
	if _descriptor_7 then
		GuiHelperRenderOrder.equalDisplayOrderTreeOrder = _descriptor_7.value
	end
	local _descriptor_8 = _decorator_4(GuiHelperRenderOrder, "equalDisplayOrderTreeOrder", {
		value = GuiHelperRenderOrder.equalDisplayOrderTreeOrder,
	})
	if _descriptor_8 then
		GuiHelperRenderOrder.equalDisplayOrderTreeOrder = _descriptor_8.value
	end
	local _decorator_6 = Skip(not Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	local _decorator_7 = DisplayName("A deep child with a high ZIndex under a low-ZIndex parent loses under Sibling and wins under Global")
	local _decorator_8 = Each({ { "Sibling", "Shallow" }, { "Global", "Deep" } })
	local _descriptor_9 = Test(GuiHelperRenderOrder, "zIndexBehaviorOrder", {
		value = GuiHelperRenderOrder.zIndexBehaviorOrder,
	})
	if _descriptor_9 then
		GuiHelperRenderOrder.zIndexBehaviorOrder = _descriptor_9.value
	end
	local _descriptor_10 = _decorator_8(GuiHelperRenderOrder, "zIndexBehaviorOrder", {
		value = GuiHelperRenderOrder.zIndexBehaviorOrder,
	})
	if _descriptor_10 then
		GuiHelperRenderOrder.zIndexBehaviorOrder = _descriptor_10.value
	end
	local _descriptor_11 = _decorator_7(GuiHelperRenderOrder, "zIndexBehaviorOrder", {
		value = GuiHelperRenderOrder.zIndexBehaviorOrder,
	})
	if _descriptor_11 then
		GuiHelperRenderOrder.zIndexBehaviorOrder = _descriptor_11.value
	end
	local _descriptor_12 = _decorator_6(GuiHelperRenderOrder, "zIndexBehaviorOrder", {
		value = GuiHelperRenderOrder.zIndexBehaviorOrder,
	})
	if _descriptor_12 then
		GuiHelperRenderOrder.zIndexBehaviorOrder = _descriptor_12.value
	end
	local _decorator_9 = Skip(not Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	local _decorator_10 = DisplayName("With equal ZIndex a descendant draws above its ancestor under both ZIndexBehaviors")
	local _decorator_11 = Each({ { "Sibling" }, { "Global" } })
	local _descriptor_13 = Test(GuiHelperRenderOrder, "descendantAboveAncestor", {
		value = GuiHelperRenderOrder.descendantAboveAncestor,
	})
	if _descriptor_13 then
		GuiHelperRenderOrder.descendantAboveAncestor = _descriptor_13.value
	end
	local _descriptor_14 = _decorator_11(GuiHelperRenderOrder, "descendantAboveAncestor", {
		value = GuiHelperRenderOrder.descendantAboveAncestor,
	})
	if _descriptor_14 then
		GuiHelperRenderOrder.descendantAboveAncestor = _descriptor_14.value
	end
	local _descriptor_15 = _decorator_10(GuiHelperRenderOrder, "descendantAboveAncestor", {
		value = GuiHelperRenderOrder.descendantAboveAncestor,
	})
	if _descriptor_15 then
		GuiHelperRenderOrder.descendantAboveAncestor = _descriptor_15.value
	end
	local _descriptor_16 = _decorator_9(GuiHelperRenderOrder, "descendantAboveAncestor", {
		value = GuiHelperRenderOrder.descendantAboveAncestor,
	})
	if _descriptor_16 then
		GuiHelperRenderOrder.descendantAboveAncestor = _descriptor_16.value
	end
	local _decorator_12 = Skip(not Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	local _decorator_13 = DisplayName("Under Sibling with equal branch ZIndex, the later sibling branch is on top even against a deeper high-ZIndex child")
	local _descriptor_17 = Test(GuiHelperRenderOrder, "laterSiblingBranch", {
		value = GuiHelperRenderOrder.laterSiblingBranch,
	})
	if _descriptor_17 then
		GuiHelperRenderOrder.laterSiblingBranch = _descriptor_17.value
	end
	local _descriptor_18 = _decorator_13(GuiHelperRenderOrder, "laterSiblingBranch", {
		value = GuiHelperRenderOrder.laterSiblingBranch,
	})
	if _descriptor_18 then
		GuiHelperRenderOrder.laterSiblingBranch = _descriptor_18.value
	end
	local _descriptor_19 = _decorator_12(GuiHelperRenderOrder, "laterSiblingBranch", {
		value = GuiHelperRenderOrder.laterSiblingBranch,
	})
	if _descriptor_19 then
		GuiHelperRenderOrder.laterSiblingBranch = _descriptor_19.value
	end
	GuiHelperRenderOrder = Tag("Studio")(GuiHelperRenderOrder) or GuiHelperRenderOrder
end
return GuiHelperRenderOrder
