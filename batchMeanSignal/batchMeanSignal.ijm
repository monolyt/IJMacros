// Batch Signal Statistics ImageJ Plugin v1.0
// Daniel Barleben

requires("1.54f"); // make sure we're on a reasonably new Fiji

// helper: print with a tiny timestamp so lines stay ordered
function log(msg) {
    ms = getTime(); // milliseconds since ImageJ started
    totalSeconds = floor(ms / 1000);
    hours = floor(totalSeconds / 3600) % 24;
    minutes = floor(totalSeconds / 60) % 60;
    seconds = totalSeconds % 60;

    timeStamp = IJ.pad(hours, 2) + ":" + IJ.pad(minutes, 2) + ":" + IJ.pad(seconds, 2);
    print(timeStamp + " " + msg);
}

// Choose root directory
mainDir = getDirectory("Choose the main folder containing sub‑folders of image stacks");
log("> Starting up. Selected path: " + mainDir);

// Create / overwrite output
csvPath = mainDir + "signal_statistics.csv";
File.delete(csvPath);
File.append("Folder,Image,Channel,Slice,Min,Max,Mean,Median,SD", csvPath);
log("> Output CSV initialised at " + csvPath);

// Walk through each sub‑folder
list = getFileList(mainDir);
totalFolders = list.length;
folderIdx = 0;

for (i = 0; i < list.length; i++) {
    subDir = mainDir + list[i];
    if (!File.isDirectory(subDir)) continue; // skip loose files
    folderIdx++;

    log(">> Folder " + folderIdx + " / " + totalFolders + ": " + subDir);

    // find the first *.tif / *.tiff in this sub‑folder
    firstTif = "";
    files = getFileList(subDir);
    for (f = 0; f < files.length; f++) {
        lc = toLowerCase(files[f]);
        if (endsWith(lc, ".tif") || endsWith(lc, ".tiff")) { firstTif = files[f]; break; }
    }
    if (firstTif == "") {
        log("# ! No TIFF found – skipped.");
        continue;
    }

    log(">> Loading  " + firstTif);
    path = subDir + File.separator + firstTif;

    // Import once with Bio‑Formats
    run("Bio-Formats Importer", "open=[" + path + "] "
        + "color_mode=Composite view=Hyperstack stack_order=XYCZT");

    baseTitle = getTitle();
    log(">> Image window: " + baseTitle);

    // Split channels
    run("Split Channels"); // original is auto‑closed
    log(">> Split into channels");

    // list of all open image titles AFTER the split
    titles = getList("image.titles");

    // Loop over every channel stack
    for (c = 0; c < titles.length; c++) {
        if (!startsWith(titles[c], "C")) continue; // ignore non‑channel windows

        selectWindow(titles[c]);
        channelID = substring(titles[c], 1, indexOf(titles[c], "-"));  // "1", "2", "3"
        stackSize = nSlices;

        log(">>> Channel " + channelID + "  (" + stackSize + " slices)");

        // pick three Z planes
        sliceIdx = newArray(3);
        sliceIdx[0] = maxOf(1, floor(stackSize * 0.30));
        sliceIdx[1] = maxOf(1, floor(stackSize * 0.50));
        sliceIdx[2] = maxOf(1, floor(stackSize * 0.70));

        // process each chosen slice
        for (s = 0; s < sliceIdx.length; s++) {
            setSlice(sliceIdx[s]);

            run("Duplicate...", "title=measureSlice"); // working copy
            selectWindow("measureSlice");

            run("Median...", "radius=1");
            run("Subtract Background...", "rolling=50");

            // mask of non‑zero pixels
            run("Duplicate...", "title=nonZeroMask");
            selectWindow("nonZeroMask");
            setThreshold(50, 65535);
            run("Convert to Mask");

            // apply mask
            selectWindow("measureSlice");
            imageCalculator("Multiply create", "measureSlice", "nonZeroMask");
            selectWindow("Result of measureSlice");
            rename("maskedSlice");

            // threshold ignoring zeros
            run("Auto Threshold", "method=MaxEntropy ignore_black"); //MaxEntropy vs. Otsu
            run("Convert to Mask");
            run("Create Selection");

            if (selectionType != -1) {
                roiManager("reset");
                roiManager("Add");
                selectWindow("measureSlice");
                roiManager("Select", 0);

                run("Set Measurements...", "mean standard min median max redirect=measureSlice decimal=2");
                run("Measure");

                selectWindow("Results");
                minVal = getResult("Min", nResults - 1);
                maxVal = getResult("Max", nResults - 1);
                meanVal = getResult("Mean", nResults - 1);
                medVal = getResult("Median", nResults - 1);
                sdVal = getResult("StdDev", nResults - 1);
                close("Results");

                row = list[i] + "," + firstTif + ",C" + channelID + "," + sliceIdx[s] + ","
                    + minVal + "," + maxVal + "," + meanVal + "," + medVal + "," + sdVal + "\n";
                File.append(row, csvPath);

                log(">>>> SUCCESS > Slice " + sliceIdx[s] + ":  Mean " + meanVal + "  ±  SD " + sdVal
                    + "   (min " + minVal + ", max " + maxVal + ")");
            } else {
                log(">>>> FAILED > Slice " + sliceIdx[s] + ":  No ROI – skipped.");
            }

            // tidy up
            close("nonZeroMask"); close("maskedSlice"); close("measureSlice");
        } // end slice loop

        close(titles[c]);  // close this channel stack
    } // end channel loop
} // end sub‑folder loop

log("> Done. All statistics saved to: " + csvPath);
