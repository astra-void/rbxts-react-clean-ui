import React from "@rbxts/react";
import { DroppableRegistration, DroppableRegistryKey, GlobalRegistry, RegistryContext } from "../../Providers/";
import { DragEventInfo, DragStateContext, DroppableContext } from "../../Contexts";

type GuiObjectProps = React.InstanceProps<GuiObject>;
type GuiElement = React.ReactElement<GuiObjectProps>;


export interface DroppableProps {
    id?: string;
    children: GuiElement;
    onDrop?: (draggedObject: GuiObject, info?: DragEventInfo) => void;
    onDragEnter?: (draggedObject: GuiObject, info: DragEventInfo) => void;
    onDragLeave?: (draggedObject: GuiObject, info: DragEventInfo) => void;
}

export function Droppable(props: DroppableProps) {
    const registry = React.useContext(RegistryContext);
    const dragState = React.useContext(DragStateContext);
    const [guiObject, setGuiObject] = React.useState<GuiObject>();

    const propsRef = React.useRef(props);
    propsRef.current = props;

    const registration = React.useMemo<DroppableRegistration | undefined>(() => {
        if (guiObject === undefined) {
            return undefined;
        }

        return {
            guiObject,
            id: props.id,

            drop: (draggedObject, info) => {
                propsRef.current.onDrop?.(draggedObject, info);
            },

            dragEnter: (draggedObject, info) => {
                propsRef.current.onDragEnter?.(draggedObject, info);
            },

            dragLeave: (draggedObject, info) => {
                propsRef.current.onDragLeave?.(draggedObject, info);
            },
        };
    }, [guiObject, props.id]);

    React.useEffect(() => {
        if (registration === undefined || dragState.preview) {
            return;
        }

        registry?.register(
            registration.guiObject,
            DroppableRegistryKey,
            registration,
        );

        GlobalRegistry.register(
            registration.guiObject,
            DroppableRegistryKey,
            registration,
        );

        return () => {
            registry?.unregister(
                registration.guiObject,
                DroppableRegistryKey,
            );

            if (GlobalRegistry.get(registration.guiObject, DroppableRegistryKey) === registration) {
                GlobalRegistry.unregister(
                    registration.guiObject,
                    DroppableRegistryKey,
                );
            }
        };
    }, [registry, registration, dragState.preview]);

    const child = React.cloneElement(props.children, {
        ref: setGuiObject,
    });

    return (
        <DroppableContext.Provider
            value={{
                registration: registration,
            }}
        >
            {child}
        </DroppableContext.Provider>
    );
}
