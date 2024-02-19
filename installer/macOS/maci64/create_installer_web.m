clearvars
clc

if ismac
    operatingSystem = "macOS";
    architecture = computer('arch');
elseif isunix
    % Code to run on Linux platform
    disp('Platform not supported');
elseif ispc
    % Code to run on Windows platform
    disp('Platform not supported');
else
    disp('Platform not supported');
end

currentFile = mfilename('fullpath');
currentFileDir = fileparts(currentFile);
rootDir = fullfile(currentFileDir, '..', '..', '..');
buildDir = fullfile(rootDir, 'build');
currentBuildDir = fullfile(buildDir, operatingSystem, architecture);
installerOutputDir = fullfile(currentBuildDir, 'install');
srcDir = fullfile(rootDir, 'src');

addpath(srcDir);

matLabFile = fullfile(which('qtest.m'));

if(exist(currentBuildDir, 'dir'))
    [status,msg] = rmdir(currentBuildDir, 's');
    disp(msg)
end
mkdir(currentBuildDir);


disp("Compiling qtest");
tic
mcc('-m',matLabFile, '-d', currentBuildDir)
toc
disp("Compilation of qtest done");

addpath(currentBuildDir);

appFile = fullfile(currentBuildDir, 'qtest.app');

opts = compiler.package.InstallerOptions('ApplicationName', 'qtest');

opts.AuthorName = 'Regenwetters Lab';
opts.AuthorEmail = 'regenwet@illinois.edu';
opts.AuthorCompany   = 'UIUC';
opts.Version = '2.1';
opts.InstallerName = 'qtest_Installer_web';
opts.OutputDir = installerOutputDir;
opts.Description = 'QTEST is a custom-designed public-domain statistical analysis package for order-constrained inference.';
opts.Summary = 'QTEST is a custom-designed public-domain statistical analysis package for order-constrained inference.';

fprintf("Packaging qtest with options")
opts
tic
compiler.package.installer(appFile,'requiredMCRProducts.txt','Options',opts)
toc
disp("Packaging of qtest done")