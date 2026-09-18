import React from "@rbxts/react";
import { IconName, PaddingProps, ScalableElementProps } from "../../Interfaces";
interface AccordionItemProps {
    children?: React.ReactNode;
    value: string;
    disabled?: boolean;
}
declare function AccordionItem(_props: AccordionItemProps): undefined;
interface AccordionHeaderProps extends PaddingProps {
    children?: React.ReactNode | string;
    icon?: IconName;
    text?: string;
}
declare function AccordionHeader(_props: AccordionHeaderProps): undefined;
interface AccordionContentProps extends PaddingProps {
    children?: React.ReactNode;
    text?: string;
}
declare function AccordionContent(_props: AccordionContentProps): undefined;
interface AccordionBaseProps extends ScalableElementProps {
    children?: React.ReactNode;
    collapsible?: boolean;
    animationDuration?: number;
    autoSize?: boolean;
    keepMounted?: boolean;
    name?: string;
}
export interface AccordionProps extends AccordionBaseProps {
    multiple?: false;
    defaultValue?: string;
    value?: string;
    onValueChange?: (value: string | undefined) => void;
}
export interface AccordionMultipleProps extends AccordionBaseProps {
    multiple: true;
    defaultValue?: string[];
    value?: string[];
    onValueChange?: (value: string[]) => void;
}
type AccordionComponent = React.ForwardRefExoticComponent<(AccordionProps | AccordionMultipleProps) & React.RefAttributes<ImageLabel>> & {
    Item: typeof AccordionItem;
    Header: typeof AccordionHeader;
    Content: typeof AccordionContent;
};
declare const Accordion: AccordionComponent;
export { Accordion };
