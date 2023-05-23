% First, run dataSorting.m to parse the experiment files into individual
% stretches and select the correct spike channels. This creates the
% 'recdata' folder with each file containing the data for one individual
% stretch. It also saves the starting time for the stretch in the file name
% so it can be easily found in the original spike file. Eah file contains
% the 'recdata' structure containing motor length, motor force, sonos, and
% spiketimes. Each file also contains the 'parameters' structure which
% contains the animal number, cell number, and series compliance condition.

% Next, run classify.m to save the stretch type to the parameters
% structure. This will add either 'ramp', 'triangle', or 'sine' to the
% parameters structuere so different stretch types can be analyzed
% differently in later scripts.

% Then run dataProcessing.m to filter the raw data and clean it up for
% analysis. The script serves to filter the time series data and align
% everything in time. It creates the 'procdata' folder in which each file
% contains the 'procdata' structure of processed data and 'parameters' 
% structure. As the processed data is the only data utilized in the 
% analysis, there is no need to save the raw data as well as it can still
% be referenced based on file names.In this data set, some stretches 
% occured less than 1.5s after the previous stretch, so this script also
% includes a code chunk to get rid of the second stretch. For example, 
% if a ramp occurs and a sine occurs less than 1.5s later, this will be 
% kept as a ramp and the sine will be ignored due to the short rest period.
% The classification script also only uses a shortened window for each 
% stretch to account for this.
