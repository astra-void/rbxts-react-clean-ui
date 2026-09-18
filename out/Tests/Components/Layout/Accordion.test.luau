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
local Accordion = TS.import(script, script.Parent.Parent.Parent.Parent, "Components", "Layout", "Accordion").Accordion
local activateButton = TS.import(script, script.Parent.Parent.Parent, "Helpers", "fiber").activateButton
local _layout = TS.import(script, script.Parent.Parent.Parent, "Helpers", "layout")
local STUDIO_SKIP_MESSAGE = _layout.STUDIO_SKIP_MESSAGE
local assertAllDescendantsContained = _layout.assertAllDescendantsContained
local assertContained = _layout.assertContained
local assertNonZeroSize = _layout.assertNonZeroSize
local assertSizeApprox = _layout.assertSizeApprox
local assertStackedVertically = _layout.assertStackedVertically
local findDescendant = _layout.findDescendant
local rect = _layout.rect
local waitForGuiObject = _layout.waitForGuiObject
local waitForLayout = _layout.waitForLayout
local withMounted = _layout.withMounted
local HOST_WIDTH = 400
local HOST_HEIGHT = 400
local function accordion(props)
	if props == nil then
		props = {}
	end
	return React.createElement(Accordion, {
		defaultValue = props.defaultValue,
		value = props.value,
		animationDuration = 0,
	}, React.createElement(Accordion.Item, {
		value = "one",
	}, React.createElement(Accordion.Header, {
		text = "Section one",
	}), React.createElement(Accordion.Content, {
		text = "Content for section one.",
	})), React.createElement(Accordion.Item, {
		value = "two",
	}, React.createElement(Accordion.Header, {
		text = "Section two",
	}), React.createElement(Accordion.Content, {
		text = "Content for section two.",
	})))
end
local counterState = {}
local function Counter()
	local count, setCount = React.useState(0)
	counterState.increment = function()
		return setCount(function(previous)
			return previous + 1
		end)
	end
	return React.createElement("textlabel", {
		key = "CounterText",
		Text = `{count}`,
		Size = UDim2.fromOffset(100, 20),
		BackgroundTransparency = 1,
	})
end
local function optionsAccordion(props)
	local _attributes = {
		defaultValue = props.defaultValue,
		value = props.value,
		autoSize = props.autoSize,
		keepMounted = props.keepMounted,
		collapsible = props.collapsible,
	}
	local _condition = props.animationDuration
	if _condition == nil then
		_condition = 0
	end
	_attributes.animationDuration = _condition
	return React.createElement(Accordion, _attributes, React.createElement(Accordion.Item, {
		value = "one",
	}, React.createElement(Accordion.Header, {
		text = "Section one",
	}), React.createElement(Accordion.Content, nil, React.createElement(Counter))), React.createElement(Accordion.Item, {
		value = "two",
	}, React.createElement(Accordion.Header, {
		text = "Section two",
	}), React.createElement(Accordion.Content, {
		text = "Content for section two.",
	})))
end
local function multipleAccordion(defaultValue, onValueChange)
	return React.createElement(Accordion, {
		multiple = true,
		defaultValue = defaultValue,
		onValueChange = onValueChange,
		animationDuration = 0,
	}, React.createElement(Accordion.Item, {
		value = "one",
	}, React.createElement(Accordion.Header, {
		text = "Section one",
	}), React.createElement(Accordion.Content, {
		text = "Content for section one.",
	})), React.createElement(Accordion.Item, {
		value = "two",
	}, React.createElement(Accordion.Header, {
		text = "Section two",
	}), React.createElement(Accordion.Content, {
		text = "Content for section two.",
	})))
end
local function waitForAccordion(host)
	return waitForGuiObject(host, "Accordion")
end
local function findItem(root, value)
	return findDescendant(root, `AccordionItem-{value}`)
end
local function findHeader(root, value)
	return findDescendant(root, `AccordionHeaderButton-{value}`)
end
local function findHeaderButton(root, value)
	return findDescendant(root, `AccordionHeaderButton-{value}`)
end
local function waitForOpenClip(item, value)
	return waitForGuiObject(item, "ContentClip", function(clip)
		return clip.Visible and clip.AbsoluteSize.Y > 0
	end, `Timed out waiting for item "{value}" to show a visible ContentClip with a non-zero height`)
end
local function waitForClipMatchingContent(item, value, frames)
	do
		local frame = 0
		local _shouldIncrement = false
		while true do
			if _shouldIncrement then
				frame += 1
			else
				_shouldIncrement = true
			end
			if not (frame < frames) then
				break
			end
			local clip = item:FindFirstChild("ContentClip", true)
			local _result = clip
			if _result ~= nil then
				_result = _result:FindFirstChild("Content")
			end
			local content = _result
			if clip ~= nil and content ~= nil and clip.Visible and content.AbsoluteSize.Y > 0 and math.abs(clip.AbsoluteSize.Y - content.AbsoluteSize.Y) <= 1 then
				return clip
			end
			task.wait()
		end
	end
	local clip = item:FindFirstChild("ContentClip", true)
	local _result = clip
	if _result ~= nil then
		_result = _result:FindFirstChild("Content")
	end
	local content = _result
	local _exp = value
	local _result_1 = clip
	if _result_1 ~= nil then
		_result_1 = _result_1.AbsoluteSize.Y
	end
	local _result_2 = content
	if _result_2 ~= nil then
		_result_2 = _result_2.AbsoluteSize.Y
	end
	return Assert:fail(`Timed out waiting for item "{_exp}" ContentClip to reach its Content height (clip={_result_1}, content={_result_2})`)
end
local function assertClipCollapsed(item, value)
	local clip = waitForLayout(function()
		local found = item:FindFirstChild("ContentClip", true)
		return if found ~= nil and not found.Visible and found.Size.Y.Scale == 0 and found.Size.Y.Offset == 0 then found else nil
	end, `Timed out waiting for item "{value}" to keep a hidden, zero-height ContentClip`)
	Assert:notUndefined(clip:FindFirstChild("Content"), `Expected item "{value}" collapsed ContentClip to keep its Content`)
end
local function assertContentUnmounted(item, value)
	Assert["true"](Assert, item:FindFirstChild("ContentClip", true) == nil, `Expected the closed item "{value}" to have no mounted ContentClip`)
end
local AccordionMountValidation
do
	AccordionMountValidation = setmetatable({}, {
		__tostring = function()
			return "AccordionMountValidation"
		end,
	})
	AccordionMountValidation.__index = AccordionMountValidation
	function AccordionMountValidation.new(...)
		local self = setmetatable({}, AccordionMountValidation)
		return self:constructor(...) or self
	end
	function AccordionMountValidation:constructor()
	end
	function AccordionMountValidation:defaultValueExpandsItem(openValue, closedValue)
		withMounted(HOST_WIDTH, HOST_HEIGHT, accordion({
			defaultValue = openValue,
		}), function(mounted)
			local root = waitForAccordion(mounted.host)
			local openItem = findItem(root, openValue)
			local closedItem = findItem(root, closedValue)
			local clip = waitForGuiObject(openItem, "ContentClip")
			local contentText = findDescendant(clip, "AccordionContentText")
			assertNonZeroSize(clip, `open item {openValue}`)
			assertContained(contentText, clip, `open item {openValue}`)
			assertContained(clip, root, `open item {openValue}`)
			assertContentUnmounted(closedItem, closedValue)
		end)
	end
	function AccordionMountValidation:itemsStackVertically()
		withMounted(HOST_WIDTH, HOST_HEIGHT, accordion({
			defaultValue = "one",
		}), function(mounted)
			local root = waitForAccordion(mounted.host)
			local clip = waitForGuiObject(findItem(root, "one"), "ContentClip")
			local headerOne = findHeader(root, "one")
			local headerTwo = findHeader(root, "two")
			assertStackedVertically({ headerOne, clip, headerTwo }, "accordion items")
		end)
	end
	function AccordionMountValidation:controlledValueSwitches()
		withMounted(HOST_WIDTH, HOST_HEIGHT, accordion({
			value = "one",
		}), function(mounted)
			local root = waitForAccordion(mounted.host)
			local itemOne = findItem(root, "one")
			local itemTwo = findItem(root, "two")
			waitForGuiObject(itemOne, "ContentClip")
			assertContentUnmounted(itemTwo, "two")
			mounted.update(accordion({
				value = "two",
			}))
			waitForLayout(function()
				return if itemOne:FindFirstChild("ContentClip", true) == nil then true else nil
			end, "Timed out waiting for item one's ContentClip to be unmounted after the controlled value moved to two")
			local clipTwo = waitForGuiObject(itemTwo, "ContentClip")
			assertNonZeroSize(clipTwo, "item two after value switch")
			assertContained(clipTwo, root, "item two after value switch")
		end)
	end
	function AccordionMountValidation:allContained()
		withMounted(HOST_WIDTH, HOST_HEIGHT, accordion({
			defaultValue = "one",
		}), function(mounted)
			local root = waitForAccordion(mounted.host)
			waitForGuiObject(findItem(root, "one"), "ContentClip")
			assertAllDescendantsContained(root, "expanded accordion")
		end)
	end
	function AccordionMountValidation:keepMountedClosed()
		withMounted(HOST_WIDTH, HOST_HEIGHT, optionsAccordion({
			defaultValue = "two",
			keepMounted = true,
		}), function(mounted)
			local root = waitForAccordion(mounted.host)
			waitForOpenClip(findItem(root, "two"), "two")
			assertClipCollapsed(findItem(root, "one"), "one")
		end)
	end
	function AccordionMountValidation:keepMountedKeepsState()
		withMounted(HOST_WIDTH, HOST_HEIGHT, optionsAccordion({
			value = "one",
			keepMounted = true,
		}), function(mounted)
			local root = waitForAccordion(mounted.host)
			local itemOne = findItem(root, "one")
			waitForOpenClip(itemOne, "one")
			local label = findDescendant(itemOne, "CounterText")
			counterState.increment()
			waitForLayout(function()
				return if label.Text == "1" then true else nil
			end, "Timed out waiting for the counter to reach 1")
			mounted.update(optionsAccordion({
				value = "two",
				keepMounted = true,
			}))
			assertClipCollapsed(itemOne, "one")
			mounted.update(optionsAccordion({
				value = "one",
				keepMounted = true,
			}))
			waitForClipMatchingContent(itemOne, "one", 30)
			local reopened = findDescendant(itemOne, "CounterText")
			Assert:equal(reopened, label, "Expected the reopened item to reuse the same CounterText instance")
			Assert:equal(reopened.Text, "1")
		end)
	end
	function AccordionMountValidation:defaultResetsState()
		withMounted(HOST_WIDTH, HOST_HEIGHT, optionsAccordion({
			value = "one",
		}), function(mounted)
			local root = waitForAccordion(mounted.host)
			local itemOne = findItem(root, "one")
			waitForOpenClip(itemOne, "one")
			local label = findDescendant(itemOne, "CounterText")
			counterState.increment()
			waitForLayout(function()
				return if label.Text == "1" then true else nil
			end, "Timed out waiting for the counter to reach 1")
			mounted.update(optionsAccordion({
				value = "two",
			}))
			waitForLayout(function()
				return if itemOne:FindFirstChild("ContentClip", true) == nil then true else nil
			end, "Timed out waiting for item one's ContentClip to unmount")
			mounted.update(optionsAccordion({
				value = "one",
			}))
			waitForOpenClip(itemOne, "one")
			Assert:equal(findDescendant(itemOne, "CounterText").Text, "0")
		end)
	end
	function AccordionMountValidation:fillsHostHeight()
		withMounted(HOST_WIDTH, HOST_HEIGHT, optionsAccordion({}), function(mounted)
			local root = waitForAccordion(mounted.host)
			assertSizeApprox(root, HOST_WIDTH, HOST_HEIGHT, 1, "accordion without autoSize")
		end)
	end
	function AccordionMountValidation:autoSizeGrows()
		withMounted(HOST_WIDTH, HOST_HEIGHT, optionsAccordion({
			autoSize = true,
		}), function(mounted)
			local root = waitForAccordion(mounted.host)
			local closedHeight = waitForLayout(function()
				return if rect(root).height > 0 and rect(root).height < HOST_HEIGHT then rect(root).height else nil
			end, `Timed out waiting for the autoSize Accordion to be shorter than the host (height {rect(root).height})`)
			assertSizeApprox(root, HOST_WIDTH, nil, 1, "autoSize accordion width")
			activateButton(mounted, findHeaderButton(root, "two"))
			local clip = waitForOpenClip(findItem(root, "two"), "two")
			waitForLayout(function()
				return if rect(root).height >= closedHeight + rect(clip).height - 1 then true else nil
			end, `Timed out waiting for the autoSize Accordion to grow by the opened content (closed {closedHeight}, now {rect(root).height}, clip {rect(clip).height})`)
			Assert["true"](Assert, rect(root).height < HOST_HEIGHT, "Expected the opened autoSize Accordion to stay shorter than the host")
		end)
	end
	function AccordionMountValidation:multipleDefaultOpen()
		withMounted(HOST_WIDTH, HOST_HEIGHT, multipleAccordion({ "one", "two" }), function(mounted)
			local root = waitForAccordion(mounted.host)
			assertNonZeroSize(waitForOpenClip(findItem(root, "one"), "one"), "multiple item one")
			assertNonZeroSize(waitForOpenClip(findItem(root, "two"), "two"), "multiple item two")
		end)
	end
	function AccordionMountValidation:multipleClosesOne()
		local reported = {}
		withMounted(HOST_WIDTH, HOST_HEIGHT, multipleAccordion({ "one", "two" }, function(value)
			local _value = value
			table.insert(reported, _value)
			return #reported
		end), function(mounted)
			local root = waitForAccordion(mounted.host)
			local itemOne = findItem(root, "one")
			local itemTwo = findItem(root, "two")
			waitForOpenClip(itemOne, "one")
			waitForOpenClip(itemTwo, "two")
			activateButton(mounted, findHeaderButton(root, "one"))
			waitForLayout(function()
				return if itemOne:FindFirstChild("ContentClip", true) == nil then true else nil
			end, "Timed out waiting for item one's ContentClip to unmount after clicking its header")
			Assert:deepEqual(reported, { { "two" } })
			assertNonZeroSize(waitForOpenClip(itemTwo, "two"), "multiple item two after closing one")
		end)
	end
	function AccordionMountValidation:multipleOpensAnother()
		local reported = {}
		withMounted(HOST_WIDTH, HOST_HEIGHT, multipleAccordion({ "one" }, function(value)
			local _value = value
			table.insert(reported, _value)
			return #reported
		end), function(mounted)
			local root = waitForAccordion(mounted.host)
			local itemOne = findItem(root, "one")
			waitForOpenClip(itemOne, "one")
			assertContentUnmounted(findItem(root, "two"), "two")
			activateButton(mounted, findHeaderButton(root, "two"))
			waitForOpenClip(findItem(root, "two"), "two")
			assertNonZeroSize(waitForOpenClip(itemOne, "one"), "multiple item one after opening two")
			Assert:deepEqual(reported, { { "one", "two" } })
		end)
	end
	function AccordionMountValidation:reopenWhileClosing()
		withMounted(HOST_WIDTH, HOST_HEIGHT, optionsAccordion({
			defaultValue = "two",
			collapsible = true,
			animationDuration = 0.5,
		}), function(mounted)
			local root = waitForAccordion(mounted.host)
			local itemTwo = findItem(root, "two")
			waitForClipMatchingContent(itemTwo, "two", 120)
			activateButton(mounted, findHeaderButton(root, "two"))
			task.wait()
			local closing = itemTwo:FindFirstChild("ContentClip", true)
			Assert:notUndefined(closing, "Expected item two's ContentClip to still be mounted while animating closed")
			activateButton(mounted, findHeaderButton(root, "two"))
			waitForClipMatchingContent(itemTwo, "two", 120)
		end)
	end
	local _decorator = Skip(not Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	local _decorator_1 = Each({ { "one", "two" }, { "two", "one" } })
	local _decorator_2 = DisplayName("defaultValue expands that item's content to a visible height and leaves the other item's content unmounted")
	local _descriptor = Test(AccordionMountValidation, "defaultValueExpandsItem", {
		value = AccordionMountValidation.defaultValueExpandsItem,
	})
	if _descriptor then
		AccordionMountValidation.defaultValueExpandsItem = _descriptor.value
	end
	local _descriptor_1 = _decorator_2(AccordionMountValidation, "defaultValueExpandsItem", {
		value = AccordionMountValidation.defaultValueExpandsItem,
	})
	if _descriptor_1 then
		AccordionMountValidation.defaultValueExpandsItem = _descriptor_1.value
	end
	local _descriptor_2 = _decorator_1(AccordionMountValidation, "defaultValueExpandsItem", {
		value = AccordionMountValidation.defaultValueExpandsItem,
	})
	if _descriptor_2 then
		AccordionMountValidation.defaultValueExpandsItem = _descriptor_2.value
	end
	local _descriptor_3 = _decorator(AccordionMountValidation, "defaultValueExpandsItem", {
		value = AccordionMountValidation.defaultValueExpandsItem,
	})
	if _descriptor_3 then
		AccordionMountValidation.defaultValueExpandsItem = _descriptor_3.value
	end
	local _decorator_3 = Skip(not Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	local _decorator_4 = DisplayName("Headers and the expanded content are stacked top-to-bottom in item order")
	local _descriptor_4 = Test(AccordionMountValidation, "itemsStackVertically", {
		value = AccordionMountValidation.itemsStackVertically,
	})
	if _descriptor_4 then
		AccordionMountValidation.itemsStackVertically = _descriptor_4.value
	end
	local _descriptor_5 = _decorator_4(AccordionMountValidation, "itemsStackVertically", {
		value = AccordionMountValidation.itemsStackVertically,
	})
	if _descriptor_5 then
		AccordionMountValidation.itemsStackVertically = _descriptor_5.value
	end
	local _descriptor_6 = _decorator_3(AccordionMountValidation, "itemsStackVertically", {
		value = AccordionMountValidation.itemsStackVertically,
	})
	if _descriptor_6 then
		AccordionMountValidation.itemsStackVertically = _descriptor_6.value
	end
	local _decorator_5 = Skip(not Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	local _decorator_6 = DisplayName("Switching a controlled value from one to two unmounts item one's content and expands item two")
	local _descriptor_7 = Test(AccordionMountValidation, "controlledValueSwitches", {
		value = AccordionMountValidation.controlledValueSwitches,
	})
	if _descriptor_7 then
		AccordionMountValidation.controlledValueSwitches = _descriptor_7.value
	end
	local _descriptor_8 = _decorator_6(AccordionMountValidation, "controlledValueSwitches", {
		value = AccordionMountValidation.controlledValueSwitches,
	})
	if _descriptor_8 then
		AccordionMountValidation.controlledValueSwitches = _descriptor_8.value
	end
	local _descriptor_9 = _decorator_5(AccordionMountValidation, "controlledValueSwitches", {
		value = AccordionMountValidation.controlledValueSwitches,
	})
	if _descriptor_9 then
		AccordionMountValidation.controlledValueSwitches = _descriptor_9.value
	end
	local _decorator_7 = Skip(not Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	local _decorator_8 = DisplayName("With one item expanded, every visible descendant stays inside the Accordion")
	local _descriptor_10 = Test(AccordionMountValidation, "allContained", {
		value = AccordionMountValidation.allContained,
	})
	if _descriptor_10 then
		AccordionMountValidation.allContained = _descriptor_10.value
	end
	local _descriptor_11 = _decorator_8(AccordionMountValidation, "allContained", {
		value = AccordionMountValidation.allContained,
	})
	if _descriptor_11 then
		AccordionMountValidation.allContained = _descriptor_11.value
	end
	local _descriptor_12 = _decorator_7(AccordionMountValidation, "allContained", {
		value = AccordionMountValidation.allContained,
	})
	if _descriptor_12 then
		AccordionMountValidation.allContained = _descriptor_12.value
	end
	local _decorator_9 = Skip(not Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	local _decorator_10 = DisplayName("With keepMounted a closed item still has its ContentClip and Content, hidden at zero height")
	local _descriptor_13 = Test(AccordionMountValidation, "keepMountedClosed", {
		value = AccordionMountValidation.keepMountedClosed,
	})
	if _descriptor_13 then
		AccordionMountValidation.keepMountedClosed = _descriptor_13.value
	end
	local _descriptor_14 = _decorator_10(AccordionMountValidation, "keepMountedClosed", {
		value = AccordionMountValidation.keepMountedClosed,
	})
	if _descriptor_14 then
		AccordionMountValidation.keepMountedClosed = _descriptor_14.value
	end
	local _descriptor_15 = _decorator_9(AccordionMountValidation, "keepMountedClosed", {
		value = AccordionMountValidation.keepMountedClosed,
	})
	if _descriptor_15 then
		AccordionMountValidation.keepMountedClosed = _descriptor_15.value
	end
	local _decorator_11 = Skip(not Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	local _decorator_12 = DisplayName("With keepMounted a stateful child keeps its instance and state across close and reopen, at full height again")
	local _descriptor_16 = Test(AccordionMountValidation, "keepMountedKeepsState", {
		value = AccordionMountValidation.keepMountedKeepsState,
	})
	if _descriptor_16 then
		AccordionMountValidation.keepMountedKeepsState = _descriptor_16.value
	end
	local _descriptor_17 = _decorator_12(AccordionMountValidation, "keepMountedKeepsState", {
		value = AccordionMountValidation.keepMountedKeepsState,
	})
	if _descriptor_17 then
		AccordionMountValidation.keepMountedKeepsState = _descriptor_17.value
	end
	local _descriptor_18 = _decorator_11(AccordionMountValidation, "keepMountedKeepsState", {
		value = AccordionMountValidation.keepMountedKeepsState,
	})
	if _descriptor_18 then
		AccordionMountValidation.keepMountedKeepsState = _descriptor_18.value
	end
	local _decorator_13 = Skip(not Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	local _decorator_14 = DisplayName("Without keepMounted closing an item unmounts its content, so reopening starts the counter from 0")
	local _descriptor_19 = Test(AccordionMountValidation, "defaultResetsState", {
		value = AccordionMountValidation.defaultResetsState,
	})
	if _descriptor_19 then
		AccordionMountValidation.defaultResetsState = _descriptor_19.value
	end
	local _descriptor_20 = _decorator_14(AccordionMountValidation, "defaultResetsState", {
		value = AccordionMountValidation.defaultResetsState,
	})
	if _descriptor_20 then
		AccordionMountValidation.defaultResetsState = _descriptor_20.value
	end
	local _descriptor_21 = _decorator_13(AccordionMountValidation, "defaultResetsState", {
		value = AccordionMountValidation.defaultResetsState,
	})
	if _descriptor_21 then
		AccordionMountValidation.defaultResetsState = _descriptor_21.value
	end
	local _decorator_15 = Skip(not Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	local _decorator_16 = DisplayName("Without autoSize the Accordion fills the host's height even when every item is closed")
	local _descriptor_22 = Test(AccordionMountValidation, "fillsHostHeight", {
		value = AccordionMountValidation.fillsHostHeight,
	})
	if _descriptor_22 then
		AccordionMountValidation.fillsHostHeight = _descriptor_22.value
	end
	local _descriptor_23 = _decorator_16(AccordionMountValidation, "fillsHostHeight", {
		value = AccordionMountValidation.fillsHostHeight,
	})
	if _descriptor_23 then
		AccordionMountValidation.fillsHostHeight = _descriptor_23.value
	end
	local _descriptor_24 = _decorator_15(AccordionMountValidation, "fillsHostHeight", {
		value = AccordionMountValidation.fillsHostHeight,
	})
	if _descriptor_24 then
		AccordionMountValidation.fillsHostHeight = _descriptor_24.value
	end
	local _decorator_17 = Skip(not Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	local _decorator_18 = DisplayName("With autoSize the Accordion is shorter than a tall host, fills its width, and grows when a section opens")
	local _descriptor_25 = Test(AccordionMountValidation, "autoSizeGrows", {
		value = AccordionMountValidation.autoSizeGrows,
	})
	if _descriptor_25 then
		AccordionMountValidation.autoSizeGrows = _descriptor_25.value
	end
	local _descriptor_26 = _decorator_18(AccordionMountValidation, "autoSizeGrows", {
		value = AccordionMountValidation.autoSizeGrows,
	})
	if _descriptor_26 then
		AccordionMountValidation.autoSizeGrows = _descriptor_26.value
	end
	local _descriptor_27 = _decorator_17(AccordionMountValidation, "autoSizeGrows", {
		value = AccordionMountValidation.autoSizeGrows,
	})
	if _descriptor_27 then
		AccordionMountValidation.autoSizeGrows = _descriptor_27.value
	end
	local _decorator_19 = Skip(not Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	local _decorator_20 = DisplayName("In multiple mode a defaultValue listing two items opens both at once")
	local _descriptor_28 = Test(AccordionMountValidation, "multipleDefaultOpen", {
		value = AccordionMountValidation.multipleDefaultOpen,
	})
	if _descriptor_28 then
		AccordionMountValidation.multipleDefaultOpen = _descriptor_28.value
	end
	local _descriptor_29 = _decorator_20(AccordionMountValidation, "multipleDefaultOpen", {
		value = AccordionMountValidation.multipleDefaultOpen,
	})
	if _descriptor_29 then
		AccordionMountValidation.multipleDefaultOpen = _descriptor_29.value
	end
	local _descriptor_30 = _decorator_19(AccordionMountValidation, "multipleDefaultOpen", {
		value = AccordionMountValidation.multipleDefaultOpen,
	})
	if _descriptor_30 then
		AccordionMountValidation.multipleDefaultOpen = _descriptor_30.value
	end
	local _decorator_21 = Skip(not Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	local _decorator_22 = DisplayName("In multiple mode clicking an open header closes only that item and reports the remaining open values")
	local _descriptor_31 = Test(AccordionMountValidation, "multipleClosesOne", {
		value = AccordionMountValidation.multipleClosesOne,
	})
	if _descriptor_31 then
		AccordionMountValidation.multipleClosesOne = _descriptor_31.value
	end
	local _descriptor_32 = _decorator_22(AccordionMountValidation, "multipleClosesOne", {
		value = AccordionMountValidation.multipleClosesOne,
	})
	if _descriptor_32 then
		AccordionMountValidation.multipleClosesOne = _descriptor_32.value
	end
	local _descriptor_33 = _decorator_21(AccordionMountValidation, "multipleClosesOne", {
		value = AccordionMountValidation.multipleClosesOne,
	})
	if _descriptor_33 then
		AccordionMountValidation.multipleClosesOne = _descriptor_33.value
	end
	local _decorator_23 = Skip(not Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	local _decorator_24 = DisplayName("In multiple mode clicking a closed header opens it alongside the already open item")
	local _descriptor_34 = Test(AccordionMountValidation, "multipleOpensAnother", {
		value = AccordionMountValidation.multipleOpensAnother,
	})
	if _descriptor_34 then
		AccordionMountValidation.multipleOpensAnother = _descriptor_34.value
	end
	local _descriptor_35 = _decorator_24(AccordionMountValidation, "multipleOpensAnother", {
		value = AccordionMountValidation.multipleOpensAnother,
	})
	if _descriptor_35 then
		AccordionMountValidation.multipleOpensAnother = _descriptor_35.value
	end
	local _descriptor_36 = _decorator_23(AccordionMountValidation, "multipleOpensAnother", {
		value = AccordionMountValidation.multipleOpensAnother,
	})
	if _descriptor_36 then
		AccordionMountValidation.multipleOpensAnother = _descriptor_36.value
	end
	local _decorator_25 = Skip(not Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	local _decorator_26 = DisplayName("Reopening a section while it is still animating closed tweens its ContentClip back to the full content height")
	local _descriptor_37 = Test(AccordionMountValidation, "reopenWhileClosing", {
		value = AccordionMountValidation.reopenWhileClosing,
	})
	if _descriptor_37 then
		AccordionMountValidation.reopenWhileClosing = _descriptor_37.value
	end
	local _descriptor_38 = _decorator_26(AccordionMountValidation, "reopenWhileClosing", {
		value = AccordionMountValidation.reopenWhileClosing,
	})
	if _descriptor_38 then
		AccordionMountValidation.reopenWhileClosing = _descriptor_38.value
	end
	local _descriptor_39 = _decorator_25(AccordionMountValidation, "reopenWhileClosing", {
		value = AccordionMountValidation.reopenWhileClosing,
	})
	if _descriptor_39 then
		AccordionMountValidation.reopenWhileClosing = _descriptor_39.value
	end
	AccordionMountValidation = Tag("Studio")(AccordionMountValidation) or AccordionMountValidation
end
return AccordionMountValidation
