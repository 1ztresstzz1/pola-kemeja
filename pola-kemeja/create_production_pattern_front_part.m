function pattern = create_production_pattern_front_part(pattern, seam, hem)

%% separate basic pattern
position = find(pattern.part_names == 'front_part');
if isempty(position)
    error('Creation of production pattern of front part failed: It is not possible to create a production pattern without basic pattern. Please use create_production_pattern_front_part first.')
end
separator = [1; find(isnan(pattern.basic_pattern(:,1)) & isnan(pattern.basic_pattern(:,2)))];
CPL = pattern.basic_pattern(separator(position):separator(position+1),:);


%% grow basic pattern with seam allowance
pgon1 = polyshape(CPL);
pgon2 = polybuffer(pgon1, seam, 'JointType','miter');
CPL = pgon2.Vertices;
CPL = [CPL; CPL(1,:)];

f=find(CPL(:,1) < pattern.construction_points.F(1));
CPL(f,:) = CPL(f,:)- [hem-seam 0];
%% side dart
if isfield(pattern.construction_points,'dart_right') % if dart exists
    % delete points inside dart
    dart = [pattern.construction_points.dart_left+[0 2*seam];...
        pattern.construction_points.dart_left;...
        pattern.construction_points.chest_point;... 
        pattern.construction_points.dart_right;...
        pattern.construction_points.dart_right+[0 2*seam]];
    in = inpolygon(CPL(:,1), CPL(:,2), dart(:,1), dart(:,2));
    %plot(CPL(in,1), CPL(in,2),'go')
    CPL(in,:) = [];
    %plot(CPL(:,1), CPL(:,2),'r.'); hold on;
   
    % projection left point on production pattern
    CPL=[CPL, zeros(length(CPL),1)];
    ptCloud = pointCloud(CPL);
    [i_l,~] = findNearestNeighbors(ptCloud, [pattern.construction_points.dart_left 0], 1); % find next point
    %plot(ptCloud.Location(i_l,1), ptCloud.Location(i_l,2),'go');
    n1 = ptCloud.Location(i_l,1:2) - pattern.construction_points.chest_point;
    n1 = n1/norm(n1);
    P1 = pattern.construction_points.dart_left + seam*n1;
    %plot(P1(:,1), P1(:,2),'bo'); hold on;
    
    % projection right point on production pattern
    [i_r,~] = findNearestNeighbors(ptCloud, [pattern.construction_points.dart_right 0], 1); % find 2 next points
    n3 = ptCloud.Location(i_r,1:2) - pattern.construction_points.chest_point;
    n3 = n3/norm(n3);
    P3 = pattern.construction_points.dart_right + seam*n3;
    %plot(P3(:,1), P3(:,2),'bo'); hold on;
    
    % triangle for folding
    Ptemp = create_P_between_P1P2_with_d(P1, P3, 0);% find middle point
    %plot(Ptemp(1), Ptemp(2),'bo');
    a = norm(Ptemp-P1);
    b = norm(pattern.construction_points.chest_point-Ptemp);
    alpha = atan(a/b);
    y = sqrt((b*tan(2*alpha)-a)^2-a^2);
    v = P1-P3;
    n = [v(2) -v(1)];
    n = n/norm(n);
    P2 = Ptemp + y*n;
    %plot(P2(1), P2(2),'bo');
    
    % clip cut at begin and end of dart
    P1a = P1-n1*pattern.construction_dimensions.cm_cc;
    P3a = P3-n3*pattern.construction_dimensions.cm_cc;
    %plot(P1a(1), P1a(2),'ro'); plot(P3a(1), P3a(2),'ro')
    
    % write into pattern
    CPL = ptCloud.Location(:,1:2);
    if i_l<i_r % clockwise
        CPL = [CPL(1:i_l,:);...
            P1; P1a; P1+[0 0.01*pattern.construction_dimensions.cm_cc];...
            P2; P3; P3a; P3+[0.01*pattern.construction_dimensions.cm_cc 0]; CPL(i_r:end,:)];
        % move second point, because in optimize_production_pattern parts
        % are transformed to polyshape, which otherwise reduces the 'double line'.
    else % anti clockwise
        CPL = [CPL(1:i_r,:);...
            P3; P3a; P3+[0 0.01*pattern.construction_dimensions.cm_cc];...
            P2; P1; P1a; P1+[0 0.01*pattern.construction_dimensions.cm_cc]; CPL(i_l:end,:)];
    end
    pattern.construction_dimensions.dart_length = norm(P2-pattern.construction_points.chest_point);
end
    
%% write production pattern    
pattern.production_pattern = [pattern.production_pattern; CPL; NaN NaN];