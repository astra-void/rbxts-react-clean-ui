import React from "@rbxts/react";
import { Boolean, Slider } from "@rbxts/ui-labs";
import { Box, Container, createStory, Text, VStack } from "@rbxts/react-clean-ui";
import FadeGroup from "./FadeGroup";

export = createStory(
	(props) => (
		<Container center>
			<Box>
				<VStack>
					<Container LayoutOrder={0}>
						<Text text="FadeGroup Inventory Slots" variant="heading" />
					</Container>
					<Container LayoutOrder={1}>
						<Text text="Middle slot: GroupTransparency. Right slot: grey GroupColor3 disabled tint." />
					</Container>
					<Container LayoutOrder={2}>
						<FadeGroup transparency={props.controls.Transparency} disabled={props.controls.Disabled} />
					</Container>
				</VStack>
			</Box>
		</Container>
	),
	{
		Transparency: Slider(0.5, 0, 1, 0.05),
		Disabled: Boolean(true),
	},
);
