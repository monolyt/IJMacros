Stack.getPosition(channel, slice, frame);
Stack.getDimensions(width, height, channels, slices, frames);
wpath = "F:/";
imageId = getImageID();
sampleId = "1:10_"

for (c = 1; c <= channels; c++) {
    //run("Duplicate...", "duplicate channels" + c + " slices=" + slice);
    run("Make Substack...", "channels=" + c + " slices=" + slice);
    run("Enhance Contrast", "saturated=0.35");
    if (c == 1) {
        channelName = "Sytox";
    } else if (c == 2) {
        channelName = "TH-Vio570";
    } else if (c == 3) {
        channelName = "NeuN-Vio667";
    }
    fileName = sampleId + channelName + "_zpos" + slice;
    saveAs("TIFF", wpath + fileName);
    close();
    selectImage(imageId);
}
