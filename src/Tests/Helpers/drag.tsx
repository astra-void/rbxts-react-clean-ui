import React from "@rbxts/react";
import { Assert } from "@rbxts/lunit";

import {
	DraggableRegistration,
	DraggableRegistryKey,
	DroppableRegistration,
	DroppableRegistryKey,
	GlobalRegistry,
	RegistryContext,
	RegistryContextValue,
} from "../../Providers/registry.provider";
import { waitForGuiObject, waitForLayout } from "./layout";

export type FrameEvents = NonNullable<React.InstanceProps<Frame>["Event"]>;

export const dragState: {
	registry?: RegistryContextValue;
	handleEvents?: FrameEvents;
} = {};

export function resetDragState() {
	dragState.registry = undefined;
	dragState.handleEvents = undefined;
}

export function RegistryHarness() {
	dragState.registry = React.useContext(RegistryContext);
	return undefined;
}

export const DragHandle = React.forwardRef<Frame, React.InstanceProps<Frame>>((props, ref) => {
	dragState.handleEvents = props.Event;

	return (
		<frame
			key="DragHandle"
			ref={ref}
			Active={props.Active}
			BackgroundTransparency={1}
			Size={new UDim2(1, 0, 0, 24)}
			Event={props.Event}
		/>
	);
});

export function pointerInput(
	position: Vector2,
	inputType: Enum.UserInputType = Enum.UserInputType.MouseButton1,
): InputObject {
	return {
		Position: new Vector3(position.X, position.Y, 0),
		UserInputType: inputType,
	} as unknown as InputObject;
}

export function centerOf(gui: GuiObject): Vector2 {
	return gui.AbsolutePosition.add(gui.AbsoluteSize.div(2));
}

export function waitForDragItem(host: Instance, name = "DragItem"): Frame {
	waitForGuiObject<Frame>(host, "OverlayProvider");
	return waitForGuiObject<Frame>(host, name);
}

export function waitForHandleEvents(): FrameEvents {
	return waitForLayout(
		() => dragState.handleEvents,
		"Timed out waiting for Draggable.Handle to inject its Event table",
	);
}

export function waitForDraggableRegistration(dragItem: GuiObject): DraggableRegistration {
	return waitForLayout(
		() => dragState.registry?.get(dragItem, DraggableRegistryKey),
		"Timed out waiting for Draggable to register its root in the registry",
	);
}

export function waitForDroppableRegistration(dropZone: GuiObject): DroppableRegistration {
	return waitForLayout(
		() => dragState.registry?.get(dropZone, DroppableRegistryKey),
		`Timed out waiting for Droppable to register ${dropZone.Name} in the registry`,
	);
}

export function waitForGlobalDraggable(dragItem: GuiObject): DraggableRegistration {
	return waitForLayout(
		() => GlobalRegistry.get(dragItem, DraggableRegistryKey),
		"Timed out waiting for Draggable to register its root in the GlobalRegistry",
	);
}

export function waitForGlobalDroppable(dropZone: GuiObject): DroppableRegistration {
	return waitForLayout(
		() => GlobalRegistry.get(dropZone, DroppableRegistryKey),
		`Timed out waiting for Droppable to register ${dropZone.Name} in the GlobalRegistry`,
	);
}

export function pressHandle(
	handle: Frame,
	point: Vector2,
	inputType: Enum.UserInputType = Enum.UserInputType.MouseButton1,
) {
	const events = waitForHandleEvents();
	Assert.notUndefined(events.InputBegan, "Expected Draggable.Handle to inject an InputBegan handler");
	events.InputBegan!(handle, pointerInput(point, inputType));
}

export function moveTo(registration: DraggableRegistration, point: Vector2) {
	registration.draggable.updateDrag(pointerInput(point, Enum.UserInputType.MouseMovement));
	task.wait();
}

export function overlapPoint(a: GuiObject, b: GuiObject): Vector2 {
	const left = math.max(a.AbsolutePosition.X, b.AbsolutePosition.X);
	const top = math.max(a.AbsolutePosition.Y, b.AbsolutePosition.Y);
	const right = math.min(a.AbsolutePosition.X + a.AbsoluteSize.X, b.AbsolutePosition.X + b.AbsoluteSize.X);
	const bottom = math.min(a.AbsolutePosition.Y + a.AbsoluteSize.Y, b.AbsolutePosition.Y + b.AbsoluteSize.Y);

	Assert.true(right > left && bottom > top, `Expected ${a.Name} and ${b.Name} to overlap`);

	return new Vector2((left + right) / 2, (top + bottom) / 2);
}
