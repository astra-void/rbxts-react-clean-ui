import {
    Players,
    RunService,
} from "@rbxts/services";

type GuiRoot = Instance;

interface IndexedGuiObject {
    object: GuiObject;
    siblingIndex: number;
}

interface RenderSurface {
    root: LayerCollector;
    rootIndex: number;
}

export class GuiHelper {
    public static findHighestAncestorOfClass<T extends Instance>(
        instance: Instance,
        className: string,
    ): T | undefined {
        let current: Instance | undefined = instance;
        let highest: T | undefined;

        while (current) {
            if (current.IsA(className as keyof Instances)) {
                highest = current as T;
            }
            current = current.Parent;
        }

        return highest;
    }

    public static printParentTree(instance: Instance) {
        let current: Instance | undefined = instance;

        while (current !== undefined) {
            print(`${current.ClassName}: ${current.Name}`);
            current = current.Parent;
        }
    }

    public static isPointInsideGuiObject(
        guiObject: GuiObject,
        point: Vector2,
    ): boolean {
        const position = guiObject.AbsolutePosition;
        const size = guiObject.AbsoluteSize;

        return (
            point.X >= position.X &&
            point.X <= position.X + size.X &&
            point.Y >= position.Y &&
            point.Y <= position.Y + size.Y
        );
    }

    public static getGuiObjectsAtPosition(
        instance: Instance,
        point: Vector2,
    ): GuiObject[] {
        const root = this.findHighestAncestorOfClass<Frame>(instance, "Frame");

        if (root === undefined) {
            return [];
        }

        const results = new Array<GuiObject>();

        for (const descendant of root.GetDescendants()) {
            if (
                descendant.IsA("GuiObject") &&
                descendant.Visible &&
                this.isPointInsideGuiObject(descendant, point)
            ) {
                results.push(descendant);
            }
        }

        results.sort((a, b) => a.ZIndex > b.ZIndex);

        return results;
    }

    public static getGuiRenderOrder(instance: Instance): GuiObject[] {
        const result = new Array<GuiObject>();

        for (const surface of this.getRenderSurfaces(this.getGuiRoot(instance))) {
            this.appendGuiObjects(surface.root, result);
        }

        return result;
    }

    private static getGuiRoot(instance: Instance): GuiRoot {
        const surface = this.findHighestAncestorOfClass<LayerCollector>(instance, "LayerCollector");

        if (surface?.Parent !== undefined) {
            return surface.Parent;
        }

        if (RunService.IsRunning() && Players.LocalPlayer !== undefined) {
            return Players.LocalPlayer.WaitForChild("PlayerGui") as PlayerGui;
        }

        let root = instance;
        while (root.Parent !== undefined && root.Parent !== game) {
            root = root.Parent;
        }

        return root;
    }

    public static getRenderSurface(instance: Instance): LayerCollector | undefined {
        return instance.FindFirstAncestorWhichIsA("LayerCollector");
    }

    public static isGuiObjectHitAtPoint(
        guiObject: GuiObject,
        point: Vector2,
    ): boolean {
        if (!guiObject.Visible || !this.isPointInsideGuiObject(guiObject, point)) {
            return false;
        }

        let current = guiObject.Parent;

        while (current !== undefined) {
            if (current.IsA("LayerCollector")) {
                return current.Enabled && !current.IsA("SurfaceGuiBase");
            }

            if (current.IsA("GuiObject")) {
                if (!current.Visible) {
                    return false;
                }

                if (
                    (current.ClipsDescendants || current.IsA("CanvasGroup")) &&
                    !this.isPointInsideGuiObject(current, point)
                ) {
                    return false;
                }
            }

            current = current.Parent;
        }

        return false;
    }

    public static isRenderedAbove(a: GuiObject, b: GuiObject): boolean {
        if (a === b) {
            return false;
        }

        const surfaceA = this.getRenderSurface(a);
        const surfaceB = this.getRenderSurface(b);

        if (surfaceA !== surfaceB) {
            const orderA = surfaceA?.IsA("ScreenGui") ? surfaceA.DisplayOrder : 0;
            const orderB = surfaceB?.IsA("ScreenGui") ? surfaceB.DisplayOrder : 0;

            if (orderA !== orderB) {
                return orderA > orderB;
            }

            return this.isLaterInTree(surfaceA ?? a, surfaceB ?? b);
        }

        if (surfaceA?.ZIndexBehavior === Enum.ZIndexBehavior.Global && a.ZIndex !== b.ZIndex) {
            return a.ZIndex > b.ZIndex;
        }

        if (a.IsDescendantOf(b)) {
            return true;
        }

        if (b.IsDescendantOf(a)) {
            return false;
        }

        if (surfaceA?.ZIndexBehavior === Enum.ZIndexBehavior.Global) {
            return this.isLaterInTree(a, b);
        }

        const divergence = this.getDivergingAncestors(a, b);

        if (divergence === undefined) {
            return false;
        }

        const [branchA, branchB] = divergence;

        if (
            branchA.IsA("GuiObject") &&
            branchB.IsA("GuiObject") &&
            branchA.ZIndex !== branchB.ZIndex
        ) {
            return branchA.ZIndex > branchB.ZIndex;
        }

        return this.getChildIndex(branchA) > this.getChildIndex(branchB);
    }

    private static isLaterInTree(a: Instance, b: Instance): boolean {
        const divergence = this.getDivergingAncestors(a, b);

        if (divergence === undefined) {
            return false;
        }

        return this.getChildIndex(divergence[0]) > this.getChildIndex(divergence[1]);
    }

    private static getDivergingAncestors(
        a: Instance,
        b: Instance,
    ): [Instance, Instance] | undefined {
        const branchByAncestor = new Map<Instance, Instance>();
        let previous: Instance = a;
        let current: Instance | undefined = a.Parent;

        while (current !== undefined) {
            branchByAncestor.set(current, previous);
            previous = current;
            current = current.Parent;
        }

        previous = b;
        current = b.Parent;

        while (current !== undefined) {
            const branchA = branchByAncestor.get(current);

            if (branchA !== undefined) {
                return [branchA, previous];
            }

            previous = current;
            current = current.Parent;
        }

        return undefined;
    }

    private static getChildIndex(instance: Instance): number {
        const parent = instance.Parent;

        if (parent === undefined) {
            return 0;
        }

        return parent.GetChildren().indexOf(instance);
    }

    private static getRenderSurfaces(root: GuiRoot): RenderSurface[] {
        const surfaces = new Array<RenderSurface>();

        const visit = (instance: Instance) => {
            const instanceChildren = instance.GetChildren();
            for (let index = 0; index < instanceChildren.size(); index++) {
                const child = instanceChildren[index];
                if (child.IsA("LayerCollector")) {
                    surfaces.push({
                        root: child,
                        rootIndex: index,
                    });

                    continue;
                }

                visit(child);
            }
        };

        visit(root);

        surfaces.sort((a, b) => {
            if (a.root.IsA("ScreenGui") && b.root.IsA("ScreenGui")) {
                if (a.root.DisplayOrder !== b.root.DisplayOrder) {
                    return a.root.DisplayOrder < b.root.DisplayOrder;
                }
            }

            return a.rootIndex < b.rootIndex;
        });

        return surfaces;
    }

    private static appendGuiObjects(
        parent: Instance,
        result: GuiObject[],
    ): void {
        const children = new Array<IndexedGuiObject>();

        const parentChildren = parent.GetChildren();
        for (let index = 0; index < parentChildren.size(); index++) {
            const child = parentChildren[index];
            if (!child.IsA("GuiObject")) {
                continue;
            }

            children.push({
                object: child,
                siblingIndex: index,
            });
        }

        children.sort((a, b) => {
            if (a.object.ZIndex !== b.object.ZIndex) {
                return a.object.ZIndex < b.object.ZIndex;
            }

            return a.siblingIndex < b.siblingIndex;
        });

        for (const child of children) {
            result.push(child.object);
            this.appendGuiObjects(child.object, result);
        }
    }

}