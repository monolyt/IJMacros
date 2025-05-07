/**
 * DEFINE FUNCTIONS
 */

function setColors(color1, color2, color3, color4) {
    // Set color for channel 1 if provided
    if (color1 != "") {
        Stack.setChannel(1);
        run(color1);
    }
    // Set color for channel 2 if provided
    if (color2 != "") {
        Stack.setChannel(2);
        run(color2);
    }
    // Set color for channel 3 if provided
    if (color3 != "") {
        Stack.setChannel(3);
        run(color3);
    }
    // Set color for channel 4 if provided
    if (color4 != "") {
        Stack.setChannel(4);
        run(color4);
    }
}

function saveOpenImages(openWindows) {
    getMinAndMax(min, max);
    saveAs("PNG", exportPath + openWindows[i]);
    print("Image saved.");
    // Initialize the log file if it doesn't exist
    if (!File.exists(logFilePath)) {
        header = "Image Name, Min-Max Values\n";
        File.saveString(header, logFilePath);
        print("Initialized logfile in " + logFilePath);
    } else {
        print("Using existing logfile: " + logFilePath);
    }
    // Append the image name and min-max values to the log file
    File.append(openWindows[i] + ", " + min + "-" + max, logFilePath);
    print("Logged to " + logFilePath);
}

function saveVideos(openWindows) {
    run("AVI... ", "compression=JPEG frame=7 save=" + exportPath + openWindows[i] + ".avi");
    print("Video saved as: " + filePath);
}

function saveAllChannels(currentImage) {
    getDimensions(width, height, channels, slices, frames);
    // Initialize the log file if it doesn't exist
    if (!File.exists(logFilePath)) {
        header = "Image Name, Channel, Min-Max Values\n";
        File.saveString(header, logFilePath);
        print("Initialized logfile in " + logFilePath);
    } else {
        print("Using existing logfile: " + logFilePath);
    }
    // Iterate through channels
    for (c = 1; c <= channels; c++) {
        // Set the active channel string with 1 for the current channel, 0 for others
        activeChannels = "";
        for (j = 1; j <= channels; j++) {
            if (j == c) {
                activeChannels += "1"; // Active channel
            } else {
                activeChannels += "0"; // Non-active channel
            }
        }
        Stack.setActiveChannels(activeChannels); // Set only the current channel as visible
        print("Displaying channels: " + activeChannels);
        Stack.setChannel(c);
        getMinAndMax(min, max);
        filename = currentImage + "-Ch" + c;
        saveAs("PNG", exportPath + filename);
        print("Channel " + c + " saved as: " + filename + ".png");
        // Append the image name, channel, and min-max values to the log file
        File.append(filename + ", " + min + "-" + max, logFilePath);
        print("Logged to " + logFilePath + " for Channel " + c);
    }
}


/*
* DEFINE VARIABLES
*/

// Path for export
//exportPath = "G:/Export/";
exportPath = getDirectory("Choose export path: " + exportPath);

// Path for logging gray values
logFilePath = exportPath + "grayValues.txt";

/*
* ITERATE THROUGH ALL OPEN IMAGES
*/

openWindows = getList("image.titles");

// Create array of all open Mips
openMips = newArray();

for (i = 0; i < lengthOf(openWindows); i++) {
    if (startsWith(openWindows[i], "MAX")) {
        openMips = Array.concat(openMips, openWindows[i]);
    }
}

for (var i = 0; i < openWindows.length; i++) {
    selectWindow(openWindows[i]);

    //setColors("Green", "Yellow", "Red", "");
    Stack.setActiveChannels("10");
    //rename("N17-" + (i + 1) + "-" + "GFP");

    //saveOpenImages(openWindows);
    //saveVideos(openWindows);
    //saveAllChannels(openWindows[i]);

    // Create MIP
    //run("Z Project...", "projection=[Max Intensity]");

    // Insert Scale bar (optional)
    run("Scale Bar...", "width=200 height=20 thickness=20 font=0 bold overlay");

    // Set contrast automatically
    //run("Enhance Contrast", "saturated=0.35");

    // Change image type to RGB
    //run("RGB Color");

}
