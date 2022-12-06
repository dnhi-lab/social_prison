%% Analysis of SoThA data

% Always run this section, all other sections are modular and can be run
% independent from each other

clear all
clc

dirBase = '';
cd(dirBase)

data = importData(); % allP = all participants; allT = all tasks

PCLRcolumn = 69;
% 69 = adjusted PCL-R main score
% 70 = adjusted Factor 1 score
% 71 = adjusted Factor 2 score

%{
% Create the datafile that we can share publically (because of privacy
% concerns for the participants, we will not share the raw PCL-R data, but
% only the category (1 = 0-8, 2 = 9-16, 3 = 17-24, 4 = 25-32, 5 = 33-40)
% This only needs to be done once

% 42-71 contain sensitive PCL-R data
data_share = data;
data_share.allP(:,42:71)  = NaN;
data_share.allT(:,42:71)  = NaN;
data_share.someT(:,42:71) = NaN;

save('data_share.mat','data_share')
writematrix(data_share.allP, 'data_share_allP.csv')
%}

%% Participant age
age.mean    = mean (data.allP  (:,73));
age.sd      = std  (data.allP  (:,73));

%% PCL-R descriptives for the entire dataset
PCLR.mean       = mean  (data.allP  (:,PCLRcolumn));
PCLR.sd         = std   (data.allP  (:,PCLRcolumn));
PCLR.f1mean     = mean  (data.allP  (:,70));
PCLR.f1sd       = std   (data.allP  (:,70));
PCLR.f2mean     = mean  (data.allP  (:,71));
PCLR.f2sd       = std   (data.allP  (:,71));
PCLR.more30     = sum   (data.allP  (:,PCLRcolumn) >= 30);
PCLR.from25to30 = sum   (data.allP  (:,PCLRcolumn) >= 25) - PCLR.more30;
PCLR.missing_m  = mean  (data.allP  (:,66));
PCLR.missing_sd = std   (data.allP  (:,66));
PCLR.missing_max= max   (data.allP  (:,66));
PCLR.missing_min= min   (data.allP  (:,66));

%% Dictator Game and Ultimatum Game

% Create variables 
V.DGself = data(:,18);
V.UGself = data(:,19);

% Some basic descriptives
DG.fiddy        = (sum(V.DGself == 50)/length(V.DGself))*100;
UG.fiddy        = (sum(V.UGself == 50)/length(V.UGself))*100;
DG_UG.same      = (sum(V.DGself == V.UGself)/length(V.DGself))*100;
DG_UG.more_DG   = (sum(V.DGself > V.UGself)/length(V.DGself))*100;
DG.offer_mean   = mean(V.DGself);
UG.offer_mean   = mean(V.UGself);

% Calculate correlations for the plots above
[DG.PCLR_rho, DG.PCLR_pval] = corr(V.DGself, data.allP(:,PCLRcolumn));
[UG.PCLR_rho, UG.PCLR_pval] = corr(V.UGself, data.allP(:,PCLRcolumn));
[DG_UG.PCLR_rho, DG_UG.PCLR_pval] = corr(V.DGself - V.UGself, data.allP(:,PCLRcolumn));

% Calculate correlations but for the 2 factors
[DG.PCLRf1_rho, DG.PCLRf1_pval] = corr(V.DGself, data.allP(:,70));
[DG.PCLRf2_rho, DG.PCLRf2_pval] = corr(V.DGself, data.allP(:,71));
[UG.PCLRf1_rho, UG.PCLRf1_pval] = corr(V.UGself, data.allP(:,70));
[UG.PCLRf2_rho, UG.PCLRf2_pval] = corr(V.UGself, data.allP(:,71));
[DG_UG.PCLRf1_rho, DG_UG.PCLRf1_pval] = corr(V.DGself - V.UGself, data.allP(:,70));
[DG_UG.PCLRf2_rho, DG_UG.PCLRf2_pval] = corr(V.DGself - V.UGself, data.allP(:,71));

% Plot the acceptance percentage and fairness ratings for the UG offers
plot_UG_accept_fair(data.allP)
UG.acceptNoMoney = mean(data.allP(:,28))*100;
UG.fairNoMoney = mean(data.allP(:,29));
UG. acceptNoMoney_fair = sum(data.allP(:,28) == 1 & data.allP(:,29) > 0); % The amount of people who accepted the 0/100 split and gave it a fairness rating of >0

% PCLR & accepting UG offers / calculate correlation
plot_UG_PCLR_offers(data.allP, PCLRcolumn)

%% SVO and PCL-R

% Calculate each participants' PCL-R score. This commented function works, 
% but only if you have the Bioinformatics Toolbox. I don't have it with my 
% basic license, so I got someone with the license to run the code. They 
% sent me the file, so I need to import it instead of calculating it myself
% SVO = calculateSVO(Data.allP);
load('results_svo.mat')

% Exclude participants if their overall SVO responses are intransitive. 
% Here, we save a vector of who took part for later analyses (otherwise we 
% can't exclude the PCL-R scores of those whose SVO data we excluded)
transitive_SVO_overall = SVO(:,3) == 1;
transitive_SVO_secondary = ~isnan(SVO(:,8));

% For info on the SVO data structure, check the SVO_slider.m introductory
% comments

% Exclude people who are intransitive in general
SVO(SVO(:,3) == 0,:) = [];

% Count prosocials, individualists, etc., calculate percentages
SVO_an.altruists           = sum(SVO(:,2) == 1);
SVO_an.prosocials          = sum(SVO(:,2) == 2);
SVO_an.individualists      = sum(SVO(:,2) == 3);
SVO_an.competitors         = sum(SVO(:,2) == 4);
SVO_an.altruists_p         = sum(SVO(:,2) == 1)/length(SVO(:,2) == 1)*100;
SVO_an.prosocials_p        = sum(SVO(:,2) == 2)/length(SVO(:,2) == 2)*100;
SVO_an.individualists_p    = sum(SVO(:,2) == 3)/length(SVO(:,2) == 3)*100;
SVO_an.competitors_p       = sum(SVO(:,2) == 4)/length(SVO(:,2) == 4)*100;
SVO_an.inequ_min           = sum(SVO(SVO(:,2) == 2,8) == 1);
SVO_an.joint_gain          = sum(SVO(SVO(:,2) == 2,8) == 2);
SVO_an.prosocial_non_tran  = sum(isnan(SVO(SVO(:,2) == 2,8)));
SVO_an.inequ_min_p         = sum(SVO(SVO(:,2) == 2,8) == 1)/SVO_an.prosocials*100;
SVO_an.joint_gain_p        = sum(SVO(SVO(:,2) == 2,8) == 2)/SVO_an.prosocials*100;
SVO_an.prosocial_intran_p  = sum(isnan(SVO(SVO(:,2) == 2,8)))/SVO_an.prosocials*100;

[SVO_an.PCLR_rho, SVO_an.PCLR_pval] = corr(SVO(:,1), data.allP(transitive_SVO_overall,PCLRcolumn));

% For this one you have to load the SVO file again to have all participants
SVO_secondary = SVO(transitive_SVO_secondary, :);
[SVO_sec.PCLR_ideal_inequ_rho, SVO_sec.PCLR_ideal_inequ__pval] = corr(SVO_secondary(:,9), data.allP(transitive_SVO_secondary, 69));
[SVO_sec.PCLRf1_ideal_inequ_rho, SVO_sec.PCLRf1_ideal_inequ__pval] = corr(SVO_secondary(:,9), data.allP(transitive_SVO_secondary, 70));
[SVO_sec.PCLRf2_ideal_inequ_rho, SVO_sec.PCLRf2_ideal_inequ__pval] = corr(SVO_secondary(:,9), data.allP(transitive_SVO_secondary, 71));

%% 2x2 games

% Compare the PCL-R scores of the two groups
PCLR.allTmean   = mean  (data.allT  (:,PCLRcolumn));
PCLR.allTsd     = std   (data.allT  (:,PCLRcolumn));
PCLR.someTmean  = mean  (data.someT (:,PCLRcolumn));
PCLR.someTsd    = std   (data.someT (:,PCLRcolumn));

% Compare the PCL-R scores for the two groups with a Welch/independent
% samples t-test
[~, PCLR.p, PCLR.ci, PCLR.stats] = ttest2(...
    data.allT(:,PCLRcolumn), data.someT(:,PCLRcolumn),'Vartype','unequal');

% Compare age of the two groups
age.allTmean    = mean  (data.allT  (:,73));
age.someTmean   = mean  (data.someT (:,73));
[~, age.p, age.ci, age.stats] = ttest2(...
    data.allT(:,73), data.someT(:,73),'Vartype','unequal');


% This is the only section that uses Data.allT instead of Data.allP
data = data.allT;

coop            = [data(:,30), data(:,32), data(:,34), data(:,36)];
coop_rate_p     = mean([data(:,30), data(:,32), data(:,34), data(:,36)], 2)*100;
coop_rate_g     = mean([data(:,30), data(:,32), data(:,34), data(:,36)])*100;
coop_exp        = [data(:,31), data(:,33), data(:,35), data(:,37)];
coop_exp_mean   = 100 - mean([data(:,31), data(:,33), data(:,35), data(:,37)]); % Added '100 - ' because 100 was expectation that other would defect, 0 was cooperate
pcl             = data(:,PCLRcolumn);

% Compare cooperation rate and expected cooperation across the 4 games
[h,p,stats]     = cochranqtest(coop);
[p,tbl,stats]   = anova1(coop_exp);

% Plot cooperation rate in the 22 games
for iterator = 1:4
    accept_percent(iterator) = sum(coop_rate_p == iterator*25);
end

figure
boxplot(pcl, coop_rate_p)
xlabel('Cooperation rate'); ylabel('PCL-R score')
xticklabels({sprintf('25%% (%d)', accept_percent(1)), sprintf('50%% (%d)', accept_percent(2)), sprintf('75%% (%d)', accept_percent(3)), sprintf('100%% (%d)', accept_percent(4))})
xtickangle(45)
ylim([0 40])

% Calculate correlations between cooperation rate and PCL-R score
[games_PCLR.r,games_PCLR.p]     = corr(data(:,69), coop_rate_p, 'Type', 'Spearman');
[games_PCLRf1.r,games_PCLRf1.p] = corr(data(:,70), coop_rate_p, 'Type', 'Spearman');
[games_PCLRf2.r,games_PCLRf2.p] = corr(data(:,71), coop_rate_p, 'Type', 'Spearman');
