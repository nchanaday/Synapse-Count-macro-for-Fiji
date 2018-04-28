// This will ask you to select the folder where your images are saved:
dir = getDirectory("Choose a Directory");
// And this will ask you the filename of the image you want to analyze:
filename=getString("Write full image filename with the extension", "image.lsm")
//
open(dir+filename);
run("Split Channels");
green="C3-"+filename;
red="C2-"+filename;
magenta="C1-"+filename;
// First, find tracings using the GREEN channel:
selectWindow(green);
run("Subtract Background...", "rolling=50");
setAutoThreshold("Huang dark");setThreshold(35, 255);setOption("BlackBackground", false);
run("Convert to Mask");
run("Remove Outliers...", "radius=2 threshold=25 which=Dark");
run("Dilate");run("Dilate");
run("Analyze Particles...", "size=10-Infinity show=Masks display clear");
green_binary="Mask of "+green
selectWindow(green_binary);
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
selectWindow(green_binary);
run("Dilate");run("Dilate");
//
selectWindow(red);
run("Subtract Background...", "rolling=50");
setAutoThreshold("Huang dark");
run("Convert to Mask");
run("Remove Outliers...", "radius=2 threshold=50 which=Bright");
//
selectWindow(magenta);
run("Subtract Background...", "rolling=50");
setAutoThreshold("Huang dark");
run("Convert to Mask");
run("Remove Outliers...", "radius=2 threshold=50 which=Bright");
//
imageCalculator("Multiply create",red,magenta);
result="Result of "+red;
imageCalculator("Multiply create",result,green_binary);
run("Analyze Particles...", "size=5-150 pixel circularity=0.50-1.00 show=Masks summarize");
//
showMessage("Divide the total number of synapses (Count in the Summary window) by the total neurite length (Log window) to obtain the SYNAPSE NUMBER");
//