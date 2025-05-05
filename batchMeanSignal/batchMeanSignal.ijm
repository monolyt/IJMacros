// -------------------------------------------------------------
//  Signal statistics per channel
// -------------------------------------------------------------
requires("1.54f");

// Adjustable threshold range
selectMin = 100;
selectMax = 65535;

//batchMode
setBatchMode(true);

// Helper: timestamped logging
function log(msg) {
    ms = getTime();
    totalSeconds = floor(ms / 1000);
    h = floor(totalSeconds / 3600) % 24;
    m = floor(totalSeconds / 60) % 60;
    s = totalSeconds % 60;
    timeStamp = IJ.pad(h, 2) + ":" + IJ.pad(m, 2) + ":" + IJ.pad(s, 2);
    print(timeStamp + " " + msg);
}

// Choose base folder
mainDir = getDirectory("Choose the main folder containing sub‑folders of image stacks");
log("> Starting up. Selected path: " + mainDir);

// Output CSV
csvPath = mainDir + "signal_statistics.csv";
File.delete(csvPath);
File.append("Folder,Image,Channel,Slice,Min,Max,Mean,Median,SD", csvPath);
log("> Output CSV initialised at " + csvPath);

// Loop through subdirectories
list = getFileList(mainDir);
totalFolders = list.length;
folderIdx = 0;

for (i = 0; i < list.length; i++) {
    subDir = mainDir + list[i];
    if (!File.isDirectory(subDir)) continue;
    folderIdx++;
    log(">> Folder " + folderIdx + " / " + totalFolders + ": " + subDir);

    // Find first TIFF
    firstTif = "";
    files = getFileList(subDir);
    for (f = 0; f < files.length; f++) {
        lc = toLowerCase(files[f]);
        if (endsWith(lc, ".tif") || endsWith(lc, ".tiff")) {
            firstTif = files[f];
            break;
        }
    }
    if (firstTif == "") {
        log("# ! No TIFF found – skipped.");
        continue;
    }

    log(">> Loading  " + firstTif);
    path = subDir + File.separator + firstTif;

    run("Bio-Formats Importer", "open=[" + path + "] color_mode=Composite view=Hyperstack stack_order=XYCZT");
    baseTitle = getTitle();
    log(">> Image window: " + baseTitle);

    run("Split Channels");
    log(">> Split into channels");
    titles = getList("image.titles");

    for (c = 0; c < titles.length; c++) {
        if (!startsWith(titles[c], "C")) continue;

        selectWindow(titles[c]);
        channelID = substring(titles[c], 1, indexOf(titles[c], "-"));
        stackSize = nSlices;
        log(">>> Channel " + channelID + "  (" + stackSize + " slices)");

        // Choose slices at 30%, 50%, 70%
        sliceIdx = newArray(3);
        sliceIdx[0] = maxOf(1, floor(stackSize * 0.30));
        sliceIdx[1] = maxOf(1, floor(stackSize * 0.50));
        sliceIdx[2] = maxOf(1, floor(stackSize * 0.70));

        for (s = 0; s < sliceIdx.length; s++) {
            setSlice(sliceIdx[s]);
            run("Duplicate...", "title=measureSlice");
            selectWindow("measureSlice");

            run("Median...", "radius=1");
            run("Subtract Background...", "rolling=50");

            // Do not convert to mask! Stay in 16-bit and apply threshold
            setThreshold(selectMin, selectMax);
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
                    + minVal + "," + maxVal + "," + meanVal + "," + medVal + "," + sdVal;
                File.append(row, csvPath);

                log(">>>> SUCCESS > Slice " + sliceIdx[s] + ":  Mean " + meanVal + "  ±  SD " + sdVal
                    + "   (min " + minVal + ", max " + maxVal + ")");
            } else {
                log(">>>> FAILED > Slice " + sliceIdx[s] + ":  No ROI – skipped.");
            }

            close("measureSlice");
        }

        close(titles[c]);
    }
}

log("> Done. All statistics saved to: " + csvPath);
