import React from "@rbxts/react";

export interface DragEventInfo {
    inputType: Enum.UserInputType;
    input: InputObject;
    position: Vector2;
    id?: string;
}

export interface DraggableContextValue {
    isDragging: boolean,
    beginDrag: (
        input: InputObject,
        handle: GuiObject,
    ) => void;
    updateDrag: (input: InputObject) => void;
    endDrag: (input: InputObject) => void;
}

export const DraggableContext = React.createContext<DraggableContextValue | undefined>(
    undefined,
);

export interface DragStateContextValue {
    preview: boolean;
    dragging: boolean;
}

export const DragStateContext = React.createContext<DragStateContextValue>({
    preview: false,
    dragging: false,
});
