function human = create_human_from_measurement(varargin)
%% create_human_from_measurement([name, type, nw, wh, rsw, cc, wac, hc, al, cua, wrc]) - creates struct human from measurement data


%% set names and variables
names = ["Leher ke Pinggang"; "Pinggang ke Pinggul"; "Lebar Bahu";...
    %"shoulder deep"; "armhole depth"; 
    "Lingkar Dada";...
    "Lingkar Pinggang"; "Lingkar Pinggul";...
    "Panjang Lengan"; "Lingkar Lengan Atas"; "Pergelangan Tangan"];
variables = ["back_length"; "seat_length"; "rear_shoulder_width";...
    %"shoulder_deep"; "armhole_depth"; 
    "chest_circumference";...
    "waist_circumference"; "hip_circumference";...
    "arm_length"; "circumference_upper_arm"; "wrist_circumference"];
%% input help
%%%%%%%%%%%%%%%%%%
if nargin == 0
%% request user input for metadata
disp('Please enter the following data:')
in=true;

% name
in = input('Nama:','s');
human.name = in;

temp = isstrprop(human.name,'alpha');% check if only letters
if any(~temp)
    human.name(~temp)=[];
    warning('Input of name: Letters are allowed, any other character was deleted.')
end

% type
in = input('Jenis Kelamin (Male, Female) :','s');
while sum(strcmp(in, {'female','male'})) == 0
    warning('Invalid type input. Set type to: male or female')
    in = input('Type (female, male):','s');
end
human.type = in;



%% request user input for measures 

for i=1:length(variables)
    human.(variables(i)) = input(strcat(names(i),': '));
end

%% read input data
%%%%%%%%%%%%%%%%%%%
elseif nargin == 11
    human.name = varargin{1};
    temp = isstrprop(human.name,'alpha');% check if only letters
    if any(~temp)
        human.name(~temp)=[];
        warning('Input of name: Letters are allowed, any other character was deleted.')
    end

    human.type = varargin{2};
    while sum(strcmp(varargin{2}, {'female','male','child'})) == 0
        error('Invalid type input. Set type to: male, female or child.')
    end
        
    for i = 3:length(variables)+2
        human.(variables(i-2)) = varargin{i};
    end

%% error if wrong number of inputs
else
    error('create_human_from_measurement: Please enter name, type and exactly 8 body dimensions or nothing to get input help');
end

