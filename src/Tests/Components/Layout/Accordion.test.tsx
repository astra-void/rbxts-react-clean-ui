import React from "@rbxts/react";
import { Test, Assert, Decorators, Runtime, Tag, DisplayName } from "@rbxts/lunit";

const { Skip, Each } = Decorators;
import { Accordion } from "../../../Components/Layout/Accordion";
import { activateButton } from "../../Helpers/fiber";
import {
	STUDIO_SKIP_MESSAGE,
	assertAllDescendantsContained,
	assertContained,
	assertNonZeroSize,
	assertSizeApprox,
	assertStackedVertically,
	findDescendant,
	rect,
	waitForGuiObject,
	waitForLayout,
	withMounted,
} from "../../Helpers/layout";

const HOST_WIDTH = 400;
const HOST_HEIGHT = 400;

function accordion(props: { defaultValue?: string; value?: string } = {}) {
	return (
		<Accordion defaultValue={props.defaultValue} value={props.value} animationDuration={0}>
			<Accordion.Item value="one">
				<Accordion.Header text="Section one" />
				<Accordion.Content text="Content for section one." />
			</Accordion.Item>
			<Accordion.Item value="two">
				<Accordion.Header text="Section two" />
				<Accordion.Content text="Content for section two." />
			</Accordion.Item>
		</Accordion>
	);
}

const counterState: { increment?: () => void } = {};

function Counter() {
	const [count, setCount] = React.useState(0);
	counterState.increment = () => setCount((previous) => previous + 1);
	return (
		<textlabel key="CounterText" Text={`${count}`} Size={UDim2.fromOffset(100, 20)} BackgroundTransparency={1} />
	);
}

interface OptionsFixtureProps {
	defaultValue?: string;
	value?: string;
	autoSize?: boolean;
	keepMounted?: boolean;
	collapsible?: boolean;
	animationDuration?: number;
}

function optionsAccordion(props: OptionsFixtureProps) {
	return (
		<Accordion
			defaultValue={props.defaultValue}
			value={props.value}
			autoSize={props.autoSize}
			keepMounted={props.keepMounted}
			collapsible={props.collapsible}
			animationDuration={props.animationDuration ?? 0}
		>
			<Accordion.Item value="one">
				<Accordion.Header text="Section one" />
				<Accordion.Content>
					<Counter />
				</Accordion.Content>
			</Accordion.Item>
			<Accordion.Item value="two">
				<Accordion.Header text="Section two" />
				<Accordion.Content text="Content for section two." />
			</Accordion.Item>
		</Accordion>
	);
}

function multipleAccordion(defaultValue: string[], onValueChange?: (value: string[]) => void) {
	return (
		<Accordion multiple={true} defaultValue={defaultValue} onValueChange={onValueChange} animationDuration={0}>
			<Accordion.Item value="one">
				<Accordion.Header text="Section one" />
				<Accordion.Content text="Content for section one." />
			</Accordion.Item>
			<Accordion.Item value="two">
				<Accordion.Header text="Section two" />
				<Accordion.Content text="Content for section two." />
			</Accordion.Item>
		</Accordion>
	);
}

function waitForAccordion(host: Instance): ImageLabel {
	return waitForGuiObject<ImageLabel>(host, "Accordion");
}

function findItem(root: Instance, value: string): ImageLabel {
	return findDescendant<ImageLabel>(root, `AccordionItem-${value}`);
}

function findHeader(root: Instance, value: string): GuiObject {
	return findDescendant<GuiObject>(root, `AccordionHeaderButton-${value}`);
}

function findHeaderButton(root: Instance, value: string): ImageButton {
	return findDescendant<ImageButton>(root, `AccordionHeaderButton-${value}`);
}

function waitForOpenClip(item: Instance, value: string): Frame {
	return waitForGuiObject<Frame>(
		item,
		"ContentClip",
		(clip) => clip.Visible && clip.AbsoluteSize.Y > 0,
		`Timed out waiting for item "${value}" to show a visible ContentClip with a non-zero height`,
	);
}

function waitForClipMatchingContent(item: Instance, value: string, frames: number): Frame {
	for (let frame = 0; frame < frames; frame++) {
		const clip = item.FindFirstChild("ContentClip", true) as Frame | undefined;
		const content = clip?.FindFirstChild("Content") as Frame | undefined;
		if (
			clip !== undefined &&
			content !== undefined &&
			clip.Visible &&
			content.AbsoluteSize.Y > 0 &&
			math.abs(clip.AbsoluteSize.Y - content.AbsoluteSize.Y) <= 1
		) {
			return clip;
		}
		task.wait();
	}

	const clip = item.FindFirstChild("ContentClip", true) as Frame | undefined;
	const content = clip?.FindFirstChild("Content") as Frame | undefined;
	return Assert.fail(
		`Timed out waiting for item "${value}" ContentClip to reach its Content height (clip=${clip?.AbsoluteSize.Y}, content=${content?.AbsoluteSize.Y})`,
	);
}

function assertClipCollapsed(item: Instance, value: string) {
	const clip = waitForLayout(() => {
		const found = item.FindFirstChild("ContentClip", true) as Frame | undefined;
		return found !== undefined && !found.Visible && found.Size.Y.Scale === 0 && found.Size.Y.Offset === 0
			? found
			: undefined;
	}, `Timed out waiting for item "${value}" to keep a hidden, zero-height ContentClip`);
	Assert.notUndefined(
		clip.FindFirstChild("Content"),
		`Expected item "${value}" collapsed ContentClip to keep its Content`,
	);
}

function assertContentUnmounted(item: Instance, value: string) {
	Assert.true(
		item.FindFirstChild("ContentClip", true) === undefined,
		`Expected the closed item "${value}" to have no mounted ContentClip`,
	);
}

@Tag("Studio")
class AccordionMountValidation {
	@Skip(!Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	@Each([
		["one", "two"],
		["two", "one"],
	])
	@DisplayName(
		"defaultValue expands that item's content to a visible height and leaves the other item's content unmounted",
	)
	@Test
	public defaultValueExpandsItem(openValue: string, closedValue: string) {
		withMounted(HOST_WIDTH, HOST_HEIGHT, accordion({ defaultValue: openValue }), (mounted) => {
			const root = waitForAccordion(mounted.host);
			const openItem = findItem(root, openValue);
			const closedItem = findItem(root, closedValue);

			const clip = waitForGuiObject<Frame>(openItem, "ContentClip");
			const contentText = findDescendant<TextLabel>(clip, "AccordionContentText");

			assertNonZeroSize(clip, `open item ${openValue}`);
			assertContained(contentText, clip, `open item ${openValue}`);
			assertContained(clip, root, `open item ${openValue}`);
			assertContentUnmounted(closedItem, closedValue);
		});
	}

	@Skip(!Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	@DisplayName("Headers and the expanded content are stacked top-to-bottom in item order")
	@Test
	public itemsStackVertically() {
		withMounted(HOST_WIDTH, HOST_HEIGHT, accordion({ defaultValue: "one" }), (mounted) => {
			const root = waitForAccordion(mounted.host);
			const clip = waitForGuiObject<Frame>(findItem(root, "one"), "ContentClip");
			const headerOne = findHeader(root, "one");
			const headerTwo = findHeader(root, "two");

			assertStackedVertically([headerOne, clip, headerTwo], "accordion items");
		});
	}

	@Skip(!Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	@DisplayName("Switching a controlled value from one to two unmounts item one's content and expands item two")
	@Test
	public controlledValueSwitches() {
		withMounted(HOST_WIDTH, HOST_HEIGHT, accordion({ value: "one" }), (mounted) => {
			const root = waitForAccordion(mounted.host);
			const itemOne = findItem(root, "one");
			const itemTwo = findItem(root, "two");
			waitForGuiObject<Frame>(itemOne, "ContentClip");
			assertContentUnmounted(itemTwo, "two");

			mounted.update(accordion({ value: "two" }));

			waitForLayout(
				() => (itemOne.FindFirstChild("ContentClip", true) === undefined ? true : undefined),
				"Timed out waiting for item one's ContentClip to be unmounted after the controlled value moved to two",
			);
			const clipTwo = waitForGuiObject<Frame>(itemTwo, "ContentClip");

			assertNonZeroSize(clipTwo, "item two after value switch");
			assertContained(clipTwo, root, "item two after value switch");
		});
	}

	@Skip(!Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	@DisplayName("With one item expanded, every visible descendant stays inside the Accordion")
	@Test
	public allContained() {
		withMounted(HOST_WIDTH, HOST_HEIGHT, accordion({ defaultValue: "one" }), (mounted) => {
			const root = waitForAccordion(mounted.host);
			waitForGuiObject<Frame>(findItem(root, "one"), "ContentClip");

			assertAllDescendantsContained(root, "expanded accordion");
		});
	}

	@Skip(!Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	@DisplayName("With keepMounted a closed item still has its ContentClip and Content, hidden at zero height")
	@Test
	public keepMountedClosed() {
		withMounted(
			HOST_WIDTH,
			HOST_HEIGHT,
			optionsAccordion({ defaultValue: "two", keepMounted: true }),
			(mounted) => {
				const root = waitForAccordion(mounted.host);
				waitForOpenClip(findItem(root, "two"), "two");

				assertClipCollapsed(findItem(root, "one"), "one");
			},
		);
	}

	@Skip(!Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	@DisplayName(
		"With keepMounted a stateful child keeps its instance and state across close and reopen, at full height again",
	)
	@Test
	public keepMountedKeepsState() {
		withMounted(HOST_WIDTH, HOST_HEIGHT, optionsAccordion({ value: "one", keepMounted: true }), (mounted) => {
			const root = waitForAccordion(mounted.host);
			const itemOne = findItem(root, "one");
			waitForOpenClip(itemOne, "one");
			const label = findDescendant<TextLabel>(itemOne, "CounterText");

			counterState.increment!();
			waitForLayout(
				() => (label.Text === "1" ? true : undefined),
				"Timed out waiting for the counter to reach 1",
			);

			mounted.update(optionsAccordion({ value: "two", keepMounted: true }));
			assertClipCollapsed(itemOne, "one");

			mounted.update(optionsAccordion({ value: "one", keepMounted: true }));
			waitForClipMatchingContent(itemOne, "one", 30);

			const reopened = findDescendant<TextLabel>(itemOne, "CounterText");
			Assert.equal(reopened, label, "Expected the reopened item to reuse the same CounterText instance");
			Assert.equal(reopened.Text, "1");
		});
	}

	@Skip(!Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	@DisplayName("Without keepMounted closing an item unmounts its content, so reopening starts the counter from 0")
	@Test
	public defaultResetsState() {
		withMounted(HOST_WIDTH, HOST_HEIGHT, optionsAccordion({ value: "one" }), (mounted) => {
			const root = waitForAccordion(mounted.host);
			const itemOne = findItem(root, "one");
			waitForOpenClip(itemOne, "one");
			const label = findDescendant<TextLabel>(itemOne, "CounterText");

			counterState.increment!();
			waitForLayout(
				() => (label.Text === "1" ? true : undefined),
				"Timed out waiting for the counter to reach 1",
			);

			mounted.update(optionsAccordion({ value: "two" }));
			waitForLayout(
				() => (itemOne.FindFirstChild("ContentClip", true) === undefined ? true : undefined),
				"Timed out waiting for item one's ContentClip to unmount",
			);

			mounted.update(optionsAccordion({ value: "one" }));
			waitForOpenClip(itemOne, "one");

			Assert.equal(findDescendant<TextLabel>(itemOne, "CounterText").Text, "0");
		});
	}

	@Skip(!Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	@DisplayName("Without autoSize the Accordion fills the host's height even when every item is closed")
	@Test
	public fillsHostHeight() {
		withMounted(HOST_WIDTH, HOST_HEIGHT, optionsAccordion({}), (mounted) => {
			const root = waitForAccordion(mounted.host);

			assertSizeApprox(root, HOST_WIDTH, HOST_HEIGHT, 1, "accordion without autoSize");
		});
	}

	@Skip(!Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	@DisplayName(
		"With autoSize the Accordion is shorter than a tall host, fills its width, and grows when a section opens",
	)
	@Test
	public autoSizeGrows() {
		withMounted(HOST_WIDTH, HOST_HEIGHT, optionsAccordion({ autoSize: true }), (mounted) => {
			const root = waitForAccordion(mounted.host);
			const closedHeight = waitForLayout(
				() => (rect(root).height > 0 && rect(root).height < HOST_HEIGHT ? rect(root).height : undefined),
				`Timed out waiting for the autoSize Accordion to be shorter than the host (height ${rect(root).height})`,
			);
			assertSizeApprox(root, HOST_WIDTH, undefined, 1, "autoSize accordion width");

			activateButton(mounted, findHeaderButton(root, "two"));
			const clip = waitForOpenClip(findItem(root, "two"), "two");

			waitForLayout(
				() => (rect(root).height >= closedHeight + rect(clip).height - 1 ? true : undefined),
				`Timed out waiting for the autoSize Accordion to grow by the opened content (closed ${closedHeight}, now ${rect(root).height}, clip ${rect(clip).height})`,
			);
			Assert.true(
				rect(root).height < HOST_HEIGHT,
				"Expected the opened autoSize Accordion to stay shorter than the host",
			);
		});
	}

	@Skip(!Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	@DisplayName("In multiple mode a defaultValue listing two items opens both at once")
	@Test
	public multipleDefaultOpen() {
		withMounted(HOST_WIDTH, HOST_HEIGHT, multipleAccordion(["one", "two"]), (mounted) => {
			const root = waitForAccordion(mounted.host);

			assertNonZeroSize(waitForOpenClip(findItem(root, "one"), "one"), "multiple item one");
			assertNonZeroSize(waitForOpenClip(findItem(root, "two"), "two"), "multiple item two");
		});
	}

	@Skip(!Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	@DisplayName("In multiple mode clicking an open header closes only that item and reports the remaining open values")
	@Test
	public multipleClosesOne() {
		const reported: string[][] = [];

		withMounted(
			HOST_WIDTH,
			HOST_HEIGHT,
			multipleAccordion(["one", "two"], (value) => reported.push(value)),
			(mounted) => {
				const root = waitForAccordion(mounted.host);
				const itemOne = findItem(root, "one");
				const itemTwo = findItem(root, "two");
				waitForOpenClip(itemOne, "one");
				waitForOpenClip(itemTwo, "two");

				activateButton(mounted, findHeaderButton(root, "one"));

				waitForLayout(
					() => (itemOne.FindFirstChild("ContentClip", true) === undefined ? true : undefined),
					"Timed out waiting for item one's ContentClip to unmount after clicking its header",
				);
				Assert.deepEqual(reported, [["two"]]);
				assertNonZeroSize(waitForOpenClip(itemTwo, "two"), "multiple item two after closing one");
			},
		);
	}

	@Skip(!Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	@DisplayName("In multiple mode clicking a closed header opens it alongside the already open item")
	@Test
	public multipleOpensAnother() {
		const reported: string[][] = [];

		withMounted(
			HOST_WIDTH,
			HOST_HEIGHT,
			multipleAccordion(["one"], (value) => reported.push(value)),
			(mounted) => {
				const root = waitForAccordion(mounted.host);
				const itemOne = findItem(root, "one");
				waitForOpenClip(itemOne, "one");
				assertContentUnmounted(findItem(root, "two"), "two");

				activateButton(mounted, findHeaderButton(root, "two"));

				waitForOpenClip(findItem(root, "two"), "two");
				assertNonZeroSize(waitForOpenClip(itemOne, "one"), "multiple item one after opening two");
				Assert.deepEqual(reported, [["one", "two"]]);
			},
		);
	}

	@Skip(!Runtime.isRoblox(), STUDIO_SKIP_MESSAGE)
	@DisplayName(
		"Reopening a section while it is still animating closed tweens its ContentClip back to the full content height",
	)
	@Test
	public reopenWhileClosing() {
		withMounted(
			HOST_WIDTH,
			HOST_HEIGHT,
			optionsAccordion({ defaultValue: "two", collapsible: true, animationDuration: 0.5 }),
			(mounted) => {
				const root = waitForAccordion(mounted.host);
				const itemTwo = findItem(root, "two");
				waitForClipMatchingContent(itemTwo, "two", 120);

				activateButton(mounted, findHeaderButton(root, "two"));
				task.wait();

				const closing = itemTwo.FindFirstChild("ContentClip", true) as Frame | undefined;
				Assert.notUndefined(
					closing,
					"Expected item two's ContentClip to still be mounted while animating closed",
				);

				activateButton(mounted, findHeaderButton(root, "two"));

				waitForClipMatchingContent(itemTwo, "two", 120);
			},
		);
	}
}

export = AccordionMountValidation;
