function data = importData()
% Import data from a CSV file into matlab structure and make slight changes
% to make data more useable. The structure 'data' includes 4 variables: 
% 'allT' includes only participants who finished all tasks 
% 'allP' includes all participants whose data we can use
% 'someT' includes only participants who didn't do the 2*2 games
% 'labels' includes a description of each column

% Import all participants into allP
data.allP = xlsread('data');
data.allP(1,:) = []; % Exclude the header-row
data.allP(isnan(data.allP(:,42)),:) = []; % Exclude those without PCLR scores

% Exclude participants who only did SVO (3 participants with language problems)
data.allP(isnan(data.allP(:,21)),:) = [];

% Recode the category column from a 1-3 to a 1-5 scale
% (1 = 0-8, 2 = 9-16, 3 = 17-24, 4 = 25-32, 5 = 33-40)
for iPS = 1:length(data.allP(:,69))
    if data.allP(iPS,69) < 9
        data.allP(iPS,72) = 1;
    elseif data.allP(iPS,69) >= 9 && data.allP(iPS,69) < 17
        data.allP(iPS,72) = 2;
    elseif data.allP(iPS,69) >= 17 && data.allP(iPS,69) < 25
        data.allP(iPS,72) = 3;
    elseif data.allP(iPS,69) >= 25 && data.allP(iPS,69) < 33
        data.allP(iPS,72) = 4;
    elseif data.allP(iPS,69) >= 33
        data.allP(iPS,72) = 5;
    end
end

% Copy allP into allT and exclude participants who didn't do all tasks
data.allT = data.allP;
data.allT(isnan(data.allT(:,41)),:) = [];

% Copy allP into someT and exclude participants who did all tasks
data.someT = data.allP(isnan(data.allP(:,41)),:);

% Create list of column labels
data.labels  = {
'01: ID'
'02: SVO order (1 = A, 2 = B)'
'03: SVO Q1'
'04: SVO Q2'
'05: SVO Q3'
'06: SVO Q4'
'07: SVO Q5'
'08: SVO Q6'
'09: SVO Q7'
'10: SVO Q8'
'11: SVO Q9'
'12: SVO Q10'
'13: SVO Q11'
'14: SVO Q12'
'15: SVO Q13'
'16: SVO Q14'
'17: SVO Q15'
'18: DG self'
'19: UG self'
'20: UG offer 1 (50/50) (1 = accept, 0 = reject)'
'21: UG offer 1 fair (100 completely fair, 0 completely not fair)'
'22: UG offer 2 (20/80)'
'23: UG offer 2 fair'
'24: UG offer 3 (30/70)'
'25: UG offer 3 fair'
'26: UG offer 4 (10/90)'
'27: UG offer 4 fair'
'28: UG offer 5 (0/100)'
'29: UG offer 5 fair'
'30: Hawk-Dove (1 = C, 0 = D)'
'31: Hawk-Dove expectation (100 = definitely D, 0 = definitely C)'
'32: Prisoner''s Dilemma'
'33: Prisoner''s Dilemma expectation'
'34: Stag-Hunt'
'35: Stag-Hunt expectation'
'36: No Conflict'
'37: No Conflict expectation'
'38: 8 Euro utility'
'39: 24 Euro utility'
'40: 40 Euro utility'
'41: 56 Euro utility'
'42: PCL-R Scores'
'43: PCL item 1'
'44: PCL item 2'
'45: PCL item 3'
'46: PCL item 4'
'47: PCL item 5'
'48: PCL item 6'
'49: PCL item 7'
'50: PCL item 8'
'51: PCL item 9'
'52: PCL item 10'
'53: PCL item 11'
'54: PCL item 12'
'55: PCL item 13'
'56: PCL item 14'
'57: PCL item 15'
'58: PCL item 16'
'59: PCL item 17'
'60: PCL item 18'
'61: PCL item 19'
'62: PCL item 20'
'63: PCL score uncorrected'
'64: PCL factor 1 uncorrected'
'65: PCL factor 2 uncorrected'
'66: PCL score missing'
'67: PCL factor 1 missing'
'68: PCL factor 2 missing'
'69: PCL score adjusted'
'70: PCL factor 1 adjusted'
'71: PCL factor 2 adjusted'
'72: PCL Category'
'73: Age'
};

end
