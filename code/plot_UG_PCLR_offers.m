function plot_UG_PCLR_offers(data, PCLRcolumn)

accept_each_offer_accept = [data(:,20), data(:,24), data(:,22), data(:,26), data(:,28)];
UGfairnessRatings = [data(:,21), data(:,25), data(:,23), data(:,27), data(:,29)];
PCLR = data(:,PCLRcolumn);

for k = 1:5
    PCLR_accept{k} = PCLR(sum(accept_each_offer_accept, 2) == k);
end

xx = [PCLR_accept{1}; PCLR_accept{2}; PCLR_accept{3}; PCLR_accept{4}; PCLR_accept{5}];
g = [zeros(length(PCLR_accept{1}), 1); ones(length(PCLR_accept{2}), 1); 2*ones(length(PCLR_accept{3}), 1); 3*ones(length(PCLR_accept{4}), 1); 4*ones(length(PCLR_accept{5}), 1)];

for iterator = 1:5
    n_accept_each(iterator) = sum(g == iterator - 1);
end

figure
boxplot(xx, g)
xlabel('Lowest offer accepted'); ylabel('PCL-R score')
xticklabels({sprintf('until 50/50 (%d)', n_accept_each(1)), sprintf('until 30/70 (%d)', n_accept_each(2)), sprintf('until 20/80 (%d)', n_accept_each(3)), sprintf('until 10/90 (%d)', n_accept_each(4)), sprintf('until 0/100 (%d)', n_accept_each(5))})
xtickangle(45)
ylim([0 40])

[UG_offers_PCLR.r,UG_offers_PCLR.p] = corr(xx, g, 'Type', 'Spearman')

end
