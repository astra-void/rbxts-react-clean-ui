import React from "@rbxts/react";
import { Test, Assert, Decorators, Runtime, Tag, DisplayName } from "@rbxts/lunit";

const { Skip, Each } = Decorators;
import { Tooltip } from "../../../Components/Interaction/Tooltip";
import { OverlayProvider } from "../../../Providers/overlay.provider";
import {
	STUDIO_SKIP_MESSAGE,
	assertCenteredIn,
	assertContained,
	findDescendant,
	rect,
	settleFrames,
	waitForGuiObject,
	waitForLayout,
	waitForRemoval,
	withMounted,
} from "../../Helpers/layout";
import { findHostFiber } from "../../Helpers/fiber";

const CONTENT = "Helpful hint";

type HoverEvents = NonNullable<React.InstanceProps<Frame>["Event"]>;

let hoverEvents: HoverEvents | undefined;

const HoverTarget = React.forwardRef<Frame, React.InstanceProps<Frame>>((props, ref) => {
	hoverEvents = props.Event;

	return (
		<frame
			key="HoverTarget"
			ref={ref}
			BackgroundTransparency={1}
			Size={UDim2.fromOffset(100, 40)}
			Position={UDim2.fromOffset(150, 130)}
			Event={props.Event}
		/>
	);
});

interface TooltipOptions {
	disabled?: boolean;
	open?: boolean;
}

function tooltipApp(placement?: "Top" | "Bottom", options: TooltipOptions = {}) {
	return (
		<OverlayProvider>
			<Tooltip content={CONTENT} placement={placement} disabled={options.disabled} open={options.open}>
				<HoverTarget />
			</Tooltip>
		</OverlayProvider>
	);
}

function waitForTarget(host: Instance): Frame {
	waitForGuiObject<Frame>(host, "OverlayProvider");
	return waitForGuiObject<Frame>(host, "HoverTarget");
}

function hover(target: Frame) {
	const events = waitForLayout(
		() => hoverEvents,
		"Timed out waiting for Tooltip to inject hover handlers into HoverTarget",
	);
	Assert.notUndefined(events.MouseEnter, "Expected Tooltip to inject a MouseEnter handler");
	events.MouseEnter!(target, 0, 0);
}

function unhover(target: Frame) {
	const events = waitForLayout(
		() => hoverEvents,
		"Timed out waiting for Tooltip to inject hover handlers into HoverTarget",
	);
	Assert.notUndefined(events.MouseLeave, "Expected Tooltip to inject a MouseLeave handler");
	events.MouseLeave!(target, 0, 0);
}

function nativeApp() {
	return (
		<OverlayProvider>
			<Tooltip content={CONTENT}>
				<frame
					key="NativeTarget"
					BackgroundTransparency={1}
					Size={UDim2.fromOffset(100, 40)}
					Position={UDim2.fromOffset(150, 130)}
				/>
			</Tooltip>
		</OverlayProvider>
	);
}

function waitForNativeTarget(host: Instance): Frame {
	waitForGuiObject<Frame>(host, "OverlayProvider");
	return waitForGuiObject<Frame>(
		host,
		"NativeTarget",
		undefined,
		"Timed out waiting for the native <frame> inside Tooltip to mount - the tree failed to render (see the Studio output for the React error)",
	);
}

function assertNoPopup(host: Instance, message: string) {
	settleFrames(10);
	Assert.undefined(host.FindFirstChild("Tooltip", true), message);
}

@Tag("Studio")
class TooltipMountValidation {
	@Skip(!Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	@DisplayName("Before any hover the target is rendered but no Tooltip popup exists in the overlay")
	@Test
	public hiddenUntilHover() {
		hoverEvents = undefined;

		withMounted(400, 300, tooltipApp(), (mounted) => {
			waitForTarget(mounted.host);
			task.wait();

			Assert.undefined(mounted.host.FindFirstChild("Tooltip", true), "Expected no Tooltip popup before hovering");
		});
	}

	@Skip(!Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	@Each([["Top"], ["Bottom"]])
	@DisplayName(
		"Hovering the target portals a Tooltip into the overlay, centered on the target and on the requested side",
	)
	@Test
	public showsOnHover(placement: "Top" | "Bottom") {
		hoverEvents = undefined;

		withMounted(400, 300, tooltipApp(placement), (mounted) => {
			const target = waitForTarget(mounted.host);
			hover(target);

			const overlay = findDescendant<Frame>(mounted.host, "OverlayProvider");
			const tooltip = waitForGuiObject<CanvasGroup>(overlay, "Tooltip");
			const content = waitForGuiObject<Frame>(tooltip, "Content");
			const text = findDescendant<TextLabel>(content, "TooltipText");

			Assert.equal(text.Text, CONTENT, "Expected a string content prop to render as TooltipText");
			assertContained(text, content, `${placement} tooltip text`);
			assertContained(tooltip, overlay, `${placement} tooltip vs overlay`);
			assertCenteredIn(tooltip, target, "x", 1, `${placement} tooltip`);

			const tooltipRect = rect(tooltip);
			const targetRect = rect(target);
			if (placement === "Top") {
				Assert.true(
					tooltipRect.bottom <= targetRect.top + 1,
					`Expected a Top tooltip (bottom=${tooltipRect.bottom}) to sit above the target (top=${targetRect.top})`,
				);
			} else {
				Assert.true(
					tooltipRect.top >= targetRect.bottom - 1,
					`Expected a Bottom tooltip (top=${tooltipRect.top}) to sit below the target (bottom=${targetRect.bottom})`,
				);
			}
		});
	}

	@Skip(!Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	@DisplayName("Leaving the target fades the Tooltip out and removes it from the overlay")
	@Test
	public hidesAfterLeave() {
		hoverEvents = undefined;

		withMounted(400, 300, tooltipApp(), (mounted) => {
			const target = waitForTarget(mounted.host);
			hover(target);
			waitForGuiObject<CanvasGroup>(mounted.host, "Tooltip");

			unhover(target);
			waitForRemoval(mounted.host, "Tooltip");
		});
	}

	@Skip(!Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	@DisplayName("With disabled set, hovering the target never portals a popup into the overlay")
	@Test
	public disabledNoPopup() {
		hoverEvents = undefined;

		withMounted(400, 300, tooltipApp(undefined, { disabled: true }), (mounted) => {
			const target = waitForTarget(mounted.host);
			hover(target);

			assertNoPopup(mounted.host, "Expected no Tooltip popup while disabled");
		});
	}

	@Skip(!Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	@DisplayName(
		"Toggling disabled on and off keeps the very same target instance mounted, with hover handlers still injected",
	)
	@Test
	public disabledKeepsInstance() {
		hoverEvents = undefined;

		withMounted(400, 300, tooltipApp(undefined, { disabled: false }), (mounted) => {
			const target = waitForTarget(mounted.host);

			mounted.update(tooltipApp(undefined, { disabled: true }));
			settleFrames(2);
			Assert.equal(
				findDescendant<Frame>(mounted.host, "HoverTarget"),
				target,
				"Expected disabling not to remount the child",
			);
			Assert.notUndefined(
				hoverEvents?.MouseEnter,
				"Expected the child to keep its MouseEnter handler while disabled",
			);

			mounted.update(tooltipApp(undefined, { disabled: false }));
			settleFrames(2);
			Assert.equal(
				findDescendant<Frame>(mounted.host, "HoverTarget"),
				target,
				"Expected re-enabling not to remount the child",
			);

			hover(target);
			waitForGuiObject<CanvasGroup>(mounted.host, "Tooltip");
		});
	}

	@Skip(!Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	@DisplayName("Disabling a Tooltip whose popup is open hides and removes the popup")
	@Test
	public disableHidesOpen() {
		hoverEvents = undefined;

		withMounted(400, 300, tooltipApp(), (mounted) => {
			const target = waitForTarget(mounted.host);
			hover(target);
			waitForGuiObject<CanvasGroup>(mounted.host, "Tooltip");

			mounted.update(tooltipApp(undefined, { disabled: true }));
			waitForRemoval(mounted.host, "Tooltip");
		});
	}

	@Skip(!Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	@DisplayName(
		"With open={true} the popup shows without a hover, survives a MouseLeave, and goes away once open becomes false",
	)
	@Test
	public controlledOpen() {
		hoverEvents = undefined;

		withMounted(400, 300, tooltipApp(undefined, { open: true }), (mounted) => {
			const target = waitForTarget(mounted.host);
			const tooltip = waitForGuiObject<CanvasGroup>(mounted.host, "Tooltip");
			assertCenteredIn(tooltip, target, "x", 1, "controlled tooltip");

			unhover(target);
			settleFrames(20);
			Assert.notUndefined(
				mounted.host.FindFirstChild("Tooltip", true),
				"Expected MouseLeave not to close a controlled open Tooltip",
			);

			mounted.update(tooltipApp(undefined, { open: false }));
			waitForRemoval(mounted.host, "Tooltip");
		});
	}

	@Skip(!Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	@DisplayName("With open={false}, hovering the target does not show the popup")
	@Test
	public controlledClosedIgnoresHover() {
		hoverEvents = undefined;

		withMounted(400, 300, tooltipApp(undefined, { open: false }), (mounted) => {
			const target = waitForTarget(mounted.host);
			hover(target);

			assertNoPopup(mounted.host, "Expected hover not to open a Tooltip controlled with open={false}");
		});
	}

	@Skip(!Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	@DisplayName("disabled wins over open={true}: no popup is shown")
	@Test
	public disabledOverridesOpen() {
		hoverEvents = undefined;

		withMounted(400, 300, tooltipApp(undefined, { open: true, disabled: true }), (mounted) => {
			waitForTarget(mounted.host);

			assertNoPopup(mounted.host, "Expected disabled to suppress a Tooltip controlled with open={true}");
		});
	}

	@Skip(!Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	@DisplayName("Tooltip wrapping a native <frame> mounts without error and leaves the frame in place")
	@Test
	public nativeChildMounts() {
		withMounted(400, 300, nativeApp(), (mounted) => {
			const target = waitForNativeTarget(mounted.host);

			Assert.equal(target.Parent, mounted.host, "Expected the native child to render unwrapped under the host");
		});
	}

	@Skip(!Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	@DisplayName("A native <frame> child carries a real MouseEnter handler, and firing it opens the popup")
	@Test
	public nativeChildShows() {
		withMounted(400, 300, nativeApp(), (mounted) => {
			const target = waitForNativeTarget(mounted.host);

			const mouseEnterKey = (React as unknown as { Event: Record<string, unknown> }).Event.MouseEnter;
			const handler = findHostFiber(mounted, target).memoizedProps?.get(mouseEnterKey) as
				((rbx: Frame, x: number, y: number) => void) | undefined;

			Assert.notUndefined(
				handler,
				"Expected the native child to carry a MouseEnter handler under React.Event.MouseEnter",
			);
			handler!(target, 0, 0);

			const tooltip = waitForGuiObject<CanvasGroup>(mounted.host, "Tooltip");
			assertCenteredIn(tooltip, target, "x", 1, "native-child tooltip");
		});
	}
}

export = TooltipMountValidation;
