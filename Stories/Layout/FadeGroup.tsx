import React from "@rbxts/react";
import {
	Box,
	Container,
	FadeGroup as FadeGroupComponent,
	HStack,
	Icon,
	IconName,
	Text,
	VStack,
} from "@rbxts/react-clean-ui";
import { ScreenshotFrame } from "../ScreenshotFrame";

interface FadeGroupProps {
	screenshot?: boolean;
	transparency?: number;
	disabled?: boolean;
}

const DISABLED_TINT = Color3.fromRGB(110, 110, 110);

function Slot(props: {
	name: string;
	icon: IconName;
	label: string;
	LayoutOrder: number;
	transparency?: number;
	tint?: Color3;
}) {
	return (
		<FadeGroupComponent
			name={props.name}
			LayoutOrder={props.LayoutOrder}
			width={96}
			height={112}
			GroupTransparency={props.transparency ?? 0}
			GroupColor3={props.tint}
		>
			<Box width="100%" height="100%">
				<VStack
					valign="Center"
					HorizontalAlignment={Enum.HorizontalAlignment.Center}
					HorizontalFlex={Enum.UIFlexAlignment.None}
					spacing="sm"
				>
					<Icon icon={props.icon} scale="xl" LayoutOrder={0} />
					<Text text={props.label} align="Center" weight="bold" TextWrap={false} LayoutOrder={1} />
				</VStack>
			</Box>
		</FadeGroupComponent>
	);
}

function FadeGroup(props: FadeGroupProps = {}) {
	const disabled = props.disabled ?? true;

	const content = (
		<Container>
			<HStack spacing="md" Wraps={false}>
				<Slot name="NormalSlot" LayoutOrder={0} icon="leaf" label="Herb" />
				<Slot
					name="FadedSlot"
					LayoutOrder={1}
					icon="database"
					label="Ore"
					transparency={props.transparency ?? 0.5}
				/>
				<Slot
					name="DisabledSlot"
					LayoutOrder={2}
					icon="shopping-bag"
					label="Locked"
					tint={disabled ? DISABLED_TINT : undefined}
				/>
			</HStack>
		</Container>
	);

	return props.screenshot ? <ScreenshotFrame>{content}</ScreenshotFrame> : content;
}

export = FadeGroup;
