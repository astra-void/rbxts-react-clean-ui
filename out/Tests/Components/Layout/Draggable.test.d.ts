declare class DraggableMountValidation {
    rendersChildInPlace(): void;
    handleIsActive(): void;
    registersInRegistry(): void;
    dragLifecycle(): void;
    nativeHandleMounts(): void;
    nativeHandleStartsDrag(): void;
    siblingTreeDrop(kind: string): void;
    rightButtonOptIn(): void;
    unlistedInputIgnored(label: string, pressType: Enum.UserInputType): void;
    releaseMustMatch(): void;
    inputTypeReachesDrop(): void;
    renderOverlayContent(): void;
    previewSkipsTooltip(): void;
    dragClosesTooltip(): void;
    openTooltipSuppressed(): void;
}
export = DraggableMountValidation;
