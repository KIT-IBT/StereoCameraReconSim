%% ------------------------------------------------------------------------
%   specify program parameters
%  ------------------------------------------------------------------------
%%

%Set this to true if you intend to run this program without a gui
    headless = false;
        
%comment this to unsuppress all warnings
    suppressWarnings = false;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Input mesh
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%specify stl file name (file must be in the same folder as this file or in 
%one of the subfolders)
    %filename = '50x50_cube';
    %filename = 'thing';
    %filename = 'center_cone'; 
    filename = 'nested_cubes';

%If you specified a list of faces to exlude from the calculation of the
%total recosntructable area, where the IDs taken from the STL directly or
%from any other source that begins indexing at 0? If so: set true. Use
%false if your ID list was taken from MATLAB.
    indexZero = true;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Reconstruction parameter
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%specify minimum number of camera that must see a surface patch for it to
%be considered reconstructable
    reconThreshold = 2;
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Saving & output parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
%Decide what to save   
    %save matlab figures?
    savePlots = false; 
    %NOTE: use figure(openfig("filepath with extension")) to open the saved
    %plots
    
    %save the whole workspace
    saveWorkspaceVariables = false;

%plot settings
    %display the plots or not?
    displayPlots = true;
    
    %force plotting all camera images even if there are more than
    %6 cams (warning: this can cause laggy behavior and require very long 
    %time to save all the figures)
    enforcePlot = false;
    
    %show face IDs & normals where relevant
    showIDs = false;
    showNormals = false;
