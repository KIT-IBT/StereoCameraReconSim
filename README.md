# StereoCameraReconSim
Framework for Simulation of 3D mesh reconstruction with given stereo pinhole camera setup.

[![zenodo 4727698](https://user-images.githubusercontent.com/70153727/116559554-dbf08800-a900-11eb-9d43-0a4178bc4af3.png)](https://doi.org/10.5281/zenodo.4727698)

## Overview

StereoCameraReconSim is a simulation framework in MATLAB for a common main objective surgical mircoscope using multiple cameras. Deepending on a stl input mesh, it provides for each camera the respective image, the complete 3D reconstructable mesh, depending on a visibility threshold and reconstruction area in quantitative number.  For a better interpratation it is possible to excluse vertices from the reconsturction. The framework is based only on the "Parallel Compunting Toolbox" for acceleration. For deeper information, see the paper.

## Configuration 

There are different files for the simulation configuration:

1. simSettings.m
   Config parameter:
   - specify program parameters
     - **headless**: Set *true* if you intend to run this program without a gui
     - **suppressWarnings**: Set *false* to unsuppress all warnings

   - input mesh
     - **filename**: Specify stl file name (file must be in the same folder as "simSettings.m" or in one of the subfolders)
     - **indexZero**: So the vertex indices in your stl start with 0? If so: set *true*. Use *false* if your vertex ID list was taken from MATLAB.
   
   - reconstruction parameter
     - **reconThreshold**: Specify minimum number of cameras that must see a surface patch for it to be considered reconstructable
    
   - saving & output parameters
     - **savePlots**: Set *true* to save matlab figures. NOTE: use figure(openfig("filepath with extension")) to open the saved plots
     - **saveWorkspaceVariables**: Set *true* to save the whole workspace. NOTE: the output file could be several/many GB large and saving might take considerable time.
   
   - plot settings
     - **displayPlots**: Set *true* to display the plots.
     - **enforcePlot**:  Set *true* to force plotting all camera images even if there are more than 6 cams (NOTE: this can cause laggy behavior and require very long time to open all the figures)
     - **showIDs**: Set *true* to show face IDs in plots. this is intended for debugging purposes only and will clutter your plots greatly. Plots will become very laggy.
     - **showNormals**: Set *true* to show normals in plots
   
2. camSetup.m
   Config parameter:
   -  camera setup parameters
      - **camNum**: Specify the number of cameras
      - **center**: Specify the point which will be the hypothetical "focal point" of your camera setup's objective lens.

   -  parameters of the ring on which the cameras lie:
      - **L**: Hypothetical working distance L (between mesh and camera ring)
      - **b**: Baseline (ring diameter for positioning the cameras)
   
   -  intrinsic camera parameters
      - **L_x,L_y**: Sensor dimensions (width, height) in 'mm'
      - **N_x,N_y**: Sensor dimensions (width, height) in 'pixels' 
      - **o_x,o_y**: Principal point offset in 'pixels'

3. exclude_ids
   - Contains a mat-file with the vertec ids wich were excluded from the calulation. (NOTE: detailed description in the identically named folder.)

## Run
After setting the configuration parameters:

Just run "runSim.m" in MATLAB.

## Database configuration
```bash
StereoCameraReconSim
│   camSetup.m 			  # Config file for the camera setup
│   runSim.m 			  # Script for starting the simulation
│   simSettings.m 		  # Config file for programm settings
│
├───exclude_ids
│       readme_exclude_faces.txt  # Discription for futher information
│
├───functions		          # contain the core functionallity
│   │   ...
│   │
│   └───helpers
│       │   ...
│       │ 
│       └───third_party
│               ...
│
└───stl
    └───examples		  # Example meshes
	    50x50_cube.stl
	    center_cone.stl
	    nested_cubes.stl
	    thing.stl
```

## License

All source code is subject to the terms of the GNU General Public License v3.0.  
Copyright 2020 Jan Kost, Andreas Wachter - Karlsruhe Institute of Technology.

## Citation

TBD

## Contact

Jan Kost, Andreas Wachter
Institute of Biomedical Engineering  
Karlsruhe Institute of Technology  
www.ibt.kit.edu
