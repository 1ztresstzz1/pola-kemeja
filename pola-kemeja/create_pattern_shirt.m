function pattern = create_pattern_shirt(human, varargin)
%% create_pattern_shirt(human, [fit, sleeve_length, neckline, hemtype, fabric_elasticity]) - creates a pattern of a shirt


%% set default values
% only want 5 optional inputs at most
numvarargs = length(varargin);
if numvarargs > 5
    error('create_pattern_shirt: Too many inputs, requieres at most 5 optional inputs')
end

% set defaults for optional inputs
optargs = {'regular' 'long' 'round' 'plain_hem', 25};
optargs(1:numvarargs) = varargin;
[fit, sleeve_length, neckline, hemtype, fabric_elasticity] =  optargs{:};

%% write pattern properties
pattern.property.type = human.type;
pattern.property.fit = fit;
pattern.property.sleeve_length = sleeve_length;
pattern.property.neckline = neckline;
pattern.property.hemtype = hemtype;
    
%% Ininialization and parameters
pattern.part_names=[];
pattern.basic_pattern=[];
pattern.production_pattern=[];
seam = 1; 
pattern.construction_dimensions.seam = seam;
hem = 2;
pattern.construction_dimensions.hem = hem;
pattern.construction_dimensions.fit_allowance = 0.05*fabric_elasticity/100;

if strcmp(sleeve_length, 'long')
    pattern.construction_dimensions.sl = 1;
elseif strcmp(sleeve_length, '3/4sleeves')
    pattern.construction_dimensions.sl = 0.7;
elseif strcmp(sleeve_length, 'short')
    if strcmp(human.type,'female')
        pattern.construction_dimensions.sl = 0.3;
    elseif strcmp(human.type,'male')
        pattern.construction_dimensions.sl = 0.4;
    else
        error('Invalid Input for human type')
    end
elseif strcmp(sleeve_length, 'sleeveless')
    pattern.construction_dimensions.sl = 0;
else 
    error('create_pattern_shirt: Invalid input for variable sleeve_length')
end

pattern.construction_dimensions.neckline = 0;
%% constant measurements
pattern.construction_dimensions.cm_dp = 10;% jarak antar bagian
pattern.construction_dimensions.cm_nf = 2; % leher depan
pattern.construction_dimensions.cm_sf = 3; % bahu depan
pattern.construction_dimensions.cm_nb = 2; % leher belakang
pattern.construction_dimensions.cm_sb = 2; % bahu belakang
pattern.construction_dimensions.am = human.chest_circumference/24+1; % kerung lengan
pattern.construction_dimensions.f = 1.16;
if human.chest_circumference <= 89
    pattern.construction_dimensions.am = pattern.construction_dimensions.am -0.5;
elseif human.chest_circumference <= 99
    pattern.construction_dimensions.am = pattern.construction_dimensions.am -0.3;
elseif human.chest_circumference <= 109
    pattern.construction_dimensions.am = pattern.construction_dimensions.am -0.17;
elseif human.chest_circumference >=120
     pattern.construction_dimensions.am = pattern.construction_dimensions.am +0.17;
end
pattern.construction_dimensions.cm_cm = 6; % clip mark sleeve-back part
pattern.construction_dimensions.cm_cc = 0.2; % clip cut length
pattern.construction_dimensions.cm_cuff = 4; % cuffs pattern width for v-neck
pattern.construction_dimensions.cm_cuff_width = (pattern.construction_dimensions.cm_cuff-2*seam)/2; % width of final cuff

%% create construction points (struct) for torso
pattern.construction_points.A  = [0 0];
pattern.construction_points.a1 = [0,human.chest_circumference/4];
pattern.construction_points.a2 = [0,human.rear_shoulder_width/5+1];
pattern.construction_points.a3 = [0,human.rear_shoulder_width/2];
pattern.construction_points.a4 = [-human.rear_shoulder_width/5-pattern.construction_dimensions.cm_cuff_width,0];

pattern.construction_points.b3 = pattern.construction_points.a1 + [0 pattern.construction_dimensions.cm_dp];
pattern.construction_points.B  = pattern.construction_points.b3 + [0 human.chest_circumference/4];
pattern.construction_points.b1 = pattern.construction_points.B - [0,human.rear_shoulder_width/5+1];
pattern.construction_points.b2 = pattern.construction_points.B - [0,human.rear_shoulder_width/2];

pattern.construction_points.C = [-human.back_length pattern.construction_points.B(2)];
pattern.construction_points.D = [-human.back_length 0];

pattern.construction_points.C1 = [pattern.construction_points.C(1) pattern.construction_points.b3(2)];
pattern.construction_points.D1 = [pattern.construction_points.D(1) pattern.construction_points.a1(2)];

pattern.construction_points.E = pattern.construction_points.C-[human.seat_length 0];
pattern.construction_points.F = pattern.construction_points.D-[human.seat_length 0];

pattern.construction_points.E1 = [pattern.construction_points.E(1) pattern.construction_points.b3(2)];
pattern.construction_points.F1 = [pattern.construction_points.F(1) pattern.construction_points.a1(2)];

pattern.construction_points.e1 = pattern.construction_points.E+[0,-human.hip_circumference/4];
pattern.construction_points.f1 = pattern.construction_points.F+[0,human.hip_circumference/4];

pattern.construction_points.x  = pattern.construction_points.B-[human.back_length/2 0];
pattern.construction_points.x1 = [pattern.construction_points.x(1) 0];

pattern.construction_points.x2 = [pattern.construction_points.x(1),pattern.construction_points.b3(2)-1];
pattern.construction_points.x3 = [pattern.construction_points.x1(1),pattern.construction_points.a1(2)+1];

pattern.construction_points.y  = pattern.construction_points.B-[human.back_length/4 0];
pattern.construction_points.y1 = [-human.back_length/4 0];

pattern.construction_points.z = pattern.construction_points.x + [-human.back_length/5 0];
pattern.construction_points.z1 = [pattern.construction_points.z(1) pattern.construction_points.x1(2)];
pattern.construction_points.z2 = [pattern.construction_points.z(1) pattern.construction_points.x2(2)];
pattern.construction_points.z3 = [pattern.construction_points.z(1) pattern.construction_points.x3(2)];


pattern.construction_points.y2 = [pattern.construction_points.y(1), pattern.construction_points.b2(2)+3];
pattern.construction_points.y3 = [pattern.construction_points.y1(1),pattern.construction_points.a3(2)-3];
%% back part
    
% create basic pattern 
pattern = create_basic_pattern_back_part(human, pattern);

% create production pattern 
pattern = create_production_pattern_back_part(pattern, seam, hem);

%% front part

% create basic pattern
pattern = create_basic_pattern_front_part(human,pattern); 

% create production pattern 
pattern = create_production_pattern_front_part(pattern, seam, hem); 

%% optimize production pattern of front part relating to back part
%pattern = optimize_production_pattern_front_part(pattern, seam, hem);


%% create sleeve

    % create basic pattern
    pattern = create_basic_pattern_sleeve(human, pattern);

    % create production pattern
    pattern = create_production_pattern_sleeve(pattern, seam, hem);

