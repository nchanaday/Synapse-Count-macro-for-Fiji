// This will ask you to select the folder where your images are saved:
dir = getDirectory("Choose a Directory");
// And this will ask you the filename of the image you want to analyze:
filename=getString("Write full image filename with the extension", "image.lsm")
//
open(dir+filename);
run("Split Channels");
green="C1-"+filename;
red="C2-"+filename;
// First, find tracings using the RED channel:
selectWindow(red);
run("Subtract Background...", "rolling=15");
setAutoThreshold("IJ_IsoData dark");setThreshold(35, 255);setOption("BlackBackground", false);
run("Convert to Mask");
run("Remove Outliers...", "radius=2 threshold=25 which=Dark");
run("Dilate");run("Dilate");
run("Analyze Particles...", "size=10-Infinity show=Masks display clear");
red_binary="Mask of "+red
selectWindow(red_binary);
run("Convert to Mask");
run("Skeletonize");
run("Analyze Skeleton (2D/3D)", "prune=[lowest intensity voxel]");
// Calculation of total neurite length:
total_neurite_length=0;
if (nResults != 0){ 
        for (i=0; i<nResults(); i++) {
    total_neurite_length=total_neurite_length+(getResult("# Branches",i)*getResult("Average Branch Length",i)); } }
else { 
        showMessage("No Result found in result table"); }
print("Total Neurite Length (um)= "+total_neurite_length);
// Finding synapses along neurites:
selectWindow(red_binary);
run("Dilate");run("Dilate");
selectWindow(green);
run("Subtract Background...", "rolling=15");
setAutoThreshold("IJ_IsoData dark");
run("Convert to Mask");
run("Remove Outliers...", "radius=2 threshold=50 which=Bright");
imageCalculator("Multiply create", green,red_binary);
selectWindow("Result of "+green);
run("Analyze Particles...", "size=10-500 pixel circularity=0.25-1.00 show=Masks summarize");
showMessage("Divide the total number of synapses (Count in the Summary window) by the total neurite length (Log window) to obtain the SYNAPSE NUMBER");
//