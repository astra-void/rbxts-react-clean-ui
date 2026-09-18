import React from "@rbxts/react";
import { Test, Assert, Decorators, Runtime, Tag, DisplayName } from "@rbxts/lunit";

const { Skip, Each } = Decorators;
import { FadeGroup } from "../../../Components/Layout/FadeGroup";
import {
	STUDIO_SKIP_MESSAGE,
	assertSizeApprox,
	waitForGuiObject,
	waitForLayout,
	withMounted,
} from "../../Helpers/layout";

const HOST_WIDTH = 400;
const HOST_HEIGHT = 300;
const CONTENT_WIDTH = 120;
const CONTENT_HEIGHT = 50;

function content() {
	return <frame key="Inner" BackgroundTransparency={1} Size={UDim2.fromOffset(CONTENT_WIDTH, CONTENT_HEIGHT)} />;
}

function waitForFadeGroup(host: Instance, name = "FadeGroup"): CanvasGroup {
	return waitForGuiObject<CanvasGroup>(host, name);
}

@Tag("Studio")
class FadeGroupMountValidation {
	@Skip(!Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	@DisplayName(
		"With no props the root is a CanvasGroup named FadeGroup that is fully visible, untinted and borderless",
	)
	@Test
	public defaultsApplied() {
		withMounted(HOST_WIDTH, HOST_HEIGHT, <FadeGroup>{content()}</FadeGroup>, (mounted) => {
			const group = waitForFadeGroup(mounted.host);

			Assert.true(group.IsA("CanvasGroup"), `Expected FadeGroup to be a CanvasGroup, got ${group.ClassName}`);
			Assert.equal(group.GroupTransparency, 0);
			Assert.equal(group.GroupColor3, new Color3(1, 1, 1));
			Assert.equal(group.BackgroundTransparency, 1);
			Assert.equal(group.BorderSizePixel, 0);
		});
	}

	@Skip(!Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	@DisplayName("The name prop replaces the default FadeGroup instance name")
	@Test
	public customName() {
		withMounted(HOST_WIDTH, HOST_HEIGHT, <FadeGroup name="InventorySlot">{content()}</FadeGroup>, (mounted) => {
			const group = waitForFadeGroup(mounted.host, "InventorySlot");

			Assert.true(group.IsA("CanvasGroup"), `Expected InventorySlot to be a CanvasGroup, got ${group.ClassName}`);
			Assert.undefined(mounted.host.FindFirstChild("FadeGroup", true));
		});
	}

	@Skip(!Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	@Each([[0.25], [0.5], [0.75]])
	@DisplayName("A numeric GroupTransparency is applied to the CanvasGroup as given")
	@Test
	public transparencyPassesThrough(transparency: number) {
		withMounted(
			HOST_WIDTH,
			HOST_HEIGHT,
			<FadeGroup GroupTransparency={transparency}>{content()}</FadeGroup>,
			(mounted) => {
				Assert.equal(waitForFadeGroup(mounted.host).GroupTransparency, transparency);
			},
		);
	}

	@Skip(!Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	@DisplayName("A GroupTransparency binding sets the initial value and updating the binding updates the CanvasGroup")
	@Test
	public bindingDrivesTransparency() {
		const [transparency, setTransparency] = React.createBinding(0.25);

		withMounted(
			HOST_WIDTH,
			HOST_HEIGHT,
			<FadeGroup GroupTransparency={transparency}>{content()}</FadeGroup>,
			(mounted) => {
				const group = waitForFadeGroup(mounted.host);
				Assert.equal(group.GroupTransparency, 0.25);

				setTransparency(0.75);

				waitForLayout(
					() => (group.GroupTransparency === 0.75 ? true : undefined),
					`Timed out waiting for the binding to set GroupTransparency to 0.75 (is ${group.GroupTransparency})`,
				);
			},
		);
	}

	@Skip(!Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	@DisplayName("GroupColor3 is applied to the CanvasGroup as the tint colour")
	@Test
	public groupColorPassesThrough() {
		const tint = new Color3(0.5, 0.25, 0.75);

		withMounted(HOST_WIDTH, HOST_HEIGHT, <FadeGroup GroupColor3={tint}>{content()}</FadeGroup>, (mounted) => {
			Assert.equal(waitForFadeGroup(mounted.host).GroupColor3, tint);
		});
	}

	@Skip(!Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	@DisplayName("Without Size, width or height the group uses AutomaticSize XY and hugs its content")
	@Test
	public autoSizesToContent() {
		withMounted(HOST_WIDTH, HOST_HEIGHT, <FadeGroup>{content()}</FadeGroup>, (mounted) => {
			const group = waitForFadeGroup(mounted.host);

			Assert.equal(group.AutomaticSize, Enum.AutomaticSize.XY);
			assertSizeApprox(group, CONTENT_WIDTH, CONTENT_HEIGHT, 1, "auto-sized FadeGroup");
		});
	}

	@Skip(!Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	@DisplayName("An explicit Size turns AutomaticSize off and pins the group to that size regardless of content")
	@Test
	public explicitSizeFixed() {
		withMounted(
			HOST_WIDTH,
			HOST_HEIGHT,
			<FadeGroup Size={UDim2.fromOffset(200, 80)}>{content()}</FadeGroup>,
			(mounted) => {
				const group = waitForFadeGroup(mounted.host);

				Assert.equal(group.AutomaticSize, Enum.AutomaticSize.None);
				Assert.equal(group.Size, UDim2.fromOffset(200, 80));
				assertSizeApprox(group, 200, 80, 1, "explicitly sized FadeGroup");
			},
		);
	}

	@Skip(!Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	@DisplayName("LayoutOrder and ZIndex are forwarded to the CanvasGroup")
	@Test
	public orderAndZIndex() {
		withMounted(
			HOST_WIDTH,
			HOST_HEIGHT,
			<FadeGroup LayoutOrder={3} ZIndex={4}>
				{content()}
			</FadeGroup>,
			(mounted) => {
				const group = waitForFadeGroup(mounted.host);

				Assert.equal(group.LayoutOrder, 3);
				Assert.equal(group.ZIndex, 4);
			},
		);
	}

	@Skip(!Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	@DisplayName("Children, including layout objects, are parented directly to the CanvasGroup with no wrapper frame")
	@Test
	public childrenAreDirect() {
		withMounted(
			HOST_WIDTH,
			HOST_HEIGHT,
			<FadeGroup>
				<uilistlayout key="Layout" />
				{content()}
			</FadeGroup>,
			(mounted) => {
				const group = waitForFadeGroup(mounted.host);
				const inner = waitForGuiObject<Frame>(group, "Inner");
				const layout = group.FindFirstChild("Layout");

				Assert.equal(inner.Parent, group, "Expected Inner to be a direct child of the CanvasGroup");
				Assert.notUndefined(layout, "Expected the UIListLayout to be a direct child of the CanvasGroup");
				Assert.true(layout!.IsA("UIListLayout"), "Expected Layout to be the UIListLayout child");
			},
		);
	}

	@Skip(!Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	@DisplayName("A forwarded ref resolves to the rendered CanvasGroup instance")
	@Test
	public refIsCanvasGroup() {
		const ref = React.createRef<CanvasGroup>();

		withMounted(HOST_WIDTH, HOST_HEIGHT, <FadeGroup ref={ref}>{content()}</FadeGroup>, (mounted) => {
			const group = waitForFadeGroup(mounted.host);

			Assert.equal(ref.current, group);
		});
	}
}

export = FadeGroupMountValidation;
