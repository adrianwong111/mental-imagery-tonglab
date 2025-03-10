 dd  Screen('Preference', 'SkipSyncTests', 2);

% Clear the workspace and the screen
sca;
close all;
clear;

% Here we call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);

% Seed the random number generator
rng('shuffle')

% Get the screen numbers
screens = Screen('Screens');

% Draw to the external screen if avaliable
screenNumber = max(screens);

% Define black and white
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
grey = (white + black)/2;
red = [50 0 0]; %red value half of max green value
green = [0 50 0]; %417CDellCRT.xlsx max green value = 123
% Set screen opacity
opacity = 1;
PsychDebugWindowConfiguration([], opacity)

% Open the screen
[window, windowRect] = PsychImaging('OpenWindow', screenNumber,[],[],32,2);

% Flip to clear
Screen('Flip', window);
HideCursor;
% Gamma correction (run phase2_photometry.mat in 417C computer, get gamma
% table)
%load("phase2_photometry.mat");
% Screen('LoadNormalizedGammaTable', screenNumber, linearizedCLUT);
%Screen('LoadNormalizedGammaTable', screenNumber, inverseCLUT);

% Get the size of the on screen window
[screenXpixels, screenYpixels] = Screen('WindowSize', window);

% Query the frame duration
ifi = Screen('GetFlipInterval', window);

% Set drawing to maximum priority level
topPriorityLevel = MaxPriority(window);
Priority(topPriorityLevel);

% Get the centre coordinate of the window
[xCenter, yCenter] = RectCenter(windowRect);

%% Keyboard information
escapeKey = KbName('ESCAPE');
greenKey = KbName('1');
redKey = KbName('3');
mixedKey = KbName('2');

%% condList 
% 30 trials per condition
freqs = [4;8;16];
trialsPerCond = 40;
condList = repelem(Shuffle(freqs), trialsPerCond);
numTrials = length(condList);
condList(:,2) = Shuffle(repelem([1;2], numTrials/2)); % R or G cue for imagery
condList(:,3) = Shuffle(zeros(numTrials, 1)); 
% Catch trials on 10% of all trials (0 for normal, 1 for catch)
%condList(:,3) = Shuffle([zeros(numTrials * 0.9, 1); ones(numTrials * 0.1, 1)]);
condList(:,3) = zeros(numTrials,1);
phz = [rand()*2*pi; rand()*2*pi; rand()*2*pi];
condList(:,4) = repelem(phz, trialsPerCond);

respList = zeros(numTrials, 2); % 1st col: response, 2nd col: RT

%% Gabor information
% 3 visual degrees = 107 px
iwidth = 200;
sd = 0.2;
freq = [4, 8, 16];
theta = [pi/2, 0];

% Vert, green, low freq
% Draw the Gabors
gaborVertLow = makeGabor2(iwidth, freq(1), phz(1), theta(1), sd);
gaborVertLow(:,:,2) = gaborVertLow; 
gaborVertLow(:,:,[1 3]) = 0; % creates green vertical gabor
gaborVertLowTex = Screen('MakeTexture', window, gaborVertLow);
% Hori, red, low freq
gaborHoriLow = makeGabor2(iwidth, freq(1), phz(1), theta(2), sd);
gaborHoriLow(:,:,2:3) = 0; % creates red horizontal gabor
gaborHoriLow(gaborHoriLow == 0.5) = 0;
gaborHoriLowTex = Screen('MakeTexture', window, gaborHoriLow);
% Vert, green, med freq
gaborVertMed = makeGabor2(iwidth, freq(2), phz(2), theta(1), sd);
gaborVertMed(:,:,2) = gaborVertMed; 
gaborVertMed(:,:,[1 3]) = 0; % creates green vertical gabor
gaborVertMedTex = Screen('MakeTexture', window, gaborVertMed);
% Hori, red, med freq
gaborHoriMed = makeGabor2(iwidth, freq(2), phz(2), theta(2), sd);
gaborHoriMed(:,:,2:3) = 0; % creates red horizontal gabor
gaborHoriMed(gaborHoriMed == 0.5) = 0;
gaborHoriMedTex = Screen('MakeTexture', window, gaborHoriMed);
% Vert, green, high freq
gaborVertHigh = makeGabor2(iwidth, freq(3), phz(3), theta(1), sd);
gaborVertHigh(:,:,2) = gaborVertHigh; 
gaborVertHigh(:,:,[1 3]) = 0; % creates green vertical gabor
gaborVertHighTex = Screen('MakeTexture', window, gaborVertHigh);
% Hori, red, high freq
gaborHoriHigh = makeGabor2(iwidth, freq(3), phz(3), theta(2), sd);
gaborHoriHigh(:,:,2:3) = 0; % creates red horizontal gabor
gaborHoriHigh(gaborHoriHigh == 0.5) = 0;
gaborHoriHighTex = Screen('MakeTexture', window, gaborHoriHigh);

Textures = [gaborVertLowTex gaborHoriLowTex; gaborVertMedTex gaborHoriMedTex; gaborVertHighTex gaborHoriHighTex];

% Position of gabors on screen
distfromfix = xCenter/2;
xPos = [xCenter - distfromfix, xCenter + distfromfix];
yPos = [yCenter, yCenter];

% Destination rectangles for Gabors
gaborRectdims = [0,0,iwidth,iwidth];
allRects = nan(4,2);
for i = 1:2
    allRects(:,i) = CenterRectOnPointd(gaborRectdims, xPos(i), yPos(i));
end

%% Experimental loop
Screen('FillRect', window, black);
Screen('Flip', window);

for trial = 1:numTrials
    % If this is the first trial we present a start screen and wait for a
    % key-press
    if trial == 1
        Screen('Preference', 'TextAntiAliasing', 1);
        Screen('TextSize', window, 20);
        DrawFormattedText(window, 'Press Any Key To Begin', 'center', ...
            [], white);
        Screen('Flip', window);
        KbWait([],2);
        text4 = '\n If you see a G, you should try your best to imagine a green vertical grating.';
        text5 = '\n If you see an R, you should try your best to imagine a red horizontal grating.';
        text6 = '\n During the imagery interval, keep your eyes fixated on the dot.';
        text7 = '\n\n You will then see some stimuli briefly, followed by a question mark. Report what you saw using key presses.';
        text8 = '\n Press 1 to indicate that you saw the green vertical grating.';
        text9 = '\n Press 3 to indicate that you saw the red horizontal grating.';
        text10 = '\n Press 2 to indicate that you saw a mixture of the two stimuli.';
        text11 = '\n\n Press any key to start the experiment.';
        DrawFormattedText(window, [text4 text5 text6 text7 text8 text9 ...
            text10 text11], 'center', [], white);
        Screen('Flip', window);
        KbWait([],2);
    end
    
    % Allow participant to rest between blocks
    if mod(trial, trialsPerCond) == 1 && trial ~= 1
        Screen('Preference', 'TextAntiAliasing', 1);
        Screen('TextSize', window, 20);
        text1 = 'End of block.';
        text2 = '\n Feel free to take a rest.';
        text3 = '\n When you are ready, press any key to continue.';
        DrawFormattedText(window, [text1 text2 text3], 'center', ...
            'center', white);
        Screen('Flip', window);
        KbWait([],2);
    end

    % We will present the cue for 750 ms
    numSecscue = 0.75;
    numFramescue = round(numSecscue / ifi);
    waitframes = 1;
    
    cueNumber = condList(trial, 2); 
    if cueNumber == 1
       cueLetter = 'G';
    elseif cueNumber == 2
        cueLetter = 'R';
    end
    
    % For accurate timing
    vbl = Screen('Flip', window);
    for frame = 1:numFramescue
    
        % Draw the left cue to the screen
        Screen('TextSize', window, 20);
        DrawFormattedText(window, cueLetter, screenXpixels * 0.25 - 10, screenYpixels * 0.5 + 10, white);
    
        % Draw the right cue to the screen
        Screen('TextSize', window, 20);
        DrawFormattedText(window, cueLetter, screenXpixels * 0.75 - 10, screenYpixels * 0.5 + 10, white);
    
        % Flip to the screen
        vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
    
    end

    % Fixation dots (imagery)
    % Enable alpha blending for anti-aliasing
    Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

    % We will present fixation dots for 7 seconds
    numSecsdot2 = 7;
    numFramesdot2 = round(numSecsdot2 / ifi);
    waitframes = 1;
    
    % For accurate timing
    vbl = Screen('Flip', window);
    for frame = 1:numFramesdot2
   
        Screen('DrawDots', window, [screenXpixels*0.25 screenXpixels*0.75; ...
            screenYpixels*0.5 screenYpixels*0.5], 5, 1, [], 2);
    
        % Flip to the screen
        vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
    
    end

    % Gabors 
    numSecsgabor = 0.75;
    numFramesgabor = round(numSecsgabor/ifi);
    waitframes = 1;
    
    if condList(trial, 3) == 0
        vbl = Screen('Flip', window );
        for frame = 1:numFramesgabor  
            
            % Set the right blend function for drawing the gabors
            Screen('BlendFunction', window, 'GL_ONE', 'GL_ZERO');
            
            if condList(trial,1) == freq(1)
                Screen('DrawTextures', window, [Textures(1,1), Textures(1,2)], [], allRects); 
            elseif condList(trial,1) == freq(2)
                Screen('DrawTextures', window, [Textures(2,1), Textures(2,2)], [], allRects); 
            elseif condList(trial,1) == freq(3)
                Screen('DrawTextures', window, [Textures(3,1), Textures(3,2)], [], allRects); 
            end

            % Change the blend function to draw an antialiased fixation point
            % in the centre of the array
            Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
        
            % Draw the fixation points
            Screen('DrawDots', window, [xPos; yPos], 5, white, [], 2);
    
            % Flip to the screen
            vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
        end
    elseif condList(trial, 3) == 1
        vbl = Screen('Flip', window);
        for frame = 1:numFramesgabor
            % Set the right blend function for drawing the gabors
            %Screen('BlendFunction', window, 'GL_ONE', 'GL_ZERO');
            Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
    
            % Draw the Gabors
            if condList(trial,1) == freq(1)
                Screen('DrawTextures', window, [Textures(1,1), Textures(1,1)], [], allRects,[],[],0.5); 
                Screen('DrawTextures', window, [Textures(1,2), Textures(1,2)], [], allRects,[],[],0.5);  
            elseif condList(trial,1) == freq(2)
                Screen('DrawTextures', window, [Textures(2,1), Textures(2,1)], [], allRects,[],[],0.5); 
                Screen('DrawTextures', window, [Textures(2,2), Textures(2,2)], [], allRects,[],[],0.5);  
            elseif condList(trial,1) == freq(3)
                Screen('DrawTextures', window, [Textures(3,1), Textures(3,1)], [], allRects,[],[],0.5);  
                Screen('DrawTextures', window, [Textures(3,2), Textures(3,2)], [], allRects,[],[],0.5);  
            end
            
            % Change the blend function to draw an antialiased fixation point
            % in the centre of the array
            Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
        
            % Draw the fixation points
            Screen('DrawDots', window, [xPos; yPos], 5, white, [], 2);
    
            % Flip to the screen
            vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
        end
    end

    % Question mark to both sides for 1.5 seconds, participant response
    % Question mark to both sides, participant response (limit 1.5 seconds) 
    % Draw the left cue to the screen
    Screen('TextSize', window, 20);
    DrawFormattedText(window, '?', screenXpixels * 0.25 - 10, screenYpixels * 0.5 + 10, white);

    % Draw the right cue to the screen
    Screen('TextSize', window, 20);
    DrawFormattedText(window, '?', screenXpixels * 0.75 - 10, screenYpixels * 0.5 + 10, white);
    
    % Flip to the screen
    vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
    
    % Check the keyboard
    % Responses: green vertical = 1, red horizontal = 3, mixed = 2
    respToBeMade = true;
    s = 0;
    response = 0;
    maxWait = 1.5;
    stopTime = GetSecs + maxWait;
    while respToBeMade && (GetSecs < stopTime)
        [keyIsDown, secs, keyCode] = KbCheck;
        if keyCode(escapeKey)
            ShowCursor;
            sca;
            return
        elseif keyCode(greenKey)
            s = secs;
            response = 1;
            respToBeMade = false;
        elseif keyCode(redKey)
            s = secs;
            response = 3;
            respToBeMade = false;
        elseif keyCode(mixedKey)
            s = secs;
            response = 2;
            respToBeMade = false;
        end
    end

    % Record the trial data into response matrix
    respList(trial, 1) = respList(trial, 1) + response;
    % Record response time in second column
    respList(trial, 2) = respList(trial, 2) + s - vbl; 

end

%% Data processing and analysis
data = [condList respList];

% Save out reported mixed stimuli trials into separate array
rowsWith2 = data(:, 5) == 2;
mixedTrialsData = data(rowsWith2, :);
% Calculate percentage of trials reporting mixed stimuli
[rows, ~] = size(mixedTrialsData);
percentMixed = rows/numTrials;
% Save out rows without reported mixed stimuli into another array
rowsWithout2 = ~rowsWith2;
normalTrialsData = data(rowsWithout2, :);

sortedNormal = sortrows(normalTrialsData, 2, "ascend"); % sort by cue 
cueTypes = {'RCue', 'GCue'};
numCueTypes = numel(cueTypes);

perceptGreen = zeros(numCueTypes, 3);
perceptRed = zeros(numCueTypes, 3);

for ii = 1:numCueTypes
    cueRows = sortedNormal(:,2) == ii;
    cueData = sortedNormal(cueRows, :);

    lowfreqrows = cueData(:,1) == freqs(1);
    lowfreqs = cueData(lowfreqrows, :);
    medfreqrows = cueData(:,1) == freqs(2);
    medfreqs = cueData(medfreqrows, :);
    highfreqrows = cueData(:,1) == freqs(3);
    highfreqs = cueData(highfreqrows, :);

    [numrowslow, ~] = size(lowfreqs);
    [numrowsmed, ~] = size(medfreqs);
    [numrowshigh, ~] = size(highfreqs);

    respGreenLow = lowfreqs(:,5) == 1;
    respGreenMed = medfreqs(:,5) == 1;
    respGreenHigh = highfreqs(:,5) == 1;
    respRedLow = lowfreqs(:,5) == 3;
    respRedMed = medfreqs(:,5) == 3;
    respRedHigh = highfreqs(:,5) == 3;

    perceptGreen(ii, 1) = sum(respGreenLow)/numrowslow;
    perceptRed(ii, 1) = sum(respRedLow)/numrowslow;
    perceptGreen(ii, 2) = sum(respGreenMed)/numrowsmed;
    perceptRed(ii, 2) = sum(respRedMed)/numrowsmed;
    perceptGreen(ii, 3) = sum(respGreenHigh)/numrowshigh;
    perceptRed(ii, 3) = sum(respRedHigh)/numrowshigh;
end

% Plotting data
x = categorical({'Low', 'Medium', 'High'});
x = reordercats(x, {'Low', 'Medium', 'High'});
% 1st row (low freq): green percept given green cue, red percept given green
% cue, green percept given red cue, red percept given red cue
% 2nd row (med freq), 3rd row (high freq)
y = [perceptGreen(1,1) perceptRed(1,1) perceptGreen(2,1) perceptRed(2,1);...
    perceptGreen(1,2) perceptRed(1,2) perceptGreen(2,2) perceptRed(2,2);...
    perceptGreen(1,3) perceptRed(1,3) perceptGreen(2,3) perceptRed(2,3)];
b = bar(x, y);
xlabel('Spatial Frequency')
ylabel('Perceptual Dominance')
legend('g | G', 'r | G', 'g | R', 'r | R');

%% End of experiment
% Clear the screen. 
sca;