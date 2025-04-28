// Signal To Background ImageJ Plugin v1.3
// Daniel Barleben
// Last edit: 2024-05-14
// Saves more infos than v1.2, including SD values, (optionally) ROIs and has more usable ROI color config

name = "danielba";
dataPath = "C:/Users/" + name + "/Desktop/SB/";

// Check if the dataPath directory already exists
if (!File.isDirectory(dataPath)) {
    // If the directory does not exist, create it
    File.makeDirectory(dataPath);
    // Confirm folder creation
    if (File.isDirectory(dataPath)) {
        print("dataPath succesfully created");
    } else {
        print("Failed to create dataPath");
    }
} else {
    print("dataPath already exists");
}

//*********Measure Signal**********
run("Clear Results");
run("Set Measurements...", "area mean standard min median redirect=None decimal=3");
filename = getTitle;
print(filename);
run("Duplicate...", " ");
filenameTh = getTitle;
run("Threshold...");
setAutoThreshold("Otsu dark");
setOption("BlackBackground", false);
run("Enhance Contrast", "saturated=0.35");
waitForUser("Please adjust minimum if necessary...");
run("Convert to Mask");
run("Create Selection");
selectWindow(filename);
run("Restore Selection");
// Make selection more visible and save Signal ROI
roiManager("Add");
roiManager("Select", 0);
roiManager("Set Fill Color", "#5000ff00");
close(filenameTh);
selectWindow(filename);
waitForUser("Please correct artifacts in this selection. Press 'ALT' continuosly and select unwanted artifacts.");
//roiManager("Save", dataPath + filename + "_Signal.roi");
run("Measure");
Signal_mean = getResult("Mean", 0);
Signal_median = getResult("Median", 0);
Signal_min = getResult("Min");
Signal_max = getResult("Max", 0);
Signal_sd = getResult("StdDev", 0);
print("Signal Mean = " + Signal_mean);
print("Signal Median = " + Signal_median);
print("Signal Max = " + Signal_max);
print("Signal Min = " + Signal_min);
print("Signal SD = " + Signal_sd);

// Initialize ROI manager
roiManager("Select", 0);
roiManager("Delete");

//*******Measure Background**********

Dialog.create("Measure Background");
items = newArray("Select Background manually", "Use inverse for Background", "Select Background by threshold");
Dialog.addRadioButtonGroup("Background selection", items, 1, 2, "Select Background manually");
Dialog.show();
BackMeth = Dialog.getRadioButton();

if (BackMeth == "Use inverse for Background") {
    run("Enlarge...", "enlarge=30");
    run("Make Inverse");
    // Save ROI
    roiManager("Add");
    roiManager("Select", 0);
    roiManager("Set Fill Color", "#50ff0000");
    //roiManager("Rename", filename + "_Background");
    //roiManager("Save", dataPath + filename + "_Background.roi");
    run("Measure");
}
if (BackMeth == "Select Background manually") {
    setTool("rectangle");
    run("Select None");
    waitForUser("Please select background. For multiple selection press 'Shift' continously");
    // Save ROI
    roiManager("Add");
    roiManager("Select", 0);
    roiManager("Set Fill Color", "#50ff0000");
    //roiManager("Rename", filename + "_Background");
    //roiManager("Save", dataPath + filename + "_Background.roi");
    run("Measure");
}
if (BackMeth == "Select Background by threshold") {
    run("Select None");
    run("Duplicate...", " ");
    filenameThB = getTitle;
    run("Threshold...");
    setAutoThreshold("Otsu dark");
    setOption("BlackBackground", false);
    setThreshold(600, Signal_min - 500);
    waitForUser("Please select Threshold...");
    run("Convert to Mask");
    run("Create Selection");
    roiManager("Add");
    roiManager("Select", 0);
    roiManager("Set Fill Color", "#50ff0000");
    selectWindow(filename);
    run("Restore Selection");
    close(filenameThB);
    waitForUser("Please correct wrong selections with 'ALT' ...");
    // Save ROI
    //roiManager("Delete");
    //roiManager("Add");
    //roiManager("Select", 0);
    //roiManager("Set Fill Color", "#60ff0000");
    //roiManager("Rename", filename + "_Background");
    //roiManager("Save", dataPath + filename + "_Background.roi");
    run("Measure");
}
Background_mean = getResult("Mean", 1);
Background_median = getResult("Median", 1);
Background_min = getResult("Min");
Background_max = getResult("Max", 1);
Background_sd = getResult("StdDev", 1);
print("Background Mean = " + Background_mean);
print("Background SD = " + Background_sd);

//*********Calculation***********
signaltobackground_mean = Signal_mean / Background_mean;
signaltobackground_median = Signal_median / Background_median;
signalminusbackground_mean = Signal_mean - Background_mean;
signalminusbackground_median = Signal_median - Background_median;

print("S/B mean = " + signaltobackground_mean);
print("S-B mean = " + signalminusbackground_mean);


// Print the calculated results
//print("S/B Mean:");
if (File.exists("C:/Users/" + name + "/Desktop/SB/Result_table.txt")) {
    File.append(filename + "\t" +
        signaltobackground_mean + "\t" +
        signaltobackground_median + "\t" +
        signalminusbackground_mean + "\t" +
        signalminusbackground_median + "\t" +
        Signal_mean + "\t" +
        Signal_median + "\t" +
        Signal_min + "\t" +
        Signal_max + "\t" +
        Signal_sd + "\t" +
        Background_mean + "\t" +
        Background_median + "\t" +
        Background_min + "\t" +
        Background_max + "\t" +
        Background_sd,
        "C:/Users/" + name + "/Desktop/SB/Result_table.txt");
} else {
    f = File.open("C:/Users/" + name + "/Desktop/SB/Result_table.txt");
    print(f, "Filename" + "\t" +
        "SB_mean" + "\t" +
        "SB_median" + "\t" +
        "S-B_mean" + "\t" +
        "S-B_median" + "\t" +
        "Signal_mean" + "\t" +
        "Signal_median" + "\t" +
        "Signal_min" + "\t" +
        "Signal_max" + "\t" +
        "Signal_SD" + "\t" +
        "Background_mean" + "\t" +
        "Background_median" + "\t" +
        "Background_min" + "\t" +
        "Background_max" + "\t" +
        "Background_SD");
    print(f, filename + "\t" +
        signaltobackground_mean + "\t" +
        signaltobackground_median + "\t" +
        signalminusbackground_mean + "\t" +
        signalminusbackground_median + "\t" +
        Signal_mean + "\t" +
        Signal_median + "\t" +
        Signal_min + "\t" +
        Signal_max + "\t" +
        Signal_sd + "\t" +
        Background_mean + "\t" +
        Background_median + "\t" +
        Background_min + "\t" +
        Background_max + "\t" +
        Background_sd);
    File.close(f);
}

// Initialize ROI manager
roiManager("Select", 0);
roiManager("Delete");

//open("C:\\Users\\"+name+"\\Desktop\\Result_table.txt");
