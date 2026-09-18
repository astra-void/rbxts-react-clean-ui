import React from "@rbxts/react";
import { DragEventInfo, DraggableContextValue } from "../Contexts";
export interface RegistryKey<_T extends defined> {
    readonly name: string;
}
export interface DroppableRegistration {
    guiObject: GuiObject;
    id?: string;
    drop: (draggedObject: GuiObject, info?: DragEventInfo) => void;
    dragEnter?: (draggedObject: GuiObject, info: DragEventInfo) => void;
    dragLeave?: (draggedObject: GuiObject, info: DragEventInfo) => void;
}
export declare const DroppableRegistryKey: RegistryKey<DroppableRegistration>;
export interface DraggableRegistration {
    guiObject: GuiObject;
    id?: string;
    draggable: DraggableContextValue;
}
export declare const DraggableRegistryKey: RegistryKey<DraggableRegistration>;
export interface RegistryContextValue {
    register: <T extends defined>(guiObject: GuiObject, key: RegistryKey<T>, value: T) => void;
    unregister: <T extends defined>(guiObject: GuiObject, key: RegistryKey<T>) => void;
    get: <T extends defined>(guiObject: GuiObject, key: RegistryKey<T>) => T | undefined;
    getAll: <T extends defined>(key: RegistryKey<T>) => T[];
    GetNextId: () => string;
}
export declare const RegistryContext: React.Context<RegistryContextValue | undefined>;
export interface RegistryProviderProps {
    children?: React.ReactNode;
}
export declare function createRegistry(): RegistryContextValue;
export declare const GlobalRegistry: RegistryContextValue;
export declare function RegistryProvider(props: RegistryProviderProps): React.JSX.Element;
export declare function useRegistryRegistration<T extends defined>(key: RegistryKey<T>, createRegistration: (guiObject: GuiObject) => T, dependencies: React.DependencyList): {
    ref: React.Dispatch<React.SetStateAction<GuiObject | undefined>>;
    guiObject: GuiObject | undefined;
    registration: T | undefined;
};
