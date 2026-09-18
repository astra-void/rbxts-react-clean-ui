import React from "@rbxts/react";
import ReactRoblox, { createPortal } from "@rbxts/react-roblox";
import { Test, Assert, Decorators, Runtime, Tag, DisplayName } from "@rbxts/lunit";

const { Skip, Each } = Decorators;
import { Draggable } from "../../../Components/Layout/Draggable";
import { Droppable } from "../../../Components/Layout/Droppable";
import { DragEventInfo } from "../../../Contexts/draggable.context";
import { OverlayProvider } from "../../../Providers/overlay.provider";
import {
	DraggableRegistration,
	DroppableRegistration,
	DroppableRegistryKey,
	RegistryProvider,
} from "../../../Providers/registry.provider";
import {
	MountedElement,
	STUDIO_SKIP_MESSAGE,
	assertContained,
	assertSizeApprox,
	findDescendant,
	settleFrames,
	waitForDescendant,
	waitForGuiObject,
	waitForLayout,
	withMounted,
} from "../../Helpers/layout";
import {
	DragHandle,
	RegistryHarness,
	centerOf,
	dragState,
	moveTo,
	overlapPoint,
	pointerInput,
	pressHandle,
	resetDragState,
	waitForDragItem,
	waitForDraggableRegistration,
	waitForDroppableRegistration,
	waitForGlobalDraggable,
	waitForGlobalDroppable,
} from "../../Helpers/drag";

const DROP_ID = "target";
const DRAG_ID = "item";

interface ZoneSpec {
	id: string;
	name: string;
	zIndex: number;
	onDrop: (dragged: GuiObject) => void;
}

interface LoggedZoneSpec {
	id: string;
	name: string;
	position: UDim2;
	zIndex: number;
}

type Reported = { droppable?: DroppableRegistration };

function droppableFixture(onDrop?: (dragged: GuiObject) => void) {
	return (
		<RegistryProvider>
			<RegistryHarness />
			<Droppable id={DROP_ID} onDrop={onDrop}>
				<frame key="DropZone" Size={UDim2.fromOffset(120, 80)} BackgroundTransparency={1} />
			</Droppable>
		</RegistryProvider>
	);
}

function dragSource(onDropped?: (droppable?: DroppableRegistration) => void) {
	return (
		<Draggable id={DRAG_ID} onDropped={onDropped}>
			<frame key="DragItem" Size={UDim2.fromOffset(160, 90)} BackgroundTransparency={1}>
				<Draggable.Handle>
					<DragHandle />
				</Draggable.Handle>
			</frame>
		</Draggable>
	);
}

function reporter(reported: Reported) {
	return (droppable?: DroppableRegistration) => {
		reported.droppable = droppable;
	};
}

function dropZone(spec: ZoneSpec) {
	return (
		<Droppable id={spec.id} onDrop={spec.onDrop}>
			<frame
				key={spec.name}
				Position={UDim2.fromOffset(200, 150)}
				Size={UDim2.fromOffset(150, 120)}
				ZIndex={spec.zIndex}
				BackgroundTransparency={1}
			/>
		</Droppable>
	);
}

function dragToZonesFixture(zones: ZoneSpec[], onDropped?: (droppable?: DroppableRegistration) => void) {
	return (
		<RegistryProvider>
			<OverlayProvider>
				<RegistryHarness />
				{dragSource(onDropped)}
				{zones.map((zone) => dropZone(zone))}
			</OverlayProvider>
		</RegistryProvider>
	);
}

function loggedZone(spec: LoggedZoneSpec, log: string[]) {
	return (
		<Droppable
			id={spec.id}
			onDrop={() => log.push(`drop:${spec.id}`)}
			onDragEnter={() => log.push(`enter:${spec.id}`)}
			onDragLeave={() => log.push(`leave:${spec.id}`)}
		>
			<frame
				key={spec.name}
				Position={spec.position}
				Size={UDim2.fromOffset(150, 120)}
				ZIndex={spec.zIndex}
				BackgroundTransparency={1}
			/>
		</Droppable>
	);
}

function loggedZonesFixture(zones: LoggedZoneSpec[], log: string[], withDraggable = true) {
	return (
		<RegistryProvider>
			<OverlayProvider>
				<RegistryHarness />
				{withDraggable && dragSource()}
				{zones.map((zone) => loggedZone(zone, log))}
			</OverlayProvider>
		</RegistryProvider>
	);
}

function noProviderFixture(
	withZone: boolean,
	onDropped: (droppable?: DroppableRegistration) => void,
	onDrop: (dragged: GuiObject, info?: DragEventInfo) => void,
) {
	return (
		<OverlayProvider>
			{dragSource(onDropped)}
			{withZone && (
				<Droppable id={DROP_ID} onDrop={onDrop}>
					<frame
						key="DropZone"
						Position={UDim2.fromOffset(200, 150)}
						Size={UDim2.fromOffset(150, 120)}
						BackgroundTransparency={1}
					/>
				</Droppable>
			)}
		</OverlayProvider>
	);
}

function ineligibleFixture(mode: string, onDropped: (droppable?: DroppableRegistration) => void) {
	const clipped = mode === "clipped";

	return (
		<RegistryProvider>
			<OverlayProvider>
				<RegistryHarness />
				{dragSource(onDropped)}
				<Droppable id="back">
					<frame
						key="BackZone"
						Position={UDim2.fromOffset(200, 150)}
						Size={UDim2.fromOffset(150, 120)}
						ZIndex={1}
						BackgroundTransparency={1}
					/>
				</Droppable>
				<frame
					key="FrontWrapper"
					Position={UDim2.fromOffset(200, 150)}
					Size={clipped ? UDim2.fromOffset(40, 40) : UDim2.fromOffset(150, 120)}
					ClipsDescendants={clipped}
					Visible={mode !== "hiddenAncestor"}
					ZIndex={2}
					BackgroundTransparency={1}
				>
					<Droppable id="front">
						<frame
							key="FrontZone"
							Size={UDim2.fromOffset(150, 120)}
							Visible={mode !== "hidden"}
							ZIndex={2}
							BackgroundTransparency={1}
						/>
					</Droppable>
				</frame>
			</OverlayProvider>
		</RegistryProvider>
	);
}

function crossGuiFixture(secondRoot: Frame, onDropped: (droppable?: DroppableRegistration) => void) {
	return (
		<RegistryProvider>
			<OverlayProvider>
				<RegistryHarness />
				{dragSource(onDropped)}
				<Droppable id="local">
					<frame
						key="LocalZone"
						Position={UDim2.fromOffset(200, 150)}
						Size={UDim2.fromOffset(150, 120)}
						ZIndex={50}
						BackgroundTransparency={1}
					/>
				</Droppable>
				{createPortal(
					<Droppable id="other">
						<frame key="OtherZone" Size={UDim2.fromScale(1, 1)} BackgroundTransparency={1} />
					</Droppable>,
					secondRoot,
				)}
			</OverlayProvider>
		</RegistryProvider>
	);
}

function zIndexBehaviorFixture(onDropped: (droppable?: DroppableRegistration) => void) {
	return (
		<RegistryProvider>
			<OverlayProvider>
				<RegistryHarness />
				{dragSource(onDropped)}
				<Droppable id="shallow">
					<frame
						key="ShallowZone"
						Position={UDim2.fromOffset(200, 150)}
						Size={UDim2.fromOffset(150, 120)}
						ZIndex={5}
						BackgroundTransparency={1}
					/>
				</Droppable>
				<frame
					key="LowParent"
					Position={UDim2.fromOffset(200, 150)}
					Size={UDim2.fromOffset(150, 120)}
					ZIndex={1}
					BackgroundTransparency={1}
				>
					<Droppable id="deep">
						<frame key="DeepZone" Size={UDim2.fromScale(1, 1)} ZIndex={10} BackgroundTransparency={1} />
					</Droppable>
				</frame>
			</OverlayProvider>
		</RegistryProvider>
	);
}

function emptyFixture() {
	return <frame key="Empty" Size={UDim2.fromOffset(10, 10)} BackgroundTransparency={1} />;
}

function waitForDropZone(host: Instance): Frame {
	return waitForGuiObject<Frame>(host, "DropZone");
}

function waitForZone(host: Instance, name: string): Frame {
	const zone = waitForDescendant<Frame>(host, name, () => true);
	waitForDroppableRegistration(zone);
	return zone;
}

function startDrag(host: Frame): DraggableRegistration {
	const dragItem = waitForDragItem(host);
	const registration = waitForDraggableRegistration(dragItem);
	const handle = findDescendant<Frame>(dragItem, "DragHandle");

	pressHandle(handle, centerOf(handle));
	waitForLayout(
		() => (!dragItem.Visible ? true : undefined),
		"Timed out waiting for the original to hide while dragging",
	);

	return registration;
}

function hostPoint(host: Frame, x: number, y: number): Vector2 {
	return host.AbsolutePosition.add(new Vector2(x, y));
}

function withSecondGui(mounted: MountedElement, displayOrder: number, fn: (gui: ScreenGui, root: Frame) => void) {
	const screenGui = mounted.host.Parent as ScreenGui;

	const gui = new Instance("ScreenGui");
	gui.Name = "SecondGui";
	gui.DisplayOrder = displayOrder;
	gui.Parent = screenGui.Parent;

	const root = new Instance("Frame");
	root.Name = "SecondRoot";
	root.BackgroundTransparency = 1;
	root.Position = UDim2.fromOffset(220, 170);
	root.Size = UDim2.fromOffset(150, 120);
	root.Parent = gui;

	try {
		fn(gui, root);
	} finally {
		mounted.update(emptyFixture());
		root.Destroy();
		gui.Destroy();
	}
}

@Tag("Studio")
class DroppableMountValidation {
	@Skip(!Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	@DisplayName("Renders its child in place with no wrapper, at the child's own size, inside the host")
	@Test
	public rendersChildUnwrapped() {
		resetDragState();

		withMounted(400, 300, droppableFixture(), (mounted) => {
			const zone = waitForDropZone(mounted.host);

			Assert.equal(
				zone.Parent,
				mounted.host,
				"Expected the drop zone to be a direct child of the host (no wrapper)",
			);
			assertSizeApprox(zone, 120, 80, 1, "drop zone");
			assertContained(zone, mounted.host, "drop zone vs host");
		});
	}

	@Skip(!Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	@DisplayName(
		"Registers its child under DroppableRegistryKey with its id, and the registration's drop() forwards the dragged object to onDrop",
	)
	@Test
	public registersAndForwardsDrop() {
		resetDragState();
		const dropped: GuiObject[] = [];

		withMounted(
			400,
			300,
			droppableFixture((dragged) => dropped.push(dragged)),
			(mounted) => {
				const zone = waitForDropZone(mounted.host);
				const registration = waitForDroppableRegistration(zone);

				Assert.equal(registration.id, DROP_ID);
				Assert.equal(
					registration.guiObject,
					zone,
					"Expected the registration to point at the cloned child instance",
				);

				const dragged = new Instance("Frame");
				registration.drop(dragged);

				Assert.equal(dropped.size(), 1, "Expected onDrop to fire exactly once");
				Assert.equal(dropped[0], dragged, "Expected onDrop to receive the dragged GuiObject unchanged");

				dragged.Destroy();
			},
		);
	}

	@Skip(!Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	@DisplayName("Unmounting the Droppable removes its registry entry")
	@Test
	public unregistersOnUnmount() {
		resetDragState();

		withMounted(400, 300, droppableFixture(), (mounted) => {
			const zone = waitForDropZone(mounted.host);
			waitForDroppableRegistration(zone);

			const registry = dragState.registry!;

			mounted.update(
				<RegistryProvider>
					<RegistryHarness />
					<frame key="Placeholder" Size={UDim2.fromOffset(10, 10)} BackgroundTransparency={1} />
				</RegistryProvider>,
			);

			waitForLayout(
				() => (registry.get(zone, DroppableRegistryKey) === undefined ? true : undefined),
				"Timed out waiting for the Droppable's registry entry to be removed after unmount",
			);
		});
	}

	@Skip(!Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	@DisplayName("Moving a drag across the target several times fires onDrop zero times, then exactly once on release")
	@Test
	public dropFiresOnceOnRelease() {
		resetDragState();
		const dropped: GuiObject[] = [];
		const zones: ZoneSpec[] = [
			{ id: DROP_ID, name: "DropZone", zIndex: 1, onDrop: (dragged) => dropped.push(dragged) },
		];

		withMounted(400, 300, dragToZonesFixture(zones), (mounted) => {
			const zone = waitForDropZone(mounted.host);
			waitForDroppableRegistration(zone);

			const registration = startDrag(mounted.host);
			const target = centerOf(zone);

			for (let step = 1; step <= 3; step++) {
				registration.draggable.updateDrag(
					pointerInput(target.add(new Vector2(step * 4, 0)), Enum.UserInputType.MouseMovement),
				);
				task.wait();
			}

			Assert.equal(
				dropped.size(),
				0,
				`Expected onDrop not to fire while the pointer only moves over the target, but it fired ${dropped.size()} time(s) during 3 moves`,
			);

			registration.draggable.endDrag(pointerInput(target));

			Assert.equal(dropped.size(), 1, `Expected onDrop to fire exactly once on release, got ${dropped.size()}`);
			Assert.equal(dropped[0], registration.guiObject, "Expected onDrop to receive the dragged root GuiObject");
		});
	}

	@Skip(!Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	@DisplayName(
		"With two overlapping targets, onDropped reports the one with the higher ZIndex even when it is declared first",
	)
	@Test
	public topmostZIndexReported() {
		resetDragState();
		let reported: DroppableRegistration | undefined;
		const zones: ZoneSpec[] = [
			{ id: "top", name: "TopZone", zIndex: 2, onDrop: () => {} },
			{ id: "bottom", name: "BottomZone", zIndex: 1, onDrop: () => {} },
		];

		withMounted(
			400,
			300,
			dragToZonesFixture(zones, (droppable) => {
				reported = droppable;
			}),
			(mounted) => {
				const top = waitForGuiObject<Frame>(mounted.host, "TopZone");
				waitForDroppableRegistration(top);
				waitForDroppableRegistration(waitForGuiObject<Frame>(mounted.host, "BottomZone"));

				const registration = startDrag(mounted.host);
				registration.draggable.endDrag(pointerInput(centerOf(top)));

				Assert.notUndefined(reported, "Expected onDropped to report a droppable under the pointer");
				Assert.equal(
					reported!.id,
					"top",
					`Expected the higher-ZIndex target "top" to win the drop, but "${reported!.id}" did`,
				);
			},
		);
	}

	@Skip(!Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	@DisplayName(
		"With two overlapping targets, only the one drawn on top has onDrop fired; the target underneath gets nothing",
	)
	@Test
	public onlyTopmostReceivesDrop() {
		resetDragState();
		let topDrops = 0;
		let bottomDrops = 0;
		const zones: ZoneSpec[] = [
			{
				id: "top",
				name: "TopZone",
				zIndex: 2,
				onDrop: () => {
					topDrops++;
				},
			},
			{
				id: "bottom",
				name: "BottomZone",
				zIndex: 1,
				onDrop: () => {
					bottomDrops++;
				},
			},
		];

		withMounted(400, 300, dragToZonesFixture(zones), (mounted) => {
			const top = waitForGuiObject<Frame>(mounted.host, "TopZone");
			waitForDroppableRegistration(top);
			waitForDroppableRegistration(waitForGuiObject<Frame>(mounted.host, "BottomZone"));

			const registration = startDrag(mounted.host);
			registration.draggable.endDrag(pointerInput(centerOf(top)));

			Assert.equal(topDrops, 1, `Expected the top target's onDrop to fire once, got ${topDrops}`);
			Assert.equal(
				bottomDrops,
				0,
				`Expected the covered target's onDrop not to fire, but it fired ${bottomDrops} time(s)`,
			);
		});
	}

	@Skip(!Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	@DisplayName("With two overlapping targets at the same ZIndex, the later sibling (drawn on top) wins the drop")
	@Test
	public laterSiblingReported() {
		resetDragState();
		let reported: DroppableRegistration | undefined;
		const zones: ZoneSpec[] = [
			{ id: "earlier", name: "EarlierZone", zIndex: 1, onDrop: () => {} },
			{ id: "later", name: "LaterZone", zIndex: 1, onDrop: () => {} },
		];

		withMounted(
			400,
			300,
			dragToZonesFixture(zones, (droppable) => {
				reported = droppable;
			}),
			(mounted) => {
				const later = waitForGuiObject<Frame>(mounted.host, "LaterZone");
				waitForDroppableRegistration(later);
				waitForDroppableRegistration(waitForGuiObject<Frame>(mounted.host, "EarlierZone"));

				const registration = startDrag(mounted.host);
				registration.draggable.endDrag(pointerInput(centerOf(later)));

				Assert.notUndefined(reported, "Expected onDropped to report a droppable under the pointer");
				Assert.equal(
					reported!.id,
					"later",
					`Expected the later sibling "later" to win the drop, but "${reported!.id}" did`,
				);
			},
		);
	}

	@Skip(!Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	@DisplayName(
		"Moving on, within, across, off and back onto targets pairs every enter with one leave, and release drops then leaves",
	)
	@Test
	public enterLeaveSequence() {
		resetDragState();
		const log: string[] = [];
		const zones: LoggedZoneSpec[] = [
			{ id: "left", name: "LeftZone", position: UDim2.fromOffset(20, 150), zIndex: 1 },
			{ id: "right", name: "RightZone", position: UDim2.fromOffset(230, 150), zIndex: 1 },
		];

		withMounted(400, 300, loggedZonesFixture(zones, log), (mounted) => {
			const left = waitForZone(mounted.host, "LeftZone");
			const right = waitForZone(mounted.host, "RightZone");
			const registration = startDrag(mounted.host);

			moveTo(registration, centerOf(left));
			moveTo(registration, centerOf(left).add(new Vector2(5, 0)));
			moveTo(registration, centerOf(right));
			moveTo(registration, hostPoint(mounted.host, 200, 210));
			moveTo(registration, centerOf(left));
			registration.draggable.endDrag(pointerInput(centerOf(left)));

			Assert.equal(
				log.join(","),
				"enter:left,leave:left,enter:right,leave:right,enter:left,drop:left,leave:left",
				"Expected the enter/leave/drop sequence to pair every enter with exactly one leave",
			);
		});
	}

	@Skip(!Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	@DisplayName(
		"Over two overlapping targets only the top one is entered; moving to the uncovered part of the lower one hands over",
	)
	@Test
	public enterFollowsTopmost() {
		resetDragState();
		const log: string[] = [];
		const zones: LoggedZoneSpec[] = [
			{ id: "top", name: "TopZone", position: UDim2.fromOffset(200, 150), zIndex: 2 },
			{ id: "bottom", name: "BottomZone", position: UDim2.fromOffset(100, 100), zIndex: 1 },
		];

		withMounted(400, 300, loggedZonesFixture(zones, log), (mounted) => {
			const top = waitForZone(mounted.host, "TopZone");
			const bottom = waitForZone(mounted.host, "BottomZone");
			const registration = startDrag(mounted.host);
			const bottomOnly = hostPoint(mounted.host, 120, 120);

			moveTo(registration, overlapPoint(top, bottom));
			moveTo(registration, bottomOnly);
			registration.draggable.endDrag(pointerInput(bottomOnly));

			Assert.equal(
				log.join(","),
				"enter:top,leave:top,enter:bottom,drop:bottom,leave:bottom",
				"Expected the covered target to receive nothing while the top target is hovered",
			);
		});
	}

	@Skip(!Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	@DisplayName("Unmounting the Draggable while it hovers a target sends that target exactly one leave")
	@Test
	public leaveOnUnmount() {
		resetDragState();
		const log: string[] = [];
		const zones: LoggedZoneSpec[] = [
			{ id: "left", name: "LeftZone", position: UDim2.fromOffset(20, 150), zIndex: 1 },
		];

		withMounted(400, 300, loggedZonesFixture(zones, log), (mounted) => {
			const left = waitForZone(mounted.host, "LeftZone");
			const registration = startDrag(mounted.host);

			moveTo(registration, centerOf(left));
			Assert.equal(log.join(","), "enter:left", "Expected one enter before the Draggable unmounts");

			mounted.update(loggedZonesFixture(zones, log, false));
			settleFrames(3);

			Assert.equal(
				log.join(","),
				"enter:left,leave:left",
				"Expected the hovered target to get exactly one leave when the dragging Draggable unmounts",
			);
			Assert.equal(
				findDescendant<Frame>(mounted.host, "LeftZone"),
				left,
				"Expected the Droppable to stay mounted",
			);
		});
	}

	@Skip(!Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	@DisplayName(
		"With no RegistryProvider anywhere, a drop reaches a Droppable in the same React root or in a separate root",
	)
	@Each([["sameRoot"], ["separateRoot"]])
	@Test
	public noProviderDrop(kind: string) {
		resetDragState();
		const reported: Reported = {};
		let dropInfo: DragEventInfo | undefined;
		let dropCount = 0;
		const onDrop = (_dragged: GuiObject, info?: DragEventInfo) => {
			dropCount++;
			dropInfo = info;
		};

		withMounted(400, 300, noProviderFixture(kind === "sameRoot", reporter(reported), onDrop), (mounted) => {
			let otherHost: Frame | undefined;
			let otherRoot: ReactRoblox.Root | undefined;

			if (kind === "separateRoot") {
				otherHost = new Instance("Frame");
				otherHost.Name = "OtherRoot";
				otherHost.BackgroundTransparency = 1;
				otherHost.Position = UDim2.fromOffset(200, 150);
				otherHost.Size = UDim2.fromOffset(150, 120);
				otherHost.Parent = mounted.host.Parent;

				otherRoot = ReactRoblox.createRoot(otherHost);
				otherRoot.render(
					<Droppable id={DROP_ID} onDrop={onDrop}>
						<frame key="DropZone" Size={UDim2.fromScale(1, 1)} BackgroundTransparency={1} />
					</Droppable>,
				);
			}

			try {
				const zone = waitForDropZone(otherHost ?? mounted.host);
				waitForGlobalDroppable(zone);
				const dragItem = waitForDragItem(mounted.host);
				const registration = waitForGlobalDraggable(dragItem);
				const handle = findDescendant<Frame>(dragItem, "DragHandle");

				pressHandle(handle, centerOf(handle));
				waitForLayout(
					() => (!dragItem.Visible ? true : undefined),
					"Timed out waiting for the original to hide while dragging",
				);
				registration.draggable.endDrag(pointerInput(centerOf(zone)));

				Assert.equal(
					dropCount,
					1,
					`Expected the ${kind} Droppable's onDrop to fire once without a RegistryProvider`,
				);
				Assert.equal(dropInfo?.id, DRAG_ID);
				Assert.equal(
					reported.droppable?.id,
					DROP_ID,
					"Expected onDropped to report the provider-less Droppable",
				);
			} finally {
				otherRoot?.unmount();
				otherHost?.Destroy();
			}
		});
	}

	@Skip(!Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	@DisplayName(
		"A higher target that is hidden, has a hidden ancestor, or is clipped away at the pointer is skipped for the one beneath",
	)
	@Each([
		["visible", "front"],
		["hidden", "back"],
		["hiddenAncestor", "back"],
		["clipped", "back"],
	])
	@Test
	public ineligibleTargetSkipped(mode: string, expected: string) {
		resetDragState();
		const reported: Reported = {};

		withMounted(400, 300, ineligibleFixture(mode, reporter(reported)), (mounted) => {
			const back = waitForZone(mounted.host, "BackZone");
			waitForZone(mounted.host, "FrontZone");
			const registration = startDrag(mounted.host);

			registration.draggable.endDrag(pointerInput(centerOf(back)));

			Assert.notUndefined(reported.droppable, `Expected a droppable to be reported for mode ${mode}`);
			Assert.equal(
				reported.droppable!.id,
				expected,
				`Expected "${expected}" to win with the front target ${mode}, but "${reported.droppable!.id}" did`,
			);
		});
	}

	@Skip(!Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	@DisplayName("Across ScreenGuis the higher DisplayOrder wins, even over a target with a much larger ZIndex")
	@Each([
		[10, "other"],
		[-10, "local"],
	])
	@Test
	public displayOrderWins(displayOrder: number, expected: string) {
		resetDragState();
		const reported: Reported = {};

		withMounted(400, 300, emptyFixture(), (mounted) => {
			withSecondGui(mounted, displayOrder, (_gui, root) => {
				mounted.update(crossGuiFixture(root, reporter(reported)));

				const localZone = waitForZone(mounted.host, "LocalZone");
				const other = waitForZone(root, "OtherZone");
				const registration = startDrag(mounted.host);

				registration.draggable.endDrag(pointerInput(overlapPoint(localZone, other)));

				Assert.equal(
					reported.droppable?.id,
					expected,
					`Expected "${expected}" to win with the second ScreenGui at DisplayOrder ${displayOrder}`,
				);
			});
		});
	}

	@Skip(!Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	@DisplayName("A target in a ScreenGui that is disabled at drag time is skipped, even with the higher DisplayOrder")
	@Each([
		[true, "other"],
		[false, "local"],
	])
	@Test
	public disabledGuiSkipped(enabled: boolean, expected: string) {
		resetDragState();
		const reported: Reported = {};

		withMounted(400, 300, emptyFixture(), (mounted) => {
			withSecondGui(mounted, 10, (gui, root) => {
				mounted.update(crossGuiFixture(root, reporter(reported)));

				const localZone = waitForZone(mounted.host, "LocalZone");
				const other = waitForZone(root, "OtherZone");
				const point = overlapPoint(localZone, other);
				gui.Enabled = enabled;

				const registration = startDrag(mounted.host);
				registration.draggable.endDrag(pointerInput(point));

				Assert.equal(
					reported.droppable?.id,
					expected,
					`Expected "${expected}" to win with the second ScreenGui Enabled=${enabled}`,
				);
			});
		});
	}

	@Skip(!Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	@DisplayName(
		"Sibling ZIndexBehavior compares the top-level branches' ZIndex, Global compares each target's own ZIndex",
	)
	@Each([
		["Sibling", "shallow"],
		["Global", "deep"],
	])
	@Test
	public zIndexBehavior(behavior: string, expected: string) {
		resetDragState();
		const reported: Reported = {};

		withMounted(400, 300, zIndexBehaviorFixture(reporter(reported)), (mounted) => {
			(mounted.host.Parent as ScreenGui).ZIndexBehavior =
				behavior === "Global" ? Enum.ZIndexBehavior.Global : Enum.ZIndexBehavior.Sibling;

			const shallow = waitForZone(mounted.host, "ShallowZone");
			const deep = waitForZone(mounted.host, "DeepZone");
			const registration = startDrag(mounted.host);

			registration.draggable.endDrag(pointerInput(overlapPoint(shallow, deep)));

			Assert.equal(
				reported.droppable?.id,
				expected,
				`Expected "${expected}" to win under ZIndexBehavior.${behavior}`,
			);
		});
	}
}

export = DroppableMountValidation;
