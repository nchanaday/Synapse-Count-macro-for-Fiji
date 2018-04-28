// Macro to obtain
// SYNAPSE NUMBER PER MICRON OF NEURITE
// Created by Natali L. Chanaday
//
// This will ask you to select the folder where your images are saved:
dir = getDirectory("Choose a Directory");
// And this will ask you the root name of the images you want to analyze
// (plus some extra info) 
// to do a for loop and open all of them sequencially:
filenameloop = getString("Write image filename root without number", "image");
start = getNumber("Write first file number (without zeros)", 1) ;
end = getNumber("Write last file number (without zeros)", 99) ;
Zstack = getNumber("Are the images Z stacks? ; Yes = write 1 ; No = write 0", 0);
//
for (i=start;i<=end;i++) {
filename=filenameloop+" "+i+".czi";
//
open(dir+filename); print(filename);
run("Subtract Background...", "rolling=20 stack");
//
	// If you have a Z stack and want to do a Maximum Intensity Projection:
	if (Zstack==1) {
		run("Z Project...", "projection=[Max Intensity]");
		run("Split Channels");
		green="C3-MAX_"+filename;
		red="C2-MAX_"+filename;
		magenta="C1-MAX_"+filename;
		blue="C4-MAX_"+filename; }	
	// If you don't have a stack:
	else {
		run("Split Channels");
		green="C3-"+filename;
		red="C2-"+filename;
		magenta="C1-"+filename;
		blue="C4-"+filename; }
	//
// SKELETON:	
// First, find tracings using the GREEN channel:
	selectWindow(green);
	setAutoThreshold("IJ_IsoData dark");setThreshold(35, 255);setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Remove Outliers...", "radius=2 threshold=25 which=Dark");
	run("Dilate");run("Dilate");
	run("Analyze Particles...", "size=10-Infinity show=Masks display clear");
	green_binary="Mask of "+green;
	selectWindow(green_binary);
	run("Convert to Mask");
	run("Skeletonize");
	run("Analyze Skeleton (2D/3D)", "prune=[lowest intensity voxel]");
// Calculation of total neurite length:
	total_neurite_length=0;
	if (nResults != 0){ 
        	for (j=0; j<nResults(); j++) {
    	total_neurite_length=total_neurite_length+(getResult("# Branches",j)*getResult("Average Branch Length",j)); } }
	else { 
        showMessage("No Result found in result table"); }
		print("Total Neurite Length (um)= "+total_neurite_length);
// Finding synapses along neurites:
	selectWindow(green_binary);
	run("Dilate");run("Dilate");
//
// RED signal colocalizing with the skeleton:
	selectWindow(red);
	setAutoThreshold("IJ_IsoData dark");
	run("Convert to Mask");
	run("Remove Outliers...", "radius=2 threshold=50 which=Bright");
	imageCalculator("Multiply create",red,green_binary);
	run("Analyze Particles...", "size=5-150 pixel circularity=0.50-1.00 show=Masks summarize");
	red_puncta="Result of "+red;
//
// MAGENTA signal colocalizing with the skeleton:
	selectWindow(magenta);
	setAutoThreshold("IJ_IsoData dark");
	run("Convert to Mask");
	run("Remove Outliers...", "radius=2 threshold=50 which=Bright");
	imageCalculator("Multiply create",magenta,green_binary);
	run("Analyze Particles...", "size=5-150 pixel circularity=0.50-1.00 show=Masks summarize");
	magenta_puncta="Result of "+magenta;
//
// COLOCALIZATION of all THREE channels:
	imageCalculator("Multiply create",red_puncta,magenta_puncta);
	result="Result of "+red_puncta;
	run("Analyze Particles...", "size=5-150 pixel circularity=0.50-1.00 show=Masks summarize");
//
// Nuclei mask:
	selectWindow(blue);
	setAutoThreshold("Triangle dark");
	run("Convert to Mask");
//
// To save a merged image with the results (tracings and masks with colocalizing puncta):	
COLOC_yellow="Mask of "+result;
vectorcolor="c1=["+red+"] c2=["+green_binary+"] c3=["+blue+"] c6=["+magenta+"] c7=["+COLOC_yellow+"] create keep";
run("Merge Channels...", vectorcolor);
outfile=filenameloop+" "+i+" Result image.tif";
saveAs("Tiff",dir+outfile);
//
selectWindow("Summary"); 
lines = split(getInfo(), "\n"); 
headings = split(lines[0], "\t"); 
for (j=1; j<=3; j++) {
	values = split(lines[j], "\t"); 
   	if (j==1) {
      	print("Number of RED puncta colocalizing with skeleton:");
      	print(headings[0]+": "+values[0]);
      	print(headings[1]+": "+values[1]); }
   	else if (j==2) {
		print("Number of MAGENTA puncta colocalizing with skeleton:");
      	print(headings[0]+": "+values[0]);
      	print(headings[1]+": "+values[1]); }
	else if (j==3) {
		print("Total number of SYNAPSES (colocaliztion of three colors):");
      	print(headings[0]+": "+values[0]);
      	print(headings[1]+": "+values[1]); } 	   
}
//
print("--------o--------o--------o--------o--------o--------o----------");
//
	run("Close All");
	selectWindow("Results"); 
    run("Close");
    selectWindow("Summary"); 
    run("Close");
}
//
print("Divide the total number of synapses (Count) by the total neurite length (um) to obtain the SYNAPSE NUMBER");
// 
// To save the results (total dendrite length and counted puncta):
selectWindow("Log");
outresult=filenameloop+" RESULT.txt";
saveAs("Text",dir+outresult);
//
// THE END!!