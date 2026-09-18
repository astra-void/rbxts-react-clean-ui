declare class DroppableMountValidation {
    rendersChildUnwrapped(): void;
    registersAndForwardsDrop(): void;
    unregistersOnUnmount(): void;
    dropFiresOnceOnRelease(): void;
    topmostZIndexReported(): void;
    onlyTopmostReceivesDrop(): void;
    laterSiblingReported(): void;
    enterLeaveSequence(): void;
    enterFollowsTopmost(): void;
    leaveOnUnmount(): void;
    noProviderDrop(kind: string): void;
    ineligibleTargetSkipped(mode: string, expected: string): void;
    displayOrderWins(displayOrder: number, expected: string): void;
    disabledGuiSkipped(enabled: boolean, expected: string): void;
    zIndexBehavior(behavior: string, expected: string): void;
}
export = DroppableMountValidation;
