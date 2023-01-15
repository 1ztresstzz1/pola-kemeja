%% inital state
close all; clc; clear all;
warning('off','all');

%% create struct of type 'human' 

% a) pengukuran langsung
human_example = create_human_from_measurement('Fachrul Alam','male', 42, 32, 45, 96, 84, 102, 60, 36, 20);

% b) pengukuran manual
% human_example = create_human_from_measurement;

%% create pattern
pattern = create_pattern_shirt(human_example, 'regular', 'long', 'round', 'plain_hem');

plot_basic_pattern(pattern);
plot_production_pattern(pattern)

%% optional: visual check of pattern
% plot_construction_points(pattern); hold on;
% plot_construction_points_sleeve(pattern);

%plot_all_sizes(pattern);

%% create production files 
 create_production_files_ep(human_example, pattern); % external production

