import React, { useEffect, useRef, useState } from "@rbxts/react";
import ReactRoblox from "@rbxts/react-roblox";
import {
	Box,
	CleanThemeContext,
	Container,
	Corners,
	Draggable,
	DragEventInfo,
	Droppable,
	HStack,
	Icon,
	IconName,
	Text,
	ThemeProvider,
	Tooltip,
	VStack,
} from "@rbxts/react-clean-ui";
import { ScreenshotFrame } from "../ScreenshotFrame";

type Location = "shelf" | "basket";

interface DemoItem {
	name: string;
	icon: IconName;
	qty: number;
	nativeHandle?: boolean;
}

type Stock = Record<Location, DemoItem[]>;

const INITIAL_STOCK: Stock = {
	shelf: [
		{ name: "Apple", icon: "apple", qty: 4 },
		{ name: "Bathtub", icon: "bath", qty: 1 },
		{ name: "Automobile", icon: "automobile", qty: 2, nativeHandle: true },
	],
	basket: [],
};

const LOCATION_LABELS: Record<Location, string> = {
	shelf: "Shelf",
	basket: "Basket",
};

function parseId(id?: string): [Location, string] | undefined {
	if (id === undefined) return undefined;
	const [location, name] = id.split(":");
	if ((location !== "shelf" && location !== "basket") || name === undefined) return undefined;
	return [location, name];
}

function describeInput(info?: DragEventInfo): string {
	if (info?.inputType === Enum.UserInputType.MouseButton2) return "right-drag: split";
	if (info?.inputType === Enum.UserInputType.Touch) return "touch: move";
	return "left-drag: move";
}

function transfer(stock: Stock, from: Location, to: Location, name: string, split: boolean): Stock {
	const source = stock[from].find((item) => item.name === name);
	if (from === to || source === undefined) return stock;

	const amount = split ? math.max(1, math.floor(source.qty / 2)) : source.qty;
	const remaining = source.qty - amount;

	const fromItems =
		remaining > 0
			? stock[from].map((item) => (item.name === name ? { ...item, qty: remaining } : item))
			: stock[from].filter((item) => item.name !== name);

	const existing = stock[to].find((item) => item.name === name);
	const toItems =
		existing !== undefined
			? stock[to].map((item) => (item.name === name ? { ...item, qty: item.qty + amount } : item))
			: [...stock[to], { ...source, qty: amount }];

	return { ...stock, [from]: fromItems, [to]: toItems } as Stock;
}

interface RemoteBinProps {
	onDrop: (draggedObject: GuiObject, info?: DragEventInfo) => void;
	onDragEnter: () => void;
	onDragLeave: () => void;
}

function RemoteBin(props: RemoteBinProps) {
	const [hovered, setHovered] = useState(false);

	return (
		<Droppable
			id="remote"
			onDrop={props.onDrop}
			onDragEnter={() => {
				setHovered(true);
				props.onDragEnter();
			}}
			onDragLeave={() => {
				setHovered(false);
				props.onDragLeave();
			}}
		>
			<DropSurface key="RemoteBin" hovered={hovered} Size={UDim2.fromScale(1, 1)}>
				<uilistlayout
					key="Center"
					HorizontalAlignment={Enum.HorizontalAlignment.Center}
					VerticalAlignment={Enum.VerticalAlignment.Center}
				/>
				<Text text={hovered ? "Release to drop (separate React root)" : "Separate React root"} />
			</DropSurface>
		</Droppable>
	);
}

interface SurfaceProps extends React.InstanceProps<Frame> {
	children?: React.ReactNode;
}

// Row surface for list items: uses the theme's table tokens rather than Box, whose themed panel art and
// padding (e.g. Wooden) are sized for whole panels, not 40px rows.
function ItemSurface(props: SurfaceProps) {
	const theme = React.useContext(CleanThemeContext);
	const tokens = theme.components.table;

	return (
		<frame
			key="ItemSurface"
			Size={UDim2.fromScale(1, 1)}
			BackgroundColor3={tokens.backgroundColor}
			BackgroundTransparency={tokens.backgroundTransparency}
			BorderSizePixel={0}
			{...props}
		>
			<uistroke
				key="Stroke"
				Thickness={tokens.borderThickness}
				BorderStrokePosition={Enum.BorderStrokePosition.Inner}
				Color={tokens.borderColor}
			/>
			<Corners radius={tokens.cornerRadius} />
			<uipadding key="Padding" PaddingLeft={new UDim(0, 8)} PaddingRight={new UDim(0, 8)} />
			{props.children}
		</frame>
	);
}

// Drop target surface: uses the theme's draggable placeholder tokens and outlines in the success colour on hover.
interface DropSurfaceProps {
	hovered: boolean;
	Position?: UDim2;
	Size?: UDim2;
	ZIndex?: number;
	children?: React.ReactNode;
}

function DropSurface(props: DropSurfaceProps) {
	const theme = React.useContext(CleanThemeContext);
	const placeholder = theme.components.draggable.placeholder;
	const hovered = props.hovered;

	return (
		<frame
			BackgroundColor3={placeholder.backgroundColor}
			BackgroundTransparency={placeholder.backgroundTransparency}
			BorderSizePixel={0}
			Position={props.Position}
			Size={props.Size}
			ZIndex={props.ZIndex}
		>
			<uistroke
				key="Stroke"
				Thickness={hovered ? math.max(2, placeholder.borderThickness) : placeholder.borderThickness}
				BorderStrokePosition={Enum.BorderStrokePosition.Inner}
				Color={hovered ? theme.colors.intents.success.default.borderColor : placeholder.borderColor}
			/>
			<Corners radius={placeholder.cornerRadius} />
			{props.children}
		</frame>
	);
}

interface DragAndDropProps {
	screenshot?: boolean;
	customPreview?: boolean;
	rightDrag?: boolean;
	placeholder?: boolean;
}

function DragAndDrop(props: DragAndDropProps) {
	const theme = React.useContext(CleanThemeContext);
	const primary = theme.colors.intents.primary.default;
	const info = theme.colors.intents.info.default;
	const success = theme.colors.intents.success.default;
	const panelImage = theme.components.box.backgroundImage;

	const [stock, setStock] = useState<Stock>(INITIAL_STOCK);
	const [hovered, setHovered] = useState<string>();
	const [drops, setDrops] = useState(0);
	const [enters, setEnters] = useState(0);
	const [leaves, setLeaves] = useState(0);
	const [log, setLog] = useState<string[]>(["Drag an item onto a target"]);

	const remoteHostRef = useRef<Frame>();
	const remoteRootRef = useRef<ReactRoblox.Root>();

	const inputTypes =
		props.rightDrag === false
			? [Enum.UserInputType.MouseButton1, Enum.UserInputType.Touch]
			: [Enum.UserInputType.MouseButton1, Enum.UserInputType.MouseButton2, Enum.UserInputType.Touch];

	const pushLog = (line: string) => {
		setLog((previous) => {
			const lines = [line, ...previous];
			while (lines.size() > 3) lines.pop();
			return lines;
		});
	};

	const enter = (id: string) => {
		setHovered(id);
		setEnters((count) => count + 1);
	};

	const leave = (id: string) => {
		setHovered((current) => (current === id ? undefined : current));
		setLeaves((count) => count + 1);
	};

	const recordDrop = (target: string, dragInfo?: DragEventInfo) => {
		const parsed = parseId(dragInfo?.id);
		setDrops((count) => count + 1);
		pushLog(`${parsed?.[1] ?? "Item"} -> ${target} (${describeInput(dragInfo)})`);
	};

	const dropOnList = (location: Location) => (_: GuiObject, dragInfo?: DragEventInfo) => {
		const parsed = parseId(dragInfo?.id);
		recordDrop(LOCATION_LABELS[location], dragInfo);
		if (parsed === undefined) return;
		const split = dragInfo?.inputType === Enum.UserInputType.MouseButton2;
		setStock((current) => transfer(current, parsed[0], location, parsed[1], split));
	};

	useEffect(() => {
		const host = remoteHostRef.current;
		if (host === undefined) return;

		const root = ReactRoblox.createRoot(host);
		remoteRootRef.current = root;

		return () => {
			remoteRootRef.current = undefined;
			root.unmount();
		};
	}, []);

	useEffect(() => {
		// A separate root does not inherit context, so hand it the current theme explicitly.
		remoteRootRef.current?.render(
			<ThemeProvider theme={theme}>
				<RemoteBin
					onDrop={(_, dragInfo) => recordDrop("Separate root", dragInfo)}
					onDragEnter={() => enter("remote")}
					onDragLeave={() => leave("remote")}
				/>
			</ThemeProvider>,
		);
	});

	const renderItem = (location: Location, item: DemoItem, index: number) => {
		const label = `${item.name} x${item.qty}`;

		const row = item.nativeHandle ? (
			<ItemSurface>
				<HStack valign="Center" Wraps={false}>
					<Draggable.Handle>
						<frame
							key="Grip"
							Size={UDim2.fromOffset(20, 20)}
							BackgroundColor3={theme.components.draggable.placeholder.backgroundColor}
							BorderSizePixel={0}
							LayoutOrder={1}
						>
							<uicorner key="Corner" CornerRadius={new UDim(0, 4)} />
							<textlabel
								key="GripLabel"
								Size={UDim2.fromScale(1, 1)}
								BackgroundTransparency={1}
								Font={Enum.Font.GothamBold}
								TextSize={14}
								TextColor3={primary.textColor}
								Text="::"
							/>
						</frame>
					</Draggable.Handle>
					<Icon icon={item.icon} LayoutOrder={2} />
					<Text text={label} TextWrapped={false} LayoutOrder={3} />
				</HStack>
			</ItemSurface>
		) : (
			<Draggable.Handle>
				<Container width="100%" height="100%">
					<Tooltip content={`${item.name}: drag me, the preview never shows this`}>
						<ItemSurface>
							<HStack valign="Center" Wraps={false}>
								<Icon icon={item.icon} LayoutOrder={1} />
								<Text text={label} TextWrapped={false} LayoutOrder={2} />
							</HStack>
						</ItemSurface>
					</Tooltip>
				</Container>
			</Draggable.Handle>
		);

		return (
			<Draggable
				id={`${location}:${item.name}`}
				inputTypes={inputTypes}
				placeholder={props.placeholder}
				renderOverlay={
					props.customPreview
						? () => (
								<Box
									box-shadow="0"
									BackgroundColor3={info.backgroundColor}
									BackgroundTransparency={0.2}
								>
									<HStack valign="Center">
										<Icon icon={item.icon} LayoutOrder={1} />
										<Text
											text={`Moving ${item.name}`}
											TextColor3={info.textColor}
											LayoutOrder={2}
										/>
									</HStack>
								</Box>
							)
						: undefined
				}
				onDropped={(droppable, dragInfo) => {
					if (droppable === undefined) {
						pushLog(`${item.name} released outside: snapped back (${describeInput(dragInfo)})`);
					}
				}}
			>
				<Container width="100%" height="40" LayoutOrder={index}>
					{row}
				</Container>
			</Draggable>
		);
	};

	const renderList = (location: Location) => (
		<Droppable
			id={location}
			onDrop={dropOnList(location)}
			onDragEnter={() => enter(location)}
			onDragLeave={() => leave(location)}
		>
			<Container width="250" height="420" LayoutOrder={location === "shelf" ? 1 : 2}>
				<Box
					box-shadow="0"
					background-image={
						hovered === location && panelImage !== undefined && panelImage.image !== ""
							? { ...panelImage, tintColor: success.backgroundColor }
							: undefined
					}
					border-thickness={hovered === location && panelImage === undefined ? 2 : undefined}
					border-color={hovered === location ? success.borderColor : undefined}
				>
					<VStack>
						<Text text={LOCATION_LABELS[location]} variant="heading" LayoutOrder={0} />
						{stock[location].map((item, index) => renderItem(location, item, index + 1))}
					</VStack>
				</Box>
			</Container>
		</Droppable>
	);

	const renderZone = (id: string, label: string, position: UDim2, zIndex: number) => (
		<Droppable
			id={id}
			onDrop={(_, dragInfo) => recordDrop(label, dragInfo)}
			onDragEnter={() => enter(id)}
			onDragLeave={() => leave(id)}
		>
			<DropSurface
				key={label}
				hovered={hovered === id}
				Position={position}
				Size={UDim2.fromOffset(170, 90)}
				ZIndex={zIndex}
			>
				<uipadding key="Padding" PaddingTop={new UDim(0, 6)} PaddingLeft={new UDim(0, 8)} />
				<Text text={label} />
			</DropSurface>
		</Droppable>
	);

	const content = (
		<Container width="800" height="420">
			<HStack Wraps={false}>
				{renderList("shelf")}
				{renderList("basket")}
				<Container width="280" height="420" LayoutOrder={3}>
					<VStack>
						<frame
							key="Overlap"
							Size={UDim2.fromOffset(280, 140)}
							BackgroundTransparency={1}
							LayoutOrder={1}
						>
							{renderZone("lower", "Lower zone", UDim2.fromOffset(0, 0), 1)}
							{renderZone("upper", "Upper zone (on top)", UDim2.fromOffset(100, 45), 2)}
						</frame>
						<frame
							key="RemoteHost"
							ref={remoteHostRef}
							Size={UDim2.fromOffset(280, 70)}
							BackgroundTransparency={1}
							LayoutOrder={2}
						/>
						<Container width="280" height="190" LayoutOrder={3}>
							<Box box-shadow="0" ClipsDescendants>
								<VStack>
									<Text
										text={`Drops: ${drops}  Enter: ${enters}  Leave: ${leaves}`}
										variant="label"
										LayoutOrder={0}
									/>
									{log.map((line, index) => (
										<Text
											text={line}
											variant="label"
											TextWrapped
											Size={UDim2.fromScale(1, 0)}
											AutomaticSize={Enum.AutomaticSize.Y}
											LayoutOrder={index + 1}
										/>
									))}
								</VStack>
							</Box>
						</Container>
					</VStack>
				</Container>
			</HStack>
		</Container>
	);

	return props.screenshot ? <ScreenshotFrame>{content}</ScreenshotFrame> : content;
}

export = DragAndDrop;
