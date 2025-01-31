%% READMME
% this is a readme to describe how to use this code to reproduce the
% results for the paper by Stephens, Ting, and Cope in the Journal of
% Experimental Physiology 2025.

% The first script to run is dataSorting.m. The data processing pipeline is
% first to export .smr files of experiment recordings from Spike2 as .mat
% files. The matlab code here is expecting the spike channels to be
% pre-sorted such that the data is a vector of times and named 'Spikes' so
% that the channel can be identified in Matlab. The dataSorting.m script is
% expecting all the files to be in one folder, and the convention used
% here is that one file has all the data for a single cell and all the cell
% data from an experiment (one animal on one day) goes in an individual
% folder. The dataSorting.m script will loop through one folder at a time
% that is selected by the user and create a subfolder called 'recdata'
% where it will store files for single stretches. The only processing in
% this script is taking derivatives to identify stretch periods, these
% derivatives are not stored as data. The end result is a collection of
% files for individual stretches with raw data for motor displacement,
% motor force, muscle length from sonos, time, spike times, and
% instantaneous firing rates. It also saves a parameters file with the
% animal number, cell number, stretch type, cell type, and stretch start
% time within the experiment file. One note is that this script also scales
% the sonos channel by a factor of 15, which is the scaling factor from
% volts to mm based on previous calibration in the lab. As a note, this
% calibration is not repeated for each experiment so absolute lengths are
% not compared between animals and should be taken as approximations.

% The next script to run is dataProcessing.m. This is the script that does
% all the data processing. The way the script is written is admittedly
% confusing, but it was written when analyzing a data set where some
% experiments had sonomicrometry and others didn't so it had to account for
% different data structures. The first step is subtracting the initial
% sonos length. In preliminary analysis, there does not appear to be
% change in the resting length measured by sonos apart from stretches that
% appear right at the beginning of the trial when the muscle was being
% stimulated via the peripheral nerve for cell identification. The next
% step is defining the parameters for downsampling and filtering. After
% defining these parameters the data is actually processed. The script
% takes the time vector as a reference to identify the other
% regularly-sampled data channels it then loops through these channels,
% applies the filters and takes derivatives. It then trims off the NaNs
% introduced by the sgolaydiff function and saves the data to the new
% procdata structure. The end result is a procdata folder in the original
% data folder with individual files of processed data for each stretch.
% This folder serves as the data source for the rest of the analysis.

% The next script is Fig2.m which begins the analysis.