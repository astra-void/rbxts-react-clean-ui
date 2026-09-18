import React from "@rbxts/react";
type EventCallback = (...args: never[]) => void;
export declare class ElementHelper {
    static isHostElement(element: React.ReactElement): boolean;
    static getEventKey(name: string): unknown;
    static cloneWithEvents<P>(element: React.ReactElement<P>, props: Record<string, unknown>, events: Record<string, EventCallback>): React.ReactElement<P>;
}
export {};
