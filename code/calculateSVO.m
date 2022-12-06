function SVO_out_acker = calculateSVO(data)

columns_a = [(1:15)+2, 42, 2];
columns_b = [[6, 5, 4, 3, 2, 1, 15, 14, 13, 12, 11, 10, 9, 8, 7]+2, 42, 2];

SVO_data_a = data(data(:,2) == 1, columns_a);
SVO_data_b = data(data(:,2) == 2, columns_b);
SVO_data = [SVO_data_a; SVO_data_b];

EP_gambles_v2 % get values of SVO items & HF items

n_sub = size(SVO_data, 1); % sample size

% calculate SVO
for i_sub = 1:n_sub

    % SVO items & answers in order
    % get chosen payoff pair for each item from chosen options (1-9)
    for i_ite = 1:15 % all 15 SVO items
        SVO_out_item{i_sub}(i_ite,1:2) = SL(1:2, SVO_data(i_sub,i_ite), i_ite); % make cell for each subj. with chosen payoff for self and other (1:2)
    end

    % save as matrix: one row for each participant, items columnwise 
    SVO_out_item_m(i_sub,:) = reshape(SVO_out_item{i_sub}',[1,30]);
end

SVO_out_acker(:,:) = SVO_Slider(SVO_out_item_m); % run SVO_Slider script

end
