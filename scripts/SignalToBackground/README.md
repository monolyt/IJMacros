# Signal To Background Macro (ImageJ/Fiji)

## Description

This macro calculates the **signal-to-background ratio** and additional statistical parameters from a single image (⚠️ *not a hyperstack*) in ImageJ or Fiji.
It assists users in selecting the signal area and background area and exports results into a text file for further analysis.

## Setup

Before using the macro, you must adjust two variables at the beginning of the script:

- **Line 6 – `name`**:
  Set your Windows username (email prefix).
  Example:
  ```javascript
    name = "danielba";
  ```
- **Line 7 – `dataPath`**:
  Set the path where the result table will be saved.
  Options depending on your system:

  System Type | Suggested `dataPath` example
  ---|---
  Older SCCM PCs | `dataPath = "C:/Users/" + name + "/Desktop/SB/";`
  Newer Intune PCs (OneDrive) | `dataPath = "C:/Users/" + name + "/OneDrive - Miltenyi Biotec  B.V. & Co. Kg/Desktop/SB/";`
  Custom Path | e.g. `dataPath = "C:/Users/" + name + "/SB/";`

  Make sure the path you set exists or let the script create it automatically.

## Process Workflow

1. Open an image (not a hyperstack!) in ImageJ or Fiji.
2. Run the macro.
3. A threshold adjustment window opens:
    - Adjust the upper slider to correctly select your signal.
    - Signal is visualized in red.
    - Confirm by pressing "OK" in the pop-up window.
4. The signal selection is now shown as a green overlay.
5. Artifact correction step:
    - Use an ROI tool (e.g. rectangle) and press <kbd>Alt</kbd> while selecting to remove unwanted regions (e.g. artifacts, unwanted signals).
    - Confirm by pressing "OK".
6. Background selection:
    - A dialog appears to choose one of three background selection methods:
      - Manual: Draw background ROI manually.
      - Inverse: Automatically use the area outside the signal (with a 30-pixel margin) as background.
      - Threshold: Select background via thresholding, similar to signal.
7. Select background following the instructions for the method you chose. Background is visualized in red.
8. Artifact correction for background:
    - Again, press <kbd>Alt</kbd> while selecting regions to remove any non-background areas.
    - Confirm by pressing "OK".
9. The macro finishes automatically (the window will close silently).
10. Results are appended to a file named `Result_table.txt` inside the `dataPath` directory.


## Output

The macro outputs the following measurements:

Measurement | Description
---|---
`signaltobackground_mean` | Mean Signal / Mean Background
`signaltobackground_median` | Median Signal / Median Background
`signalminusbackground_mean` | Mean Signal - Mean Background
`signalminusbackground_median` | Median Signal - Median Background
`Signal_mean` | Mean intensity of the signal area
`Signal_median` | Median intensity of the signal area
`Signal_min` | Minimum intensity in the signal area
`Signal_max` | Maximum intensity in the signal area
`Signal_sd` | Standard deviation of intensity in the signal area
`Background_mean` | Mean intensity of the background area
`Background_median` | Median intensity of the background area
`Background_min` | Minimum intensity in the background area
`Background_max` | Maximum intensity in the background area
`Background_sd` | Standard deviation of intensity in the background area

Results are appended (not overwritten) to the Result_table.txt file each time the macro is used, allowing batch analysis.

## Notes

- Hyperstacks are not supported — only single images should be used.
- Make sure the `dataPath` is correctly set up to avoid errors when saving results.
- If unexpected behavior occurs, try using a simplified local `dataPath` (like `C:/Users/<username>/SB/`).
