import React from "@rbxts/react";
import { DragEventInfo } from "../../Contexts";
type GuiObjectProps = React.InstanceProps<GuiObject>;
type GuiElement = React.ReactElement<GuiObjectProps>;
export interface DroppableProps {
    id?: string;
    children: GuiElement;
    onDrop?: (draggedObject: GuiObject, info?: DragEventInfo) => void;
    onDragEnter?: (draggedObject: GuiObject, info: DragEventInfo) => void;
    onDragLeave?: (draggedObject: GuiObject, info: DragEventInfo) => void;
}
export declare function Droppable(props: DroppableProps): React.JSX.Element;
export {};
