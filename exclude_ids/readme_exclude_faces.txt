Only relevant if you want the simulation to exclude certain faces from the calculation of the reconstructable area. 
N.B. this does not exclude these faces from the recosntructable sub-mesh, it only prevents their area value from being added to the total area.

Procedure:
    Variant A: in MATLAB
        1. Determine the IDs of the faces you'd like to exclude. Face ID = index of a face in the list of faces imported from the input STL.
        2. Concatenate all relevant IDs in a [1 x N] vector "exclIDs" in MATLAB and save "exclIDs" in a .mat file.
        3. Rename the file to <meshname>.mat where <meshname> is the name of your STL file (<meshname>.stl). 
        4. Place the .mat file here.
        5. In simSettings.m set the parameter "indexZero = false".

    Variant B: directly from STL (e.g. using external mesh viewer/editor)
        1. Determine the IDs of the faces you'd like to exclude. Check whether first face has index 0 or 1.
        2. Concatenate all relevant IDs in a 1xN vector "exclIDs" in MATLAB and save "exclIDs" in a .mat file.
        3. Rename the file to <meshname>.mat where <meshname> ist the name of your STL file (<meshname>.stl). 
        4. Place the .mat file here.
        5. In simSettings.m on
            a. If first face in step 1 had index/ID 0: set "indexZero = true"
            a. If first face in step 1 had index/ID 1: set "indexZero = false"
