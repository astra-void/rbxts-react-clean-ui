import React from "@rbxts/react";
import { PositionElementProps, SizeElementProps, ZIndexElementProps } from "../../Interfaces/";
export interface FadeGroupProps extends SizeElementProps, PositionElementProps, ZIndexElementProps, React.InstanceProps<CanvasGroup> {
    name?: string;
}
export declare const FadeGroup: React.ForwardRefExoticComponent<Omit<FadeGroupProps, "ref"> & React.RefAttributes<CanvasGroup>>;
