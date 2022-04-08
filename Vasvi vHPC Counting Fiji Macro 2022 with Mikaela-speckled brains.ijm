dir1 = getDirectory("/Users/kah218/Desktop/Vasvi-Icky Brains");	 /* Selects an input directory. Note the double slashes. */
dir2 = dir1 + "/Results/";                                                  			/* Creates the folders (Results and Masks), inside the input folder, where the output files and processed images will be saved. */ 
dir3 = dir1 + "/Masks/";
dir4 = dir1 + "/Areas/";
File.makeDirectory(dir2);                                                			/* Creates a new output directory in the selected input folder. */
File.makeDirectory(dir3);
File.makeDirectory(dir4);
print(dir2);                                                             				/* Prints the path to the output directory in a log for later reference. */
print(dir3);
print(dir4);

run("Set Measurements...", "area mean display redirect=None decimal=3");  		/* Sets the measurement options and scale to be used later */ 

Dialog.create("Please enter the parameters");				/* Creates a pop-up window for... */
Dialog.addString("File suffix: ", ".tif", 5);					/* File type. The 5 is the length of the space to type. When running the macro, this will be prompted only before the first image opens, click "OK". */
Dialog.show(); 

suffix = Dialog.getString();							/* Gets dialog input string (to be used in the function; tells it to take all files that end with "suffix"). */
processFolder(dir1);								/* The whole input folder will be processed. */											    

function processFolder(dir1) {						/* Creates a function which enables automated processing. */ 
    list = getFileList(dir1);							/* Lists the input files inside the folder. */
    for (i = 0; i < list.length; i++) {						/* Counts the number of files on which it will run the function. */
        if(File.isDirectory(list[i]))						/* Runs the function in a loop for each i:th file on the list, through list[i]. */
            processFolder("" + dir1 + list[i]);
        if(endsWith(list[i], suffix))
            processFile(dir1, list[i]);
    }
}
 
function processFile(dir1, file) {						/* OK  	This function runs on all the pictures in a directory. The function starts here ("{"), but ends at the end of the macro ("}"). */
	open(dir1+file);  	/* Opens the .czi image and splits it by channel without prompting a dialog to click first */

run("Remove Outliers...", "radius=10 threshold=75 which=Bright");
run("Set Scale...", "distance=1 known=1 pixel=1 unit= 1.88720 micron");
run("8-bit");	

run("Brightness/Contrast..."); /*commented before*/
setMinAndMax(7, 82);												//* Sets Brightness & Contrast to a level that makes the cells easy to see by eye
call("ij.ImagePlus.setDefault16bitRange", 8);				/* Needed to make sure the B&C adjustment matches the bit settings of the image, if not done the thresholding is all wonky!*/

setTool("polygon");								/* Commented before. This part is from Marie's (& Falk's) macro, which prompts you to draw around the ROI and both give an area measurement (microns^2) and use the same ROI for future measurements */
waitForUser("Now, please, mark your desired region of interest (ROI), \n then click OK to proceed.");
run("Measure");	

filename = getTitle();
dotindex = indexOf(filename,".");						/* Establishes where is the "dot" in the file name, that is where the extension starts (WARNING: If the file name contains multiple dots, the code won't work). */
areaName = substring(filename, 0 , dotindex); 				/* Creates a variable "areaName" without the file type out of the string of variable "filename". */
rename(areaName);			
results_area = dir4 + areaName + ".csv";					/* Exports area of the ROI as a .csv file, and closes the Results window */
saveAs("Results", results_area);
selectWindow("Results");
run("Close");
selectImage(1);

run("Smooth");
run("Subtract Background...", "rolling=4000");

setAutoThreshold("Default dark");
//run("Threshold...");		//commented before
call("ij.plugin.frame.ThresholdAdjuster.setMode", "B&W");
setThreshold(15, 104, "raw");
//setThreshold(15, 104);
setOption("BlackBackground", true);
run("Convert to Mask");
run("Restore Selection");

run("ROI Manager...");
roiManager("Add");

run("Watershed");

run("Analyze Particles...", "size=50.00-500.00 circularity=0.20-1.00 show=[Overlay Masks] display summarize overlay");
run("Flatten");

imgName = substring(areaName, 0 , dotindex); 			//* Creates a variable "imageName" without the file type out of the string of variable "filename". */
rename(imgName);					//* Renames original image, so that the extension won't be retained as a part of the name. */
maskname = dir3 + imgName + ".tif";				//* Creates a variable with the whole file path, image name and .tif extension for exporting correctly. */
saveAs("tiff", maskname);					//* Saves the mask with all cells labelled as a new .tif file in the Masks folder

selectImage(2);
run("Close");

selectImage(1);
run("Close");

selectWindow("Results");
results_pa = dir2 + areaName + ".csv";														/* Exports area of the ROI as a .csv file, and closes the Results window */
saveAs("Results", results_pa);
run("Close");

selectWindow("Summary");
summary_pa = dir2 + "Summary-" + areaName + ".csv";											/* Exports area of the ROI as a .csv file, and closes the Results window */
saveAs("Results", summary_pa);
run("Close");

selectWindow("ROI Manager");																//* Clears and closes the ROI manager. */
roiManager("reset");
run("Close");

}
