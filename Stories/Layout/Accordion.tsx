import React from "@rbxts/react";
import { Accordion as AccordionComponent, Button, Container, HStack, Icon, Text, VStack } from "@rbxts/react-clean-ui";
import { ScreenshotFrame } from "../ScreenshotFrame";

interface AccordionProps {
	screenshot?: boolean;
	collapsible?: boolean;
	multiple?: boolean;
	autoSize?: boolean;
	keepMounted?: boolean;
	animationDuration?: number;
}

function Counter(props: { LayoutOrder?: number }) {
	const [count, setCount] = React.useState(0);

	return (
		<Container name="Counter" LayoutOrder={props.LayoutOrder}>
			<HStack valign="Center">
				<Button
					name="CounterButton"
					text="Increment"
					LayoutOrder={0}
					Event={{ Activated: () => setCount((value) => value + 1) }}
				/>
				<Text name="CounterText" text={`Clicked ${count} times`} LayoutOrder={1} />
			</HStack>
		</Container>
	);
}

function renderItems() {
	return [
		<AccordionComponent.Item key="sections" value="sections">
			<AccordionComponent.Header text="How many sections can be open at once?" />
			<AccordionComponent.Content text="One by default. Toggle Collapsible to allow closing the open section entirely, or Multiple to let several sections stay open at the same time." />
		</AccordionComponent.Item>,
		<AccordionComponent.Item key="custom-header" value="custom-header">
			<AccordionComponent.Header>
				<HStack valign="Center">
					<Icon icon="info-circle" />
					<Text text="Can I put my own components in the header?" />
				</HStack>
			</AccordionComponent.Header>
			<AccordionComponent.Content text="Yes, pass any component as children to Accordion.Header instead of the text and icon props, such as the Text and Icon used to build this header." />
		</AccordionComponent.Item>,
		<AccordionComponent.Item key="content" value="content">
			<AccordionComponent.Header text="What kind of content can a section hold?" />
			<AccordionComponent.Content>
				<VStack>
					<Text
						text="Anything. Accordion.Content accepts arbitrary React children and resizes itself automatically to fit them, whether that's plain text or a composite layout like the row below."
						LayoutOrder={0}
					/>
					<Container name="IconRow" LayoutOrder={1}>
						<HStack valign="Center">
							<Icon icon="check" LayoutOrder={0} />
							<Text text="Icons, buttons, or other components all work here." LayoutOrder={1} />
						</HStack>
					</Container>
				</VStack>
			</AccordionComponent.Content>
		</AccordionComponent.Item>,
		<AccordionComponent.Item key="counter" value="counter">
			<AccordionComponent.Header text="Does content keep its state when closed?" />
			<AccordionComponent.Content>
				<VStack>
					<Text
						text="Only with keepMounted. Click the button, then close and reopen this section: the count resets by default, but survives with KeepMounted on."
						LayoutOrder={0}
					/>
					<Counter LayoutOrder={1} />
				</VStack>
			</AccordionComponent.Content>
		</AccordionComponent.Item>,
		<AccordionComponent.Item key="disabled" value="disabled" disabled>
			<AccordionComponent.Header text="Why is this section disabled?" />
			<AccordionComponent.Content text="Disabled items cannot be expanded, regardless of their content." />
		</AccordionComponent.Item>,
	];
}

function Accordion(props: AccordionProps = {}) {
	const content = (
		<Container width={400} height={380}>
			{props.multiple ? (
				<AccordionComponent
					multiple
					defaultValue={["sections", "counter"]}
					autoSize={props.autoSize}
					keepMounted={props.keepMounted}
					animationDuration={props.animationDuration}
				>
					{renderItems()}
				</AccordionComponent>
			) : (
				<AccordionComponent
					defaultValue="sections"
					collapsible={props.collapsible}
					autoSize={props.autoSize}
					keepMounted={props.keepMounted}
					animationDuration={props.animationDuration}
				>
					{renderItems()}
				</AccordionComponent>
			)}
		</Container>
	);

	return props.screenshot ? <ScreenshotFrame>{content}</ScreenshotFrame> : content;
}

export = Accordion;
