import React from "@rbxts/react";
import { createPortal } from "@rbxts/react-roblox";
import { Test, Assert, Decorators, Runtime, Tag, DisplayName } from "@rbxts/lunit";

const { Skip, Each } = Decorators;
import { Draggable } from "../../../Components/Layout/Draggable";
import { Droppable } from "../../../Components/Layout/Droppable";
import { Tooltip } from "../../../Components/Interaction/Tooltip";
import { DragEventInfo } from "../../../Contexts/draggable.context";
import { OverlayProvider } from "../../../Providers/overlay.provider";
import { DroppableRegistration, RegistryProvider } from "../../../Providers/registry.provider";
import {
	STUDIO_SKIP_MESSAGE,
	assertContained,
	assertSizeApprox,
	findDescendant,
	settleFrames,
	waitForGuiObject,
	waitForLayout,
	waitForRemoval,
	withMounted,
} from "../../Helpers/layout";
import {
	DragHandle,
	FrameEvents,
	RegistryHarness,
	centerOf,
	moveTo,
	pointerInput,
	pressHandle,
	resetDragState,
	waitForDragItem,
	waitForDraggableRegistration,
	waitForDroppableRegistration,
	waitForHandleEvents,
} from "../../Helpers/drag";
import { findHostFiber } from "../../Helpers/fiber";

const DRAG_ID = "item";
const SIBLING_ID = "sibling";
const ZONE_ID = "zone";
const TOOLTIP_TEXT = "Item details";

const tooltipTargetEvents = new Map<Instance, FrameEvents>();

const TooltipTarget = React.forwardRef<Frame, React.InstanceProps<Frame>>((props, ref) => {
	const events = props.Event;

	const captureRef = (instance: Frame | undefined) => {
		if (typeIs(ref, "function")) {
			ref(instance);
		} else if (ref !== undefined) {
			ref.current = instance;
		}

		if (instance !== undefined && events !== undefined) {
			tooltipTargetEvents.set(instance, events);
		}
	};

	return (
		<frame
			key="TooltipTarget"
			ref={captureRef}
			BackgroundTransparency={1}
			Size={UDim2.fromScale(1, 1)}
			Event={props.Event}
		/>
	);
});

interface DragOptions {
	inputTypes?: Enum.UserInputType[];
	renderOverlay?: () => React.ReactNode;
	onStartDrag?: (info: DragEventInfo) => void;
	onDropped?: (droppable: DroppableRegistration | undefined, info: DragEventInfo) => void;
	onDrop?: (dragged: GuiObject, info?: DragEventInfo) => void;
}

function draggableFixture(onStartDrag?: () => void, onDropped?: () => void) {
	return (
		<RegistryProvider>
			<OverlayProvider>
				<RegistryHarness />
				<Draggable id={DRAG_ID} onStartDrag={onStartDrag} onDropped={onDropped}>
					<frame key="DragItem" Size={UDim2.fromOffset(160, 90)} BackgroundTransparency={1}>
						<Draggable.Handle>
							<DragHandle />
						</Draggable.Handle>
					</frame>
				</Draggable>
			</OverlayProvider>
		</RegistryProvider>
	);
}

function optionsFixture(options: DragOptions) {
	return (
		<RegistryProvider>
			<OverlayProvider>
				<RegistryHarness />
				<Draggable
					id={DRAG_ID}
					inputTypes={options.inputTypes}
					renderOverlay={options.renderOverlay}
					onStartDrag={options.onStartDrag}
					onDropped={options.onDropped}
				>
					<frame key="DragItem" Size={UDim2.fromOffset(160, 90)} BackgroundTransparency={1}>
						<Draggable.Handle>
							<DragHandle />
						</Draggable.Handle>
					</frame>
				</Draggable>
				<Droppable id={ZONE_ID} onDrop={options.onDrop}>
					<frame
						key="DropZone"
						Position={UDim2.fromOffset(200, 150)}
						Size={UDim2.fromOffset(150, 120)}
						BackgroundTransparency={1}
					/>
				</Droppable>
			</OverlayProvider>
		</RegistryProvider>
	);
}

function nativeHandleFixture(onStartDrag?: () => void) {
	return (
		<RegistryProvider>
			<OverlayProvider>
				<RegistryHarness />
				<Draggable id={DRAG_ID} onStartDrag={onStartDrag}>
					<frame key="DragItem" Size={UDim2.fromOffset(160, 90)} BackgroundTransparency={1}>
						<Draggable.Handle>
							<frame key="NativeHandle" Size={new UDim2(1, 0, 0, 24)} BackgroundTransparency={1} />
						</Draggable.Handle>
					</frame>
				</Draggable>
			</OverlayProvider>
		</RegistryProvider>
	);
}

function siblingTreeFixture(
	siblingRoot: Frame,
	onDropped: (droppable?: DroppableRegistration) => void,
	onDrop: (dragged: GuiObject) => void,
) {
	return (
		<RegistryProvider>
			<OverlayProvider>
				<RegistryHarness />
				<Draggable id={DRAG_ID} onDropped={onDropped}>
					<frame key="DragItem" Size={UDim2.fromOffset(160, 90)} BackgroundTransparency={1}>
						<Draggable.Handle>
							<DragHandle />
						</Draggable.Handle>
					</frame>
				</Draggable>
				{createPortal(
					<Droppable id={SIBLING_ID} onDrop={onDrop}>
						<frame key="SiblingZone" Size={UDim2.fromScale(1, 1)} BackgroundTransparency={1} />
					</Droppable>,
					siblingRoot,
				)}
			</OverlayProvider>
		</RegistryProvider>
	);
}

function tooltipFixture(open?: boolean) {
	return (
		<RegistryProvider>
			<OverlayProvider>
				<RegistryHarness />
				<Draggable id={DRAG_ID}>
					<frame key="DragItem" Size={UDim2.fromOffset(160, 90)} BackgroundTransparency={1}>
						<Tooltip content={TOOLTIP_TEXT} open={open}>
							<TooltipTarget />
						</Tooltip>
						<Draggable.Handle>
							<DragHandle />
						</Draggable.Handle>
					</frame>
				</Draggable>
			</OverlayProvider>
		</RegistryProvider>
	);
}

function emptyFixture() {
	return <frame key="Empty" Size={UDim2.fromOffset(10, 10)} BackgroundTransparency={1} />;
}

function inputTypesFor(label: string): Enum.UserInputType[] | undefined {
	return label === "rightOnly" ? [Enum.UserInputType.MouseButton2] : undefined;
}

@Tag("Studio")
class DraggableMountValidation {
	@Skip(!Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	@DisplayName(
		"Idle, the child renders in place with no wrapper or placeholder, visible, at its own size, inside the host",
	)
	@Test
	public rendersChildInPlace() {
		resetDragState();

		withMounted(400, 300, draggableFixture(), (mounted) => {
			const dragItem = waitForDragItem(mounted.host);

			Assert.equal(
				dragItem.Parent,
				mounted.host,
				"Expected the dragged element to be a direct child of the host (no wrapper)",
			);
			Assert.true(dragItem.Visible, "Expected the original to be visible while not dragging");
			Assert.undefined(
				mounted.host.FindFirstChild("DraggablePlaceholder", true),
				"Expected no placeholder while not dragging",
			);

			assertSizeApprox(dragItem, 160, 90, 1, "drag item");
			assertContained(dragItem, mounted.host, "drag item vs host");
		});
	}

	@Skip(!Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	@DisplayName(
		"Draggable.Handle marks its child Active and injects an InputBegan handler, without touching the root element",
	)
	@Test
	public handleIsActive() {
		resetDragState();

		withMounted(400, 300, draggableFixture(), (mounted) => {
			const dragItem = waitForDragItem(mounted.host);
			const handle = findDescendant<Frame>(dragItem, "DragHandle");

			Assert.equal(handle.Parent, dragItem, "Expected the handle to stay a direct child of the drag item");
			Assert.true(handle.Active, "Expected Draggable.Handle to clone its child with Active=true");
			Assert.false(dragItem.Active, "Expected the root element's own Active to be left at its default");

			const events = waitForHandleEvents();
			Assert.notUndefined(events.InputBegan, "Expected Draggable.Handle to inject an InputBegan handler");

			assertContained(handle, dragItem, "handle vs drag item");
		});
	}

	@Skip(!Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	@DisplayName("Registers its root under DraggableRegistryKey with its id and an idle (not dragging) draggable")
	@Test
	public registersInRegistry() {
		resetDragState();

		withMounted(400, 300, draggableFixture(), (mounted) => {
			const dragItem = waitForDragItem(mounted.host);
			const registration = waitForDraggableRegistration(dragItem);

			Assert.equal(registration.id, DRAG_ID);
			Assert.equal(
				registration.guiObject,
				dragItem,
				"Expected the registration to point at the cloned root instance",
			);
			Assert.false(
				registration.draggable.isDragging,
				"Expected a freshly mounted Draggable not to report itself as dragging",
			);
		});
	}

	@Skip(!Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	@DisplayName(
		"A press on the handle starts a drag (placeholder shown, original hidden, preview in the overlay) and releasing ends it",
	)
	@Test
	public dragLifecycle() {
		resetDragState();
		let startCount = 0;
		let dropCount = 0;

		withMounted(
			400,
			300,
			draggableFixture(
				() => {
					startCount++;
				},
				() => {
					dropCount++;
				},
			),
			(mounted) => {
				const dragItem = waitForDragItem(mounted.host);
				const registration = waitForDraggableRegistration(dragItem);
				const handle = findDescendant<Frame>(dragItem, "DragHandle");
				const overlay = findDescendant<Frame>(mounted.host, "OverlayProvider");

				const pressPoint = centerOf(handle);
				pressHandle(handle, pressPoint);

				Assert.equal(startCount, 1, "Expected onStartDrag to fire once when the drag begins");
				Assert.true(registration.draggable.isDragging, "Expected the registration to report an active drag");

				const placeholder = waitForGuiObject<Frame>(mounted.host, "DraggablePlaceholder");
				waitForLayout(
					() => (!dragItem.Visible ? true : undefined),
					"Timed out waiting for the original to hide while dragging",
				);
				const preview = waitForLayout(
					() => overlay.FindFirstChild("DragItem") as Frame | undefined,
					"Timed out waiting for the drag preview to be portalled into the overlay",
				);

				Assert.equal(
					placeholder.Parent,
					mounted.host,
					"Expected the placeholder to sit where the original does",
				);
				assertSizeApprox(placeholder, 160, 90, 1, "placeholder");
				Assert.true(preview.Visible, "Expected the preview clone to be visible");
				assertSizeApprox(preview, 160, 90, 1, "drag preview");

				registration.draggable.endDrag(pointerInput(pressPoint.add(new Vector2(30, 20))));

				Assert.equal(dropCount, 1, "Expected onDropped to fire once when the drag ends");
				Assert.false(registration.draggable.isDragging, "Expected the registration to report the drag as over");

				waitForLayout(
					() => (dragItem.Visible ? true : undefined),
					"Timed out waiting for the original to reappear after the drop",
				);
				waitForLayout(
					() => (mounted.host.FindFirstChild("DraggablePlaceholder", true) === undefined ? true : undefined),
					"Timed out waiting for the placeholder to be removed after the drop",
				);
				waitForLayout(
					() => (overlay.FindFirstChild("DragItem") === undefined ? true : undefined),
					"Timed out waiting for the preview to leave the overlay after the drop",
				);
				Assert.equal(
					dragItem.Position,
					UDim2.fromOffset(0, 0),
					"Expected the original to keep its Position without retainPosition",
				);
			},
		);
	}

	@Skip(!Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	@DisplayName("Draggable.Handle wrapping a native <frame> mounts without error and marks that frame Active")
	@Test
	public nativeHandleMounts() {
		resetDragState();

		withMounted(400, 300, nativeHandleFixture(), (mounted) => {
			const handle = waitForGuiObject<Frame>(
				mounted.host,
				"NativeHandle",
				undefined,
				"Timed out waiting for the native <frame> inside Draggable.Handle to mount - the tree failed to render (see the Studio output for the React error)",
			);

			Assert.true(handle.Active, "Expected Draggable.Handle to set Active=true on the native frame");
		});
	}

	@Skip(!Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	@DisplayName("A press on a native <frame> handle reaches the frame's real InputBegan event and starts the drag")
	@Test
	public nativeHandleStartsDrag() {
		resetDragState();
		let startCount = 0;

		withMounted(
			400,
			300,
			nativeHandleFixture(() => {
				startCount++;
			}),
			(mounted) => {
				const handle = waitForGuiObject<Frame>(
					mounted.host,
					"NativeHandle",
					undefined,
					"Timed out waiting for the native <frame> inside Draggable.Handle to mount - the tree failed to render (see the Studio output for the React error)",
				);
				const dragItem = waitForDragItem(mounted.host);
				const registration = waitForDraggableRegistration(dragItem);

				const inputBeganKey = (React as unknown as { Event: Record<string, unknown> }).Event.InputBegan;
				const handler = findHostFiber(mounted, handle).memoizedProps?.get(inputBeganKey) as
					((rbx: Frame, input: InputObject) => void) | undefined;

				Assert.notUndefined(
					handler,
					"Expected the native handle to carry an InputBegan handler under React.Event.InputBegan",
				);
				handler!(handle, pointerInput(centerOf(handle)));

				Assert.equal(startCount, 1, "Expected onStartDrag to fire once when the native handle is pressed");
				Assert.true(registration.draggable.isDragging, "Expected the registration to report an active drag");

				registration.draggable.endDrag(pointerInput(centerOf(handle)));
			},
		);
	}

	@Skip(!Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	@DisplayName(
		"A drop lands on a Droppable that lives in a sibling tree (another root Frame or another ScreenGui) rather than under the Draggable's own root Frame",
	)
	@Each([["Frame"], ["ScreenGui"]])
	@Test
	public siblingTreeDrop(kind: string) {
		resetDragState();
		let dropped: DroppableRegistration | undefined;
		let droppedCalls = 0;
		let dropCount = 0;

		withMounted(400, 300, emptyFixture(), (mounted) => {
			const screenGui = mounted.host.Parent as ScreenGui;
			let siblingGui: ScreenGui | undefined;

			if (kind === "ScreenGui") {
				siblingGui = new Instance("ScreenGui");
				siblingGui.Name = "SiblingGui";
				siblingGui.DisplayOrder = 10;
				siblingGui.Parent = screenGui.Parent;
			}

			const siblingRoot = new Instance("Frame");
			siblingRoot.Name = "SiblingRoot";
			siblingRoot.BackgroundTransparency = 1;
			siblingRoot.Position = UDim2.fromOffset(220, 150);
			siblingRoot.Size = UDim2.fromOffset(150, 120);
			siblingRoot.ZIndex = 2;
			siblingRoot.Parent = siblingGui ?? screenGui;

			try {
				mounted.update(
					siblingTreeFixture(
						siblingRoot,
						(droppable) => {
							droppedCalls++;
							dropped = droppable;
						},
						() => {
							dropCount++;
						},
					),
				);

				const dragItem = waitForDragItem(mounted.host);
				const registration = waitForDraggableRegistration(dragItem);
				const zone = waitForGuiObject<Frame>(siblingRoot, "SiblingZone");
				waitForDroppableRegistration(zone);
				const handle = findDescendant<Frame>(dragItem, "DragHandle");

				pressHandle(handle, centerOf(handle));
				waitForLayout(
					() => (!dragItem.Visible ? true : undefined),
					"Timed out waiting for the original to hide while dragging",
				);

				registration.draggable.endDrag(pointerInput(centerOf(zone)));

				Assert.equal(droppedCalls, 1, "Expected onDropped to fire once on release");
				Assert.notUndefined(
					dropped,
					`Expected onDropped to report the Droppable in the sibling ${kind} under the pointer, but it reported none`,
				);
				Assert.equal(dropped!.id, SIBLING_ID);
				Assert.equal(dropCount, 1, `Expected the sibling ${kind}'s Droppable onDrop to fire once on release`);
			} finally {
				mounted.update(emptyFixture());
				siblingRoot.Destroy();
				siblingGui?.Destroy();
			}
		});
	}

	@Skip(!Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	@DisplayName(
		"With inputTypes including MouseButton2, a right-button press starts the drag and onStartDrag reports MouseButton2",
	)
	@Test
	public rightButtonOptIn() {
		resetDragState();
		const started: DragEventInfo[] = [];

		withMounted(
			400,
			300,
			optionsFixture({
				inputTypes: [Enum.UserInputType.MouseButton1, Enum.UserInputType.MouseButton2],
				onStartDrag: (info) => started.push(info),
			}),
			(mounted) => {
				const dragItem = waitForDragItem(mounted.host);
				const registration = waitForDraggableRegistration(dragItem);
				const handle = findDescendant<Frame>(dragItem, "DragHandle");
				const pressPoint = centerOf(handle);

				pressHandle(handle, pressPoint, Enum.UserInputType.MouseButton2);

				try {
					Assert.equal(
						started.size(),
						1,
						`Expected a right-button press to start one drag, got ${started.size()}`,
					);
					Assert.equal(started[0].inputType, Enum.UserInputType.MouseButton2);
					Assert.equal(started[0].id, DRAG_ID);
					Assert.true(
						registration.draggable.isDragging,
						"Expected the registration to report an active drag",
					);
					waitForGuiObject<Frame>(mounted.host, "DraggablePlaceholder");
				} finally {
					registration.draggable.endDrag(pointerInput(pressPoint, Enum.UserInputType.MouseButton2));
				}
			},
		);
	}

	@Skip(!Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	@DisplayName(
		"A press whose input type is not in inputTypes starts nothing: right button with the default, left button with a right-only list",
	)
	@Each([
		["default", Enum.UserInputType.MouseButton2],
		["rightOnly", Enum.UserInputType.MouseButton1],
	])
	@Test
	public unlistedInputIgnored(label: string, pressType: Enum.UserInputType) {
		resetDragState();
		let startCount = 0;

		withMounted(
			400,
			300,
			optionsFixture({
				inputTypes: inputTypesFor(label),
				onStartDrag: () => {
					startCount++;
				},
			}),
			(mounted) => {
				const dragItem = waitForDragItem(mounted.host);
				const registration = waitForDraggableRegistration(dragItem);
				const handle = findDescendant<Frame>(dragItem, "DragHandle");

				pressHandle(handle, centerOf(handle), pressType);
				settleFrames(3);

				Assert.equal(startCount, 0, `Expected a ${pressType.Name} press not to start a ${label} drag`);
				Assert.false(registration.draggable.isDragging, "Expected the registration to stay idle");
				Assert.true(dragItem.Visible, "Expected the original to stay visible");
				Assert.undefined(mounted.host.FindFirstChild("DraggablePlaceholder", true), "Expected no placeholder");
			},
		);
	}

	@Skip(!Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	@DisplayName(
		"A right-button drag ignores a left-button release over the target and only drops on the right-button release",
	)
	@Test
	public releaseMustMatch() {
		resetDragState();
		let droppedCalls = 0;
		let dropCount = 0;

		withMounted(
			400,
			300,
			optionsFixture({
				inputTypes: [Enum.UserInputType.MouseButton2],
				onDropped: () => {
					droppedCalls++;
				},
				onDrop: () => {
					dropCount++;
				},
			}),
			(mounted) => {
				const dragItem = waitForDragItem(mounted.host);
				const registration = waitForDraggableRegistration(dragItem);
				const zone = waitForGuiObject<Frame>(mounted.host, "DropZone");
				waitForDroppableRegistration(zone);
				const handle = findDescendant<Frame>(dragItem, "DragHandle");

				pressHandle(handle, centerOf(handle), Enum.UserInputType.MouseButton2);
				waitForLayout(
					() => (!dragItem.Visible ? true : undefined),
					"Timed out waiting for the original to hide while dragging",
				);

				registration.draggable.endDrag(pointerInput(centerOf(zone), Enum.UserInputType.MouseButton1));

				Assert.equal(droppedCalls, 0, "Expected a left-button release not to end a right-button drag");
				Assert.equal(dropCount, 0, "Expected no drop on a mismatched release");
				Assert.true(registration.draggable.isDragging, "Expected the drag to still be active");

				registration.draggable.endDrag(pointerInput(centerOf(zone), Enum.UserInputType.MouseButton2));

				Assert.equal(droppedCalls, 1, "Expected the right-button release to end the drag");
				Assert.equal(dropCount, 1, "Expected the right-button release to drop on the target once");
				Assert.false(registration.draggable.isDragging, "Expected the drag to be over");
			},
		);
	}

	@Skip(!Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	@DisplayName(
		"The drag's starting input type, the Draggable id and the release point reach both Droppable.onDrop and onDropped",
	)
	@Test
	public inputTypeReachesDrop() {
		resetDragState();
		let dropInfo: DragEventInfo | undefined;
		let droppedInfo: DragEventInfo | undefined;
		let droppedTarget: DroppableRegistration | undefined;

		withMounted(
			400,
			300,
			optionsFixture({
				inputTypes: [Enum.UserInputType.MouseButton1, Enum.UserInputType.MouseButton2],
				onDropped: (droppable, info) => {
					droppedTarget = droppable;
					droppedInfo = info;
				},
				onDrop: (_dragged, info) => {
					dropInfo = info;
				},
			}),
			(mounted) => {
				const dragItem = waitForDragItem(mounted.host);
				const registration = waitForDraggableRegistration(dragItem);
				const zone = waitForGuiObject<Frame>(mounted.host, "DropZone");
				waitForDroppableRegistration(zone);
				const handle = findDescendant<Frame>(dragItem, "DragHandle");
				const releasePoint = centerOf(zone);

				pressHandle(handle, centerOf(handle), Enum.UserInputType.MouseButton2);
				moveTo(registration, releasePoint);
				registration.draggable.endDrag(pointerInput(releasePoint, Enum.UserInputType.MouseButton2));

				Assert.notUndefined(dropInfo, "Expected Droppable.onDrop to receive a DragEventInfo from a real drop");
				Assert.equal(dropInfo!.inputType, Enum.UserInputType.MouseButton2);
				Assert.equal(dropInfo!.id, DRAG_ID);
				Assert.equal(dropInfo!.position, releasePoint, "Expected info.position to be the release point");

				Assert.notUndefined(droppedInfo, "Expected onDropped to receive a DragEventInfo");
				Assert.equal(droppedInfo!.inputType, Enum.UserInputType.MouseButton2);
				Assert.equal(droppedTarget?.id, ZONE_ID);
			},
		);
	}

	@Skip(!Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	@DisplayName(
		"With renderOverlay, the preview is a DragOverlay frame at the item's size holding the custom content, with no clone of the child",
	)
	@Test
	public renderOverlayContent() {
		resetDragState();

		withMounted(
			400,
			300,
			optionsFixture({
				renderOverlay: () => (
					<frame key="OverlayIcon" Size={UDim2.fromScale(1, 1)} BackgroundTransparency={1} />
				),
			}),
			(mounted) => {
				const dragItem = waitForDragItem(mounted.host);
				const registration = waitForDraggableRegistration(dragItem);
				const handle = findDescendant<Frame>(dragItem, "DragHandle");
				const overlay = findDescendant<Frame>(mounted.host, "OverlayProvider");
				const pressPoint = centerOf(handle);

				pressHandle(handle, pressPoint);

				try {
					const dragOverlay = waitForLayout(
						() => overlay.FindFirstChild("DragOverlay") as Frame | undefined,
						"Timed out waiting for the DragOverlay frame to be portalled into the overlay",
					);
					const icon = waitForGuiObject<Frame>(dragOverlay, "OverlayIcon");

					Assert.equal(
						icon.Parent,
						dragOverlay,
						"Expected the renderOverlay content to be a direct child of DragOverlay",
					);
					Assert.undefined(
						overlay.FindFirstChild("DragItem", true),
						"Expected no clone of the child in the overlay",
					);
					Assert.true(dragOverlay.Visible, "Expected DragOverlay to be visible");
					assertSizeApprox(dragOverlay, 160, 90, 1, "DragOverlay");
					assertSizeApprox(icon, 160, 90, 1, "renderOverlay content");
				} finally {
					registration.draggable.endDrag(pointerInput(pressPoint));
				}

				waitForRemoval(overlay, "DragOverlay", 30);
			},
		);
	}

	@Skip(!Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	@DisplayName(
		"While dragging, hovering the preview in the overlay never opens a Tooltip that sits inside the dragged content",
	)
	@Test
	public previewSkipsTooltip() {
		resetDragState();
		tooltipTargetEvents.clear();

		withMounted(400, 300, tooltipFixture(), (mounted) => {
			const dragItem = waitForDragItem(mounted.host);
			const registration = waitForDraggableRegistration(dragItem);
			const handle = findDescendant<Frame>(dragItem, "DragHandle");
			const overlay = findDescendant<Frame>(mounted.host, "OverlayProvider");
			const pressPoint = centerOf(handle);

			pressHandle(handle, pressPoint);

			try {
				const preview = waitForLayout(
					() => overlay.FindFirstChild("DragItem") as Frame | undefined,
					"Timed out waiting for the drag preview to be portalled into the overlay",
				);
				settleFrames(2);

				const previewTarget = preview.FindFirstChild("TooltipTarget", true) as Frame | undefined;
				Assert.notUndefined(previewTarget, "Expected the preview clone to contain the TooltipTarget");
				const previewEvents = tooltipTargetEvents.get(previewTarget!);
				Assert.notUndefined(
					previewEvents?.MouseEnter,
					"Expected the preview's Tooltip to inject a MouseEnter handler",
				);
				previewEvents!.MouseEnter!(previewTarget!, pressPoint.X, pressPoint.Y);

				settleFrames(10);

				Assert.undefined(
					overlay.FindFirstChild("Tooltip", true),
					"Expected no Tooltip popup in the overlay while dragging, but hovering the drag preview opened one",
				);
				Assert.undefined(
					overlay.FindFirstChild("TooltipText", true),
					"Expected no tooltip content in the overlay while dragging",
				);
			} finally {
				registration.draggable.endDrag(pointerInput(pressPoint));
			}
		});
	}

	@Skip(!Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	@DisplayName(
		"A hovered Tooltip inside the item closes when the drag starts and stays closed after the drop until hovered again",
	)
	@Test
	public dragClosesTooltip() {
		resetDragState();
		tooltipTargetEvents.clear();

		withMounted(400, 300, tooltipFixture(), (mounted) => {
			const dragItem = waitForDragItem(mounted.host);
			const registration = waitForDraggableRegistration(dragItem);
			const handle = findDescendant<Frame>(dragItem, "DragHandle");
			const overlay = findDescendant<Frame>(mounted.host, "OverlayProvider");
			const target = findDescendant<Frame>(dragItem, "TooltipTarget");
			const pressPoint = centerOf(handle);

			const events = waitForLayout(
				() => tooltipTargetEvents.get(target),
				"Timed out waiting for Tooltip to inject hover handlers into TooltipTarget",
			);
			Assert.notUndefined(events.MouseEnter, "Expected Tooltip to inject a MouseEnter handler");
			events.MouseEnter!(target, pressPoint.X, pressPoint.Y);
			waitForGuiObject<CanvasGroup>(overlay, "Tooltip");

			pressHandle(handle, pressPoint);

			try {
				waitForRemoval(overlay, "Tooltip");
			} finally {
				registration.draggable.endDrag(pointerInput(pressPoint));
			}

			waitForLayout(
				() => (dragItem.Visible ? true : undefined),
				"Timed out waiting for the original to reappear after the drop",
			);
			settleFrames(10);

			Assert.undefined(
				overlay.FindFirstChild("Tooltip", true),
				"Expected the Tooltip to stay closed after the drop, since the hover was forgotten when the drag hid the original",
			);
		});
	}

	@Skip(!Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	@DisplayName(
		"A controlled open Tooltip in the item closes for the whole drag (original and preview) and reopens after the drop",
	)
	@Test
	public openTooltipSuppressed() {
		resetDragState();
		tooltipTargetEvents.clear();

		withMounted(400, 300, tooltipFixture(true), (mounted) => {
			const dragItem = waitForDragItem(mounted.host);
			const registration = waitForDraggableRegistration(dragItem);
			const handle = findDescendant<Frame>(dragItem, "DragHandle");
			const overlay = findDescendant<Frame>(mounted.host, "OverlayProvider");
			const pressPoint = centerOf(handle);

			waitForGuiObject<CanvasGroup>(overlay, "Tooltip");

			pressHandle(handle, pressPoint);

			try {
				waitForLayout(
					() => overlay.FindFirstChild("DragItem") as Frame | undefined,
					"Timed out waiting for the drag preview to be portalled into the overlay",
				);
				waitForRemoval(overlay, "Tooltip");
				settleFrames(10);

				Assert.undefined(
					overlay.FindFirstChild("Tooltip", true),
					"Expected no Tooltip popup during the drag, but an open={true} Tooltip (original or preview) showed one",
				);
			} finally {
				registration.draggable.endDrag(pointerInput(pressPoint));
			}

			waitForGuiObject<CanvasGroup>(overlay, "Tooltip");
		});
	}
}

export = DraggableMountValidation;
