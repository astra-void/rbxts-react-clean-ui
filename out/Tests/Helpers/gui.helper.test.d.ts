declare class GuiHelperRenderOrder {
    notAboveSelf(): void;
    displayOrderFirst(): void;
    equalDisplayOrderTreeOrder(): void;
    zIndexBehaviorOrder(behavior: string, expected: string): void;
    descendantAboveAncestor(behavior: string): void;
    laterSiblingBranch(): void;
}
export = GuiHelperRenderOrder;
