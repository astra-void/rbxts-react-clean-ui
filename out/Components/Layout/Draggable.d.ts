import React from "@rbxts/react";
import { DroppableRegistration } from "../../Providers";
import { DragEventInfo } from "../../Contexts";
type GuiObjectProps = React.InstanceProps<GuiObject>;
type GuiElement = React.ReactElement<GuiObjectProps>;
interface DragHandleProps {
    children: GuiElement;
}
declare function DragHandle({ children }: DragHandleProps): React.ReactElement<GuiObjectProps, string | React.JSXElementConstructor<any>>;
export interface DraggableProps {
    onDropped?: (droppable: DroppableRegistration | undefined, info: DragEventInfo) => void;
    onDragged?: (droppable: DroppableRegistration | undefined, info: DragEventInfo) => void;
    onStartDrag?: (info: DragEventInfo) => void;
    inputTypes?: Enum.UserInputType[];
    renderOverlay?: () => React.ReactNode;
    placeholder?: boolean;
    retainPosition?: boolean;
    children: GuiElement;
    id?: string;
}
type DraggableComponent = React.ForwardRefExoticComponent<DraggableProps & React.RefAttributes<Frame>> & {
    Handle: typeof DragHandle;
};
declare const Draggable: DraggableComponent;
export { Draggable };
