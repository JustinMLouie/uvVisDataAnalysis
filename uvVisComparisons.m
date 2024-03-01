clc; clear all;

%{
File Notes: 

Nonabstracted parts to update for each sample set: 
1. plot legend - update labels each time
2. Subtitle

If you want to add additional readings, copy the if statement loop that
checks through another folder, and add another difference calc, and then
update plots accordingly

Week 1 data: 231213, 240214
CSV 7: 231213_noPMMA_sampleB.csv and CSV 6: 240214_noPMMA_1week_SampleA.csv
missing experimental settings data in excel sheets
Data goes from 190-2700 instead of 2700-190

%}

currentDir = pwd;
currentDirItems = dir(currentDir);

dateInitial = '231213';
dateWeek1 = '240214';
numSamples = 8; % Update as needed

csvDataInitial = zeros(2511, 2, numSamples);
csvDataWeek1 = zeros(2511, 2, numSamples);
diffReadings = zeros(2511, numSamples);

% Iterate through currentDir and pull all csvs of relevance
for i = 1:length(currentDirItems)
    if currentDirItems(i).isdir && ~strcmp(currentDirItems(i).name, '.') ...
            && ~strcmp(currentDirItems(i).name, '..') ...
            && ~strcmp(currentDirItems(i).name, '.git') ...
            && ~strcmp(currentDirItems(i).name, '.DS_Store') 

        disp(['Folder: ', currentDirItems(i).name]);
        
        targetDirPath = fullfile(currentDir, currentDirItems(i).name);

        csvDataInitial = fileAdder(currentDir, currentDirItems, i, dateInitial, targetDirPath, 2,csvDataInitial);
        csvDataWeek1 = fileAdder(currentDir, currentDirItems, i, dateWeek1, targetDirPath, 1, csvDataWeek1);
    end
end

fprintf("Finished loading CSVs \n")

fprintf("Calculating ∆R \n \n")
wavelengths = (190:2700)';
for i = 1:numSamples
    initialReadings = csvDataInitial(:, 2, i);
    week1Readings = csvDataWeek1(:, 2, i);
    diffReadings(:, i) = week1Readings - initialReadings;
end


%{
UV-VIS ranges for graphs:
Full Spectrum: 190-2700
UV: 190-400 nm
Vis: 400-900 nm
NIR: 900-2500 nm

Indices:
Full Spectrum: 1:2511
UV: 1:211
Vis: 211-711 nm
NIR: 711-2511 nm
%}

fprintf("Starting graphing")
subtitleText = "2/14/24 - 1 week measurements, 12/13/23 - Initial Measurements";
graphDiff("Full Spectrum", numSamples, wavelengths, diffReadings, 1, 2511);
graphDiff("UV", numSamples, wavelengths, diffReadings, 1, 211);
graphDiff("VIS", numSamples, wavelengths, diffReadings, 211, 711);
graphDiff("NIR", numSamples, wavelengths, diffReadings, 711, 2511);

% pulls all csvs from a given folder and uploads data into a 3d matrix
function csvDataUploads = fileAdder(currentDir, currentDirItems, i, date, targetDirPath, misformattedFileNum, csvDataUploads)
    % csvDataUploads = zeros(2511, 2, numSamples);
    if contains(currentDirItems(i).name, date) % checks if folder name contains date
        % fprintf("------")
        csvCounter = 0; % counts number of CSVs found so far
        cd(targetDirPath); % cds into folder of csvs
        enteredDir = pwd;
        enteredDirItems = dir(enteredDir);
        for j = 1:length(enteredDirItems)
            if endsWith(enteredDirItems(j).name, '.csv')
                csvCounter = csvCounter  + 1;
                disp(['CSV ', num2str(csvCounter), ': ', enteredDirItems(j).name]);
                tempStorage = readmatrix(enteredDirItems(j).name);
                if csvCounter == misformattedFileNum
                    tempStorage = flipud(tempStorage);
                    tempStorage = tempStorage(1:end, :);
                else
                    tempStorage = tempStorage(17:2527, :);
                end
                csvDataUploads(:, :, csvCounter) = tempStorage;
            end
        end
        fprintf("Returning to currentDir");
        fprintf("\n \n");
        cd(currentDir);
    end
end

% function to plot diff UV-Vis reflectance diff at diff spectrums
function graphDiff(spectrumType, numSamples, wavelengths, diffReadings, startWavelength, endWavelength)   
    figure(); 
    hold on; 
    % plots diff for each plot
    for i = 1:numSamples
        plot(wavelengths(startWavelength:endWavelength), diffReadings(startWavelength:endWavelength, i));
    end
    
    xlabel("Wavelength (nm)"); 
    ylabel("∆R"); 
    ylim([-10 10]);
    title("Diffuse Reflectance Loss of White Paint Samples: " + spectrumType); % Concatenate title with spectrum type
    subtitle("2/14/24 - 1 week measurements, 12/13/23 - Initial Measurements");
    legend("0 wt% PMMA Sample A", "0 wt% PMMA Sample B", "0 wt% PMMA Sample C", ...
        "15 wt% PMMA Sample A", "15 wt% PMMA Sample B", "15 wt% PMMA Sample C", ...
        "30 wt% PMMA Sample A", "30 wt% PMMA Sample B");
    hold off;
end

