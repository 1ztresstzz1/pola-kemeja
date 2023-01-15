function directory = create_production_files_ep(human, pattern, varargin)
%% check name
temp = isstrprop(human.name,'alpha');
if any(~temp)
    human.name(~temp)=[];
end


%% make directory
d = date;
if length(varargin)==0 
    directory = strcat(d,'_Pola_Kemeja_LaserCut_',human.name);
else
    directory = varargin{1};
end
mkdir(directory);

%% create dxf-file for pattern
filename = fullfile(directory, 'Pola_Kemeja_LaserCut.dxf');
FID = dxf_open(filename);
separator = [1; find(isnan(pattern.production_pattern(:,1)) & isnan(pattern.production_pattern(:,2)))];

%% 
pattern.construction_dimensions.cm_d = 50; %jarak antar pola

% front part
position = find(pattern.part_names == 'front_part');
PL = pattern.production_pattern(separator(position):separator(position+1),:);
if isequaln(PL(end,:),[NaN NaN])
    PL = PL(1:end-1,:);
end
if isequaln(PL(1,:),[NaN NaN]) 
    PL = PL(2:end,:);
end
PL = PL.*10; % cm to mm
PL = PL + [0 pattern.construction_dimensions.cm_d];
PLtemp = [1 0; 0 -1]*PL'; PLtemp = PLtemp'; % mirror on x-axis
PL = [PL; PLtemp(end:-1:1,:)]; % mirrored and original assembled
PL = PL + [-min(PL(:,1)) -min(PL(:,2))]; % move to origin
edge_front = [min(PL(:,1)) max(PL(:,2))]; % save edge for other alignments
dxf_polyline(FID,PL(:,1),PL(:,2),zeros(length(PL),1));

% back part
position = find(pattern.part_names == 'back_part');
PL = pattern.production_pattern(separator(position):separator(position+1),:);
if isequaln(PL(end,:),[NaN NaN])
    PL = PL(1:end-1,:);
end
if isequaln(PL(1,:),[NaN NaN])
    PL = PL(2:end,:);
end
PL = PL.*10; % cm to mm
PL = PL - pattern.construction_points.B.*10; % move to x-axis
PLtemp = [1 0; 0 -1]*PL'; PLtemp = PLtemp'; % mirror on x-axis
PL = [PL; PLtemp(end:-1:1,:)]; % mirrored and original assembled
edge_back = [min(PL(:,1)), min(PL(:,2))];
PL = PL + (edge_front - edge_back +[0 pattern.construction_dimensions.cm_d]); % move above front part
edge_back = [max(PL(:,1)), max(PL(:,2))];
dxf_polyline(FID,PL(:,1),PL(:,2),zeros(length(PL),1));

% sleeve
position = find(pattern.part_names == 'sleeve');
if isempty(position) 
    error('Pola lengan tidak terdeteksi. Mohon tambahkan pola lengan');
elseif ~isempty(position) 
    separator = [1; find(isnan(pattern.production_pattern(:,1)) & isnan(pattern.production_pattern(:,2)))];
    PL = pattern.production_pattern(separator(position):separator(position+1),:);
    if isequaln(PL(end,:),[NaN NaN])
        PL = PL(1:end-1,:);
    end
    if isequaln(PL(1,:),[NaN NaN])
    PL = PL(2:end,:);
    end
    PL = PL.*10; % cm to mm
    PL = [0 1; -1 0]*PL'; PL = PL'; % rotation -90 deg
    PL = PL + [0 -pattern.construction_dimensions.cm_d]; % create small distance to x-axis
    PLtemp = [1 0; 0 -1]*PL'; PLtemp = PLtemp'; % mirror on x-axis
    edge_sleeve = [min(PL(:,1)), min(PL(:,2))];
    PL = PL + [-edge_sleeve(1)+edge_back(1)+pattern.construction_dimensions.cm_d -edge_sleeve(2)]; % move left of front part
    PLtemp = PLtemp + [-edge_sleeve(1)+edge_back(1)+pattern.construction_dimensions.cm_d -edge_sleeve(2)];
    edge_sleeve = [max(PLtemp(:,1)), max(PLtemp(:,2))];
    dxf_polyline(FID,PL(:,1),PL(:,2),zeros(length(PL),1));
    dxf_polyline(FID,PLtemp(:,1),PLtemp(:,2),zeros(length(PLtemp),1));
end

% mark reference length
PL = [edge_sleeve(1) edge_sleeve(2)+pattern.construction_dimensions.cm_d];
PL = [PL; PL+[-50 0]];
PL = [PL; PL(2,:)+[0 50]; PL(1,:)+[0 50]; PL(1,:)];
%PLplot(PL,'k');
dxf_polyline(FID,PL(:,1),PL(:,2),zeros(length(PL),1));
dxf_text(FID,PL(2,1),PL(2,2)-30,0,'5x5 cm', ...
  'TextHeight',20)

dxf_close(FID)
%% save human for documentation
fname = strcat(directory,'/',d,'_Data_Ukuran_',human.name);
save(fname,'human');

%% save dart length
if isfield(pattern.construction_points,'dart_right')
    fname = strcat(directory,'/',d,'_dart_length',human.name);
    dart_length = pattern.construction_dimensions.dart_length;
    save(fname,'dart_length');
end

end