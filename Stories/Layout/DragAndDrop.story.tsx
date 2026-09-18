import React from "@rbxts/react";
import { Boolean } from "@rbxts/ui-labs";
import { Container, createStory, Text, VStack } from "@rbxts/react-clean-ui";
import DragAndDrop from "./DragAndDrop";

export = createStory(
	(props) => (
		<Container center>
			<VStack>
				<Text
					text="Hover an item for its tooltip, drag it between lists, onto the overlapping zones or the separate-root target. Right-drag splits a stack; release outside any target to snap back."
					variant="label"
					TextWrapped
					Size={UDim2.fromOffset(800, 0)}
					AutomaticSize={Enum.AutomaticSize.Y}
					LayoutOrder={1}
				/>
				<Container LayoutOrder={2}>
					<DragAndDrop
						customPreview={props.controls["Custom preview"]}
						rightDrag={props.controls["Right-drag split"]}
						placeholder={props.controls.Placeholder}
					/>
				</Container>
			</VStack>
		</Container>
	),
	{
		"Custom preview": Boolean(false),
		"Right-drag split": Boolean(true),
		Placeholder: Boolean(true),
	},
);
