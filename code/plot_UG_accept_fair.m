function plot_UG_accept_fair(data)

% Single plot that displays 1) the percnetage of acceptance, and 2) the
% fairness ratings for the different offers in the Ultimatum Game. 

UGacceptancePercentages = [data(:,20), data(:,24), data(:,22), data(:,26), data(:,28)];
UGfairnessRatings = [data(:,21), data(:,25), data(:,23), data(:,27), data(:,29)];

figure
subplot(1,2,1)
bar(mean(UGacceptancePercentages)*100)
xticklabels({'50/50', '30/70', '20/80', '10/90', '0/100'})
xlabel('Offer (participant/other)'); ylabel('% accept')
subplot(1,2,2)
boxplot(UGfairnessRatings)
xticklabels({'50/50', '30/70', '20/80', '10/90', '0/100'})
xlabel('Offer (participant/other)'); ylabel('How fair?')
ylim([-5 105])

% Add the individual data points to the box plots
hold on
xCenter = 1:size(UGfairnessRatings, 2); 
spread = 0.5; % 0=no spread; 0.5=random spread within box bounds (can be any value)
for i = 1:size(UGfairnessRatings, 2)
    plot(rand(size(UGfairnessRatings(:,i)))*spread -(spread/2) + xCenter(i), UGfairnessRatings(:,i), 'bo','linewidth', 2)
end

end
