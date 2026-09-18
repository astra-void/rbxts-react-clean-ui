import { Test, Assert, Decorators, Runtime, Tag, DisplayName } from "@rbxts/lunit";
import { GuiHelper } from "../../Helpers/gui.helper";
import { STUDIO_SKIP_MESSAGE } from "./layout";

const { Skip, Each } = Decorators;

function makeGui(parent: Instance, name: string, displayOrder = 0): ScreenGui {
	const gui = new Instance("ScreenGui");
	gui.Name = name;
	gui.DisplayOrder = displayOrder;
	gui.Parent = parent;
	return gui;
}

function makeFrame(parent: Instance, name: string, zIndex = 1): Frame {
	const frame = new Instance("Frame");
	frame.Name = name;
	frame.ZIndex = zIndex;
	frame.Parent = parent;
	return frame;
}

function withTree(fn: (root: Folder) => void) {
	const root = new Instance("Folder");
	root.Name = "RenderOrderTree";

	try {
		fn(root);
	} finally {
		root.Destroy();
	}
}

function assertAbove(a: GuiObject, b: GuiObject, message: string) {
	Assert.true(GuiHelper.isRenderedAbove(a, b), `${message}: expected ${a.Name} above ${b.Name}`);
	Assert.false(GuiHelper.isRenderedAbove(b, a), `${message}: expected ${b.Name} not above ${a.Name}`);
}

@Tag("Studio")
class GuiHelperRenderOrder {
	@Skip(!Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	@DisplayName("An object is never reported as rendered above itself")
	@Test
	public notAboveSelf() {
		withTree((root) => {
			const frame = makeFrame(makeGui(root, "Gui"), "Frame");

			Assert.false(GuiHelper.isRenderedAbove(frame, frame));
		});
	}

	@Skip(!Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	@DisplayName("Across ScreenGuis the higher DisplayOrder wins regardless of ZIndex or which ScreenGui comes first")
	@Test
	public displayOrderFirst() {
		withTree((root) => {
			const high = makeFrame(makeGui(root, "HighGui", 5), "HighFrame", 1);
			const low = makeFrame(makeGui(root, "LowGui", 0), "LowFrame", 1000);

			assertAbove(high, low, "DisplayOrder 5 vs 0");
		});
	}

	@Skip(!Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	@DisplayName("Across ScreenGuis with equal DisplayOrder the later ScreenGui in the tree is on top")
	@Test
	public equalDisplayOrderTreeOrder() {
		withTree((root) => {
			const earlier = makeFrame(makeGui(root, "EarlierGui"), "EarlierFrame", 50);
			const later = makeFrame(makeGui(root, "LaterGui"), "LaterFrame", 1);

			assertAbove(later, earlier, "equal DisplayOrder");
		});
	}

	@Skip(!Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	@DisplayName("A deep child with a high ZIndex under a low-ZIndex parent loses under Sibling and wins under Global")
	@Each([
		["Sibling", "Shallow"],
		["Global", "Deep"],
	])
	@Test
	public zIndexBehaviorOrder(behavior: string, expected: string) {
		withTree((root) => {
			const gui = makeGui(root, "Gui");
			gui.ZIndexBehavior = behavior === "Global" ? Enum.ZIndexBehavior.Global : Enum.ZIndexBehavior.Sibling;

			const shallow = makeFrame(gui, "Shallow", 5);
			const lowParent = makeFrame(gui, "LowParent", 1);
			const deep = makeFrame(lowParent, "Deep", 10);

			if (expected === "Deep") {
				assertAbove(deep, shallow, `ZIndexBehavior.${behavior}`);
			} else {
				assertAbove(shallow, deep, `ZIndexBehavior.${behavior}`);
			}
		});
	}

	@Skip(!Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	@DisplayName("With equal ZIndex a descendant draws above its ancestor under both ZIndexBehaviors")
	@Each([["Sibling"], ["Global"]])
	@Test
	public descendantAboveAncestor(behavior: string) {
		withTree((root) => {
			const gui = makeGui(root, "Gui");
			gui.ZIndexBehavior = behavior === "Global" ? Enum.ZIndexBehavior.Global : Enum.ZIndexBehavior.Sibling;

			const parent = makeFrame(gui, "Parent");
			const child = makeFrame(parent, "Child");

			assertAbove(child, parent, `ZIndexBehavior.${behavior}`);
		});
	}

	@Skip(!Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	@DisplayName(
		"Under Sibling with equal branch ZIndex, the later sibling branch is on top even against a deeper high-ZIndex child",
	)
	@Test
	public laterSiblingBranch() {
		withTree((root) => {
			const gui = makeGui(root, "Gui");
			gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling;

			const earlier = makeFrame(gui, "EarlierBranch", 1);
			const deep = makeFrame(earlier, "DeepChild", 99);
			const later = makeFrame(gui, "LaterBranch", 1);

			assertAbove(later, deep, "Sibling tie");
		});
	}
}

export = GuiHelperRenderOrder;
