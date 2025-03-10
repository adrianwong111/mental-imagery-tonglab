% Population analysis of data for mental imagery pilot
datafiles1 = dir('/Users/adrianwong/Desktop/PTB/Mental imagery face inversion/experimentdata/*_expt1.mat');
datafiles2 = dir('/Users/adrianwong/Desktop/PTB/Mental imagery face inversion/experimentdata/*_expt2.mat');

VVIQ_scores = []; % total VVIQ score for each participant
 
VVIQ1clean = []; % removed outliers from VVIQ_scores
VVIQ2clean = []; % removed outliers from VVIQ_scores
% Experiment 1 (Gabors)

% For each subject (rows),
% 1st col: % primed low, 2nd col: % primed med, 3rd col: % primed high
% imagery strength = percent primed = np / (n - nm - nx) * 100
% np = number of trials where dominant stimulus was primed by imagined
% stimulus, n = total number of trials, nm = number of mock trials, nx =
% number of trials where participants reported mixed percept during rivalry
% presentation
% no nm (mock trials) 
% exclude participants with more than 20% mixed percepts
rec = zeros(length(datafiles1), 2);
for abc = 1:length(rec)
    load(datafiles1(abc).name);
    nummixed = sum(data(:,5) == 2);
    a = nummixed/numTrials;
    rec(abc,1) = a;
    if a > 0.2
        rec(abc,2) = 1;
    end
end
elim = rec(:,2) == 1;
datafiles1(elim) = [];
% Exclude ptcpts 3, 7, 9
datafiles1(3,:) = [];
datafiles1(7,:) = [];
datafiles1(9,:) = [];

rec2 = zeros(length(datafiles2), 2);
for abc = 1:length(rec2)
    load(datafiles2(abc).name);
    nummixed = sum(data(:,5) == 2);
    a = nummixed/numTrials;
    rec2(abc,1) = a;
    if a > 0.2
        rec2(abc,2) = 1;
    end
end
elim2 = rec2(:,2) == 1;
datafiles2(elim2) = [];

%% Imagery strength vs VVIQ
percent_primed_all = nan(length(datafiles1), 1);
percent_primed_conds = nan(length(datafiles1), 3);
population_mixed_trials = nan(length(datafiles1),1);
% for loop across participants
for partics = 1:length(datafiles1)
   % load this participant's data
   load(datafiles1(partics).name);
   % find np trials
   primed_Ind = (data(:,2) == 1 & data(:,5) == 1) | (data(:,2) == 2 & data(:,5) == 3);
   primed_trials = find(primed_Ind);
   num_primed_total = length(primed_trials);
   % find nx trials
   mixed_Ind = data(:,5) == 2;
   mixed_trials = find(mixed_Ind);
   num_mixed_total = length(mixed_trials);
   % calculate percent primed (all trials)
   percent_primed_all(partics,1) = num_primed_total / (numTrials - num_mixed_total) * 100;
end
figure(1); bar(percent_primed_all)
xlabel('Participant'); ylabel('Imagery strength (% primed)'); ylim([0 100])
title('Expt1 Imagery strength of each participant')

% correlate vviq scores with overall imagery strength scores
figure(2); scatter(VVIQ1clean, percent_primed_all);
xlabel('VVIQ score'); ylabel('Imagery strength (% primed)'); xlim([0 100]); ylim([16 80])
title('Expt1 Imagery strength vs VVIQ scores')

[r1, p1] = corrcoef(VVIQ1clean, percent_primed_all)

% Experiment 2
rec2 = zeros(length(datafiles2), 2);
for abc = 1:length(rec2)
    load(datafiles2(abc).name);
    nummixed = sum(data(:,5) == 2);
    a = nummixed/numTrials;
    rec2(abc,1) = a;
    if a > 0.2
        rec2(abc,2) = 1;
    end
end
elim2 = rec2(:,2) == 1;
datafiles2(elim2) = [];

percent_primed_all2 = nan(length(datafiles2), 1);
percent_primed_conds2 = nan(length(datafiles2), 3);
population_mixed_trials2 = nan(length(datafiles2),1);
% for loop across participants
for partics = 1:length(datafiles2)
   % load this participant's data
   load(datafiles2(partics).name);
   % find np trials
   primed_Ind = (data(:,2) == 1 & data(:,5) == 1) | (data(:,2) == 2 & data(:,5) == 3);
   primed_trials = find(primed_Ind);
   num_primed_total = length(primed_trials);
   % find nx trials
   mixed_Ind = data(:,5) == 2;
   mixed_trials = find(mixed_Ind);
   num_mixed_total = length(mixed_trials);
   % calculate percent primed (all trials)
   percent_primed_all2(partics,1) = num_primed_total / (numTrials - num_mixed_total) * 100;
end
figure(3); bar(percent_primed_all2)
xlabel('Participant'); ylabel('Imagery strength (% primed)'); ylim([0 100])
title('Expt2 Imagery strength of each participant')

% correlate vviq scores with overall imagery strength scores
figure(4); scatter(VVIQ2clean, percent_primed_all2);
xlabel('VVIQ score'); ylabel('Imagery strength (% primed)'); xlim([0 100]); ylim([16 80])
title('Expt2 Imagery strength vs VVIQ scores')

[r2, p2] = corrcoef(VVIQ2clean, percent_primed_all2)

%% Imagery strength for each condition
% Experiment 1
for jj = 1:length(datafiles1) % participants with > 20% mixed trials excluded
   % load this participant's data
   load(datafiles1(jj).name);
   % find np trials 
   primed_Ind = (data(:,2) == 1 & data(:,5) == 1) | (data(:,2) == 2 & data(:,5) == 3); 
   primed_trials = find(primed_Ind);
   % find nx trials
   mixed_Ind = data(:,5) == 2;
   mixed_trials = find(mixed_Ind);
   for kk = 1:3
      % Calculate percent primed for each frequency condition
      % At each frequency condition, find np, n, and nx
      freqs_primed_Ind = data(primed_trials, 1) == freqs(kk);
      num_primed_trials = sum(freqs_primed_Ind);
      mixed_trials_freqs_Ind = data(mixed_trials, 1) == freqs(kk);
      num_mixed_trials_freqs = sum(mixed_trials_freqs_Ind);
      percent_primed_conds(jj,kk) = num_primed_trials / (trialsPerCond - num_mixed_trials_freqs) * 100;
   end
end
figure(5); bar(percent_primed_conds); 
xlabel('Participants'); ylabel('Imagery strength (% primed)'); ylim([0 100])
legend({'Low', 'Medium', 'High'})
title('Expt1 Imagery strength of each participant for each frequency condition')

means_freqs = mean(percent_primed_conds);
figure(6); 
xaxis = 1:3;
bar(xaxis, means_freqs); 
hold on
xlabel('Spatial frequency'); xticklabels({'Low', 'Medium', 'High'}); 
ylabel('Imagery strength (% primed)'); ylim([0 100])
title('Expt1 Imagery strength of each frequency condition across participants')
err = std(percent_primed_conds)/sqrt(length(percent_primed_conds));
e = errorbar(xaxis,means_freqs, err, err);
e.Color = 'black';
hold off

% One-way ANOVA of mean imagery strength for each frequency condition
aov = anova(percent_primed_conds)
% Post-hoc pairwise tests of imagery strength differences between frequency conditions
posthoc = multcompare(aov)

% Experiment 2
for jj = 1:length(datafiles2) % participants with > 20% mixed trials excluded
   % load this participant's data
   load(datafiles2(jj).name);
   % find np trials (eliminated latter condition for gabor vs face t test)
   primed_Ind = (data(:,2) == 2 & data(:,5) == 3); %(data(:,2) == 1 & data(:,5) == 1) | 
   primed_trials = find(primed_Ind);
   % find nx trials
   mixed_Ind = data(:,5) == 2;
   mixed_trials = find(mixed_Ind);
   for kk = 1:3
      % Calculate percent primed for each filter condition
      % At each filter condition, find np, n, and nx
      freqs_primed_Ind = data(primed_trials, 1) == filters(kk);
      num_primed_trials = sum(freqs_primed_Ind);
      mixed_trials_freqs_Ind = data(mixed_trials, 1) == filters(kk);
      num_mixed_trials_freqs = sum(mixed_trials_freqs_Ind);
      percent_primed_conds2(jj,kk) = num_primed_trials / (trialsPerCond - num_mixed_trials_freqs) * 100;
   end
end
figure(7); bar(percent_primed_conds2); 
xlabel('Participants'); ylabel('Imagery strength (% primed)'); ylim([0 100])
legend({'None', 'Low-pass', 'High-pass'})
title('Expt2 Imagery strength of each participant for each filter condition')

means_freqs2 = mean(percent_primed_conds2)';
figure(8);
xaxis = 1:3;
bar(xaxis, means_freqs2); 
hold on
xlabel('Filter condition'); xticklabels({'None', 'Low-pass', 'High-pass'}); %xlim([0 4]) 
ylabel('Imagery strength (% primed)'); ylim([0 100])
title('Expt2 Imagery strength of each filter condition across participants')
err2 = std(percent_primed_conds2)/sqrt(length(percent_primed_conds2));
e2 = errorbar(xaxis,means_freqs2, err2, err2);
e2.Color = 'black';
hold off

% One-way ANOVA of mean imagery strength for each filter condition
aov2 = anova(percent_primed_conds2)
% Post-hoc pairwise tests of imagery strength differences between filter conditions
posthoc2 = multcompare(aov2)

%% Relative dominance of each eye across SFs (old)
lefteyedom = zeros(length(datafiles1), 3);
righteyedom = zeros(length(datafiles1), 3);
for kk = 1:length(datafiles1)
    load(datafiles1(kk).name);
    lowfreqlefteyedom = sum(data(:,5) == 1 & data(:,1) == 4);
    medfreqlefteyedom = sum(data(:,5) == 1 & data(:,1) == 8);
    highfreqlefteyedom = sum(data(:,5) == 1 & data(:,1) == 16);
    lowfreqrighteyedom = sum(data(:,5) == 3 & data(:,1) == 4);
    medfreqrighteyedom = sum(data(:,5) == 3 & data(:,1) == 8);
    highfreqrighteyedom = sum(data(:,5) == 3 & data(:,1) == 16);
    lefteyedom(kk, 1) = lowfreqlefteyedom;
    lefteyedom(kk, 2) = medfreqlefteyedom;
    lefteyedom(kk, 3) = highfreqlefteyedom;
    righteyedom(kk, 1) = lowfreqrighteyedom;
    righteyedom(kk, 2) = medfreqrighteyedom;
    righteyedom(kk, 3) = highfreqrighteyedom;
end
tiledlayout(3,2)
nexttile
bar(lefteyedom(:,1)); title("Counts of left eye dom, low freq"); xlabel("Participant"); ylabel("Counts")
nexttile
bar(righteyedom(:,1)); title("Counts of right eye dom, low freq"); xlabel("Participant"); ylabel("Counts")
nexttile
bar(lefteyedom(:,2)); title("Counts of left eye dom, med freq"); xlabel("Participant"); ylabel("Counts")
nexttile
bar(righteyedom(:,2)); title("Counts of right eye dom, med freq"); xlabel("Participant"); ylabel("Counts")
nexttile
bar(lefteyedom(:,3)); title("Counts of left eye dom, high freq"); xlabel("Participant"); ylabel("Counts")
nexttile
bar(righteyedom(:,3)); title("Counts of right eye dom, high freq"); xlabel("Participant"); ylabel("Counts")

%% Relative dominance of right eye across SFs (new)
% Left eye dom = 0, mixed = 0.5, right eye dom = 1
eyedom = zeros(length(datafiles1), 3);
for kk = 1:length(datafiles1)
    load(datafiles1(kk).name)
    lowfreqmixed = 0.5*(sum(data(:,5) == 2 & data(:,1) == 4));
    medfreqmixed = 0.5*(sum(data(:,5) == 2 & data(:,1) == 8));
    highfreqmixed = 0.5*(sum(data(:,5) == 2 & data(:,1) == 16));
    lowfreqrighteyedom = sum(data(:,5) == 3 & data(:,1) == 4);
    medfreqrighteyedom = sum(data(:,5) == 3 & data(:,1) == 8);
    highfreqrighteyedom = sum(data(:,5) == 3 & data(:,1) == 16);
    eyedom(kk,1) = (lowfreqmixed + lowfreqrighteyedom) / (numTrials/3);
    eyedom(kk,2) = (medfreqmixed + medfreqrighteyedom) / (numTrials/3);
    eyedom(kk,3) = (highfreqmixed + highfreqrighteyedom) / (numTrials/3);
end

tiledlayout(3,1)
nexttile
bar(eyedom(:,1)); title("Percent dominance of right eye, low freq"); xlabel("Participant"); ylabel("% right dominant")
nexttile
bar(eyedom(:,2)); title("Percent dominance of right eye, med freq"); xlabel("Participant"); ylabel("% right dominant")
nexttile
bar(eyedom(:,3)); title("Percent dominance of right eye, high freq"); xlabel("Participant"); ylabel("% right dominant")

%% Relative dominance of right eye across filters 
% Left eye dom = 0, mixed = 0.5, right eye dom = 1
eyedom2 = zeros(length(datafiles2), 3);
for kk = 1:length(datafiles2)
    load(datafiles2(kk).name)
    nofiltmixed = 0.5*(sum(data(:,5) == 2 & data(:,1) == 1));
    lowfiltmixed = 0.5*(sum(data(:,5) == 2 & data(:,1) == 2));
    highfiltmixed = 0.5*(sum(data(:,5) == 2 & data(:,1) == 3));
    nofiltrightdom = sum(data(:,5) == 3 & data(:,1) == 1);
    lowfiltrightdom = sum(data(:,5) == 3 & data(:,1) == 2);
    highfiltrightdom = sum(data(:,5) == 3 & data(:,1) == 3);
    eyedom2(kk,1) = (nofiltmixed + nofiltrightdom) / (numTrials/3);
    eyedom2(kk,2) = (lowfiltmixed + lowfiltrightdom) / (numTrials/3);
    eyedom2(kk,3) = (highfiltmixed + highfiltrightdom) / (numTrials/3);
end

tiledlayout(3,1)
nexttile
bar(eyedom2(:,1)); title("Percent dominance of right eye, no filter"); xlabel("Participant"); ylabel("% right dominant")
nexttile
bar(eyedom2(:,2)); title("Percent dominance of right eye, low-pass"); xlabel("Participant"); ylabel("% right dominant")
nexttile
bar(eyedom2(:,3)); title("Percent dominance of right eye, high-pass"); xlabel("Participant"); ylabel("% right dominant");ylim([0 1])
