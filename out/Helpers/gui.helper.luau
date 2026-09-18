-- Compiled with roblox-ts v3.0.0
local TS = _G[script]
local _services = TS.import(script, TS.getModule(script, "@rbxts", "services"))
local Players = _services.Players
local RunService = _services.RunService
local GuiHelper
do
	GuiHelper = setmetatable({}, {
		__tostring = function()
			return "GuiHelper"
		end,
	})
	GuiHelper.__index = GuiHelper
	function GuiHelper.new(...)
		local self = setmetatable({}, GuiHelper)
		return self:constructor(...) or self
	end
	function GuiHelper:constructor()
	end
	function GuiHelper:findHighestAncestorOfClass(instance, className)
		local current = instance
		local highest
		while current do
			if current:IsA(className) then
				highest = current
			end
			current = current.Parent
		end
		return highest
	end
	function GuiHelper:printParentTree(instance)
		local current = instance
		while current ~= nil do
			print(`{current.ClassName}: {current.Name}`)
			current = current.Parent
		end
	end
	function GuiHelper:isPointInsideGuiObject(guiObject, point)
		local position = guiObject.AbsolutePosition
		local size = guiObject.AbsoluteSize
		return point.X >= position.X and point.X <= position.X + size.X and point.Y >= position.Y and point.Y <= position.Y + size.Y
	end
	function GuiHelper:getGuiObjectsAtPosition(instance, point)
		local root = self:findHighestAncestorOfClass(instance, "Frame")
		if root == nil then
			return {}
		end
		local results = {}
		for _, descendant in root:GetDescendants() do
			if descendant:IsA("GuiObject") and descendant.Visible and self:isPointInsideGuiObject(descendant, point) then
				table.insert(results, descendant)
			end
		end
		table.sort(results, function(a, b)
			return a.ZIndex > b.ZIndex
		end)
		return results
	end
	function GuiHelper:getGuiRenderOrder(instance)
		local result = {}
		for _, surface in self:getRenderSurfaces(self:getGuiRoot(instance)) do
			self:appendGuiObjects(surface.root, result)
		end
		return result
	end
	function GuiHelper:getGuiRoot(instance)
		local surface = self:findHighestAncestorOfClass(instance, "LayerCollector")
		local _result = surface
		if _result ~= nil then
			_result = _result.Parent
		end
		if _result ~= nil then
			return surface.Parent
		end
		if RunService:IsRunning() and Players.LocalPlayer ~= nil then
			return Players.LocalPlayer:WaitForChild("PlayerGui")
		end
		local root = instance
		while root.Parent ~= nil and root.Parent ~= game do
			root = root.Parent
		end
		return root
	end
	function GuiHelper:getRenderSurface(instance)
		return instance:FindFirstAncestorWhichIsA("LayerCollector")
	end
	function GuiHelper:isGuiObjectHitAtPoint(guiObject, point)
		if not guiObject.Visible or not self:isPointInsideGuiObject(guiObject, point) then
			return false
		end
		local current = guiObject.Parent
		while current ~= nil do
			if current:IsA("LayerCollector") then
				return current.Enabled and not current:IsA("SurfaceGuiBase")
			end
			if current:IsA("GuiObject") then
				if not current.Visible then
					return false
				end
				if (current.ClipsDescendants or current:IsA("CanvasGroup")) and not self:isPointInsideGuiObject(current, point) then
					return false
				end
			end
			current = current.Parent
		end
		return false
	end
	function GuiHelper:isRenderedAbove(a, b)
		if a == b then
			return false
		end
		local surfaceA = self:getRenderSurface(a)
		local surfaceB = self:getRenderSurface(b)
		if surfaceA ~= surfaceB then
			local _result = surfaceA
			if _result ~= nil then
				_result = _result:IsA("ScreenGui")
			end
			local orderA = if _result then surfaceA.DisplayOrder else 0
			local _result_1 = surfaceB
			if _result_1 ~= nil then
				_result_1 = _result_1:IsA("ScreenGui")
			end
			local orderB = if _result_1 then surfaceB.DisplayOrder else 0
			if orderA ~= orderB then
				return orderA > orderB
			end
			return self:isLaterInTree(surfaceA or a, surfaceB or b)
		end
		local _result = surfaceA
		if _result ~= nil then
			_result = _result.ZIndexBehavior
		end
		local _condition = _result == Enum.ZIndexBehavior.Global
		if _condition then
			_condition = a.ZIndex ~= b.ZIndex
		end
		if _condition then
			return a.ZIndex > b.ZIndex
		end
		if a:IsDescendantOf(b) then
			return true
		end
		if b:IsDescendantOf(a) then
			return false
		end
		local _result_1 = surfaceA
		if _result_1 ~= nil then
			_result_1 = _result_1.ZIndexBehavior
		end
		if _result_1 == Enum.ZIndexBehavior.Global then
			return self:isLaterInTree(a, b)
		end
		local divergence = self:getDivergingAncestors(a, b)
		if divergence == nil then
			return false
		end
		local _binding = divergence
		local branchA = _binding[1]
		local branchB = _binding[2]
		if branchA:IsA("GuiObject") and branchB:IsA("GuiObject") and branchA.ZIndex ~= branchB.ZIndex then
			return branchA.ZIndex > branchB.ZIndex
		end
		return self:getChildIndex(branchA) > self:getChildIndex(branchB)
	end
	function GuiHelper:isLaterInTree(a, b)
		local divergence = self:getDivergingAncestors(a, b)
		if divergence == nil then
			return false
		end
		return self:getChildIndex(divergence[1]) > self:getChildIndex(divergence[2])
	end
	function GuiHelper:getDivergingAncestors(a, b)
		local branchByAncestor = {}
		local previous = a
		local current = a.Parent
		while current ~= nil do
			local _current = current
			local _previous = previous
			branchByAncestor[_current] = _previous
			previous = current
			current = current.Parent
		end
		previous = b
		current = b.Parent
		while current ~= nil do
			local _current = current
			local branchA = branchByAncestor[_current]
			if branchA ~= nil then
				return { branchA, previous }
			end
			previous = current
			current = current.Parent
		end
		return nil
	end
	function GuiHelper:getChildIndex(instance)
		local parent = instance.Parent
		if parent == nil then
			return 0
		end
		local _exp = parent:GetChildren()
		local _instance = instance
		return (table.find(_exp, _instance) or 0) - 1
	end
	function GuiHelper:getRenderSurfaces(root)
		local surfaces = {}
		local visit
		visit = function(instance)
			local instanceChildren = instance:GetChildren()
			for index = 0, #instanceChildren - 1 do
				local child = instanceChildren[index + 1]
				if child:IsA("LayerCollector") then
					local _arg0 = {
						root = child,
						rootIndex = index,
					}
					table.insert(surfaces, _arg0)
					continue
				end
				visit(child)
			end
		end
		visit(root)
		table.sort(surfaces, function(a, b)
			if a.root:IsA("ScreenGui") and b.root:IsA("ScreenGui") then
				if a.root.DisplayOrder ~= b.root.DisplayOrder then
					return a.root.DisplayOrder < b.root.DisplayOrder
				end
			end
			return a.rootIndex < b.rootIndex
		end)
		return surfaces
	end
	function GuiHelper:appendGuiObjects(parent, result)
		local children = {}
		local parentChildren = parent:GetChildren()
		for index = 0, #parentChildren - 1 do
			local child = parentChildren[index + 1]
			if not child:IsA("GuiObject") then
				continue
			end
			local _arg0 = {
				object = child,
				siblingIndex = index,
			}
			table.insert(children, _arg0)
		end
		table.sort(children, function(a, b)
			if a.object.ZIndex ~= b.object.ZIndex then
				return a.object.ZIndex < b.object.ZIndex
			end
			return a.siblingIndex < b.siblingIndex
		end)
		for _, child in children do
			local _result = result
			local _object = child.object
			table.insert(_result, _object)
			self:appendGuiObjects(child.object, result)
		end
	end
end
return {
	GuiHelper = GuiHelper,
}
