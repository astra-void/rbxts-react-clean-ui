# Droppable

`Droppable` marks a GUI element as a drop target for `Draggable` (see [draggable.md](./draggable.md)). It follows the shared conventions in [Components](../index.md) and the layout-wide notes in [Layout](./index.md).

`Droppable` is the passive half of the drag-and-drop pair: it tracks no drag state of its own. It registers a `GuiObject` so a `Draggable` can find it by position, and forwards drop/hover notifications to its callbacks.

## Public API

- `DroppableProps` (exported):
  - `children: ReactElement<GuiObjectProps>` — the element that defines the drop area's bounds. It is cloned, not wrapped.
  - `id?: string` — stored on the registration and surfaced to `Draggable`'s `onDragged`/`onDropped` as `DroppableRegistration.id`.
  - `onDrop?: (draggedObject: GuiObject, info?: DragEventInfo) => void` — fires exactly once when a drag is released over this target and it is the topmost target there. Never fires while the pointer only moves. `info` (see draggable.md) carries the `UserInputType` that started the drag and the `Draggable`'s `id`; it is always present when a `Draggable` fires the drop and only missing when something calls `registration.drop(obj)` directly.
  - `onDragEnter?: (draggedObject: GuiObject, info: DragEventInfo) => void` — fires when a drag moves onto this target and it becomes the topmost target under the pointer.
  - `onDragLeave?: (draggedObject: GuiObject, info: DragEventInfo) => void` — fires when this target stops being the hovered topmost target: the pointer moves off it or onto a target drawn above it, the drag is released (after `onDrop`, if it got the drop), or the dragging `Draggable` unmounts. Every enter is paired with one leave.
- `DroppableRegistration` (from Providers): `{ guiObject, id?, drop(draggedObject, info?), dragEnter?(draggedObject, info), dragLeave?(draggedObject, info) }`.
- No `disabled` prop and no visuals of its own; hover styling is the consumer's job, typically driven by `onDragEnter`/`onDragLeave`.

## Registration

- On mount, `Droppable` registers its child's instance under `DroppableRegistryKey` in the shared module-level registry (`GlobalRegistry`), and also in the nearest `RegistryProvider`'s registry if there is one. It unregisters on unmount and re-registers when `id` changes. No provider is required.
- Changing `onDrop`/`onDragEnter`/`onDragLeave` does not re-register; the latest callbacks are always used.
- A `Droppable` rendered inside a `Draggable`'s drag preview does not register, so a dragged item can't be dropped onto its own preview.
- `Droppable` provides `DroppableContext` (`{ registration }`) to its subtree, so a custom child can compare its own registration with the one reported by `Draggable.onDragged`.

## Drop detection semantics

- Detection is done by the dragging `Draggable` (see draggable.md "Drop-target detection"): the pointer must be inside the target's rect, the target must be effectively visible and not clipped at that point, and among overlapping targets only the one drawn on top (DisplayOrder, ZIndex, ZIndexBehavior, sibling and ancestor order) is notified.
- Detection doesn't filter by which `Draggable` is dragged; accept/reject in `onDrop` using `info.id` or the dragged `GuiObject`.

## Layout

- `Droppable` does not affect its child's size or position.

## Theme

`Droppable` has no theme entry.

## Story

Covered by the shared drag/drop story (see draggable.md):
- A `Droppable` highlighted through `onDragEnter`/`onDragLeave`.
- A rejected drop: releasing with no `Droppable` underneath calls neither `onDrop` nor anything else.
- Two overlapping `Droppable`s with distinct `id`s where only the top one receives the drop.

## Loom

- Reuses the `Draggable` Loom scene.

## Implementation notes

- `Droppable` doesn't use `useRegistryRegistration` any more: it needs to register in two registries and skip registration in the drag preview. The hook is still exported unchanged.
- The registration's `drop`/`dragEnter`/`dragLeave` read the latest props through `propsRef`, and the registration object is memoised on `[guiObject, id]` only. Recreating it on every callback change (as the old `[id, onDrop]` deps did with inline lambdas) would re-register every render.
- On cleanup, `GlobalRegistry` is only cleared if it still holds this exact registration, so a quick remount on the same instance isn't wiped by the old cleanup.
