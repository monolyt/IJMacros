# Signal Statistics per Channel

## Description

This ImageJ/Fiji macro automatically extracts **signal statistics** from multi-channel 3D fluorescence microscopy images located in **subfolders**. It computes per-slice signal metrics for selected Z-planes in each channel, minimizing background influence through automated thresholding and background subtraction.

Ideal for high-throughput quantification of signal intensity in multichannel imaging experiments.

## Setup

1. Save the macro file (`SignalStatsPerChannel.ijm`) in your Fiji `macros` directory or anywhere accessible.
2. Launch **Fiji** (version ≥ 1.54f recommended).
3. Run the macro (via *Plugins > Macros > Run...*).
4. When prompted, select the **root directory** containing your image subfolders.

> The macro assumes each subfolder contains a single image stack (TIFF format), which may be a multi-channel Z-stack.

## Process Workflow

1. For each subfolder:
   - Load the **first** `.tif` or `.tiff` stack using Bio-Formats.
   - Split into individual channels.
   - Select 3 Z-slices: at 30%, 50%, and 70% depth.
2. For each selected slice:
   - Apply **median filtering** and **rolling ball background subtraction**.
   - Generate a **foreground mask** using MaxEntropy thresholding.
   - Extract the ROI from the mask and measure the following statistics from the preprocessed image:
     - **Min, Max, Mean, Median, Standard Deviation**
3. Export results into a single CSV file:
   - Located in the root folder
   - Named `signal_statistics.csv`

## Output

Each row in the CSV contains:

Column | Description
---|---
`Folder` | Subfolder name
`Image` | Filename of the processed stack
`Channel` | Channel identifier (e.g., `C1`)
`Slice` | Z-plane index within the stack
`Min` | Minimum pixel intensity within the ROI
`Max` | Maximum pixel intensity within the ROI
`Mean` | Mean intensity inside the ROI
`Median` | Median intensity inside the ROI
`SD` | Standard deviation of intensity inside the ROI

## Limitations

- Only the **first TIFF file** per subfolder is processed.
- Assumes all image stacks are **multi-channel 3D**.
- If no ROI is detected on a slice (e.g., too dim), that slice is skipped.
- Uses fixed Z-slice positions (30%, 50%, 70%); full-stack averaging not implemented.

## Example Folder Structure

```
RootFolder/
├── Sample1/
│   └── image_stack1.tif
├── Sample2/
│   └── image_stack2.tiff
├── Sample3/
│   └── my_microscopy_data.tif
```

After running, you will find:

```
RootFolder/
└── signal_statistics.csv
```
