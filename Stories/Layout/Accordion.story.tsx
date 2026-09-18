import React from "@rbxts/react";
import { Boolean } from "@rbxts/ui-labs";
import { Box, Container, createStory } from "@rbxts/react-clean-ui";
import Accordion from "./Accordion";

export = createStory(
	(props) => (
		<Container center>
			<Box>
				<Accordion
					collapsible={props.controls.Collapsible}
					multiple={props.controls.Multiple}
					autoSize={props.controls.AutoSize}
					keepMounted={props.controls.KeepMounted}
					animationDuration={props.controls.Animation ? undefined : 0}
				/>
			</Box>
		</Container>
	),
	{
		Collapsible: Boolean(false),
		Multiple: Boolean(false),
		AutoSize: Boolean(false),
		KeepMounted: Boolean(false),
		Animation: Boolean(true),
	},
);
