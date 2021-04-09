%% ------------------------------------------------------------------------
%   "Main" - Script
%  ------------------------------------------------------------------------
%%
clc
disp('----------------START----------------')
%close open plots
close all
clearvars

%adds all folders & subfolders in this file's directory to the search path.
locPaths = genpath(pwd);
addpath(locPaths)

if ~contains(struct2array(ver), 'Parallel Computing Toolbox')
   fprintf(2,'\nThe Parallel Computing Toolbox is not installed, but it is required!\n')
   fprintf(2,'The script was terminated\n')
   fprintf(2,'Please, install the Parallel Computing Toolbox\n')
   return;
end

%load user settings
simSettings;
try
    load([filename,'.mat']) %use this line to load the list from a file,
                            %comment otherwise
    excludeIDs = exclIDs; %assign whatever the name of the matrix in your
                          %llaoded file was to "excludeIds"
                          
    if indexZero
        %fix for matlab beginning to count at 1:
        excludeIDs = excludeIDs+1;
    end
    disp('loaded face exclusion list, proceeding.')
catch filenotFound
    excludeIDs = [];
    disp('No face exclusion list found, proceeding.')
end

%% some preprations
if headless
    set(0, 'defaultFigureRenderer', 'painters');
else
    set(0, 'DefaultFigureRenderer', 'opengl');
    dbstop if error
end

%set matlab default .mat version to 7.3, required for saving files
%exceeding 2GB
rootgroup = settings();
targetVer = 'v7.3';
notSet = false;
try
    ver = rootgroup.matlab.general.matfile.SaveFormat.PersonalValue;
catch
    notSet = true;
end

if notSet
    rootgroup.matlab.general.matfile.SaveFormat.PersonalValue = targetVer;
else
    if ~strcmp(ver,targetVer) %current default version is not 7.3
        rootgroup.matlab.general.matfile.SaveFormat.PersonalValue = ...
                                                                 targetVer;
    end
end

%add pre-2018b plot controls for convenience
if ~verLessThan('matlab', '9.5') %read as: if version newer than 2018b
    set(groot,'defaultFigureCreateFcn','addToolbarExplorationButtons(gcf)')
end

%string unique to the current run of the script. Used in file names &
%temporary job directories
camNumber = readCamSetup;
identString = [filename,'_',...
               num2str(camNumber),'_',...
               datestr(now, 'dd-mmm-yyyy'),'_',...
               datestr(now,'HHMM')];
%attempt to create a parallel pool withthe maximum number of workers 
%available to the machine
currentParPool = gcp('nocreate');
if isempty(currentParPool)
    %create a local cluster object
    pc = parcluster('local');
    if isunix
        %specific to clusters using SLURM
        %try to get the number of dedicated cores from cluster environment
        numProcessors = getenv('SLURM_NPROCS'); %string!
        if ~isempty(numProcessors)
            numWorkers = str2num(numProcessors);
            parpool_tmpdir = fullfile(getenv('TMP'),...
                                    '.matlab','local_cluster_jobs',...
                                    'slurm_jobID_',getenv('SLURM_JOB_ID'));
        else
            %slurm not present
            try
                numWorkers = feature('numcores');
            catch
                error('Platform not Supported')
            end
            parpool_tmpdir = fullfile(tempdir,identString);
        end
    else
            try
                numWorkers = feature('numcores');
            catch
                error('Platform not Supported')
            end
        parpool_tmpdir = fullfile(tempdir,identString);
    end
    mkdir(parpool_tmpdir)
	pc.JobStorageLocation = parpool_tmpdir;
    %start parallel pool with maximum number of workers avaiable on the
    %machine
    parpool(pc,numWorkers);
end

if suppressWarnings
    warning('off','all')
    parfevalOnAll(gcp(), @warning, 0, 'off');
else
    warning('on','all')
    parfevalOnAll(gcp(), @warning, 0, 'on');
end

displayPlots = displayPlots & (~headless); %headless overrules display plot

%% Read the stl file specified above
disp('----------------')
disp('RECON SIM RUNNING')
disp('----------------')
warning('off','MATLAB:polyshape:repairedBySimplify')
fullName = [filename,'.stl'];
surfaceData = readSurface(fullName,displayPlots,showNormals,showIDs);
disp('Subject mesh successfully read from: ')
disp(fullName)
disp('----------------')
%% Collect user-defined camera calibration & calculate the intrinsic matrix
%edit camSetup.m to implement your own camera model 6 setup
[camParams,camNum] = getCamParams;
disp('Extrinsic camera parameters done')
disp('----------------')
%% Build camera coordinate systems, extrinsic and projection matrices etc. 
%Also plot overview of the camera situation -> displayed if displayPlots is
%"true", saved to the struct camData either way. 
camData = calcTransform(camParams,displayPlots);
disp('Intrinsic camera parameters done')
%%Add mesh bounding Box to the camera setup overview figure. 
tmpPlot = addMeshBoundingBoxToPlot(camData.coordinateSystemsPlot,...
                                   surfaceData.originalMesh.vertices);
camData.coordinateSystemsPlot = tmpPlot;
%% project original mesh vertices and centroids into 
%image coordinates & add to the mesh struct for use wherever needed
%(prevents havig to do these projections all over the place in loops later)
orginalVertices = surfaceData.originalMesh.vertices;
orginalCentroids = surfaceData.originalMesh.centroids;
imageVertices = zeros(...
    size(orginalVertices,1),2,camNum);
imageCentroids = zeros(...
    size(orginalCentroids,1),2,camNum);
for i = 1:camNum
    projMatrix = camData.projMatrices(:,:,i);
    [imageVertices(:,:,i),~,~] = ...
        projectToImageCoords(orginalVertices,projMatrix);
    [imageCentroids(:,:,i),~,~] = ...
       projectToImageCoords(orginalCentroids,projMatrix);
end
surfaceData.originalMesh.imageVertices = imageVertices;
surfaceData.originalMesh.imageCentroids = imageCentroids;

%% Gather potentially visible faces for each camera in individual structs
disp('--------------------------------')
disp(['Finding occlusion relationships in ',num2str(camNum),...
                                                          ' camera views'])
tic
    [camViews,fov] = findOcclusionRelationships(camData,surfaceData);
toc

%% clip faces a the FOV and/or against each other, where necessary                                                          
disp('--------------------------------')
disp('Clipping')
tic
    clippedCamViews = clipFaces(camViews,fov.fovPolyShapes,...
                                                     camData.projMatrices);
toc
%% Sort faces after clipping & plot camera views if applicable
disp('--------------------------------')
disp('Sorting clipping results & plotting')
tic
    processedCamViews = collectAndPlot(clippedCamViews,...
                        orginalCentroids,displayPlots,enforcePlot,showIDs);
toc
%% find reconstructable rest polygons of all faces andtriagulate them
%  these rest triagulations are addedup to an exportable mesh (which equals
%  the reconstructable subset of the input mesh.
disp('--------------------------------')
disp('Determining Reconstructable subset of Mesh')
if reconThreshold < 2
    error(['Recontructability Threshold must be greater than 2. ',...
        'You can grab the visible faces from the results, but no ',...
        'simulated reconstruction was perfomed.'])
else
    tic
        reconstruction = findReconstructableArea(reconThreshold,...
              surfaceData,processedCamViews.data,excludeIDs,displayPlots);
    toc
end
%% Save results to folder (folder is unique for each run)
disp('--------------------------------')
disp('Saving results - This may take several minutes!')
disp('----------------')
tic
    if ~exist('results', 'dir')
        mkdir('results')
    end
    currFolderName = fullfile('results',identString);
    if ~exist(currFolderName, 'dir')
        mkdir(currFolderName)
    end
    plotFolderName = fullfile(currFolderName,'plots');
    if ~exist(plotFolderName, 'dir')
        mkdir(plotFolderName)
    end
    areaFolderName = fullfile(currFolderName,'core_output');
    if ~exist(areaFolderName, 'dir')
        mkdir(areaFolderName)
    end
    disp('Saving reconstructable surface as STL.')
    %export reconstructable surface regions to STL file
    stlFileName = fullfile(areaFolderName,...
                          ['reconstructable_Surface-',identString,'.stl']);
    stlwrite(stlFileName,...
             reconstruction.reconSurf.ConnectivityList,...
             reconstruction.reconSurf.Points)
    disp('Saving area values.')
    origArea = surfaceData.originalMesh.totalArea;
    save(fullfile(areaFolderName,'originalArea.mat'),'origArea')
    recArea = reconstruction.totalArea;
    save(fullfile(areaFolderName,'reconstructableArea.mat'),'recArea')
    
    if saveWorkspaceVariables
        varFolderName = fullfile(currFolderName,'workspace_vars');
        if ~exist(varFolderName, 'dir')
            mkdir(varFolderName)
        end
        disp('Saving model surface data.')
        %save the potentially relevant portions of  the workspace
        numFaces = surfaceData.numFaces;
        originalMesh = surfaceData.originalMesh;
        save(fullfile(varFolderName,'surfaceData.mat'),...
                                                'numFaces','originalMesh')
        camSetupParams = camParams;
        FOV = fov;
        camSetup = rmfield(camData,'coordinateSystemsPlot');
        disp('Saving camera setup info.')
        save(fullfile(varFolderName,'camSetupInfo.mat'),...
                                         'camSetupParams','camSetup','FOV')
        
        %save(fullfile(varFolderName,'camViews.mat'),'camViews',...
        %                                                'clippedCamViews')
        disp('Saving camera views.')
        clippingResults = processedCamViews.data;
        save(fullfile(varFolderName,'clippedCamViews.mat'),...
                                                        'clippingResults')
        
        reconstructedFaces = reconstruction.reconData;
        save(fullfile(varFolderName,'reconstruction.mat'),...
                                                     'reconstructedFaces')                                       
    else
        disp('Saving variables was disabled, saving area values only.')
    end
    if savePlots
        disp('Saving plots.')
        savefig(surfaceData.patchPlot,...
                    fullfile(plotFolderName,'origSurf.fig'),...
                    'compact')
        savefig(camData.coordinateSystemsPlot,...
                    fullfile(plotFolderName,'camLocations3D.fig'),...
                    'compact')
        savefig(reconstruction.recSurfFig,...
                    fullfile(plotFolderName,'reconstructableSurf.fig'),...
                    'compact')
        savefig(reconstruction.fullSurfFig,...
                    fullfile(plotFolderName,'orig-recon-overlay.fig'),...
                    'compact')
        if ~processedCamViews.plots.skipped_plotting
            suffixA = 'img.fig';
            suffixB = 'surf.fig';
            for i = 1:camNum
                prefix = ['cam',num2str(i)];
                savefig(processedCamViews.plots.cameraImages.(prefix),...
                        fullfile(plotFolderName,[prefix,suffixA]),'compact')
                savefig(processedCamViews.plots.visibleArea3D.(prefix),...
                        fullfile(plotFolderName,[prefix,suffixB]),'compact')
            end
        else
            file = fullfile(plotFolderName,'camPlotsSkipped.txt');
            fid = fopen(file,'w+'); 
            fprintf(fid, 'Generation of camera image plots was disabled.');
            fclose(fid);
        end
    else
        disp('Saving plots was diabled, skipping.')
    end
toc
('--------------------------------')
disp('Done!')
disp('----------------END----------------')

%removes the local directories from the search path
rmpath(locPaths)