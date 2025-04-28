// Prompt the user to select the directory
dir = getDirectory("Select the directory containing OME-TIFF files");

// Recursively find all .ome.tiff and .tiff files in the directory
list = getFileList(dir);
fileList = "";
fileList = findTiffFiles(dir, list, fileList);

setBatchMode(false); // Enable batch mode for faster processing

// Split the concatenated string into an array of file paths and sort them
fileArray = split(fileList, "\n");
Array.sort(fileArray);

// Open the images in the sorted order, only opening the first TIFF in each subfolder
lastFolder = "";
for (i = 0; i < fileArray.length; i++) {
    path = fileArray[i];
    currentFolder = File.getParent(path);

    if (currentFolder != lastFolder) {
        print("Opening: " + path);
        run("Bio-Formats Importer", "open=[" + path + "] color_mode=Composite view=Hyperstack use_virtual_stack");
        lastFolder = currentFolder;
    }
}

setBatchMode(false); // Disable batch mode

// Function to find all .ome.tiff and .tiff files recursively
function findTiffFiles(currentDir, fileList, result) {
    for (i = 0; i < fileList.length; i++) {
        path = currentDir + fileList[i];
        if (File.isDirectory(path)) {
            // Recursively search subdirectories
            newList = getFileList(path);
            result = findTiffFiles(path + "/", newList, result);
        } else if (endsWith(path, ".ome.tiff") || endsWith(path, ".ome.tif") || endsWith(path, ".tiff") || endsWith(path, ".tif")) {
            result += path + "\n";  // Add the path to the result string with a newline separator
        }
    }
    return result;
}
