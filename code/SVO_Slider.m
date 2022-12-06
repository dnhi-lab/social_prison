%% SVO SLIDER MEASURE EVALUATION FUNCTION
% 
% Kurt Ackermann, September 19, 2011

function [output, ips_format] = SVO_Slider(varargin) 

% Example 1: [Slider_output] = SVO_Slider(Data)
% Example 2: [Slider_output, All_data] = SVO_Slider(Data)
% Example 3: [Slider_output] = SVO_Slider(Versions,Data)
% Example 4: [Slider_output, All_data] = SVO_Slider(Versions,Data)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% INPUT
%
% The function accepts several variants
% of input argument constellations. The following input argument
% constellations are allowed:
%
% 1) DATA ONLY 
%   -> Primary items, or Secondary items, or All items 
%   -> Data will be evaluated according to item order of version A
%
%   1.1) Option variant (e.g. [1 9 3 2,5 ... 2], decimals for fine grained data are allowed) 
%   1.2) Full chosen payoffs variant (e.g. [50 100 85 15 ... 85 85])
%   1.3) Own payoff variant (e.g. [50 85 ... 85]) 
%        -> CAUTION WITH OWN PAYOF VARIANT: 
%           Enter OTHER ONE'S payoff in the item with undefined slope, 
%           i.e. the item with endpoints [85 85 85 15], which is item 1 in
%           version A and item 6 in version B.
% 
% 2) VERSION & DATA
%   -> 1st input argument: version ,2nd input argument: data (all of the data variants described under 1.1-1.3 are allowed)
%
%
% OUTPUT
%
% 1) If only one output argument is called, the output contains the following information given a certain input:
%
%   A) If input data is only primary items, the output has 7 columns:
%
%       Column 1: SVO Angle
%       Colunm 2: SVO Category (1=Altruistic, 2=Prosocial, 3=Individualistic, 4=Competitive)
%       Column 3: Transitivity Check (1 = Transitive, 0 = Intransitive)
%       Columns 4-7: Rank order of preferences (1st pref. & 2nd pref. & 3rd pref. & least pref.)
%
% 
%   B) If input data is only secondary items, the output has 7 columns:
%
%       Column 1: Prosocial type (1 = Inequality averse, 2 = Joint gain maximizing)
%       Colunm 2: Normalized mean distance from ideal inequality aversion options
%       Column 3: Normalized mean distance from ideal joint gain maximizing options
%       Columns 4-7: Rank order of preferences (1st pref. & 2nd pref. & 3rd pref. & least pref.)
%                    CODING: 1 = Inequality averse, 2 = Joint Max, 3 =
%                    Individualism/Competitiveness, 4 = Altruism
%
%   C) If input data is primary and secondary items, the output has 14 columns:
%
%       Columns 1-7 = Columns 1-7 from A)
%       Colunms 8-14: Columns 1-7 from B)
%   
%  2) If a second output argument is called, this second output argument
%     contains the choices made by the subjects in all items in ips-format, 
%     while items are ordered according to version A.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





if nargin == 1; % If input is data only
    
    input = cell2mat(varargin);
    
    data = input;
    version_marker = 0; % All data is according to version A
    online_version_marker = 0;
    
elseif nargin == 2; % If input is Version & Data
    
    if ischar(varargin{2}) == 0;
        
        input = cell2mat(varargin);
    
    data = input(:,2:size(input,2));
    versions = input(:,1);
    version_marker = 1; % Data are mixed versions
    online_version_marker = 0;
    
    elseif ischar(varargin{2}) == 1;
        
        input = cell2mat(varargin(1));
        data = input;
        versions = ones(size(data,1),1);
        version_marker = 1; % Data are mixed versions (artifact)
    online_version_marker = 1;
    
    end
        
    
elseif nargin == 3; % If output from online version is inserted
    
    input = cell2mat(varargin(1:2));
    data = input(:,2:(size(input,2)));
    versions = input(:,1);
    version_marker = 1; % Data are mixed versions
    online_version_marker = 1;
    
end

%Defining other markers (relevant for secondary item evaluation):
option_marker = 0; % 0 = other format, 1 = option format
fine_grain_marker = 0; % 0 = normal, 1 = fine_grained



if size(data,2) == 12 || size(data,2) == 18 || size(data,2) == 30; % If format is full payoffs
    
    if version_marker == 0;
        ips_format = full2ips(data); % Transforms data in full payoffs variant into ips_format, i.e. a 3D matrix(Items,Payoffs,Subjects)
    elseif version_marker == 1;
        conv_data = conv_full(data,versions);
        ips_format = full2ips(conv_data);
    end
    
elseif size(data,2) == 6 || size(data,2) == 9 || size(data,2) == 15; % If format is either option or partial format
    
    if min(min(data)) < 10; % If data is in option format
        
        option_marker = 1; % Mark data as option format
        
        if version_marker == 0;
            ips_format = opt2ips(data); % Transforms data in option variant into ips_format, i.e. a 3D matrix(Items,Payoffs,Subjects)
            
        elseif version_marker == 1;
            conv_data = conv_opt(data,versions);
            ips_format = opt2ips(conv_data);
        end
        
    elseif min(min(data)) > 10; % If data is in partial payoff format
        
        if version_marker == 0;
            ips_format = part2ips(data); % Transforms data in partial (own) payoffs variant into ips_format, i.e. a 3D matrix(Items,Payoffs,Subjects)
        elseif version_marker == 1;
            conv_data = conv_opt(data,versions);
            ips_format = part2ips(conv_data);
        end
        
    end
    
else
    
    ips_format = [];
    
end

if isempty(ips_format) == 0;
    output = SM_evaluation(ips_format); % Evaluate data in ips_format
else
    disp('Input error.  The inputed format is neither 6 primary items, nor 9 secondary items, nor all items...');
    output = [];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% This function evaluates Slider Measure Data in IPS format
    function [output] = SM_evaluation(ips_format)
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% Checkin if Bioinformatics Toolbox is available and licenced %%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        featureStr = {'Bioinformatics_Toolbox'};
        
        index = cellfun(@(f) license('test',f),featureStr);
        availableFeatures = featureStr(logical(index));
        index = cellfun(@(f) license('checkout',f),availableFeatures);
        checkedOutFeatures = availableFeatures(logical(index));
        
        if isempty(checkedOutFeatures) == 1;
            bio_toolbox_check = 0; % Bioinformatics toolbox missing
            disp('Bioinformatics Toolbox is not available: Check for Transitivity and rank order of preferences was not performed. Install the Bioinformatics Toolbox in order to be able to check for transitivity and produce rank order of preferences.');
        elseif isempty(checkedOutFeatures) == 0;
            bio_toolbox_check = 1; % Bioinformatics toolbox available
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        
        if size(ips_format,1) == 6; % If only primary items are used
            
            output = primary_evalu(ips_format);
            
        elseif size(ips_format,1) == 9; % If only secondary items are used
            
            if (option_marker == 0 || fine_grain_marker == 1) && online_version_marker == 0;
            [proso_type, ineq_output, real_type_ranking] = secondary_evalu(ips_format); % Proso_type: 1=Inequality, 2=Joint Gain
            % ineq_output(1): Normalized distance to ideal inequality aversion;
            % ineq_output(2): Normalized distance to ideal joint gain maximization;
            elseif option_marker == 1 && fine_grain_marker == 0;
                if version_marker == 0;
                    [proso_type, ineq_output, real_type_ranking] = secondary_evalu(data); 
                elseif version_marker == 1;
                    [proso_type, ineq_output, real_type_ranking] = secondary_evalu(conv_data);
                end
            else 
            [proso_type, ineq_output, real_type_ranking] = secondary_evalu(ips_format);    
            end
            output = [proso_type ineq_output real_type_ranking];
            
            
        elseif size(ips_format,1) == 15; % If all items are used
            
            primary_data = ips_format(1:6,:,:);
            secondary_data = ips_format(7:15,:,:);
            
            output_1 = primary_evalu(primary_data);
            
            if (option_marker == 0 || fine_grain_marker == 1) && online_version_marker == 0;
            [proso_type, ineq_output, real_type_ranking] = secondary_evalu(secondary_data); % Proso_type: 1=Inequality, 2=Joint Gain
            % ineq_output(1): Distance to ideal inequality aversion;
            % ineq_output(2): Distance to ideal joint gain maximization;
            elseif option_marker == 1 && fine_grain_marker == 0;
                if version_marker == 0;
                    [proso_type, ineq_output, real_type_ranking] = secondary_evalu(data(:,7:15)); 
                elseif version_marker == 1;
                    [proso_type, ineq_output, real_type_ranking] = secondary_evalu(conv_data(:,7:15));
                end
            else 
            [proso_type, ineq_output, real_type_ranking] = secondary_evalu(secondary_data);
            end
            output = [output_1 proso_type ineq_output real_type_ranking];
            
        end
        
        
        %% Function for evaluating the Primary items
        
        function [output] = primary_evalu(primary_data)
            
            SVO_angles = zeros(size(primary_data,3),1);
            SVO_cat = zeros(size(primary_data,3),1);
            transitivity = zeros(size(primary_data,3),1);
            ranking_out = zeros(size(primary_data,3),4);
            
            for count = 1:size(primary_data,3);
                if isnan(sum(sum(primary_data(:,:,count)))) == 1; % If there is missing value in the primary items
                    SVO_angles(count,1) = NaN;
                    SVO_cat(count,1) = NaN;
                    transitivity(count,1) = NaN;
                    ranking_out(count,1:4) = NaN;
                    
                elseif isnan(sum(sum(primary_data(:,:,count)))) == 0;
                    SVO_angles(count,1) = atand((mean(primary_data(:,2,count))-50)./(mean(primary_data(:,1,count))-50));
                    SVO_cat(count,1) = angle2cat(SVO_angles(count,1));
                    if bio_toolbox_check == 1;
                        [transitivity(count,1), ranking_out(count,:)] = transitivity_check_ranking(primary_data(:,:,count));
                    elseif bio_toolbox_check == 0;
                        transitivity(count,1) = NaN;
                        ranking_out(count,:) = NaN;
                    end
                    
                    
                end
                
            end
            
            output = [SVO_angles SVO_cat transitivity ranking_out];
            
        end
        
        
        
        %% Function for evaluating the Secondary items
        
        function [type_id, ineq_output real_type_ranking] = secondary_evalu(secondary_data)
            
            
            if online_version_marker == 0;
                
                %% If data is in IPS format
                
                if size(secondary_data,2) == 2;
                    
                    secondary_data = round(secondary_data);
                    
                    
                    ineq_output = zeros(size(secondary_data,3),2);
                    type_id = zeros(size(secondary_data,3),1);
                    real_type_ranking = zeros(size(secondary_data,3),4);
                    
                    %% Determine inequality option position between 0 and 1:
                    
                    item_endpoints_self = [
                        100 70
                        90 100
                        100 50
                        100 90
                        70 100
                        50 100
                        50 100
                        100 70
                        90 100];
                    
                    item_range_self = zeros(size(item_endpoints_self,1),101);
                    item_range_other = zeros(size(item_endpoints_self,1),101);
                    ineq_index = zeros(size(item_endpoints_self,1),1);
                    for count = 1:size(item_endpoints_self,1);
                        item_range_self(count,:) = linspace(item_endpoints_self(count,1),item_endpoints_self(count,2),101);
                        item_range_other(count,:) = item(6+count,item_range_self(count,:));
                        [~, ineq_index(count,1)] = min(abs(item_range_self(count,:)-item_range_other(count,:)));
                    end
                    
                    
                    
                    ideal_inequality_aversion = ineq_index';
                    
                    
                    ideal_joint_maximizer=[
                        101
                        NaN
                        1
                        101
                        NaN
                        101
                        NaN
                        1
                        1]';
                    
                    ideal_individualist = [
                        1
                        101
                        1
                        1
                        101
                        101
                        101
                        1
                        101]';
                    
                    ideal_altruist =[
                        101
                        1
                        101
                        101
                        1
                        1
                        1
                        101
                        1]';
                    
                    
                    %% Determine chosen option position between 0 and 1:
                    
                    secondary_data_option = zeros(size(secondary_data,3),size(secondary_data,1));
                    
                    for count = 1:size(secondary_data,3);
                        for count_2 = 1:size(secondary_data,1);
                            if isnan(secondary_data(count_2,1,count)) == 0;
                                [~, secondary_data_option(count,count_2)] = min(abs(secondary_data(count_2,1,count)-item_range_self(count_2,:)));
                            else
                                secondary_data_option(count,count_2) = NaN;
                            end
                        end
                    end
                    
                    max_diff = 101-1;
                    
                    
                    %% If data is in option format
                elseif size(secondary_data,2) == 9;
                    
                    
                    ineq_output = zeros(size(secondary_data,1),2);
                    type_id = zeros(size(secondary_data,1),1);
                    real_type_ranking = zeros(size(secondary_data,1),4);
                    
                    
                    ideal_inequality_aversion =[
                        6
                        5
                        4
                        7
                        5
                        8
                        5
                        3
                        2]';
                    
                    ideal_joint_maximizer=[
                        9
                        NaN
                        1
                        9
                        NaN
                        9
                        NaN
                        1
                        1]';
                    
                    ideal_individualist = [
                        1
                        9
                        1
                        1
                        9
                        9
                        9
                        1
                        9]';
                    
                    ideal_altruist =[
                        9
                        1
                        9
                        9
                        1
                        1
                        1
                        9
                        1]';
                    
                    max_diff = 9-1;
                    
                    secondary_data_option = secondary_data;
                end
                
                
                
                %% Calculate differences
                Ineq_diff = nanmean(((abs(secondary_data_option-(repmat(ideal_inequality_aversion,size(secondary_data_option,1),1))))./max_diff),2);
                joint_diff = nanmean(((abs(secondary_data_option-(repmat(ideal_joint_maximizer,size(secondary_data_option,1),1))))./max_diff),2);
                indi_diff = nanmean(((abs(secondary_data_option-(repmat(ideal_individualist,size(secondary_data_option,1),1))))./max_diff),2);
                altr_diff = nanmean(((abs(secondary_data_option-(repmat(ideal_altruist,size(secondary_data_option,1),1))))./max_diff),2);
                
                diff_mat = [Ineq_diff joint_diff indi_diff altr_diff];
                
                % IF higher resolution online-version is used:
            elseif online_version_marker == 1;
                
                ineq_output = zeros(size(secondary_data,3),2);
                type_id = zeros(size(secondary_data,3),1);
                real_type_ranking = zeros(size(secondary_data,3),4);
                
                %% Determine inequality option position between 0 and 1:
                
                
                slope = [
                    .6;
                    1;
                    (5/3);
                    (1/3);
                    1;
                    5;
                    1;
                    3;
                    .2];
                
                
                item_endpoints_self = [
                    100 70
                    90 100
                    100 50
                    100 90
                    70 100
                    50 100
                    50 100
                    100 70
                    90 100];
                
                
                item_endpoints_other = [
                    50 100
                    100 90
                    70 100
                    70 100
                    100 70
                    100 90
                    100 50
                    90 100
                    100 50];
                
                max_diff = zeros(9,1);
                for count = 1:9;
                    max_diff(count,1) = pdist([item_endpoints_self(count,:);item_endpoints_other(count,:)]);
                end
                
                
                ideal_inequality_aversion_proxy = [
                    81 81
                    95 95
                    81 81
                    93 93
                    85 85
                    92 92
                    75 75
                    93 93
                    92 92];
                
                ideal_inequality_aversion = zeros(9,2);
                for count = 1:9;
                    ideal_inequality_aversion(count,:) = projectpoint(min(item_endpoints_other(count,:)),slope(count),ideal_inequality_aversion_proxy(count,1),ideal_inequality_aversion_proxy(count,2));
                end
                
                
                ideal_joint_maximizer=[
                    70 100
                    NaN NaN
                    100 70
                    90 100
                    NaN NaN
                    100 90
                    NaN NaN
                    100 90
                    90 100];
                
                ideal_individualist = [
                    100 50
                    100 90
                    100 70
                    100 70
                    100 70
                    100 90
                    100 50
                    100 90
                    100 50];
                
                ideal_altruist =[
                    70 100
                    90 100
                    50 100
                    90 100
                    70 100
                    50 100
                    50 100
                    70 100
                    90 100];
                
                
                
                
                % Project all chosen points on item lines
                
                projected_choices = zeros(size(secondary_data));
                for count_1 = 1:size(secondary_data,3);
                    for count_2 = 1:9;
                        projected_choices(count_2,:,count_1) = projectpoint(min(item_endpoints_other(count_2,:)),slope(count_2),secondary_data(count_2,1,count_1),secondary_data(count_2,2,count_1));
                    end
                end
                
                
                
                
                Ineq_diff_proxy = zeros(9,1);
                joint_diff_proxy = zeros(9,1);
                indi_diff_proxy = zeros(9,1);
                altr_diff_proxy = zeros(9,1);
                
                Ineq_diff = zeros(size(secondary_data,3),1);
                joint_diff = zeros(size(secondary_data,3),1);
                indi_diff = zeros(size(secondary_data,3),1);
                altr_diff = zeros(size(secondary_data,3),1);
                
                for count = 1:size(secondary_data,3);
                    for count_2 = 1:9;
                        
                        Ineq_diff_proxy(count_2,1) = (pdist([projected_choices(count_2,:,count) ; ideal_inequality_aversion(count_2,:)]))./(max_diff(count_2));
                        joint_diff_proxy(count_2,1) = pdist([projected_choices(count_2,:,count) ; ideal_joint_maximizer(count_2,:)])./(max_diff(count_2));
                        indi_diff_proxy(count_2,1) = pdist([projected_choices(count_2,:,count) ; ideal_individualist(count_2,:)])./(max_diff(count_2));
                        altr_diff_proxy(count_2,1) = pdist([projected_choices(count_2,:,count) ; ideal_altruist(count_2,:)])./(max_diff(count_2));
                        
                        Ineq_diff(count,1) = nanmean(Ineq_diff_proxy);
                        joint_diff(count,1) = nanmean(joint_diff_proxy);
                        indi_diff(count,1) = nanmean(indi_diff_proxy);
                        altr_diff(count,1) = nanmean(altr_diff_proxy);
                        
                        
                        
                    end
                    
                    Ineq_diff_proxy = [];
                    joint_diff_proxy = [];
                    indi_diff_proxy = [];
                    altr_diff_proxy = [];
                end
                secondary_data_option = ones(size(secondary_data,3),1);
                
                diff_mat = [Ineq_diff joint_diff indi_diff altr_diff];
                
            end
            
            
            
            [secondary_ranking_values,secondary_ranking_out] = sort(diff_mat,2,'ascend'); % 1 = Inequality, 2 = Joint Max, 3 = Individualism, 4 = Altrusism
            
            
            for count = 1:size(secondary_data_option,1);
                
                if isnan(mean(secondary_ranking_values(count,:),2)) == 0;
                
                if secondary_ranking_out(count,1)+secondary_ranking_out(count,2) == 3; % If inequality and joint max are ranked first..
                    
                    if secondary_ranking_values(count,1) == secondary_ranking_values(count,2); % If there is a tie
                        type_id(count,1) = 0.5;
                        ineq_output(count,:) = [.5 .5]; %1st column ineq dist percent, 2nd column joint max dist percent
                        real_type_ranking(count,:) = secondary_ranking_out(count,:);
                        
                    else
                        type_id(count,1) = secondary_ranking_out(count,1); % 1 = Inequality, 2 = Joint Max
                        ineq_output(count,:) = [Ineq_diff(count,1)./(Ineq_diff(count,1)+joint_diff(count,1)) joint_diff(count,1)./(Ineq_diff(count,1)+joint_diff(count,1))];
                        real_type_ranking(count,:) = secondary_ranking_out(count,:);
                        
                    end
                    
                else % If inequality and joint max are NOT ranked first..
                    
                    type_id(count,1) = NaN; % 1 = Inequality, 2 = Joint Max
                    ineq_output(count,:) = [NaN NaN];
                    real_type_ranking(count,:) = secondary_ranking_out(count,:);
                    
                end
                
                else
                    
                    type_id(count,1) = NaN; % 1 = Inequality, 2 = Joint Max
                    ineq_output(count,:) = [NaN NaN];
                    real_type_ranking(count,:) = [NaN NaN NaN NaN];
                    
                end
                    
            end
        end
        
        
        
        %% Function for checking for transitivity and producing rank order of
        %% preferences
        
        function [transitivity, ranking_out] = transitivity_check_ranking(primary_data)
            
            % EXAMPLE
            % one DM's selected alocations from the 6 sliders, version 1
            % input_matrix =[85    85; 100    50; 85    85; 50   100; 75    75; 85    85];
            
            
            
            item_endpoints =[85 85 85 15
                85 15 100 50
                50 100 85 85
                50 100 85 15
                100 50 50 100
                100 50 85 85];
            catagories = [2 4; 4 3; 1 2; 1 4; 3 1; 3 2]; % 1=alt, 2=prosoc, 3=ind, 4=comp
            
            distance_matrix = zeros(6,2);
            endpoint_distance = zeros(6,1);
            for count = 1 : 6;
                distance_matrix(count,1) = pdist([primary_data(count,:); item_endpoints(count,[1 2])]);
                distance_matrix(count,2) = pdist([primary_data(count,:); item_endpoints(count,[3 4])]);
                endpoint_distance(count,1) = pdist([item_endpoints(count,[1 2]); item_endpoints(count,[3 4])]);
            end
            
            ranking = zeros(1,4);
            compare1 = zeros(1,6);
            compare2 = zeros(1,6);
     
%             % Uncomment the following lines and comment the ones below for applying 1/3 margin transitivity rule 
%             
%             endpoint_thresholds = endpoint_distance./3;
%             
%             for count = 1 : 6
%                 if (distance_matrix(count,1) < distance_matrix(count,2)) 
%                     if distance_matrix(count,1) < endpoint_thresholds(count,1);
%                     compare1(count) = catagories(count,1);
%                     compare2(count) = catagories(count,2);
%                     ranking(catagories(count,1)) = ranking(catagories(count,1)) + 1;
%                     ranking(catagories(count,2)) = ranking(catagories(count,2)) + 0;
%                     else
%                     ranking(catagories(count,1)) = ranking(catagories(count,1)) + .5;
%                     ranking(catagories(count,2)) = ranking(catagories(count,2)) + .5;
%                     end
%                 elseif distance_matrix(count,1) > distance_matrix(count,2);
%                     if distance_matrix(count,2) < endpoint_thresholds(count,1);
%                     compare2(count) = catagories(count,1);
%                     compare1(count) = catagories(count,2);
%                     ranking(catagories(count,1)) = ranking(catagories(count,1)) + 0;
%                     ranking(catagories(count,2)) = ranking(catagories(count,2)) + 1;
%                     else
%                     ranking(catagories(count,1)) = ranking(catagories(count,1)) + .5;
%                     ranking(catagories(count,2)) = ranking(catagories(count,2)) + .5;
%                     end
%                 elseif distance_matrix(count,1) == distance_matrix(count,2);
%                     ranking(catagories(count,1)) = ranking(catagories(count,1)) + .5;
%                     ranking(catagories(count,2)) = ranking(catagories(count,2)) + .5;
%                 end
%             end
            
%             Uncomment the above lines and comment the following in order
%             to apply 1/3 transitivity rule:
%
            for count = 1 : 6
                if distance_matrix(count,1) < distance_matrix(count,2);
                    compare1(count) = catagories(count,1);
                    compare2(count) = catagories(count,2);
                    ranking(catagories(count,1)) = ranking(catagories(count,1)) + 1;
                    ranking(catagories(count,2)) = ranking(catagories(count,2)) + 0;
                elseif distance_matrix(count,1) > distance_matrix(count,2);
                    compare2(count) = catagories(count,1);
                    compare1(count) = catagories(count,2);
                    ranking(catagories(count,1)) = ranking(catagories(count,1)) + 0;
                    ranking(catagories(count,2)) = ranking(catagories(count,2)) + 1;
                elseif distance_matrix(count,1) == distance_matrix(count,2);
                    ranking(catagories(count,1)) = ranking(catagories(count,1)) + .5;
                    ranking(catagories(count,2)) = ranking(catagories(count,2)) + .5;
                end
            end
            
            %
            
            compare1(compare1==0) = [];
            compare2(compare2==0) = [];
            
            DG = sparse(compare1,compare2,true,4,4);
            
            % view(biograph(DG))
            
            transitivity = graphisdag(DG);
            
            if transitivity == 1;
                
                [~,ranking_out] = sort(ranking,'descend');
                
            elseif transitivity == 0;
                
                ranking_out(1:4) = NaN;
                
            end
            
            
        end
        
        
        %% Function for categorizing subjects according to SVO angles
        
        function [SVO_cat] = angle2cat(SVO_angles)
            if SVO_angles >= 57.15;
                SVO_cat = 1; % Altruism = 1
            elseif SVO_angles < 57.15 && SVO_angles >= 22.45;
                SVO_cat = 2; % Prosocial = 2;
            elseif SVO_angles < 22.45 && SVO_angles >= -12.04;
                SVO_cat = 3; % Individualistic = 3;
            elseif SVO_angles < -12.04;
                SVO_cat = 4; % Competitiveness = 4;
            elseif isnan(SVO_angles) == 1;
                SVO_cat = NaN;
            else
                SVO_cat = 0; % Unclassifiable because on border = 0;
            end
            
        end
        
        
    end




%% Item function:

    function [value] = item(item_nr,payoff)
        if item_nr == 1;
            value = payoff; % Insert payoff for the other in item 1!  This is the item with an undefined slope.
        elseif item_nr == 2;
            value = ((7/3).*payoff) - (550/3);
        elseif item_nr == 3;
            value = ((-3/7).*payoff) + (850/7);
        elseif item_nr == 4;
            value = (-(17/7).*payoff) + (1550/7);
        elseif item_nr == 5;
            value = (-1.*payoff) + 150;
        elseif item_nr == 6;
            value = (-(7/3).*payoff) + (850/3);
        elseif item_nr == 7;
            value = (-(5/3).*payoff) + (650/3);
        elseif item_nr == 8;
            value = ((-1).*payoff) + 190;
        elseif item_nr == 9;
            value = (-(3/5).*payoff) + 130;
        elseif item_nr == 10;
            value = ((-3).*payoff) + 370;
        elseif item_nr == 11;
            value = ((-1).*payoff) + 170;
        elseif item_nr == 12;
            value = (-(1/5).*payoff) + 110;
        elseif item_nr == 13;
            value = ((-1).*payoff) + 150;
        elseif item_nr == 14;
            value = (-(1/3).*payoff) + (370/3);
        elseif item_nr == 15;
            value = ((-5).*payoff) + 550;
        end
    end

%% Inverse item function:

    function [value] = item_inverse(item_nr,payoff)
        if item_nr == 1;
            value = 85;
        elseif item_nr == 2;
            value = (payoff+(550/3))/(7/3);
        elseif item_nr == 3;
            value = (payoff-(850/7))/(-3/7);
        elseif item_nr == 4;
            value = (payoff-(1550/7))/(-17/7);
        elseif item_nr == 5;
            value = (payoff - 150)/-1;
        elseif item_nr == 6;
            value = (payoff - (850/3))/(-7/3);
        elseif item_nr == 7;
            value = (payoff-(650/3))/(-5/3);
        elseif item_nr == 8;
            value = (payoff-190)/-1;
        elseif item_nr == 9;
            value = (payoff-130)/(-3/5);
        elseif item_nr == 10;
            value = (payoff-370)/-3;
        elseif item_nr == 11;
            value = (payoff-170)/-1;
        elseif item_nr == 12;
            value = (payoff-110)/(-1/5);
        elseif item_nr == 13;
            value = (payoff-150)/-1;
        elseif item_nr == 14;
            value = (payoff-(370/3))/(-1/3);
        elseif item_nr == 15;
            value = (payoff-550)/-5;
        end
    end



%% Function for transforming data in option variant into ips_format
%
% ips_format: 3 dimensional matrix containing items as rows, payoffs as
% columns (1st column = payoff to self, 2nd column = payoff to other), and
% subjects as the third dimension

    function [ips_format] = opt2ips(data)
        
        if size(data,2) == 6 || size(data,2) == 15 || size(data,2) == 9;
            
            ips_format = zeros(size(data,2),2,size(data,1));
            
            SM_stim_v1 = [
                85 85 85 76 85 68 85 59 85 50 85 41 85 33 85 24 85 15
                85 15 87 19 89 24 91 28 93 33 94 37 96 41 98 46 100 50
                50 100 54 98 59 96 63 94 68 93 72 91 76 89 81 87 85 85
                50 100 54 89 59 79 63 68 68 58 72 47 76 36 81 26 85 15
                100 50 94 56 88 63 81 69 75 75 69 81 63 88 56 94 50 100
                100 50 98 54 96 59 94 63 93 68 91 72 89 76 87 81 85 85
                ];
            
            SM_inequality_stim_v1 = [
                100 50 96 56 93 63 89 69 85 75 81 81 78 88 74 94 70 100
                90 100 91 99 93 98 94 96 95 95 96 94 98 93 99 91 100 90
                100 70 94 74 88 78 81 81 75 85 69 89 63 93 56 96 50 100
                100 70 99 74 98 78 96 81 95 85 94 89 93 93 91 96 90 100
                70 100 74 96 78 93 81 89 85 85 89 81 93 78 96 74 100 70
                50 100 56 99 63 98 69 96 75 95 81 94 88 93 94 91 100 90
                50 100 56 94 63 88 69 81 75 75 81 69 88 63 94 56 100 50
                100 90 96 91 93 93 89 94 85 95 81 96 78 98 74 99 70 100
                90 100 91 94 93 88 94 81 95 75 96 69 98 63 99 56 100 50
                ];
            
            SM_payoffself_v1 = SM_stim_v1(:,1:2:17);
            SM_payoffother_v1 = SM_stim_v1(:,2:2:18);
            SM_inequality_payoffself_v1 = SM_inequality_stim_v1(:,1:2:17);
            SM_inequality_payoffother_v1 = SM_inequality_stim_v1(:,2:2:18);
            SM_all_items_self = [SM_payoffself_v1; SM_inequality_payoffself_v1];
            SM_all_items_other = [SM_payoffother_v1; SM_inequality_payoffother_v1];
            
            if nansum(nansum(data-floor(data))) == 0 % If data in option variant are all integers (not fine grained)
                
                fine_grain_marker = 0; %Mark data as not fine grained
                
                for count_1 = 1:size(data,1);
                    
                    for count_2 = 1:size(data,2);
                        
                        if size(data,2) == 6; % If only primary items are used
                            
                            if isnan(data(count_1,count_2)) == 0;
                                ips_format(count_2,:,count_1) = [SM_payoffself_v1(count_2,data(count_1,count_2)) SM_payoffother_v1(count_2,data(count_1,count_2))];
                            else
                                ips_format(count_2,:,count_1) = [NaN NaN];
                            end
                        elseif size(data,2) == 9; %If onyl secondary items are used
                            
                            if isnan(data(count_1,count_2)) == 0;
                                ips_format(count_2,:,count_1) = [SM_inequality_payoffself_v1(count_2,data(count_1,count_2)) SM_inequality_payoffother_v1(count_2,data(count_1,count_2))];
                            else
                                ips_format(count_2,:,count_1) = [NaN NaN];
                            end
                            
                        elseif size(data,2) == 15; %If all items are used
                            
                            if isnan(data(count_1,count_2)) == 0;
                                ips_format(count_2,:,count_1) = [SM_all_items_self(count_2,data(count_1,count_2)) SM_all_items_other(count_2,data(count_1,count_2))];
                            else
                                ips_format(count_2,:,count_1) = [NaN NaN];
                            end
                        end
                        
                    end
                    
                end
                
            else % If data in option variant is also decimals (fine grained)
                
                fine_grain_marker = 1;
                
                data = (round(data.*10))./10; % If there is more than one decimal, round such that there is only one decimal
                data_fine_grained = ((data.*10)+1)-10; % Convert data such that the values can be used as indexes
                
                item_extension_self_all = zeros(size(SM_all_items_self,1),81); % 81 because: length([1:.1:9]) = 81
                item_extension_other_all = zeros(size(SM_all_items_other,1),81); % 81 because: length([1:.1:9]) = 81
                
                
                for count = 1:size(SM_all_items_self,1);
                    item_extension_self_all(count,:) = linspace(SM_all_items_self(count,1),SM_all_items_self(count,size(SM_all_items_self,2)),81);
                    item_extension_other_all(count,:) = linspace(SM_all_items_other(count,1),SM_all_items_other(count,size(SM_all_items_other,2)),81);
                end
                
                item_extension_self_primary = item_extension_self_all(1:6,:);
                item_extension_other_primary = item_extension_other_all(1:6,:);
                item_extension_self_secondary = item_extension_self_all(7:15,:);
                item_extension_other_secondary = item_extension_other_all(7:15,:);
                
                for count_1 = 1:size(data,1);
                    
                    for count_2 = 1:size(data,2);
                        
                        if size(data,2) == 6; % If only primary items are used
                            if isnan(data_fine_grained(count_1,count_2)) == 0;
                                ips_format(count_2,:,count_1) = [item_extension_self_primary(count_2,data_fine_grained(count_1,count_2)) item_extension_other_primary(count_2,data_fine_grained(count_1,count_2))];
                            else
                                ips_format(count_2,:,count_1) = [NaN NaN];
                            end
                        elseif size(data,2) == 9; %If onyl secondary items are used
                            if isnan(data_fine_grained(count_1,count_2)) == 0;
                                ips_format(count_2,:,count_1) = [item_extension_self_secondary(count_2,data_fine_grained(count_1,count_2)) item_extension_other_secondary(count_2,data_fine_grained(count_1,count_2))];
                            else
                                ips_format(count_2,:,count_1) = [NaN NaN];
                            end
                            
                        elseif size(data,2) == 15; %If all items are used
                            if isnan(data_fine_grained(count_1,count_2)) == 0;
                                ips_format(count_2,:,count_1) = [item_extension_self_all(count_2,data_fine_grained(count_1,count_2)) item_extension_other_all(count_2,data_fine_grained(count_1,count_2))];
                            else
                                ips_format(count_2,:,count_1) = [NaN NaN];
                            end
                        end
                        
                    end
                    
                end
                
            end
            
        else
            disp('Format is neither 6 primary items, nor 9 secondary items, nor all items...');
            ips_format = [];
        end
        
    end



%% Function for transforming data in full payoff variant into ips_format
%
% ips_format: 3 dimensional matrix containing items as rows, payoffs as
% columns (1st column = payoff to self, 2nd column = payoff to other), and
% subjects as the third dimension

    function  ips_format = full2ips(data)
        
        if size(data,2) == 12 || size(data,2) == 18 || size(data,2) == 30;
            
            payoff_self = data(:,1:2:(size(data,2)-1));
            payoff_other = data(:,2:2:size(data,2));
            
            ips_format = zeros(size(payoff_self,2),2,size(data,1));
            
            for count_1 = 1:size(data,1);
                for count_2 = 1:size(payoff_self,2);
                    if isnan(payoff_self(count_1,count_2)) == 0 && isnan(payoff_other(count_1,count_2)) == 0;
                        ips_format(count_2,:,count_1) = [payoff_self(count_1,count_2) payoff_other(count_1,count_2)];
                    elseif isnan(payoff_self(count_1,count_2)) == 0 && isnan(payoff_other(count_1,count_2)) == 1;
                        if count_2 == 1;
                            ips_format(count_2,:,count_1) = [payoff_self(count_1,count_2) NaN];
                        else
                            ips_format(count_2,:,count_1) = [payoff_self(count_1,count_2) item(count_2,payoff_self(count_1,count_2))];
                        end
                    elseif isnan(payoff_self(count_1,count_2)) == 1 && isnan(payoff_other(count_1,count_2)) == 0;
                        if count_2 == 1;
                            ips_format(count_2,:,count_1) = [85 payoff_other(count_1,count_2)]; %Payoff for self in item 1 is always 85
                        else
                            ips_format(count_2,:,count_1) = [item_inverse(count_2,payoff_other(count_1,count_2)) payoff_other(count_1,count_2)];
                        end
                    else
                        ips_format(count_2,:,count_1) = [NaN NaN];
                    end
                end
            end
            
        else
            disp('Format is neither 6 primary items, nor 9 secondary items, nor all items...');
            ips_format = [];
        end
    end



%% Function for transforming data in partial payoff variant into ips_format
%
% ips_format: 3 dimensional matrix containing items as rows, payoffs as
% columns (1st column = payoff to self, 2nd column = payoff to other), and
% subjects as the third dimension

    function  ips_format = part2ips(data)
        
        
        ips_format = zeros(size(data,2),2,size(data,1));
        
        if size(data,2) == 6 || size(data,2) == 15 || size(data,2) == 9;
            
            for count_1 = 1:size(data,1);
                for count_2 = 1:size(data,2);
                    
                    if size(data,2) == 6 || size(data,2) == 15;
                        if count_2 == 1; % In the first item, payoffs to the self are always 85
                            if isnan(data(count_1,count_2)) == 0;
                                ips_format(count_2,:,count_1) = [85 data(count_1,count_2)];
                            else
                                ips_format(count_2,:,count_1) = [85 NaN];
                            end
                        else
                            if isnan(data(count_1,count_2)) == 0;
                                ips_format(count_2,:,count_1) = [data(count_1,count_2) item(count_2,data(count_1,count_2))];
                            else
                                ips_format(count_2,:,count_1) = [NaN NaN];
                            end
                        end
                        
                    elseif size(data,2) == 9;
                        if isnan(data(count_1,count_2)) == 0;
                            ips_format(count_2,:,count_1) = [data(count_1,count_2) item(count_2+6,data(count_1,count_2))];
                        else
                            ips_format(count_2,:,count_1) = [NaN NaN];
                        end
                        
                    end
                    
                end
            end
            
        else
            disp('Format is neither 6 primary items, nor 9 secondary items, nor all items...');
            ips_format = [];
        end
    end



%% Function for converting mixed versions full payoff data into version 1
%% full payoff data

    function    [conv_data] = conv_full(data,versions)
        
        payoffself(1:size(data,1),1:(size(data,2)/2)) = data(:,1:2:(size(data,2)-1));
        payoffother(1:size(data,1),1:(size(data,2)/2)) = data(:,2:2:size(data,2));
        
        conv_data = zeros(size(data));
        
        if size(data,2) == 12 || size(data,2) == 18; % If only primary items OR only secondary items are used
            
            for count = 1:size(data,1);
                if versions(count) == 2; % Convert version 2 into version 1
                    payoffself(count,:) = fliplr(payoffself(count,:));
                    payoffother(count,:) = fliplr(payoffother(count,:));
                elseif versions(count) == 1; % Version 1 stays the same
                    payoffself(count,:) = payoffself(count,:);
                    payoffother(count,:) = payoffother(count,:);
                elseif isnan(versions(count)) == 1; %If version is missing, make output NaNs
                    payoffself(count,:) = NaN; 
                    payoffother(count,:) = NaN;
                end
            end
            for count_1 = 1:size(data,1)
                for count_2 = 1:size(payoffself,2);
                    
                        conv_data(count_1,[((count_2.*2)-1) (count_2.*2)]) = [payoffself(count_1,count_2) payoffother(count_1,count_2)];
                        
                    
                end
                
            end
            
        elseif size(data,2) == 30
            
            payoffself_primary = payoffself(:,1:6);
            payoffself_secondary = payoffself(:,7:15);
            payoffother_primary = payoffother(:,1:6);
            payoffother_secondary = payoffother(:,7:15);
            
            for count = 1:size(data,1);
                if versions(count) == 2; % Convert version 2 into version 1
                    payoffself_primary(count,:) = fliplr(payoffself_primary(count,:));
                    payoffother_primary(count,:) = fliplr(payoffother_primary(count,:));
                    payoffself_secondary(count,:) = fliplr(payoffself_secondary(count,:));
                    payoffother_secondary(count,:) = fliplr(payoffother_secondary(count,:));
                elseif versions(count) == 1; % Version 1 stays the same
                    payoffself_primary(count,:) = payoffself_primary(count,:);
                    payoffother_primary(count,:) = payoffother_primary(count,:);
                    payoffself_secondary(count,:) = payoffself_secondary(count,:);
                    payoffother_secondary(count,:) = payoffother_secondary(count,:);
                elseif isnan(versions(count)) == 1; %If version is missing, make output NaNs
                    payoffself_primary(count,:) = NaN;
                    payoffother_primary(count,:) = NaN;
                    payoffself_secondary(count,:) = NaN;
                    payoffother_secondary(count,:) = NaN;
                end
            end
            
            payoffself = [payoffself_primary payoffself_secondary];
            payoffother = [payoffother_primary payoffother_secondary];
            
            for count_1 = 1:size(data,1)
                for count_2 = 1:size(payoffself,2);
                    
                        conv_data(count_1,[((count_2.*2)-1) (count_2.*2)]) = [payoffself(count_1,count_2) payoffother(count_1,count_2)];
                        
                    
                end
                
            end
            
        end
    end


%% Function for converting mixed versions options data into version 1
%% options data

    function  [conv_data] = conv_opt(data,versions)
        
        conv_data = zeros(size(data));
        
        if size(data,2) == 6 || size(data,2) == 9;
            for count = 1:size(data,1);
                if versions(count) == 1;
                    conv_data(count,:) = data(count,:);
                elseif versions(count) == 2;
                    conv_data(count,:) = fliplr(data(count,:));
                elseif isnan(versions(count)) == 1; %If version is missing, make output NaNs
                    conv_data(count,:) = NaN;
                end
                
            end
            
            
        elseif size(data,2) == 15;
            
            primary_data = data(:,1:6);
            secondary_data = data(:,7:15);
            for count = 1:size(data,1);
                if versions(count) == 1;
                    conv_data(count,:) = data(count,:);
                elseif versions(count) == 2;
                    conv_data(count,:) = [fliplr(primary_data(count,:)) fliplr(secondary_data(count,:))];
                elseif isnan(versions(count)) == 1; %If version is missing, make output NaNs
                    conv_data(count,:) = NaN;
                end
            end
        end
        
        
    end


    function [projection_point] = projectpoint(low_other,slope,self,other)
        
        s_one = -1.*slope;
        s_two = -1./s_one;
        c_one = -1.*s_one.*low_other+100;
        c_two = self - s_two.*other;
        x = (c_one-c_two)./(s_two-s_one);
        y = x.*s_one+c_one;



        projection_point = [y x];
        
    end

end