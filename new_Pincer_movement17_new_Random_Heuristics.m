function new_Pincer_movement17_new_Random_Heuristics
%%Final SA model Main algorithm, has Pr of acceptance in both pos and neg Energy value
% Pincer strategy
% Bot1 and Bot3 : Shows Flanking movement with arbitraty conduction rates
% Bot2 and Bot4 : Shows Blockade strategy with arbitraty conduction rates but attacks when at striking_range
% Increasing the population from 2 to 4 shows Pincer movement with both flanking
% maneuver and blockage strategy portrayed in the scenario
%%
% If generated node's Energy value is greater than current node, then new node is accepted. 
% If generated node's Energy value is less than current node, then it is
% rejected with a probability
% While rejection, Ghost remains stationary and does not make any moves.
%%
close all
clc
% load standard game data
gameData = load('gameData.mat');

overallEnemySpeed = 1/16;   % standard ghost speed, 
grumpyTime = 700;           % time-increments that ghosts stay grumpy for
grumpyTimeSwitch = 200;     % time-increments that grumpy ghosts show that they are going to turn normal again
newEnemyTime = 500;         % time-increments that pass before the next ghost is let out of his cage
game.speed = 0.025;         % game speed (time-increment between two frames) maximum possible without lag on my machine: 0.008

pacman.speed = 1/16;        
if any(strcmp(listfonts,'Courier New'))
    pacFont = 'Courier New';
else
    pacFont = 'Arial';
end

% create figure
screen_size = get(0,'ScreenSize');                  % get screen size
figure_size = [650 650];                            % figure-size
limit_left = screen_size(3)/2-figure_size(1)/2;     % figure centered horizontally
limit_down = screen_size(4)/2-figure_size(2)/2;     % figure centered vertically
pacman_Fig = figure('units','pixels','Position',[limit_left limit_down figure_size(1) figure_size(2)],...  
    'Color','k','Resize','on','MenuBar','none','Visible','on',...
    'NumberTitle','off','Name','Pacman','doublebuffer','on',...
    'KeyPressFcn',@KeyAction,...                % Keyboard-Callback
    'CloseRequestFcn',@(s,e)PacmanCloseFcn);    % when figure is closed
myAxes1 = axes('Units','normalized','Position',[0.1 0.1 0.8 0.8],...                                            
    'XLim',[-3.11 32.01],'YLim',[-3.11 32.01]); 
hold(myAxes1,'on')
axis(myAxes1,'off','equal')

allDirections = gameData.gameData.allDirections;    % all possible Directions in each square
allSprites = gameData.gameData.allSprites;          % all sprites-data
allWalls = gameData.gameData.allWalls;              % all wall-data
ghostSprites = allSprites.ghosts;                   % all ghosts-Sprites
eyeSprites = allSprites.eyes;                       % all eyes-Sprites
grumpySprites = allSprites.grumpy;                  % all grumpy-Sprites
fruits.data = allSprites.fruits;                    % all fruits-Sprites

plot(myAxes1,allWalls.pacmanWalls(1,:),allWalls.pacmanWalls(2,:),'b-','LineWidth',2)    % plot all walls
plot(myAxes1,[13.1 15.9],[18.75 18.75],'w-','LineWidth',3)                              % plot gate of ghost cage

%% Coins 
coins = gameData.gameData.coins;    % all coins-data
coins.originalData = coins.data;    % remember that data for a new game
coins.plot = plot(coins.data(:,1),coins.data(:,2),'w.','MarkerSize',7); % plot all coins

imagesc(myAxes1,'XData',[0 0.001],'YData',[0.001 0],'CData',repmat(1:length(allSprites.colormap(:,1)),[length(allSprites.colormap(:,1)), 1]),'Visible','on');
colormap(allSprites.colormap)   % change colormap

%% Initialize Ghosts
enemies(1).pos = [14.5, 20];            % ghost position
enemies(1).dir = 0;                     % current ghost direction (right-1, down-2, left-3, up-4)
enemies(1).oldDir = 1;                  % last ghost direction
enemies(1).speed = overallEnemySpeed;   % ghost speed
enemies(1).status = 1;                  % ghost status (0-in cage, 1-normal, 2-grumpy, 3-eyes) 
enemies(1).statusTimer = -1;            % remember time for status change
enemies(1).curPosMov = [1, 3];          % current squares's possible moves
enemies(1).plot = imagesc(myAxes1,'XData',[enemies(1).pos(1)-0.6 enemies(1).pos(1)+0.6],'YData',[enemies(1).pos(2)+0.6 enemies(1).pos(2)-0.6],'CData',ghostSprites{1,2,1});
enemies(1).text = text(enemies(1).pos(1),enemies(1).pos(2),'100','Color','w','FontSize',8,'Visible','off','Parent',myAxes1,'FontName',pacFont,'FontWeight','bold');
enemies(1).possibleMoves = 1;
% enemies(1).distance1 = 0;
enemies(1).x1 = 1;
enemies(1).y1 = 1;
enemies(1).x1a = 1;
enemies(1).y1a = 1;
Timer_on1 = 1 ;

enemies(2).pos = [12.5, 17.5];
enemies(2).dir = 0;
enemies(2).oldDir = 1;
enemies(2).speed = overallEnemySpeed;
enemies(2).status = 1;
enemies(2).statusTimer = -1;
enemies(2).curPosMov = [1, 3];;
enemies(2).plot = imagesc(myAxes1,'XData',[enemies(2).pos(1)-0.6 enemies(2).pos(1)+0.6],'YData',[enemies(2).pos(2)+0.6 enemies(2).pos(2)-0.6],'CData',ghostSprites{2,2,1});
enemies(2).text = text(enemies(2).pos(1),enemies(2).pos(2),'100','Color','w','FontSize',8,'Visible','off','Parent',myAxes1,'FontName',pacFont,'FontWeight','bold');
enemies(2).possibleMoves = 1;
% enemies(2).distance2 = 0;
enemies(2).x1 = 1;
enemies(2).y1 = 1;
enemies(2).x1a = 1;
enemies(2).y1a = 1;
Timer_on2 = 1 ; 

enemies(3).pos = [14.5, 16.5];
enemies(3).dir = 0;
enemies(3).oldDir = 1;
enemies(3).speed = overallEnemySpeed;
enemies(3).status = 1;
enemies(3).statusTimer = -1;
enemies(3).curPosMov = [1, 3];;
enemies(3).plot = imagesc(myAxes1,'XData',[enemies(3).pos(1)-0.6 enemies(3).pos(1)+0.6],'YData',[enemies(3).pos(2)+0.6 enemies(3).pos(2)-0.6],'CData',ghostSprites{3,2,1});
enemies(3).text = text(enemies(3).pos(1),enemies(3).pos(2),'100','Color','w','FontSize',8,'Visible','off','Parent',myAxes1,'FontName',pacFont,'FontWeight','bold');
enemies(3).possibleMoves = 1;
% enemies(3).distance3 = 0;
enemies(3).x1 = 1;
enemies(3).y1 = 1;
enemies(3).x1a = 1;
enemies(3).y1a = 1;
Timer_on3 = 1 ;

enemies(4).pos = [16.5, 17.5];
enemies(4).dir = 0;
enemies(4).oldDir = 1;
enemies(4).speed = overallEnemySpeed;
enemies(4).status = 0;
enemies(4).statusTimer = -1;
enemies(4).curPosMov = 0;
enemies(4).plot = imagesc(myAxes1,'XData',[enemies(4).pos(1)-0.6 enemies(4).pos(1)+0.6],'YData',[enemies(4).pos(2)+0.6 enemies(4).pos(2)-0.6],'CData',ghostSprites{4,2,1});
enemies(4).text = text(enemies(4).pos(1),enemies(4).pos(2),'100','Color','w','FontSize',8,'Visible','off','Parent',myAxes1,'FontName',pacFont,'FontWeight','bold');
enemies(4).possibleMoves = 1;
% enemies(4).distance4 = 0;
enemies(4).x1 = 1;
enemies(4).y1 = 1;
enemies(4).x1a = 1;
enemies(4).y1a = 1;
Timer_on4 = 1 ;
%% Fruits
fruits.pos = [0, 0];    % fruit position
fruits.item = 1;        % current level's fruit
fruits.score = [100 100 200 200 300 300 400 500]; % scores for each fruit
fruits.picked = zeros(1,8); % how many time each fruit picked was up
fruits.timer = randi([300,1500],1); % time window when fruit will appear
fruits.scoreText = text(fruits.pos(1),fruits.pos(2),'100','Color','w','FontSize',8,'Visible','off','Parent',myAxes1,'FontName',pacFont,'FontWeight','bold');
fruits.plot = imagesc(myAxes1,'XData',[0 1],'YData',[1 0],'CData',fruits.data{fruits.item},'Visible','off','Parent',myAxes1);
fruits.bottomPlot = gobjects(1,8);
fruits.bottomText = gobjects(1,8);
for ii = 1:8
    fruits.bottomPlot(ii) = imagesc(myAxes1,'XData',[27 29]-(ii-1)*2.4,'YData',[-0.8 -2.8],'CData',fruits.data{ii},'Visible','off','Parent',myAxes1);
    fruits.bottomText(ii) = text(28-(ii-1)*2.4,-3.5,[num2str(0) 'x'],'Color','w','FontSize',12,'FontName',pacFont,'FontWeight','bold','HorizontalAlignment','center','Parent',myAxes1,'Visible','off');
end

ghostFrame = 1;             % make the ghosts wobble
grumpyColorChange = 0;      % determines grumpy host color (blue or white)
grumpyTimeSwitchSave = 0;   % this variable remembers the timer-status, so the grumpy-ghosts all change at the the same time (blue-white-blue-...)
ghostPoints = 100;           % determines how many points a ghost adds to the score (doubles with each kill)

%% Initialize pacman
pacman.size = 0.8;          % pacman size
pacman.pos = [25 30];%[25 2];%[25 5];%[5 5];%[25 5];%[5 5];%[4 8];%[25 8];      % position of pacman
pacman.dir = 0;             % direction of pacman
pacman.oldDir = 1;          % old direction of pacman
pacman.status = -2;         % -2 is normal, -3 is hit by ghost (don't ask me why I chose 'em numbers like that)

% Calculate all pacman frames, from closed to fully open
for ii = 0:18
    pacman.frames{1,ii+1} = [[-0.3 sin(linspace(pi/2+ii*pi/18,5/2*pi-ii*pi/18,50))*pacman.size -0.3];[0 cos(linspace(pi/2+ii*pi/18,5/2*pi-ii*pi/18,50))*pacman.size 0]];
    pacman.frames{2,ii+1} = [[0 sin(linspace(pi/2+ii*pi/18+pi/2,5/2*pi-ii*pi/18+pi/2,50))*pacman.size 0];[0.3 cos(linspace(pi/2+ii*pi/18+pi/2,5/2*pi-ii*pi/18+pi/2,50))*pacman.size 0.3]];
    pacman.frames{3,ii+1} = [[0.3 sin(linspace(pi/2+ii*pi/18-pi,5/2*pi-ii*pi/18-pi,50))*pacman.size 0.3];[0 cos(linspace(pi/2+ii*pi/18-pi,5/2*pi-ii*pi/18-pi,50))*pacman.size 0]];
    pacman.frames{4,ii+1} = [[0 sin(linspace(pi/2+ii*pi/18-pi/2,5/2*pi-ii*pi/18-pi/2,50))*pacman.size 0];[-0.3 cos(linspace(pi/2+ii*pi/18-pi/2,5/2*pi-ii*pi/18-pi/2,50))*pacman.size -0.3]];
end

curFrame = 5;           % open-close-frame
frameDirection = 1;     % direction-frame
pacman.plot = fill(pacman.frames{pacman.oldDir,curFrame}(1,:)+pacman.pos(1),pacman.frames{pacman.oldDir,curFrame}(2,:)+pacman.pos(2),'y','Parent',myAxes1);

%% lives, score, level, info, animations...
lives.data = 3;         % lives of pacman
lives.plot = gobjects(1,3);
for ii = 1:lives.data
    lives.plot(ii) = fill(pacman.frames{1,5}(1,:)+1+3*(ii-1),pacman.frames{1,5}(2,:)-2,'y');
end

score.data = 0;         % score
score.plot = text(29,33.5,['Score: ' num2str(score.data)],'Color','w','FontSize',16,'HorizontalAlign','Right','FontName',pacFont,'FontWeight','bold');

level.data = 1;          	% level
level.plot = text(0,33.5,['Level: ' num2str(level.data)],'Color','w','FontSize',16,'HorizontalAlign','Left','FontName',pacFont,'FontWeight','bold');

info.text = text(14.65,13.9,'READY!','Color','g','FontSize',14,'FontWeight','bold','horizontalAlignment','center','FontName',pacFont,'FontWeight','bold');

rays.num = 12;          % bursting rays when pacman is hit by ghost
rays.numFrames = 20;
rays.t = linspace(0,2*pi*(1-1/rays.num),rays.num);
rays.rad1 = linspace(0,1,rays.numFrames);
rays.rad2 = linspace(0.5,1,rays.numFrames);
rays.plot = plot(0, 0,'y-','Visible','off');

%% Timer
myTimer = timer('TimerFcn',@(s,e)GameLoop,'Period',game.speed,'ExecutionMode','fixedRate');

%% UI-controls
newGameButton = uicontrol('Style','pushbutton',...
    'units','normalized',...
    'String','New Game',...
    'FontSize',16,...
    'ForegroundColor','k',...
    'Position',[0.38 0.81 0.24 0.05],...
    'Parent',pacman_Fig,...
    'Enable','off',...
    'ButtonDownFcn',@(s,e)newGameButtonFun);
createGhostsButton = uicontrol('Style','pushbutton',...
    'units','normalized',...
    'String','Create Ghosts',...
    'FontSize',16,...
    'ForegroundColor','k',...
    'Position',[0.38 0.75 0.24 0.05],...
    'Parent',pacman_Fig,...
    'Enable','off',...
    'ButtonDownFcn',@(s,e)createGhostsFun);
loadGhostsButton = uicontrol('Style','pushbutton',...
    'units','normalized',...
    'String','Load Ghosts',...
    'FontSize',16,...
    'ForegroundColor','k',...
    'Position',[0.38 0.69 0.24 0.05],...
    'Parent',pacman_Fig,...
    'Enable','off',...
    'ButtonDownFcn',@(s,e)loadGhostsFun);

%% Include Pacman Ghost Creator
% first an empty figure is created. The figure-parameters are then
% specified in "pacmanCreator.m".
pacmanGhostCreator_Fig = figure('Visible','off');

    function newGameButtonFun
        coins.data = coins.originalData;
        level.data = 1;
        score.data = 0;
        lives.data = 3;
        set(lives.plot(:),'Visible','on')
        set(fruits.bottomPlot(:),'Visible','off')
        set(newGameButton,'Visible','off')
        set(createGhostsButton,'Visible','off')
        set(loadGhostsButton,'Visible','off')
        set(pacmanGhostCreator_Fig,'Visible','off')
        
        newGame
        set(info.text,'Visible','off')
    end

    function createGhostsFun
        pacmanCreator(pacmanGhostCreator_Fig);
    end

    function loadGhostsFun
        [FileName,PathName,~] = uigetfile('*.mat');
        gameData = load(fullfile([PathName FileName]));
        allSprites = gameData.gameData.allSprites;
        ghostSprites = allSprites.ghosts;
        eyeSprites = allSprites.eyes;
        grumpySprites = allSprites.grumpy;
        colormap(allSprites.colormap)
        
        for nn = 1:4
            plotGhost(enemies(nn),ghostSprites{nn,enemies(nn).oldDir,ghostFrame+1},zeros(14,14))
        end
    end

    function GameLoop
        pacmanMoveFun
        enemyRefresh
%         pillsFun
        fruitsFun
        coinsFun
    end

    function newGame

        stop(myTimer)
        enemies(1).pos = [14.5, 20];
        enemies(2).pos = [12.5, 17.5];
        enemies(3).pos = [14.5, 16.5];
        enemies(4).pos = [16.5, 17.5];
        for nn = 1:4
            enemies(nn).status = 0;
            enemies(nn).dir = 0;
            enemies(nn).oldDir = 2;
            enemies(nn).speed = overallEnemySpeed;
            enemies(nn).statusTimer = -1;
            enemies(nn).curPosMov = [1 3];
            enemies(nn).possibleMoves = 1;
%             enemies(nn).distance = 10;
            enemies(nn).x1 = 1;
            enemies(nn).y1 = 1;
            enemies(nn).x1a = 1;
            enemies(nn).y1a = 1;
            
        end
        enemies(1).dir = 1;
        enemies(1).status = 1;
        
%         enemies(2).dir = 1;
%         enemies(2).status = 1;
%         enemies(3).dir = 1;
%         enemies(3).status = 1;
%         enemies(4).dir = 1;
%         enemies(4).status = 1;
        pacman.pos = [25 30];%[25 2];%[25 5];%[5 5];%[25 5];%[5 5];%[4 8];%[25 8];
        pacman.dir = 0;
        pacman.oldDir = 1;
        pacman.status = -2;

        set(pacman.plot,'XData',pacman.frames{pacman.oldDir,curFrame}(1,:)+pacman.pos(1),'YData',pacman.frames{pacman.oldDir,curFrame}(2,:)+pacman.pos(2))
        set(info.text,'String','READY!','Color','g','Visible','on')
        
        for nn = 1:4
            plotGhost(enemies(nn),ghostSprites{nn,enemies(nn).oldDir,ghostFrame+1},zeros(14,14))
            set(enemies(nn).plot,'Visible','on')
        end
        
        pause(1)
        set(info.text,'Visible','off')
        start(myTimer)
    end

    function coinsFun
        if any(ismember(coins.data,findSquare(pacman,pacman.oldDir),'rows'))
            coins.data(ismember(coins.data,findSquare(pacman,pacman.oldDir),'rows'),:) = [];
            score.data = score.data+1;
        end
        
        set(coins.plot,'XData',coins.data(:,1),'YData',coins.data(:,2))
        set(score.plot,'String',['Score: ' num2str(score.data)])
        
        if isempty(coins.data) % next Level
            level.data = level.data+1;
            set(level.plot,'String',['Level: ' num2str(level.data)]);
            game.speed = game.speed-0.002;
            if game.speed < 0.009   %  0.025
                game.speed = 0.009; %  0.025 (limit game speed, so screen has time to update itself)
            end
            stop(myTimer)
            set(myTimer,'Period',game.speed)
            coins.data = coins.originalData;
%             pills.data = pills.originalData;
            fruits.timer = randi([300,1500],1);
            newGame
        end
    end

    function fruitsFun
        if (fruits.timer > 0 && fruits.timer < myTimer.TasksExecuted) || (fruits.timer > 0 && length(coins.data(:,1)) <= 10)
            fruits.timer = -1;
            
            fruits.item = mod(level.data,9);
            
            if level.data > 8
                fruits.item = mod(level.data-8*floor(level.data/8),9)+(~mod(level.data-8*floor(level.data/8),9))*8;
            end
            
            fruits.pos = coins.originalData(randi([1 length(coins.originalData(:,1))],1),:);
            
            alphaMask = fruits.data{fruits.item};
            alphaMask(alphaMask~=1) = 0;
            alphaMask = ~alphaMask;
            set(fruits.plot,'Visible','on','XData',[fruits.pos(1)-0.6 fruits.pos(1)+0.6],'YData',[fruits.pos(2)+0.6 fruits.pos(2)-0.6],'CData',fruits.data{fruits.item},'AlphaData',alphaMask)
        end 
        if any(ismember(fruits.pos,findSquare(pacman,pacman.oldDir),'rows'))
            for mm = 0:30
                set(fruits.scoreText,'String',num2str(fruits.score(fruits.item)),'Position',[fruits.pos(1)-0.6,fruits.pos(2)+(mm)/30+0.6,0],'Visible','on')
                pause(0.02)
            end
            fruits.pos = [0,0];
            fruits.picked(fruits.item) = fruits.picked(fruits.item)+1;
            score.data = score.data+fruits.score(fruits.item);
            set(fruits.scoreText,'Visible','off')
            set(fruits.plot,'Visible','off')
            set(fruits.bottomPlot(fruits.item),'CData',fruits.data{fruits.item},'Visible','on')
            set(fruits.bottomText(fruits.item),'String',[num2str(fruits.picked(fruits.item)) 'x'],'Visible','on');
        end
    end
    function pacmanMoveFun
        
        % Tunnel logic
        if pacman.pos(1) > 28
            pacman.pos(1) = 1;
        elseif pacman.pos(1) < 1
            pacman.pos(1) = 28;
        end
        pacman = pathWayLogic(pacman,pacman.speed);
    
        if frameDirection   % if mouth is opening 
            curFrame = curFrame+1;
        else                % if mouth is closing
            curFrame = curFrame-1;
        end
        
        if curFrame == 1        % if mouth is fully closed
            frameDirection = 1;
        elseif curFrame == 7    % if mouth is fully open
            frameDirection = 0;
        end
        
        % update pacman plot
        set(pacman.plot,'XData',pacman.frames{pacman.oldDir,curFrame}(1,:)+pacman.pos(1),'YData',pacman.frames{pacman.oldDir,curFrame}(2,:)+pacman.pos(2))
        
        if pacman.status == -3 % if pacman is hit by ghost
            lives.data = lives.data-1;  % lose 1 life
            
            % start animation
            for nn = 1:4 % turn ghosts off
                set(enemies(nn).plot,'Visible','off')
            end
            
            for nn = 0:18 % make pacman disappear
                set(pacman.plot,'XData',pacman.frames{pacman.oldDir,nn+1}(1,:)+pacman.pos(1),'YData',pacman.frames{pacman.oldDir,nn+1}(2,:)+pacman.pos(2))
                pause(0.05)
            end
            
            switch pacman.oldDir % move bursting-center to correct position
                case 1
                    explodeCorrection = [-0.4 0];
                case 2
                    explodeCorrection = [0 0.4];
                case 3
                    explodeCorrection = [0.4 0];
                case 4
                    explodeCorrection = [0 -0.4];
            end
            
            for nn = 1:rays.numFrames   % make pacman burst
                circ1 = rays.rad1(nn)*[sin(rays.t); cos(rays.t)];
                circ2 = rays.rad2(nn)*[sin(rays.t); cos(rays.t)];

                rays.data = zeros(2,3*rays.num);

                for kk = 1:rays.num
                    rays.data(1,1+(kk-1)*3:3+(kk-1)*3) = pacman.pos(1)+[circ1(1,kk) circ2(1,kk) NaN]+explodeCorrection(1);
                    rays.data(2,1+(kk-1)*3:3+(kk-1)*3) = pacman.pos(2)+[circ1(2,kk) circ2(2,kk) NaN]+explodeCorrection(2);
                end
                set(rays.plot,'XData',rays.data(1,:),'YData',rays.data(2,:),'Visible','on')
                pause(0.05)
            end
            set(rays.plot,'Visible','off')
            
            if lives.data >= 0 % start anew
                set(lives.plot(lives.data+1),'Visible','off')
                newGame
            else % Game Over
                set(info.text,'Visible','on','String','Game Over', 'Color','r')
                stop(myTimer)
                set(newGameButton,'Visible','on')
                set(createGhostsButton,'Visible','on')
                set(loadGhostsButton,'Visible','on')
            end
        end
        
    end

    function enemyRefresh % handles status and appearance of all ghosts 
        
        if curFrame == 3 || curFrame == 7 % switch between frames for movement illusion
            ghostFrame = ~ghostFrame;
        end
        for nn = 1:4 % consider one ghost at a time
            % ghost hits pacman
            if enemies(nn).status == 1 && abs(pacman.pos(1)-enemies(nn).pos(1)) < 1.1 && abs(pacman.pos(2)-enemies(nn).pos(2)) < 1.1
                pacman.status = -3; % pacman dies
            end
            
            % pacman hits grumpy ghost -> ghost dies
            if enemies(nn).status == 2 && abs(pacman.pos(1)-enemies(nn).pos(1)) < 1.1 && abs(pacman.pos(2)-enemies(nn).pos(2)) < 1.1
                enemies(nn).status = 3;
                enemies(nn).speed = overallEnemySpeed*2;
                enemies(nn).statusTimer = myTimer.TasksExecuted;
                ghostPoints = ghostPoints*2;
                score.data = score.data+ghostPoints;
                for mm = 0:30
                    set(enemies(nn).text,'String',num2str(ghostPoints),'Position',[enemies(nn).pos(1)-0.6,enemies(nn).pos(2)+mm/30,0],'Visible','on')
                    pause(0.02)
                end
                set(enemies(nn).text,'Visible','off')
            end
            
            % ghost or grumpy ghost exits the cage after certain time
            if nn > 1 && newEnemyTime*(nn-1) == myTimer.TasksExecuted
                if enemies(nn).status == 4
                    enemies(nn).status = 6;
                else
                    enemies(nn).status = 5;
                end
            end
            
            switch enemies(nn).status % handle ghost status 1 to 7
                case {0,4} % inside cage
                    if enemies(nn).pos(2) >= 17.5
                        enemies(nn).dir = 2;
                    elseif enemies(nn).pos(2) <= 16.5
                        enemies(nn).dir = 4;
                    end
                    switch enemies(nn).dir
                        case 2
                            enemySpeed = [0 -overallEnemySpeed];
                            enemies(nn).oldDir = enemies(nn).dir;
                            enemies(nn).pos = enemies(nn).pos+enemySpeed;
                        case 4
                            enemySpeed = [0 overallEnemySpeed];
                            enemies(nn).oldDir = enemies(nn).dir;
                            enemies(nn).pos = enemies(nn).pos+enemySpeed;
                    end
                    
                case 1 % normal mode
                    if enemies(nn).dir > 0
                        enemies(nn).oldDir = enemies(nn).dir;
                    end
                    if ~any(allPossibleMoves(enemies(nn)) == enemies(nn).dir) || ~isequal(allPossibleMoves(enemies(nn)),enemies(nn).curPosMov)
                        curSquare11 = findSquare(enemies(1),enemies(1).dir);
                        curSquare12 = findSquare(enemies(2),enemies(2).dir);
                        curSquare13 = findSquare(enemies(3),enemies(3).dir);
                        curSquare14 = findSquare(enemies(4),enemies(4).dir);
                        curSquare2 = findSquare(pacman,pacman.dir);
                       
                        [enemies(1).dir] = shortestPath(curSquare11,curSquare2,enemies(1));
                         [enemies(2).dir] = shortestPath2(curSquare12,curSquare2,enemies(2));
                          [enemies(3).dir] = shortestPath3(curSquare13,curSquare2,enemies(3));
                           [enemies(4).dir] = shortestPath4(curSquare14,curSquare2,enemies(4));
%                         oldpossibleMoves = possibleMoves ; 
pacman.pos;
                        enemies(nn) = pathWayLogic(enemies(nn),enemies(nn).speed);
                        enemies(nn).curPosMov = allPossibleMoves(enemies(nn));
                    else
                        enemies(nn) = pathWayLogic(enemies(nn),enemies(nn).speed);
                    end
                    
                case 2 % grumpy mode
                    if enemies(nn).dir > 0
                        enemies(nn).oldDir = enemies(nn).dir;
                    end
                    if ~any(allPossibleMoves(enemies(nn)) == enemies(nn).dir) || ~isequal(allPossibleMoves(enemies(nn)),enemies(nn).curPosMov)
                        curSquare1 = findSquare(enemies(nn),enemies(nn).dir);
                        curSquare2 = findSquare(pacman,pacman.dir);

                        [enemies(nn).dir] = shortestPath(curSquare1,curSquare2,enemies(nn));
                    end
                    enemies(nn) = pathWayLogic(enemies(nn),overallEnemySpeed*0.5);
                case 3 % eye mode
                    if enemies(nn).dir > 0
                        enemies(nn).oldDir = enemies(nn).dir;
                    end
                    if ~any(allPossibleMoves(enemies(nn)) == enemies(nn).dir) || ~isequal(allPossibleMoves(enemies(nn)),enemies(nn).curPosMov)
                        curSquare1 = findSquare(enemies(nn),enemies(nn).dir);
                        curSquare2 = [14.5, 20];

                        [enemies(nn).dir] = shortestPath(curSquare1,curSquare2,enemies(nn),possibleMoves);
                    end
                    enemies(nn) = pathWayLogic(enemies(nn),enemies(nn).speed*1);
                    if isequal(findSquare(enemies(nn),enemies(nn).dir),[14, 20]) || isequal(findSquare(enemies(nn),enemies(nn).dir),[15, 20])
                        enemies(nn).status = 7;
                        enemies(nn).pos = [14.5,20];
                        enemies(nn).dir = 2;
                    end
                case {5,6} % 5-inside cage on the way out normal mode, 6-inside cage on the way out grumpy mode
                    if enemies(nn).pos(1) < 14.5
                        enemies(nn).dir = 1;
                    elseif enemies(nn).pos(1) > 14.5
                        enemies(nn).dir = 3;
                    elseif enemies(nn).pos(2) < 19.75
                        enemies(nn).dir = 4;
                    elseif enemies(nn).pos(2) >= 19.75
                        if enemies(nn).status == 6
                            enemies(nn).status = 2;
                        else
                            enemies(nn).status = 1;
                        end
                    end
                    switch enemies(nn).dir
                        case 1
                            enemySpeed = [overallEnemySpeed 0];
                            enemies(nn).oldDir = enemies(nn).dir;
                            enemies(nn).pos = enemies(nn).pos+enemySpeed;
                        case 3
                            enemySpeed = [-overallEnemySpeed 0];
                            enemies(nn).oldDir = enemies(nn).dir;
                            enemies(nn).pos = enemies(nn).pos+enemySpeed;
                        case 4
                            enemySpeed = [0 overallEnemySpeed];
                            enemies(nn).oldDir = enemies(nn).dir;
                            enemies(nn).pos = enemies(nn).pos+enemySpeed;
                    end
                case 7 % on the way inside the cage
                    enemies(nn).dir = 2;
                    enemySpeed = [0 -overallEnemySpeed];
                    enemies(nn).oldDir = enemies(nn).dir;
                    enemies(nn).pos = enemies(nn).pos+enemySpeed;
                    if enemies(nn).pos(2) <= 16.5
                        enemies(nn).status = 5;
                    end
            end
            
            % ghost appearance depending on current ghost status
            if (enemies(nn).status == 2 || enemies(nn).status == 4 || enemies(nn).status == 6) && myTimer.TasksExecuted - enemies(nn).statusTimer < grumpyTime-grumpyTimeSwitch
                alphaMask = grumpySprites{1,ghostFrame+1}; % transparency
                plotGhost(enemies(nn),grumpySprites{1,ghostFrame+1},alphaMask)
            elseif (enemies(nn).status == 2 || enemies(nn).status == 4 || enemies(nn).status == 6) && myTimer.TasksExecuted - enemies(nn).statusTimer < grumpyTime
                % ghosts switch from blue to white every 10 frames
                if ~mod(myTimer.TasksExecuted,10) && grumpyTimeSwitchSave ~= myTimer.TasksExecuted
                    grumpyColorChange = ~grumpyColorChange;
                    grumpyTimeSwitchSave = myTimer.TasksExecuted; % remembers last color change
                end
                alphaMask = grumpySprites{grumpyColorChange+1,ghostFrame+1};
                plotGhost(enemies(nn),grumpySprites{grumpyColorChange+1,ghostFrame+1},alphaMask)
            elseif (enemies(nn).status == 3 || enemies(nn).status == 7) && myTimer.TasksExecuted - enemies(nn).statusTimer < grumpyTime-grumpyTimeSwitch
                alphaMask = eyeSprites{nn,enemies(nn).oldDir};
                plotGhost(enemies(nn),eyeSprites{nn,enemies(nn).oldDir},alphaMask)
            else
                enemies(nn).speed = overallEnemySpeed;
                alphaMask = ghostSprites{nn,enemies(nn).oldDir,ghostFrame+1};
                plotGhost(enemies(nn),ghostSprites{nn,enemies(nn).oldDir,ghostFrame+1},alphaMask)
            end
            % return from grumpy to normal
            if (enemies(nn).status == 2 && myTimer.TasksExecuted - enemies(nn).statusTimer >= grumpyTime) || (enemies(nn).status == 3 && myTimer.TasksExecuted - enemies(nn).statusTimer >= grumpyTime-grumpyTimeSwitch)
                enemies(nn).status = 1;
            end
            % Tunnel logic
            if enemies(nn).pos(1) > 28
                enemies(nn).pos(1) = 1;
            elseif enemies(nn).pos(1) < 1
                enemies(nn).pos(1) = 28;
            end
            % remember ghost movement possiblities, proportional to enemy
            % speed, so that he remebers only the last squares's
            % possibilities
            if ~mod(myTimer.TasksExecuted,1/enemies(nn).speed+1)
                enemies(nn).curPosMov = allPossibleMoves(enemies(nn));
            end
        end
        
    end

    function plotGhost(curGhost,curCData,curAlphaMask)
        curAlphaMask(curAlphaMask~=1) = 0;
        curAlphaMask = ~curAlphaMask;
        set(curGhost.plot,'XData',[curGhost.pos(1)-0.6 curGhost.pos(1)+0.6],...
                          'YData',[curGhost.pos(2)+0.6 curGhost.pos(2)-0.6],...
                          'CData',curCData,...
                          'AlphaData',curAlphaMask)
    end
    function curSquare = findSquare(entity,dir)
        if dir == 1 || dir == 4
            curSquare = [round(entity.pos(1)-0.45),round(entity.pos(2)-0.45)];
        else
            curSquare = [round(entity.pos(1)+0.45),round(entity.pos(2)+0.45)];
        end
    end

    function possibleMoves = allPossibleMoves(entity)
        curSquare = findSquare(entity,entity.dir);
        possibleMoves = allDirections{curSquare(1),curSquare(2)};
    end
separation = 0.5;%12.59;  %14  %16 %15   % 18.59 magical number 
rate1 = 1;%0.9700+0.0090;
rate2 = 1;%0.9700+0.0090;
t = +linspace(1,1,50);
T1 = 1;%10^3;
iter12 = 0 ;
distance1_array = zeros(1);
position1 = [12.5, 17.5];
position2 = [12.5, 17.5];
position3 = [14.5, 16.5];
position4 = [16.5, 17.5]; 
%%
%%
% simple -> simpler -> simplest -> my AI
function [nextMove1] = shortestPath(square1,square2,entity)
    iter12 = iter12 + 1 ;
    possibleMoves = allDirections{square1(1),square1(2)};
    enemies(1).possibleMoves = possibleMoves;
    %         Test_pacman = square2
    position1 = square1 ; 
    x1 = abs(square1(1)-square2(1));
    y1 = abs(square1(2)-square2(2));
    enemies(1).x1 = x1;
    enemies(1).y1 = y1;
    %         distance = x1 + y1
    distance1 = x1 + y1 ;
    enemies(1).distance1 = distance1;
    x1a = (square1(1)-square2(1));
    y1a = (square1(2)-square2(2));
    enemies(1).x1a = x1a;
    enemies(1).y1a = y1a;

    %         if (x1a < 0)
    %             x1_negative = x1a
    %         end
    if x1 >= y1;
        if x1a >= 0
            nextMove = 3;
        else
            nextMove = 1;
        end
    else
        if y1a >= 0;
            nextMove = 2;
        else
            nextMove = 4;
        end
    end
    nextMove_d10 = nextMove;
%% Sigmoid function -> Simulated Annealing, from High Temp(Random walk) to Low Temperature(Hill Climbing)
    t = linspace(1,10^3,50);  % t inversely proportional to Temperature,
%     Therefore, Temperature Very Low-> Very High
    T_0 = 10^3;
    if distance1 == 0 ;
        Temperature12 = 1000;
    else
        Temperature12 = 10^3*(0.9800+0.0000)^t(distance1); % Temperature,Low->High % Arbitrary Max distance 50
        Temperature12';
    end
%     Temperature12 = 1;
    sigmoid_fun_current = (1 + exp(-06*((1*distance1))/Temperature12))^(-1);
iter12
Temperature12
%     count1 = 0 ;
%     random_Gen = (randi([1, 100],1))/100;  % 0.5*max(sigmoid_function) = 0.250 ; % 50 % chance of selection 
%     if (sigmoid_function <= random_Gen); % if (Temperature <= 130);
%         count1 = count1 + 1 ;
%     end
%     Ghost_Distance = distance1;
%     Ghost_Temperature = Temperature;
%     Pr_1st_Ghost = sigmoid_function;
%     count1;
%%
%% end Sigmoid function Max Distance = 40, Min Distance = 12;
%%
% if (count1 == 1)
    %     flag10001 = 1
    corner = numel(possibleMoves);
    %% Node Selection Start : Completely avoids tunnel's nextMove
    tunnel = intersect(enemies(1).dir,enemies(1).possibleMoves);
    tunnel_out = isempty(tunnel);
    if (corner==2) & (tunnel_out==0)  ;
        nextMove = enemies(1).dir;  %      disp('tunnel')
        %% Node Selection End
    else %any(corner > 1) ;%~any(possibleMoves==enemies(1).dir) && numel(enemies(1).possibleMoves)==numel(enemies(1).possibleMoves);
        %       nextMove = nextMove;
        %         msize = numel(possibleMoves) ;
        %         idx = randperm(msize) ;
        %         nextMove = possibleMoves(idx(1:1)) ;
        % ** write code  1->Right 3->Left 2->Down 4->Up
        total_possibleMoves = numel(enemies(1).possibleMoves) ;
        switch total_possibleMoves
            %             case 1
            %                 ~any(possibleMoves==nextMove) ;
            %                 nextMove = possibleMoves ;  %Since numel(possibleMoves) is 1
            case 2   % Movement based on abs distance and non abs distance
                %                 disp('tunnel')
                %                 if (x1 >= y1) && (x1a>=0) ;
                %                     tentative_nextMove = [3] ;
                nextMove = intersect(nextMove,enemies(1).possibleMoves);
                %                 elseif (x1 >= y1) && (x1a<=0) ;
                %                     tentative_nextMove = [1];
                %                     nextMove = intersect(tentative_nextMove,possibleMoves);
                %                 elseif (y1 >= x1) && (y1a>=0) ;
                %                     tentative_nextMove = [2];
                %                     nextMove = intersect(tentative_nextMove,possibleMoves);
                %                 else (y1 >= x1) && (y1a<=0) ;
                %                     tentative_nextMove = [4];
                %                     nextMove = intersect(tentative_nextMove,possibleMoves);
                %                 end
                %            Number_nextMove = numel(nextMove) ;
                %            if (Number_nextMove > 1)
                %                if (nextMove == [1 3])
                %                    if (x1a >= 0)
                %                        nextMove = 3 ;
                %                    else
                %                        nextMove = 1 ;
                %                    end
                %                else (nextMove == [2 4])
                %                    if (y1a >= 0)
                %                        nextMove = 2 ;
                %                    else
                %                        nextMove = 4 ;
                %                    end
                %                end
                %            end
                if isempty(nextMove)  % possibleMoves does not match tentative nextMove
                    if (x1 >= y1) && (x1a>=0) ;
                        tentative_nextMove = [2] ;
                        nextMove = intersect(tentative_nextMove,enemies(1).possibleMoves);
                    elseif (x1 >= y1) && (x1a<=0) ;
                        tentative_nextMove = [4];
                        nextMove = intersect(tentative_nextMove,enemies(1).possibleMoves);
                    elseif (y1 >= x1) && (y1a>=0) ;
                        tentative_nextMove = [1];
                        nextMove = intersect(tentative_nextMove,enemies(1).possibleMoves);
                    else (y1 >= x1) && (y1a<=0) ;
                        tentative_nextMove = [3];
                        nextMove = intersect(tentative_nextMove,enemies(1).possibleMoves);
                    end
                end
                if isempty(nextMove)
                    if (x1 >= y1) && (x1a>=0) ;
                        tentative_nextMove = [4] ;
                        nextMove = intersect(tentative_nextMove,enemies(1).possibleMoves);
                    elseif (x1 >= y1) && (x1a<=0) ;
                        tentative_nextMove = [2];
                        nextMove = intersect(tentative_nextMove,enemies(1).possibleMoves);
                    elseif (y1 >= x1) && (y1a>=0) ;
                        tentative_nextMove = [3];
                        nextMove = intersect(tentative_nextMove,enemies(1).possibleMoves);
                    else (y1 >= x1) && (y1a<=0) ;
                        tentative_nextMove = [1];
                        nextMove = intersect(tentative_nextMove,enemies(1).possibleMoves);
                    end
                end
            case 3
                %                 disp('T-junction')
                if x1 > y1 ;
                    if (x1a >= 0);
                        nextMove = 3;
                    else
                        nextMove = 1;
                    end
                    nextMove = intersect(enemies(1).possibleMoves,nextMove);
                    if isempty(nextMove)
                        if (y1a >= 0) ;
                            nextMove = 2;
                        else
                            nextMove = 4;
                        end
                    end
                else y1 > x1 ;
                    if (y1a >= 0);
                        nextMove = 2;
                    else
                        nextMove = 4;
                    end
                    nextMove = intersect(enemies(1).possibleMoves,nextMove);
                    if isempty(nextMove)
                        if (x1a >= 0) ;
                            nextMove = 3;
                        else
                            nextMove = 1;
                        end
                    end
                end
                Number_nextMove = numel(nextMove) ;
                if Number_nextMove > 1
                    if (nextMove == [1 3])
                        if (x1a >= 0)
                            nextMove = 3 ;
                        else
                            nextMove = 1 ;
                        end
                    else (nextMove == [2 4])
                        if (y1a >= 0)
                            nextMove = 2 ;
                        else
                            nextMove = 4 ;
                        end
                    end
                end
                %     if (nextMove==3) || (nextMove==1) ;
                %         tentative_nextMove = [1 3] ;
                %       if (any(possibleMoves==1));
                %         possibleMoves(possibleMoves == 1) = [];
                %       else (any(possibleMoves==3));
                %         possibleMoves(possibleMoves == 3) = [];
                %       end
                %         nextMove = possibleMoves(randperm((length(possibleMoves)),1)) ;
                %     else (nextMove==2) || (nextMove==4) ;
                %         tentative_nextMove = [2 4] ;
                %       if (any(possibleMoves==2));
                %         possibleMoves(possibleMoves == 2) = [];
                %       else (any(possibleMoves==4));
                %         possibleMoves(possibleMoves == 4) = [];
                %       end
                %         nextMove = possibleMoves(randperm((length(possibleMoves)),1)) ;
                %     end
                %                 Test_case_3 = nextMove ;
            case 4
                if x1 >= y1
                    if x1a >= 0
                        nextMove = 3;
                    else
                        nextMove = 1;
                    end
                else
                    if y1a >= 0
                        nextMove = 2;
                    else
                        nextMove = 4;
                    end
                end
        end
    end
    nextMove_a1 = nextMove;
    Heat = 'Low Temperature';
    X = ['Red Ghost = ',Heat,', Manhattan distance = ',num2str(distance1)];
%     disp(X)
% elseif (count1 == 0) ;% && (enemies(1).distance1 < 2);
%%
%     disp('Acceptance_Pr > 0.46')
    corner = numel(enemies(1).possibleMoves);   
    %% Node Selection Start : Completely avoids tunnel's nextMove
%     if any(corner==2) ;%&& numel(enemies(1).possibleMoves)==numel(enemies(1).possibleMoves);
%         nextMove = enemies(1).oldDir;
%         disp('tunnel')
    %% Node Selection End
%     else %any(corner > 1) ;%~any(possibleMoves==enemies(1).dir) && numel(enemies(1).possibleMoves)==numel(enemies(1).possibleMoves);
        %       nextMove = nextMove;
        %         msize = numel(possibleMoves) ;
        %         idx = randperm(msize) ;
        %         nextMove = possibleMoves(idx(1:1)) ;
        % ** write code  1->Right 3->Left 2->Down 4->Up
        nextMove = nextMove_d10 ;
        total_possibleMoves = numel(enemies(1).possibleMoves) ;
        switch total_possibleMoves
%             case 1
%                 ~any(possibleMoves==nextMove) ;
%                 nextMove = possibleMoves ;  %Since numel(possibleMoves) is 1 
            case 2   % Movement based on abs distance and non abs distance
                %                 disp('tunnel')
%                                 if (x1 >= y1) && (x1a>=0) ;
%                                     tentative_nextMove = [3] ;
                nextMove = intersect(nextMove,enemies(1).possibleMoves);
%                                 elseif (x1 >= y1) && (x1a<=0) ;
%                                     tentative_nextMove = [1];
%                                     nextMove = intersect(tentative_nextMove,possibleMoves);
%                                 elseif (y1 >= x1) && (y1a>=0) ;
%                                     tentative_nextMove = [2];
%                                     nextMove = intersect(tentative_nextMove,possibleMoves);
%                                 else (y1 >= x1) && (y1a<=0) ;
%                                     tentative_nextMove = [4];
%                                     nextMove = intersect(tentative_nextMove,possibleMoves);
%                                 end
%                            Number_nextMove = numel(nextMove) ;
%                            if (Number_nextMove > 1)
%                                if (nextMove == [1 3])
%                                    if (x1a >= 0)
%                                        nextMove = 3 ;
%                                    else
%                                        nextMove = 1 ;
%                                    end
%                                else (nextMove == [2 4])
%                                    if (y1a >= 0)
%                                        nextMove = 2 ;
%                                    else
%                                        nextMove = 4 ;
%                                    end
%                                end
%                            end
                if isempty(nextMove)  % possibleMoves does not match tentative nextMove
                    if (x1 >= y1) && (x1a>=0) ;
                        tentative_nextMove = [2] ;
                        nextMove = intersect(tentative_nextMove,enemies(1).possibleMoves);
                    elseif (x1 >= y1) && (x1a<=0) ;
                        tentative_nextMove = [4];
                        nextMove = intersect(tentative_nextMove,enemies(1).possibleMoves);
                    elseif (y1 >= x1) && (y1a>=0) ;
                        tentative_nextMove = [1];
                        nextMove = intersect(tentative_nextMove,enemies(1).possibleMoves);
                    else (y1 >= x1) && (y1a<=0) ;
                        tentative_nextMove = [3];
                        nextMove = intersect(tentative_nextMove,enemies(1).possibleMoves);
                    end
                end
                if isempty(nextMove)
                    if (x1 >= y1) && (x1a>=0) ;
                        tentative_nextMove = [4] ;
                        nextMove = intersect(tentative_nextMove,enemies(1).possibleMoves);
                    elseif (x1 >= y1) && (x1a<=0) ;
                        tentative_nextMove = [2];
                        nextMove = intersect(tentative_nextMove,enemies(1).possibleMoves);
                    elseif (y1 >= x1) && (y1a>=0) ;
                        tentative_nextMove = [3];
                        nextMove = intersect(tentative_nextMove,enemies(1).possibleMoves);
                    else (y1 >= x1) && (y1a<=0) ;
                        tentative_nextMove = [1];
                        nextMove = intersect(tentative_nextMove,enemies(1).possibleMoves);
                    end
                end
            case 3
                %                 disp('T-junction')
                if x1 > y1 ;
                    if (x1a >= 0);
                        nextMove = 3;
                    else
                        nextMove = 1;
                    end
                    nextMove = intersect(enemies(1).possibleMoves,nextMove);
                    if isempty(nextMove)
                        if (y1a >= 0) ;
                            nextMove = 2;
                        else
                            nextMove = 4;
                        end
                    end
                else y1 > x1 ;
                    if (y1a >= 0);
                        nextMove = 2;
                    else
                        nextMove = 4;
                    end
                    nextMove = intersect(enemies(1).possibleMoves,nextMove);
                    if isempty(nextMove)
                        if (x1a >= 0) ;
                            nextMove = 3;
                        else
                            nextMove = 1;
                        end
                    end
                end
                Number_nextMove = numel(nextMove) ;
                if Number_nextMove > 1
                    if (nextMove == [1 3])
                        if (x1a >= 0)
                            nextMove = 3 ;
                        else
                            nextMove = 1 ;
                        end
                    else (nextMove == [2 4])
                        if (y1a >= 0)
                            nextMove = 2 ;
                        else
                            nextMove = 4 ;
                        end
                    end
                end
                %     if (nextMove==3) || (nextMove==1) ;
                %         tentative_nextMove = [1 3] ;
                %       if (any(possibleMoves==1));
                %         possibleMoves(possibleMoves == 1) = [];
                %       else (any(possibleMoves==3));
                %         possibleMoves(possibleMoves == 3) = [];
                %       end
                %         nextMove = possibleMoves(randperm((length(possibleMoves)),1)) ;
                %     else (nextMove==2) || (nextMove==4) ;
                %         tentative_nextMove = [2 4] ;
                %       if (any(possibleMoves==2));
                %         possibleMoves(possibleMoves == 2) = [];
                %       else (any(possibleMoves==4));
                %         possibleMoves(possibleMoves == 4) = [];
                %       end
                %         nextMove = possibleMoves(randperm((length(possibleMoves)),1)) ;
                %     end
                %                 Test_case_3 = nextMove ;
            case 4
                if x1 >= y1
                    if x1a >= 0
                        nextMove = 3;
                    else
                        nextMove = 1;
                    end
                else
                    if y1a >= 0
                        nextMove = 2;
                    else
                        nextMove = 4;
                    end
                end
%         end
    end
%%
%     Pincer_Moves = [0 nextMove];
%     idx = randi(length(Pincer_Moves)); % random index into x
%     nextMove1 = Pincer_Moves(idx);
    nextMove_a2 = nextMove;
Heat = 'High Temperature';   
X = ['Red Ghost = ',Heat,', Manhattan distance = ',num2str(distance1)];
% disp(X)
% end
%%
        corner = numel(enemies(1).possibleMoves);
%% Node Selection Start : Completely avoids tunnel's nextMove
    tunnel = intersect(enemies(1).dir,enemies(1).possibleMoves);
    tunnel_out = isempty(tunnel);
    if (corner==2) & (tunnel_out==0)  ;
        nextMove = enemies(1).dir;  %      disp('tunnel')
        %% Node Selection End
    else %any(corner > 1) ;%~any(possibleMoves==enemies(1).dir) && numel(enemies(1).possibleMoves)==numel(enemies(1).possibleMoves);
%         nextMove = nextMove_d10 ;

nextMove = enemies(1).possibleMoves ;
    if enemies(1).oldDir == 3;
    opposite_dir = [1];
    elseif enemies(1).oldDir == 1;
    opposite_dir = [3];
    elseif enemies(1).oldDir == 4;
    opposite_dir = [2];
    elseif enemies(1).oldDir == 2;
    opposite_dir = [4];
    end
nextMove = setxor(opposite_dir,nextMove);
nextMove = intersect(nextMove,enemies(1).possibleMoves);
idx = randi(length(nextMove)) ;
nextMove = nextMove(idx(:));
    if (isempty(nextMove)==1);
        idx = randi(length(enemies(1).possibleMoves)) ;
        nextMove = enemies(1).possibleMoves(idx(:));
%     elseif (isempty(new_nodes)~=1);
%         new_nodes = intersect(new_nodes,possibleMoves);
    end
        total_possibleMoves = numel(enemies(1).possibleMoves) ;
        switch total_possibleMoves;
%             case 1
%                 ~any(possibleMoves==nextMove) ;
%                 nextMove = possibleMoves ;  %Since numel(possibleMoves) is 1 
            case 2   % Movement based on abs distance and non abs distance
                %                 disp('tunnel')
%                                 if (x1 >= y1) && (x1a>=0) ;
%                                     tentative_nextMove = [3] ;
%                 nextMove = intersect(nextMove,possibleMoves);

%                 idx = randi(length(possibleMoves)); 
%                 nextMove = enemies(1).possibleMoves(idx(:));
            nextMove = enemies(1).possibleMoves ;
            if enemies(1).oldDir == 3;
                opposite_dir = [1];
            elseif enemies(1).oldDir == 1;
                opposite_dir = [3];
            elseif enemies(1).oldDir == 4;
                opposite_dir = [2];
            elseif enemies(1).oldDir == 2;
                opposite_dir = [4];
            end
            nextMove = setxor(opposite_dir,nextMove);
            nextMove = intersect(nextMove,enemies(1).possibleMoves);
            idx = randi(length(nextMove));
            nextMove = nextMove(idx(:));
            if (isempty(nextMove)==1);
                idx = randi(length(enemies(1).possibleMoves)) ;
                nextMove = enemies(1).possibleMoves(idx(:));
                %     elseif (isempty(new_nodes)~=1);
                %         new_nodes = intersect(new_nodes,possibleMoves);
            end
%                                 elseif (x1 >= y1) && (x1a<=0) ;
%                                     tentative_nextMove = [1];
%                                     nextMove = intersect(tentative_nextMove,possibleMoves);
%                                 elseif (y1 >= x1) && (y1a>=0) ;
%                                     tentative_nextMove = [2];
%                                     nextMove = intersect(tentative_nextMove,possibleMoves);
%                                 else (y1 >= x1) && (y1a<=0) ;
%                                     tentative_nextMove = [4];
%                                     nextMove = intersect(tentative_nextMove,possibleMoves);
%                                 end
%                            Number_nextMove = numel(nextMove) ;
%                            if (Number_nextMove > 1)
%                                if (nextMove == [1 3])
%                                    if (x1a >= 0)
%                                        nextMove = 3 ;
%                                    else
%                                        nextMove = 1 ;
%                                    end
%                                else (nextMove == [2 4])
%                                    if (y1a >= 0)
%                                        nextMove = 2 ;
%                                    else
%                                        nextMove = 4 ;
%                                    end
%                                end
%                            end
%                 if isempty(nextMove);  % possibleMoves does not match tentative nextMove
%                     if (x1 >= y1) && (x1a>=0) ;
%                         tentative_nextMove = [2] ;
%                         nextMove = intersect(tentative_nextMove,possibleMoves);
%                     elseif (x1 >= y1) && (x1a<=0) ;
%                         tentative_nextMove = [4];
%                         nextMove = intersect(tentative_nextMove,enemies(1).possibleMoves);
%                     elseif (y1 >= x1) && (y1a>=0) ;
%                         tentative_nextMove = [1];
%                         nextMove = intersect(tentative_nextMove,enemies(1).possibleMoves);
%                     else (y1 >= x1) && (y1a<=0) ;
%                         tentative_nextMove = [3];
%                         nextMove = intersect(tentative_nextMove,enemies(1).possibleMoves);
%                     end
%                 end
%                 if isempty(nextMove);
%                     if (x1 >= y1) && (x1a>=0) ;
%                         tentative_nextMove = [4] ;
%                         nextMove = intersect(tentative_nextMove,enemies(1).possibleMoves);
%                     elseif (x1 >= y1) && (x1a<=0) ;
%                         tentative_nextMove = [2];
%                         nextMove = intersect(tentative_nextMove,enemies(1).possibleMoves);
%                     elseif (y1 >= x1) && (y1a>=0) ;
%                         tentative_nextMove = [3];
%                         nextMove = intersect(tentative_nextMove,enemies(1).possibleMoves);
%                     else (y1 >= x1) && (y1a<=0) ;
%                         tentative_nextMove = [1];
%                         nextMove = intersect(tentative_nextMove,enemies(1).possibleMoves);
%                     end
%                 end
            case 3
%                 %                 disp('T-junction')
%                 if x1 > y1 ;
%                     if (x1a >= 0);
%                         nextMove = 3;
%                     else
%                         nextMove = 1;
%                     end
% %                     nextMove = intersect(possibleMoves,nextMove);
%                         idx = randi(length(possibleMoves)) ;
%                         nextMove = possibleMoves(idx(:));
%                     if isempty(nextMove);
%                         if (y1a >= 0) ;
%                             nextMove = 2;
%                         else
%                             nextMove = 4;
%                         end
%                     end
%                 else y1 > x1 ;
%                     if (y1a >= 0);
%                         nextMove = 2;
%                     else
%                         nextMove = 4;
%                     end
%                     %                     nextMove = intersect(possibleMoves,nextMove);
%                     idx = randi(length(possibleMoves)) ;
%                     nextMove = possibleMoves(idx(:));
%                     if isempty(nextMove);
%                         if (x1a >= 0) ;
%                             nextMove = 3;
%                         else
%                             nextMove = 1;
%                         end
%                     end
%                 end
%                 Number_nextMove = numel(nextMove) ;
%                 if Number_nextMove > 1;
%                     if (nextMove == [1 3]);
%                         if (x1a >= 0);
%                             nextMove = 3 ;
%                         else
%                             nextMove = 1 ;
%                         end
%                     else (nextMove == [2 4]);
%                         if (y1a >= 0);
%                             nextMove = 2 ;
%                         else
%                             nextMove = 4 ;
%                         end
%                     end
%                 end
            nextMove = enemies(1).possibleMoves ;
            if enemies(1).oldDir == 3;
                opposite_dir = [1 3];
            elseif enemies(1).oldDir == 1;
                opposite_dir = [1 3];
            elseif enemies(1).oldDir == 4;
                opposite_dir = [2 4];
            elseif enemies(1).oldDir == 2;
                opposite_dir = [2 4];
            end
            nextMove = setxor(opposite_dir,nextMove);
            nextMove = intersect(nextMove,enemies(1).possibleMoves);
            idx = randi(length(nextMove));
            nextMove = nextMove(idx(:));
%             if (isempty(nextMove)==1);
%                 idx = randi(length(enemies(1).possibleMoves)) ;
%                 nextMove = enemies(1).possibleMoves(idx(:));
%                 %     elseif (isempty(new_nodes)~=1);
%                 %         new_nodes = intersect(new_nodes,possibleMoves);
%             end
                
                %     if (nextMove==3) || (nextMove==1) ;
                %         tentative_nextMove = [1 3] ;
                %       if (any(possibleMoves==1));
                %         possibleMoves(possibleMoves == 1) = [];
                %       else (any(possibleMoves==3));
                %         possibleMoves(possibleMoves == 3) = [];
                %       end
                %         nextMove = possibleMoves(randperm((length(possibleMoves)),1)) ;
                %     else (nextMove==2) || (nextMove==4) ;
                %         tentative_nextMove = [2 4] ;
                %       if (any(possibleMoves==2));
                %         possibleMoves(possibleMoves == 2) = [];
                %       else (any(possibleMoves==4));
                %         possibleMoves(possibleMoves == 4) = [];
                %       end
                %         nextMove = possibleMoves(randperm((length(possibleMoves)),1)) ;
                %     end
                %                 Test_case_3 = nextMove ;
            case 4
%                 if x1 >= y1;
%                     if x1a >= 0;
%                         nextMove = 3;
%                     else
%                         nextMove = 1;
%                     end
%                 else
%                     if y1a >= 0;
%                         nextMove = 2;
%                     else
%                         nextMove = 4;
%                     end
%                 end
            nextMove = enemies(1).possibleMoves ;
            if enemies(1).oldDir == 3;
                opposite_dir = [1];
            elseif enemies(1).oldDir == 1;
                opposite_dir = [3];
            elseif enemies(1).oldDir == 4;
                opposite_dir = [2];
            elseif enemies(1).oldDir == 2;
                opposite_dir = [4];
            end
            nextMove = setxor(opposite_dir,nextMove);
            nextMove = intersect(nextMove,enemies(1).possibleMoves);
            idx = randi(length(nextMove));
            nextMove = nextMove(idx(:));  
        end
    end
%%
    Pincer_Moves = [0 nextMove];
    idx = randi(length(Pincer_Moves)); % random index into x
%     nextMove1 = Pincer_Moves(idx);
    nextMove_a3 = nextMove;
Heat = 'High Temperature';   
X = ['Red Ghost = ',Heat,', Manhattan distance = ',num2str(distance1)];
% disp(X)
% end

%%  
% new_nodes = [nextMove_a1 nextMove_a2 nextMove_a3] ;
% new_nodes = [nextMove_a1 nextMove_a2] ;
new_nodes = [nextMove_a3] ;
coordinates1 = square1;
for i = 1:numel(new_nodes)
if (new_nodes(i)==1) ;
    coordinates1(1) = coordinates1(1) + 1;
elseif (new_nodes(i)== 3) ;
    coordinates1(1) = coordinates1(1) - 1;
elseif (new_nodes(i)== 4);
    coordinates1(2) = coordinates1(2) + 1;
elseif (new_nodes(i)== 2);
    coordinates1(2) = coordinates1(2) - 1;
else (new_nodes(i)== 0);
    coordinates1(1) = coordinates1(1) ;
end
% if (i == 1) ;
% Energy_val_a3 = abs(coordinates1(1)-square2(1)) + abs(coordinates1(2)-square2(2));
% if (i == 1) ; 
Energy_val_a1 = abs(coordinates1(1)-square2(1)) + abs(coordinates1(2)-square2(2));
% elseif (i == 2) ; 
% Energy_val_a2 = abs(coordinates1(1)-square2(1)) + abs(coordinates1(2)-square2(2));
% end
coordinates1 = square1;   %% ADD THIS LINE
end
% Add extra score to fitness values of best and better heuristics  
% del_E13 = distance1 - Energy_val_a3 -0;
% del_E12 = distance1 - Energy_val_a2 +0; %Add +2 to best node
del_E11 = distance1 - Energy_val_a1 +0; %Add +2 to best node

% Energy_val_a = [del_E11 del_E12] ;
Energy_val_a = [del_E11] ;
% for i = 1:3
%     if (Energy_val_a(i) >= 0)
%         Energy_val_a(i) = Energy_val_a(i) + 2 ;
%     else (Energy_val_a(i) < 0)
%         Energy_val_a(i) = Energy_val_a(i) - 2 ;
%     end
% end
% Energy_val_a 
%Chooses between good nodes with probabality (between nextMove_a2 and nextMove_a3)
%sigmoid_fun shifts from 1 to 0.5
%[nextMove_a3 nextMove_a1 nextMove_a2]
%picks a specific node or accepts 1st good node and then moves into that node/state and does not move to nextMove_a2 
% Or when distance is high sigmoid_fun is close to 1 and accepts 1st good node is sees

%becomes explorating in nature at low distance  when distance is low
%sigmoid_fun is close to 0.5 and accepts between 
%good node (nextMove_a1 nextMove_a2)
% random_Gen1 = 0;%(randi([1, 100],1))/100 ; %if 0, then always Reject bad nodes (nextMove_a3) 
random_Gen11 = (randi([1, 100],1))/100 ; %Choose between heuristics A and B
test_sigmoid_fun_current = sigmoid_fun_current ;
%if random_Gen1 = 0; sigmoid_func = 0.5; rejects bad nodes
%if random_Gen1 = 1; sigmoid_func = 0.5; accepts bad nodes
for i = 1:numel(new_nodes) ;
if (Energy_val_a(i) > 0) ;
%     nextMove1 = new_nodes(i);
%     flag_a = 1 ;
%      % End loop
    % Pr of Acceptance
    if (sigmoid_fun_current > random_Gen11); % if (Temperature <= 130);
        nextMove1 = new_nodes(i);
        flag_accept_good_node = 1 ;
        flag_accept = 'accept';
    else (sigmoid_fun_current <= random_Gen11);
        nextMove1 = 0;
        flag_reject_good_node = 1 ;
        flag_accept = 'reject';
        % idx = find(Energy_val_a == min(Energy_val_a(:)))
        % nextMove1 = node(idx)
    end
else (Energy_val_a(i) <= 0) ;
    flag_b = 1 ;
    % Pr of Rejection
    if ((sigmoid_fun_current) < random_Gen11) 
        nextMove1 = 0 ;%nextMove_c; % Reject Generated neighbor and remain stationary
        %         Node_rejection_1 = Node_rejection_1 + 1 ;
        flag_reject_bad_node = 1;
        flag_accept = 'reject';
    else ((sigmoid_fun_current) >= random_Gen11) ;
        %         nextMove1 = nextMove_a1;
        %         idx = randi(length(Energy_val_a)) ;
        %         nextMove1 = node(idx(:));
        nextMove1 = new_nodes(i) ; 
         % End loop
        flag_accept_bad_node = 1;
        flag_accept = 'accept';
    end
end
   if (nextMove1 ~= 0)  ;
        break
    elseif (i==2)
% %         direction = enemies(1).possibleMoves;
% %         idx = randi(length(direction)); % random index into x
%         nextMove1 = new_nodes(3);
        break
    end
test_nextMove1 = nextMove1;
end
        node_i = i;
        node1 = node_i;
X1 = ['Red Ghost: ','Pr. of Acceptance = ',num2str(sigmoid_fun_current),' Temperature = ',num2str(Temperature12), ', node = ',num2str(flag_accept)];% ', distance = ',num2str(distance1)];
% disp(X1)
% nextMove1 = nextMove_a2;
% del_E21
% del_E22
% sigmoid_fun_current
% %%
%     if distance1 == 0 ;
%         pack_threshold1 = T1;
%     else
%         pack_threshold1 = [T1*(rate1)^+t(distance1)] + separation; % Temperature,Low->High % Arbitrary Max distance 50
%     end
%     pack_threshold1 ;
% pack12 = ((position1(1) - position2(1))^2 + (position1(2) - position2(2))^2)^0.5 ; 
% pack13 = ((position1(1) - position3(1))^2 + (position1(2) - position3(2))^2)^0.5 ; 
% pack14 = ((position1(1) - position4(1))^2 + (position1(2) - position4(2))^2)^0.5 ;
% % pack_wolf = pack12 + pack13 + pack14 ;
% pack_vec1 = [pack12 pack13 pack14] ;  
%     idx = find(pack_vec1==min(pack_vec1));
%     if (idx==1);
%     square3 = position2;
%     elseif (idx==2);
%     square3 = position3;
%     else (idx==3);
%     square3 = position4;
%     end
% % pack_threshold1
% % pack_wolf
% x12 = (abs(square1(1)-square3(1)))/1;
% y12 = (abs(square1(2)-square3(2)))/1;
% % enemies(1).x1 = x1;
% % enemies(1).y1 = y1;
% %         distance = x1 + y1
% distance12 = x12 + y12; 
% if ((pack_threshold1) >= distance12);
%     flag_repel = 1;
% x1 = x12;
% y1 = y12;
% % enemies(1).x1 = x1;
% % enemies(1).y1 = y1;
% %         distance = x1 + y1
% % square2 = pack_index1;
% 
% % enemies(1).x1 = x1;
% % enemies(1).y1 = y1;
% %         distance = x1 + y1
% distance12 = x1 + y1; 
% % enemies(1).distance1 = distance1;
% x1a = ((square1(1)-square3(1)));
% y1a = ((square1(2)-square3(2)));
% % enemies(1).x1a = x1a;
% % enemies(1).y1a = y1a;
% %         if (x1a < 0)
% %             x1_negative = x1a
% %         end
% if x1 >= y1;
%     if x1a >= 0
%         nextMove = 1;
%     else
%         nextMove = 3;
%     end
% else
%     if y1a >= 0;
%         nextMove = 4;
%     else
%         nextMove = 2;
%     end
% end
%     corner = numel(possibleMoves);
%     %% Node Selection Start : Completely avoids tunnel's nextMove
%     tunnel = intersect(enemies(1).dir,enemies(1).possibleMoves);
%     tunnel_out = isempty(tunnel);
% %     if (corner==2) & (tunnel_out==0)  ;
% %         nextMove = enemies(1).dir;  %      disp('tunnel')
% %         % Node Selection End
% %     else %any(corner > 1) ;%~any(possibleMoves==enemies(1).dir) && numel(enemies(1).possibleMoves)==numel(enemies(1).possibleMoves);
%         total_possibleMoves = numel(enemies(1).possibleMoves) ;
%         switch total_possibleMoves
%             case 2   % Movement based on abs distance and non abs distance
%                 nextMove = intersect(nextMove,enemies(1).possibleMoves);
%                 if isempty(nextMove)  % possibleMoves does not match tentative nextMove
%                     if (x1 >= y1) && (x1a>=0) ;
%                         tentative_nextMove = [4] ;
%                         nextMove = intersect(tentative_nextMove,enemies(1).possibleMoves);
%                     elseif (x1 >= y1) && (x1a<=0) ;
%                         tentative_nextMove = [2];
%                         nextMove = intersect(tentative_nextMove,enemies(1).possibleMoves);
%                     elseif (y1 >= x1) && (y1a>=0) ;
%                         tentative_nextMove = [3];
%                         nextMove = intersect(tentative_nextMove,enemies(1).possibleMoves);
%                     else (y1 >= x1) && (y1a<=0) ;
%                         tentative_nextMove = [1];
%                         nextMove = intersect(tentative_nextMove,enemies(1).possibleMoves);
%                     end
%                 end
%                 if isempty(nextMove)
%                     if (x1 >= y1) && (x1a>=0) ;
%                         tentative_nextMove = [2] ;
%                         nextMove = intersect(tentative_nextMove,enemies(1).possibleMoves);
%                     elseif (x1 >= y1) && (x1a<=0) ;
%                         tentative_nextMove = [4];
%                         nextMove = intersect(tentative_nextMove,enemies(1).possibleMoves);
%                     elseif (y1 >= x1) && (y1a>=0) ;
%                         tentative_nextMove = [1];
%                         nextMove = intersect(tentative_nextMove,enemies(1).possibleMoves);
%                     else (y1 >= x1) && (y1a<=0) ;
%                         tentative_nextMove = [3];
%                         nextMove = intersect(tentative_nextMove,enemies(1).possibleMoves);
%                     end
%                 end
%             case 3
%                 if x1 > y1 ;
%                     if (x1a >= 0);
%                         nextMove = 1;
%                     else
%                         nextMove = 3;
%                     end
%                     nextMove = intersect(enemies(1).possibleMoves,nextMove);
%                     if isempty(nextMove)
%                         if (y1a >= 0) ;
%                             nextMove = 4;
%                         else
%                             nextMove = 2;
%                         end
%                     end
%                 else y1 > x1 ;
%                     if (y1a >= 0);
%                         nextMove = 4;
%                     else
%                         nextMove = 2;
%                     end
%                     nextMove = intersect(enemies(1).possibleMoves,nextMove);
%                     if isempty(nextMove)
%                         if (x1a >= 0) ;
%                             nextMove = 1;
%                         else
%                             nextMove = 3;
%                         end
%                     end
%                 end
%                 Number_nextMove = numel(nextMove) ;
%                 if Number_nextMove > 1
%                     if (nextMove == [1 3])
%                         if (x1a >= 0)
%                             nextMove = 1 ;
%                         else
%                             nextMove = 3 ;
%                         end
%                     else (nextMove == [2 4])
%                         if (y1a >= 0)
%                             nextMove = 4 ;
%                         else
%                             nextMove = 2 ;
%                         end
%                     end
%                 end
%         end
% %     end
% nextMove1 = nextMove ; 
% end
%test_nextMove1
% %% Start Timer
% %     Test_timer = Timer_on1
%         if (enemies(1).distance1 >= 10) && (Timer_on1==1) ;
%             tic ;
%             Timer_on1 = 0 ;
%         end
% %             d1=0;d2=0;d3=0;d4=0;d5=0;d6=0;d7=0;d8=0;d9=0;d10=0;d11=0;d12=0;d13=0;d14=0;d15=0;d16=0;d17=0;d18=0;d19=0;d20=0;d21=0;d22=0;d23=0;d24=0;  %     d = ones(3,1);
%         if (toc>=1) && (toc<2) ;
%         d1 = enemies(1).distance1;
%         save('out1.mat','d1');Timer_on1 = 0 ;
%         end
%         if (toc>=2) && (toc<3) ;
%         d2 = enemies(1).distance1;
%         save('outout2.mat','d2');Timer_on1 = 0 ;
%         end
%         if (toc>=3) && (toc<4) ;
%         d3 = enemies(1).distance1;
%         save('out3.mat','d3');Timer_on1 = 0 ;
%         end
%         if (toc>=4) && (toc<5) ;
%         d4 = enemies(1).distance1;
%         save('out4.mat','d4');Timer_on1 = 0 ;
%         end
%         if (toc>=5) && (toc<6) ;
%         d5 = enemies(1).distance1;
%         save('out5.mat','d5');Timer_on1 = 0 ;
%         end
%         if (toc>=6) && (toc<7) ;
%         d6 = enemies(1).distance1;
%         save('out6.mat','d6');Timer_on1 = 0 ;
%         end
%         if (toc>=7) && (toc<8) ;
%         d7 = enemies(1).distance1;
%         save('out7.mat','d7');Timer_on1 = 0 ;
%         end
%         if (toc>=8) && (toc<9) ;
%         d8 = enemies(1).distance1;
%         save('out8.mat','d8');Timer_on1 = 0 ;
%         end
%         if (toc>=9) && (toc<10) ;
%         d9 = enemies(1).distance1;
%         save('out9.mat','d9');Timer_on1 = 0 ;
%         end
%         if (toc>=10) && (toc<11) ;
%         d10 = enemies(1).distance1;
%         save('outout10.mat','d10');Timer_on1 = 0 ;
%         end
%         if (toc>=11) && (toc<12) ;
%         d11 = enemies(1).distance1;
%         save('out11.mat','d11');Timer_on1 = 0 ;
%         end
%         if (toc>=12) && (toc<13) ;
%         d12 = enemies(1).distance1;
%         save('out12.mat','d12');Timer_on1 = 0 ;
%         end
%         if (toc>=13) && (toc<14) ;
%         d13 = enemies(1).distance1;
%         save('out13.mat','d13');Timer_on1 = 0 ;
%         end
%         if (toc>=14) && (toc<15) ;
%         d14 = enemies(1).distance1;
%         save('out14.mat','d14');Timer_on1 = 0 ;
%         end
%         if (toc>=15) && (toc<16) ;
%         d15 = enemies(1).distance1;
%         save('out15.mat','d15');Timer_on1 = 0 ;
%         end
%         if (toc>=16) && (toc<17) ;
%         d16 = enemies(1).distance1;
%         save('out16.mat','d16');Timer_on1 = 0 ;
%         end
%         if (toc>=17) && (toc<18) ;
%         d17 = enemies(1).distance1;
%         save('out17.mat','d17');Timer_on1 = 0 ;
%         end
%         if (toc>=18) && (toc<19) ;
%         d18 = enemies(1).distance1;
%         save('out18.mat','d18');Timer_on1 = 0 ;
%         end
%         if (toc>=19) && (toc<20) ;
%         d19 = enemies(1).distance1;
%         save('out19.mat','d19');Timer_on1 = 0 ;
%         end
%         if (toc>=20) && (toc<21) ;
%         d20 = enemies(1).distance1;
%         save('out20.mat','d20');Timer_on1 = 0 ;
%         end
%         if (toc>=21) && (toc<22) ;
%         d21 = enemies(1).distance1;
%         save('out21.mat','d21');Timer_on1 = 0 ;
%         end
%         if (toc>=22) && (toc<23) ;
%         d22 = enemies(1).distance1;
%         save('outout22.mat','d22');Timer_on1 = 0 ;
%         end
%         if (toc>=23) && (toc<24) ;
%         d23 = enemies(1).distance1;
%         save('out23.mat','d23');Timer_on1 = 0 ;
%         end
%         if (toc>=24) && (toc<25) ;
%         d24 = enemies(1).distance1;
%         save('out24.mat','d24');Timer_on1 = 0 ;
%         end
%         if (toc>=25) && (toc<26) ;
%         d25 = enemies(1).distance1;
%         save('out25.mat','d25');Timer_on1 = 0 ;
%         end
%         if (toc>=26) && (toc<27) ;
%         d26 = enemies(1).distance1;
%         save('out26.mat','d26');Timer_on1 = 0 ;
%         end
%         if (toc>=27) && (toc<28) ;
%         d27 = enemies(1).distance1;
%         save('out27.mat','d27');Timer_on1 = 0 ;
%         end
%         if (toc>=28) && (toc<29) ;
%         d28 = enemies(1).distance1;
%         save('out28.mat','d28');Timer_on1 = 0 ;
%         end
%         if (toc>=29) && (toc<30) ;
%         d29 = enemies(1).distance1;
%         save('out29.mat','d29');Timer_on1 = 0 ;
%         end
%         if (toc>=30) && (toc<31) ;
%         d30 = enemies(1).distance1;
%         save('outout30.mat','d30');Timer_on1 = 0 ;
%         end
%         if (toc>=31) && (toc<32) ;
%         d31 = enemies(1).distance1;
%         save('out31.mat','d31');Timer_on1 = 0 ;
%         end
%         if (toc>=32) && (toc<33) ;
%         d32 = enemies(1).distance1;
%         save('out32.mat','d32');Timer_on1 = 0 ;
%         end
%         if (toc>=33) && (toc<34) ;
%         d33 = enemies(1).distance1;
%         save('out33.mat','d33');Timer_on1 = 0 ;
%         end
%         if (toc>=34) && (toc<35) ;
%         d34 = enemies(1).distance1;
%         save('out34.mat','d34');Timer_on1 = 0 ;
%         end
%         if (toc>=35) && (toc<36) ;
%         d35 = enemies(1).distance1;
%         save('out35.mat','d35');Timer_on1 = 0 ;
%         flag_35 = 35 
%         end
%         if (toc>=36) && (toc<37) ;
%         d36 = enemies(1).distance1;
%         save('out36.mat','d36');Timer_on1 = 0 ;
%         flag_36 = 36 
%         end
%         if (toc>=37) && (toc<38) ;
%         d37 = enemies(1).distance1;
%         save('out37.mat','d37');Timer_on1 = 0 ;
%         flag_37 = 37 
%         end
%         if (toc>=38) && (toc<39) ;
%         d38 = enemies(1).distance1;
%         save('out38.mat','d38');Timer_on1 = 0 ;
%         flag_38 = 38 
%         end
%         if (toc>=39) && (toc<40) ;
%         d39 = enemies(1).distance1;
%         save('out39.mat','d39');Timer_on1 = 0 ;
%         flag_39 = 39 
%         end
%         if (toc>=40) && (toc<41) ;
%         d40 = enemies(1).distance1;
%         save('out40.mat','d40');Timer_on1 = 0 ;
%         flag_40 = 40 
%         end
% %         elseif (toc>=21) && (toc<22) ;
% %         d21 = enemies(1).distance1
% %         save('o21.mat','d21')
% % %         end
% %         elseif (toc>=22) && (toc<23) ;
% %         d22 = enemies(1).distance1
% %         save('o22.mat','d22')
% % %         end
% %         elseif (toc>=23) && (toc<24) ;
% %         d23 = enemies(1).distance1
% %         save('o23.mat','d23')
% % %         end
% %         end
%         
%     if (enemies(1).distance1 < 3) || (toc>=39);%(Timer_on1==0) ;
%     Timer_1 = toc;
%     %      t = timeseries(Timer_1)
%     for j = 1:60
%         if (Timer_1>j)
%             t(j) = j;
% %             distance1
%         end
%     end
% load('out1.mat','d1');
% load('outout2.mat','d2');
% load('out3.mat','d3');
% load('out4.mat','d4');
% load('out5.mat','d5');
% load('out6.mat','d6');
% load('out7.mat','d7');
% load('out8.mat','d8');
% load('out9.mat','d9');
% load('outout10.mat','d10');
% load('out11.mat','d11');
% load('out12.mat','d12');
% load('out13.mat','d13');
% load('out14.mat','d14');
% load('out15.mat','d15');
% load('out16.mat','d16');
% load('out17.mat','d17');
% load('out18.mat','d18');
% load('out19.mat','d19');
% load('out20.mat','d20');
% % load('out21.mat','d21')
% % load('out22.mat','d22')
% % load('out24.mat','d24')
% load('out21.mat','d21');
% load('outout22.mat','d22');
% load('out23.mat','d23');
% load('out24.mat','d24');
% load('out25.mat','d25');
% load('out26.mat','d26');
% load('out27.mat','d27');
% load('out28.mat','d28');
% load('out29.mat','d29');
% load('outout30.mat','d30');
% load('out31.mat','d31');
% load('out32.mat','d32');
% load('out33.mat','d33');
% load('out34.mat','d34');
% load('out35.mat','d35');
% load('out36.mat','d36');
% load('out37.mat','d37');
% load('out38.mat','d38');
% load('out39.mat','d39');
% load('out40.mat','d40');
% 
%     dist_vec = [d1 d2 d3 d4 d5 d6 d7 d8 d9 d10 d11 d12 d13 d14 d15 d16 d17 d18 d19 d20 d21 d22 d23 d24 d25 d26 d27 d28 d29 d30 d31 d32 d33 d34 d35 d36 d37 d38 d39 d40] ;% d21 d22 d23 d24] ;
%     save('dist_vec1.mat','dist_vec');
%     flag = 1;
% %     stem(1:20,dist_vec); Discrete Real time-series plot
%     end
% %% End Timer
    distance1_array(iter12) = [distance1];
    if (iter12==400) %|| (enemies(1).distance1 < 3); %&& (toc<40)
    flag_save_array = 1
%     save('distance1_array171a.mat','distance1_array');
%     save('distance1_array171b.mat','distance1_array');
%     save('distance1_array171c.mat','distance1_array');
%     save('distance1_array171d.mat','distance1_array');
%     save('distance1_array171e.mat','distance1_array');
%     save('distance1_array171f.mat','distance1_array');
%     save('distance1_array171g.mat','distance1_array');
%     save('distance1_array171h.mat','distance1_array');
%     save('distance1_array171i.mat','distance1_array');
%     save('distance1_array171j.mat','distance1_array');
%     save('distance1_array171k.mat','distance1_array');
%     save('distance1_array171l.mat','distance1_array');
%     save('distance1_array171m.mat','distance1_array');
%     save('distance1_array171n.mat','distance1_array');
%     save('distance1_array171o.mat','distance1_array');
%     save('distance1_array171p.mat','distance1_array');
%     save('distance1_array171q.mat','distance1_array');
%     save('distance1_array171r.mat','distance1_array');
%     save('distance1_array171s.mat','distance1_array');
    save('distance1_array171t.mat','distance1_array');
% %
%     save('distance1_array171a1.mat','distance1_array');
%     save('distance1_array171b1.mat','distance1_array');
%     save('distance1_array171c1.mat','distance1_array');
%     save('distance1_array171d1.mat','distance1_array');
%     save('distance1_array171e1.mat','distance1_array');
%     save('distance1_array171f1.mat','distance1_array');
%     save('distance1_array171g1.mat','distance1_array');
%     save('distance1_array171h1.mat','distance1_array');
%     save('distance1_array171i1.mat','distance1_array');
%     save('distance1_array171j1.mat','distance1_array');
%     save('distance1_array171k1.mat','distance1_array');
%     save('distance1_array171l1.mat','distance1_array');
%     save('distance1_array171m1.mat','distance1_array');
%     save('distance1_array171n1.mat','distance1_array');
%     save('distance1_array171o1.mat','distance1_array');
%     save('distance1_array171p1.mat','distance1_array');
%     save('distance1_array171q1.mat','distance1_array');
%     save('distance1_array171r1.mat','distance1_array');
%     save('distance1_array171s1.mat','distance1_array');
%     save('distance1_array171t1.mat','distance1_array');
% %
%     save('distance1_array171a2.mat','distance1_array');
%     save('distance1_array171b2.mat','distance1_array');
%     save('distance1_array171c2.mat','distance1_array');
%     save('distance1_array171d2.mat','distance1_array');
%     save('distance1_array171e2.mat','distance1_array');
%     save('distance1_array171f2.mat','distance1_array');
%     save('distance1_array171g2.mat','distance1_array');
%     save('distance1_array171h2.mat','distance1_array');
%     save('distance1_array171i2.mat','distance1_array');
%     save('distance1_array171j2.mat','distance1_array');
%     save('distance1_array171k2.mat','distance1_array');
%     save('distance1_array171l2.mat','distance1_array');
%     save('distance1_array171m2.mat','distance1_array');
%     save('distance1_array171n2.mat','distance1_array');
%     save('distance1_array171o2.mat','distance1_array');
%     save('distance1_array171p2.mat','distance1_array');
%     save('distance1_array171q2.mat','distance1_array');
%     save('distance1_array171r2.mat','distance1_array');
%     save('distance1_array171s2.mat','distance1_array');
%     save('distance1_array171t2.mat','distance1_array');
    elseif (enemies(1).distance1 < 3);
    flag_save_array = 1
%     save('distance1_array171a.mat','distance1_array');
%     save('distance1_array171b.mat','distance1_array');
%     save('distance1_array171c.mat','distance1_array');
%     save('distance1_array171d.mat','distance1_array');
%     save('distance1_array171e.mat','distance1_array');
%     save('distance1_array171f.mat','distance1_array');
%     save('distance1_array171g.mat','distance1_array');
%     save('distance1_array171h.mat','distance1_array');
%     save('distance1_array171i.mat','distance1_array');
%     save('distance1_array171j.mat','distance1_array');
%     save('distance1_array171k.mat','distance1_array');
%     save('distance1_array171l.mat','distance1_array');
%     save('distance1_array171m.mat','distance1_array');
%     save('distance1_array171n.mat','distance1_array');
%     save('distance1_array171o.mat','distance1_array');
%     save('distance1_array171p.mat','distance1_array');
%     save('distance1_array171q.mat','distance1_array');
%     save('distance1_array171r.mat','distance1_array');
%     save('distance1_array171s.mat','distance1_array');
    save('distance1_array171t.mat','distance1_array');
% %
%     save('distance1_array171a1.mat','distance1_array');
%     save('distance1_array171b1.mat','distance1_array');
%     save('distance1_array171c1.mat','distance1_array');
%     save('distance1_array171d1.mat','distance1_array');
%     save('distance1_array171e1.mat','distance1_array');
%     save('distance1_array171f1.mat','distance1_array');
%     save('distance1_array171g1.mat','distance1_array');
%     save('distance1_array171h1.mat','distance1_array');
%     save('distance1_array171i1.mat','distance1_array');
%     save('distance1_array171j1.mat','distance1_array');
%     save('distance1_array171k1.mat','distance1_array');
%     save('distance1_array171l1.mat','distance1_array');
%     save('distance1_array171m1.mat','distance1_array');
%     save('distance1_array171n1.mat','distance1_array');
%     save('distance1_array171o1.mat','distance1_array');
%     save('distance1_array171p1.mat','distance1_array');
%     save('distance1_array171q1.mat','distance1_array');
%     save('distance1_array171r1.mat','distance1_array');
%     save('distance1_array171s1.mat','distance1_array');
%     save('distance1_array171t1.mat','distance1_array');
% %
%     save('distance1_array171a2.mat','distance1_array');
%     save('distance1_array171b2.mat','distance1_array');
%     save('distance1_array171c2.mat','distance1_array');
%     save('distance1_array171d2.mat','distance1_array');
%     save('distance1_array171e2.mat','distance1_array');
%     save('distance1_array171f2.mat','distance1_array');
%     save('distance1_array171g2.mat','distance1_array');
%     save('distance1_array171h2.mat','distance1_array');
%     save('distance1_array171i2.mat','distance1_array');
%     save('distance1_array171j2.mat','distance1_array');
%     save('distance1_array171k2.mat','distance1_array');
%     save('distance1_array171l2.mat','distance1_array');
%     save('distance1_array171m2.mat','distance1_array');
%     save('distance1_array171n2.mat','distance1_array');
%     save('distance1_array171o2.mat','distance1_array');
%     save('distance1_array171p2.mat','distance1_array');
%     save('distance1_array171q2.mat','distance1_array');
%     save('distance1_array171r2.mat','distance1_array');
%     save('distance1_array171s2.mat','distance1_array');
%     save('distance1_array171t2.mat','distance1_array');
    end
end
%%
%%
function [nextMove2] = shortestPath2(square1,square2,entity)
    possibleMoves = allDirections{square1(1),square1(2)};
    position2 = square1;
    enemies(2).possibleMoves = possibleMoves;
    %         Test_pacman = square2
    x1 = abs(square1(1)-square2(1));
    y1 = abs(square1(2)-square2(2));
    enemies(2).x1 = x1;
    enemies(2).y1 = y1;
    %         distance = x1 + y1
    distance2 = x1 + y1 ;
    enemies(2).distance2 = distance2;
    x1a = (square1(1)-square2(1));
    y1a = (square1(2)-square2(2));
    enemies(2).x1a = x1a;
    enemies(2).y1a = y1a;
    %         if (x1a < 0)
    %             x1_negative = x1a
    %         end
    if x1 >= y1;
        if x1a >= 0
            nextMove2a = 3;
        else
            nextMove2a = 1;
        end
    else
        if y1a >= 0;
            nextMove2a = 2;
        else
            nextMove2a = 4;
        end
    end
    nextMove2a_d10 = nextMove2a;
    %% Sigmoid function -> Simulated Annealing, from High Temp(Random walk) to Low Temperature(Hill Climbing)
    t = linspace(1,10^3,50);  % t inversely proportional to Temperature,
%     Therefore, Temperature Very Low-> Very High
    if distance2 == 0 ;
        Temperature22 = 1000;
    else
        Temperature22 = 10^3*(0.9500+0.0050)^t(distance2); % Temperature,Low->High % Arbitrary Max distance 50
        Temperature22';
    end
%     Temperature22 = 1 ;
    % Changing sigmoid function 
    sigmoid_fun_current2 = (1 + exp(-06*((1*distance2-0))/Temperature22))^(-1);
%     count1 = 0 ;
%     random_Gen = (randi([1, 100],1))/100;  % 0.5*max(sigmoid_function) = 0.250 ; % 50 % chance of selection 
%     if (sigmoid_function <= random_Gen); % if (Temperature <= 130);
%         count1 = count1 + 1 ;
%     end
%     Ghost_Distance = distance2;
%     Ghost_Temperature = Temperature;
%     Pr_1st_Ghost = sigmoid_function;
%     count1;
%% end Sigmoid function Max Distance = 40, Min Distance = 12;
% if (count1 == 1)
    %     flag10001 = 1
    corner = numel(possibleMoves);
    %% Node Selection Start : Completely avoids tunnel's nextMove2a
    tunnel = intersect(enemies(2).dir,enemies(2).possibleMoves);
    tunnel_out = isempty(tunnel);
    if (corner==2) & (tunnel_out==0)  ;
        nextMove2a = enemies(2).dir;  %      disp('tunnel')
        %% Node Selection End
    else %any(corner > 1) ;%~any(possibleMoves==enemies(2).dir) && numel(enemies(2).possibleMoves)==numel(enemies(2).possibleMoves);
        %       nextMove2a = nextMove2a;
        %         msize = numel(possibleMoves) ;
        %         idx = randperm(msize) ;
        %         nextMove2a = possibleMoves(idx(1:1)) ;
        % ** write code  1->Right 3->Left 2->Down 4->Up
        total_possibleMoves = numel(enemies(2).possibleMoves) ;
        switch total_possibleMoves
            %             case 1
            %                 ~any(possibleMoves==nextMove2a) ;
            %                 nextMove2a = possibleMoves ;  %Since numel(possibleMoves) is 1
            case 2   % Movement based on abs distance and non abs distance
                %                 disp('tunnel')
                %                 if (x1 >= y1) && (x1a>=0) ;
                %                     tentative_nextMove2a = [3] ;
                nextMove2a = intersect(nextMove2a,enemies(2).possibleMoves);
                %                 elseif (x1 >= y1) && (x1a<=0) ;
                %                     tentative_nextMove2a = [1];
                %                     nextMove2a = intersect(tentative_nextMove2a,possibleMoves);
                %                 elseif (y1 >= x1) && (y1a>=0) ;
                %                     tentative_nextMove2a = [2];
                %                     nextMove2a = intersect(tentative_nextMove2a,possibleMoves);
                %                 else (y1 >= x1) && (y1a<=0) ;
                %                     tentative_nextMove2a = [4];
                %                     nextMove2a = intersect(tentative_nextMove2a,possibleMoves);
                %                 end
                %            Number_nextMove2a = numel(nextMove2a) ;
                %            if (Number_nextMove2a > 1)
                %                if (nextMove2a == [1 3])
                %                    if (x1a >= 0)
                %                        nextMove2a = 3 ;
                %                    else
                %                        nextMove2a = 1 ;
                %                    end
                %                else (nextMove2a == [2 4])
                %                    if (y1a >= 0)
                %                        nextMove2a = 2 ;
                %                    else
                %                        nextMove2a = 4 ;
                %                    end
                %                end
                %            end
                if isempty(nextMove2a)  % possibleMoves does not match tentative nextMove2a
                    if (x1 >= y1) && (x1a>=0) ;
                        tentative_nextMove2a = [2] ;
                        nextMove2a = intersect(tentative_nextMove2a,enemies(2).possibleMoves);
                    elseif (x1 >= y1) && (x1a<=0) ;
                        tentative_nextMove2a = [4];
                        nextMove2a = intersect(tentative_nextMove2a,enemies(2).possibleMoves);
                    elseif (y1 >= x1) && (y1a>=0) ;
                        tentative_nextMove2a = [1];
                        nextMove2a = intersect(tentative_nextMove2a,enemies(2).possibleMoves);
                    else (y1 >= x1) && (y1a<=0) ;
                        tentative_nextMove2a = [3];
                        nextMove2a = intersect(tentative_nextMove2a,enemies(2).possibleMoves);
                    end
                end
                if isempty(nextMove2a)
                    if (x1 >= y1) && (x1a>=0) ;
                        tentative_nextMove2a = [4] ;
                        nextMove2a = intersect(tentative_nextMove2a,enemies(2).possibleMoves);
                    elseif (x1 >= y1) && (x1a<=0) ;
                        tentative_nextMove2a = [2];
                        nextMove2a = intersect(tentative_nextMove2a,enemies(2).possibleMoves);
                    elseif (y1 >= x1) && (y1a>=0) ;
                        tentative_nextMove2a = [3];
                        nextMove2a = intersect(tentative_nextMove2a,enemies(2).possibleMoves);
                    else (y1 >= x1) && (y1a<=0) ;
                        tentative_nextMove2a = [1];
                        nextMove2a = intersect(tentative_nextMove2a,enemies(2).possibleMoves);
                    end
                end
            case 3
                %                 disp('T-junction')
                if x1 > y1 ;
                    if (x1a >= 0);
                        nextMove2a = 3;
                    else
                        nextMove2a = 1;
                    end
                    nextMove2a = intersect(enemies(2).possibleMoves,nextMove2a);
                    if isempty(nextMove2a)
                        if (y1a >= 0) ;
                            nextMove2a = 2;
                        else
                            nextMove2a = 4;
                        end
                    end
                else y1 > x1 ;
                    if (y1a >= 0);
                        nextMove2a = 2;
                    else
                        nextMove2a = 4;
                    end
                    nextMove2a = intersect(enemies(2).possibleMoves,nextMove2a);
                    if isempty(nextMove2a)
                        if (x1a >= 0) ;
                            nextMove2a = 3;
                        else
                            nextMove2a = 1;
                        end
                    end
                end
                Number_nextMove2a = numel(nextMove2a) ;
                if Number_nextMove2a > 1
                    if (nextMove2a == [1 3])
                        if (x1a >= 0)
                            nextMove2a = 3 ;
                        else
                            nextMove2a = 1 ;
                        end
                    else (nextMove2a == [2 4])
                        if (y1a >= 0)
                            nextMove2a = 2 ;
                        else
                            nextMove2a = 4 ;
                        end
                    end
                end
                %     if (nextMove2a==3) || (nextMove2a==1) ;
                %         tentative_nextMove2a = [1 3] ;
                %       if (any(possibleMoves==1));
                %         possibleMoves(possibleMoves == 1) = [];
                %       else (any(possibleMoves==3));
                %         possibleMoves(possibleMoves == 3) = [];
                %       end
                %         nextMove2a = possibleMoves(randperm((length(possibleMoves)),1)) ;
                %     else (nextMove2a==2) || (nextMove2a==4) ;
                %         tentative_nextMove2a = [2 4] ;
                %       if (any(possibleMoves==2));
                %         possibleMoves(possibleMoves == 2) = [];
                %       else (any(possibleMoves==4));
                %         possibleMoves(possibleMoves == 4) = [];
                %       end
                %         nextMove2a = possibleMoves(randperm((length(possibleMoves)),1)) ;
                %     end
                %                 Test_case_3 = nextMove2a ;
            case 4
                if x1 >= y1
                    if x1a >= 0
                        nextMove2a = 3;
                    else
                        nextMove2a = 1;
                    end
                else
                    if y1a >= 0
                        nextMove2a = 2;
                    else
                        nextMove2a = 4;
                    end
                end
        end
    end
    nextMove_b1 = nextMove2a;
    Heat = 'Low Temperature';
    X = ['Red Ghost = ',Heat,', Manhattan distance = ',num2str(distance2)];
%     disp(X)
% elseif (count1 == 0) ;% && (enemies(2).distance2 < 2);
%%
%     disp('Acceptance_Pr > 0.46')
    corner = numel(enemies(2).possibleMoves);   
    %% Node Selection Start : Completely avoids tunnel's nextMove2a
%     if any(corner==2) ;%&& numel(enemies(2).possibleMoves)==numel(enemies(2).possibleMoves);
%         nextMove2a = enemies(2).oldDir;
%         disp('tunnel')
    %% Node Selection End
%     else %any(corner > 1) ;%~any(possibleMoves==enemies(2).dir) && numel(enemies(2).possibleMoves)==numel(enemies(2).possibleMoves);
        %       nextMove2a = nextMove2a;
        %         msize = numel(possibleMoves) ;
        %         idx = randperm(msize) ;
        %         nextMove2a = possibleMoves(idx(1:1)) ;
        % ** write code  1->Right 3->Left 2->Down 4->Up
        nextMove2a = nextMove2a_d10 ;
        total_possibleMoves = numel(enemies(2).possibleMoves) ;
        switch total_possibleMoves
%             case 1
%                 ~any(possibleMoves==nextMove2a) ;
%                 nextMove2a = possibleMoves ;  %Since numel(possibleMoves) is 1 
            case 2   % Movement based on abs distance and non abs distance
                %                 disp('tunnel')
%                                 if (x1 >= y1) && (x1a>=0) ;
%                                     tentative_nextMove2a = [3] ;
                nextMove2a = intersect(nextMove2a,enemies(2).possibleMoves);
%                                 elseif (x1 >= y1) && (x1a<=0) ;
%                                     tentative_nextMove2a = [1];
%                                     nextMove2a = intersect(tentative_nextMove2a,possibleMoves);
%                                 elseif (y1 >= x1) && (y1a>=0) ;
%                                     tentative_nextMove2a = [2];
%                                     nextMove2a = intersect(tentative_nextMove2a,possibleMoves);
%                                 else (y1 >= x1) && (y1a<=0) ;
%                                     tentative_nextMove2a = [4];
%                                     nextMove2a = intersect(tentative_nextMove2a,possibleMoves);
%                                 end
%                            Number_nextMove2a = numel(nextMove2a) ;
%                            if (Number_nextMove2a > 1)
%                                if (nextMove2a == [1 3])
%                                    if (x1a >= 0)
%                                        nextMove2a = 3 ;
%                                    else
%                                        nextMove2a = 1 ;
%                                    end
%                                else (nextMove2a == [2 4])
%                                    if (y1a >= 0)
%                                        nextMove2a = 2 ;
%                                    else
%                                        nextMove2a = 4 ;
%                                    end
%                                end
%                            end
                if isempty(nextMove2a)  % possibleMoves does not match tentative nextMove2a
                    if (x1 >= y1) && (x1a>=0) ;
                        tentative_nextMove2a = [2] ;
                        nextMove2a = intersect(tentative_nextMove2a,enemies(2).possibleMoves);
                    elseif (x1 >= y1) && (x1a<=0) ;
                        tentative_nextMove2a = [4];
                        nextMove2a = intersect(tentative_nextMove2a,enemies(2).possibleMoves);
                    elseif (y1 >= x1) && (y1a>=0) ;
                        tentative_nextMove2a = [1];
                        nextMove2a = intersect(tentative_nextMove2a,enemies(2).possibleMoves);
                    else (y1 >= x1) && (y1a<=0) ;
                        tentative_nextMove2a = [3];
                        nextMove2a = intersect(tentative_nextMove2a,enemies(2).possibleMoves);
                    end
                end
                if isempty(nextMove2a)
                    if (x1 >= y1) && (x1a>=0) ;
                        tentative_nextMove2a = [4] ;
                        nextMove2a = intersect(tentative_nextMove2a,enemies(2).possibleMoves);
                    elseif (x1 >= y1) && (x1a<=0) ;
                        tentative_nextMove2a = [2];
                        nextMove2a = intersect(tentative_nextMove2a,enemies(2).possibleMoves);
                    elseif (y1 >= x1) && (y1a>=0) ;
                        tentative_nextMove2a = [3];
                        nextMove2a = intersect(tentative_nextMove2a,enemies(2).possibleMoves);
                    else (y1 >= x1) && (y1a<=0) ;
                        tentative_nextMove2a = [1];
                        nextMove2a = intersect(tentative_nextMove2a,enemies(2).possibleMoves);
                    end
                end
            case 3
                %                 disp('T-junction')
                if x1 > y1 ;
                    if (x1a >= 0);
                        nextMove2a = 3;
                    else
                        nextMove2a = 1;
                    end
                    nextMove2a = intersect(enemies(2).possibleMoves,nextMove2a);
                    if isempty(nextMove2a)
                        if (y1a >= 0) ;
                            nextMove2a = 2;
                        else
                            nextMove2a = 4;
                        end
                    end
                else y1 > x1 ;
                    if (y1a >= 0);
                        nextMove2a = 2;
                    else
                        nextMove2a = 4;
                    end
                    nextMove2a = intersect(enemies(2).possibleMoves,nextMove2a);
                    if isempty(nextMove2a)
                        if (x1a >= 0) ;
                            nextMove2a = 3;
                        else
                            nextMove2a = 1;
                        end
                    end
                end
                Number_nextMove2a = numel(nextMove2a) ;
                if Number_nextMove2a > 1
                    if (nextMove2a == [1 3])
                        if (x1a >= 0)
                            nextMove2a = 3 ;
                        else
                            nextMove2a = 1 ;
                        end
                    else (nextMove2a == [2 4])
                        if (y1a >= 0)
                            nextMove2a = 2 ;
                        else
                            nextMove2a = 4 ;
                        end
                    end
                end
                %     if (nextMove2a==3) || (nextMove2a==1) ;
                %         tentative_nextMove2a = [1 3] ;
                %       if (any(possibleMoves==1));
                %         possibleMoves(possibleMoves == 1) = [];
                %       else (any(possibleMoves==3));
                %         possibleMoves(possibleMoves == 3) = [];
                %       end
                %         nextMove2a = possibleMoves(randperm((length(possibleMoves)),1)) ;
                %     else (nextMove2a==2) || (nextMove2a==4) ;
                %         tentative_nextMove2a = [2 4] ;
                %       if (any(possibleMoves==2));
                %         possibleMoves(possibleMoves == 2) = [];
                %       else (any(possibleMoves==4));
                %         possibleMoves(possibleMoves == 4) = [];
                %       end
                %         nextMove2a = possibleMoves(randperm((length(possibleMoves)),1)) ;
                %     end
                %                 Test_case_3 = nextMove2a ;
            case 4
                if x1 >= y1
                    if x1a >= 0
                        nextMove2a = 3;
                    else
                        nextMove2a = 1;
                    end
                else
                    if y1a >= 0
                        nextMove2a = 2;
                    else
                        nextMove2a = 4;
                    end
                end
%         end
    end
%%
%     Pincer_Moves = [0 nextMove2a];
%     idx = randi(length(Pincer_Moves)); % random index into x
%     nextMove2a2 = Pincer_Moves(idx);  
nextMove_b2 = nextMove2a;
Heat = 'High Temperature';   
X = ['Red Ghost = ',Heat,', Manhattan distance = ',num2str(distance2)];
% disp(X)
% end
%%
        corner = numel(enemies(2).possibleMoves);
%% Node Selection Start : Completely avoids tunnel's nextMove2a
    tunnel = intersect(enemies(2).dir,enemies(2).possibleMoves);
    tunnel_out = isempty(tunnel);
    if (corner==2) & (tunnel_out==0)  ;
        nextMove2a = enemies(2).dir;  %      disp('tunnel')
        %% Node Selection End
    else %any(corner > 1) ;%~any(possibleMoves==enemies(2).dir) && numel(enemies(2).possibleMoves)==numel(enemies(2).possibleMoves);
%         nextMove2a = nextMove2a_d10 ;

nextMove2a = enemies(2).possibleMoves ;
    if enemies(2).oldDir == 3;
    opposite_dir = [1];
    elseif enemies(2).oldDir == 1;
    opposite_dir = [3];
    elseif enemies(2).oldDir == 4;
    opposite_dir = [2];
    elseif enemies(2).oldDir == 2;
    opposite_dir = [4];
    end
nextMove2a = setxor(opposite_dir,nextMove2a);
nextMove2a = intersect(nextMove2a,enemies(2).possibleMoves);
    if (isempty(nextMove2a)==1);
%         idx = randi(length(enemies(2).possibleMoves)) ;
        nextMove2a = enemies(2).dir;
%     elseif (isempty(new_nodes)~=1);
%         new_nodes = intersect(new_nodes,possibleMoves);
    end
    if (isempty(nextMove2a)==1);
        idx = randi(length(enemies(2).possibleMoves)) ;
        nextMove2a = enemies(2).possibleMoves(idx(:));
%     elseif (isempty(new_nodes)~=1);
%         new_nodes = intersect(new_nodes,possibleMoves);
    end
idx = randi(length(nextMove2a)) ;
nextMove2a = nextMove2a(idx(:));
        total_possibleMoves = numel(enemies(2).possibleMoves) ;
        switch total_possibleMoves;
%             case 1
%                 ~any(possibleMoves==nextMove2a) ;
%                 nextMove2a = possibleMoves ;  %Since numel(possibleMoves) is 1 
            case 2   % Movement based on abs distance and non abs distance
                %                 disp('tunnel')
%                                 if (x1 >= y1) && (x1a>=0) ;
%                                     tentative_nextMove2a = [3] ;
%                 nextMove2a = intersect(nextMove2a,possibleMoves);

%                 idx = randi(length(possibleMoves)); 
%                 nextMove2a = enemies(2).possibleMoves(idx(:));
            nextMove2a = enemies(2).possibleMoves ;
            if enemies(2).oldDir == 3;
                opposite_dir = [1];
            elseif enemies(2).oldDir == 1;
                opposite_dir = [3];
            elseif enemies(2).oldDir == 4;
                opposite_dir = [2];
            elseif enemies(2).oldDir == 2;
                opposite_dir = [4];
            end
            nextMove2a = setxor(opposite_dir,nextMove2a);
            nextMove2a = intersect(nextMove2a,enemies(2).possibleMoves);
            idx = randi(length(nextMove2a));
            nextMove2a = nextMove2a(idx(:));
            if (isempty(nextMove2a)==1);
                idx = randi(length(enemies(2).possibleMoves)) ;
                nextMove2a = enemies(2).possibleMoves(idx(:));
                %     elseif (isempty(new_nodes)~=1);
                %         new_nodes = intersect(new_nodes,possibleMoves);
            end
%                                 elseif (x1 >= y1) && (x1a<=0) ;
%                                     tentative_nextMove2a = [1];
%                                     nextMove2a = intersect(tentative_nextMove2a,possibleMoves);
%                                 elseif (y1 >= x1) && (y1a>=0) ;
%                                     tentative_nextMove2a = [2];
%                                     nextMove2a = intersect(tentative_nextMove2a,possibleMoves);
%                                 else (y1 >= x1) && (y1a<=0) ;
%                                     tentative_nextMove2a = [4];
%                                     nextMove2a = intersect(tentative_nextMove2a,possibleMoves);
%                                 end
%                            Number_nextMove2a = numel(nextMove2a) ;
%                            if (Number_nextMove2a > 1)
%                                if (nextMove2a == [1 3])
%                                    if (x1a >= 0)
%                                        nextMove2a = 3 ;
%                                    else
%                                        nextMove2a = 1 ;
%                                    end
%                                else (nextMove2a == [2 4])
%                                    if (y1a >= 0)
%                                        nextMove2a = 2 ;
%                                    else
%                                        nextMove2a = 4 ;
%                                    end
%                                end
%                            end
%                 if isempty(nextMove2a);  % possibleMoves does not match tentative nextMove2a
%                     if (x1 >= y1) && (x1a>=0) ;
%                         tentative_nextMove2a = [2] ;
%                         nextMove2a = intersect(tentative_nextMove2a,possibleMoves);
%                     elseif (x1 >= y1) && (x1a<=0) ;
%                         tentative_nextMove2a = [4];
%                         nextMove2a = intersect(tentative_nextMove2a,enemies(2).possibleMoves);
%                     elseif (y1 >= x1) && (y1a>=0) ;
%                         tentative_nextMove2a = [1];
%                         nextMove2a = intersect(tentative_nextMove2a,enemies(2).possibleMoves);
%                     else (y1 >= x1) && (y1a<=0) ;
%                         tentative_nextMove2a = [3];
%                         nextMove2a = intersect(tentative_nextMove2a,enemies(2).possibleMoves);
%                     end
%                 end
%                 if isempty(nextMove2a);
%                     if (x1 >= y1) && (x1a>=0) ;
%                         tentative_nextMove2a = [4] ;
%                         nextMove2a = intersect(tentative_nextMove2a,enemies(2).possibleMoves);
%                     elseif (x1 >= y1) && (x1a<=0) ;
%                         tentative_nextMove2a = [2];
%                         nextMove2a = intersect(tentative_nextMove2a,enemies(2).possibleMoves);
%                     elseif (y1 >= x1) && (y1a>=0) ;
%                         tentative_nextMove2a = [3];
%                         nextMove2a = intersect(tentative_nextMove2a,enemies(2).possibleMoves);
%                     else (y1 >= x1) && (y1a<=0) ;
%                         tentative_nextMove2a = [1];
%                         nextMove2a = intersect(tentative_nextMove2a,enemies(2).possibleMoves);
%                     end
%                 end
%                 flag100 = nextMove2a ;
            case 3
%                 %                 disp('T-junction')
%                 if x1 > y1 ;
%                     if (x1a >= 0);
%                         nextMove2a = 3;
%                     else
%                         nextMove2a = 1;
%                     end
% %                     nextMove2a = intersect(possibleMoves,nextMove2a);
%                         idx = randi(length(possibleMoves)) ;
%                         nextMove2a = possibleMoves(idx(:));
%                     if isempty(nextMove2a);
%                         if (y1a >= 0) ;
%                             nextMove2a = 2;
%                         else
%                             nextMove2a = 4;
%                         end
%                     end
%                 else y1 > x1 ;
%                     if (y1a >= 0);
%                         nextMove2a = 2;
%                     else
%                         nextMove2a = 4;
%                     end
%                     %                     nextMove2a = intersect(possibleMoves,nextMove2a);
%                     idx = randi(length(possibleMoves)) ;
%                     nextMove2a = possibleMoves(idx(:));
%                     if isempty(nextMove2a);
%                         if (x1a >= 0) ;
%                             nextMove2a = 3;
%                         else
%                             nextMove2a = 1;
%                         end
%                     end
%                 end
%                 Number_nextMove2a = numel(nextMove2a) ;
%                 if Number_nextMove2a > 1;
%                     if (nextMove2a == [1 3]);
%                         if (x1a >= 0);
%                             nextMove2a = 3 ;
%                         else
%                             nextMove2a = 1 ;
%                         end
%                     else (nextMove2a == [2 4]);
%                         if (y1a >= 0);
%                             nextMove2a = 2 ;
%                         else
%                             nextMove2a = 4 ;
%                         end
%                     end
%                 end
            nextMove2a = enemies(2).possibleMoves ;
            if enemies(2).oldDir == 3;
                opposite_dir = [1 3];
            elseif enemies(2).oldDir == 1;
                opposite_dir = [1 3];
            elseif enemies(2).oldDir == 4;
                opposite_dir = [2 4];
            elseif enemies(2).oldDir == 2;
                opposite_dir = [2 4];
            end
            nextMove2a = setxor(opposite_dir,nextMove2a);
            nextMove2a = intersect(nextMove2a,enemies(2).possibleMoves);
            idx = randi(length(nextMove2a));
            nextMove2a = nextMove2a(idx(:));
%             if (isempty(nextMove2a)==1);
%                 idx = randi(length(enemies(2).possibleMoves)) ;
%                 nextMove2a = enemies(2).possibleMoves(idx(:));
%                 %     elseif (isempty(new_nodes)~=1);
%                 %         new_nodes = intersect(new_nodes,possibleMoves);
%             end
                
                %     if (nextMove2a==3) || (nextMove2a==1) ;
                %         tentative_nextMove2a = [1 3] ;
                %       if (any(possibleMoves==1));
                %         possibleMoves(possibleMoves == 1) = [];
                %       else (any(possibleMoves==3));
                %         possibleMoves(possibleMoves == 3) = [];
                %       end
                %         nextMove2a = possibleMoves(randperm((length(possibleMoves)),1)) ;
                %     else (nextMove2a==2) || (nextMove2a==4) ;
                %         tentative_nextMove2a = [2 4] ;
                %       if (any(possibleMoves==2));
                %         possibleMoves(possibleMoves == 2) = [];
                %       else (any(possibleMoves==4));
                %         possibleMoves(possibleMoves == 4) = [];
                %       end
                %         nextMove2a = possibleMoves(randperm((length(possibleMoves)),1)) ;
                %     end
                %                 Test_case_3 = nextMove2a ;
            case 4
%                 if x1 >= y1;
%                     if x1a >= 0;
%                         nextMove2a = 3;
%                     else
%                         nextMove2a = 1;
%                     end
%                 else
%                     if y1a >= 0;
%                         nextMove2a = 2;
%                     else
%                         nextMove2a = 4;
%                     end
%                 end
            nextMove2a = enemies(2).possibleMoves ;
            if enemies(2).oldDir == 3;
                opposite_dir = [1];
            elseif enemies(2).oldDir == 1;
                opposite_dir = [3];
            elseif enemies(2).oldDir == 4;
                opposite_dir = [2];
            elseif enemies(2).oldDir == 2;
                opposite_dir = [4];
            end
            nextMove2a = setxor(opposite_dir,nextMove2a);
            nextMove2a = intersect(nextMove2a,enemies(2).possibleMoves);
            idx = randi(length(nextMove2a));
            nextMove2a = nextMove2a(idx(:));
  
        end
    end
%%
    Pincer_Moves = [0 nextMove2a];
    idx = randi(length(Pincer_Moves)); % random index into x
%     nextMove2a2 = Pincer_Moves(idx);
    nextMove_b3 = nextMove2a;
Heat = 'High Temperature';   
X = ['Red Ghost = ',Heat,', Manhattan distance = ',num2str(distance2)];
% disp(X)
% end
%%  
% new_nodes = [nextMove_b3 nextMove_b1 nextMove_b2] ;
% new_nodes = [nextMove_b1 nextMove_b2] ;
new_nodes = [nextMove_b3];

coordinates1 = square1;
for i = 1:numel(new_nodes)
if (new_nodes(i)==1) ;
    coordinates1(1) = coordinates1(1) + 1;
elseif (new_nodes(i)== 3) ;
    coordinates1(1) = coordinates1(1) - 1;
elseif (new_nodes(i)== 4);
    coordinates1(2) = coordinates1(2) + 1;
elseif (new_nodes(i)== 2);
    coordinates1(2) = coordinates1(2) - 1;
else (new_nodes(i)== 0);
    coordinates1(1) = coordinates1(1) ;
end
% if (i == 1) ;
Energy_val_b1 = abs(coordinates1(1)-square2(1)) + abs(coordinates1(2)-square2(2));
% elseif (i == 2) ; 
% Energy_val_b2 = abs(coordinates1(1)-square2(1)) + abs(coordinates1(2)-square2(2));
% % elseif (i == 3) ; 
% % Energy_val_b2 = abs(coordinates1(1)-square2(1)) + abs(coordinates1(2)-square2(2));
% end
coordinates1 = square1;   %% ADD THIS LINE
end
% del_E23 = distance2 - Energy_val_b3 - 0;
% del_E22 = distance2 - Energy_val_b2 + 0;
del_E21 = distance2 - Energy_val_b1 + 0;

Energy_val_b = [del_E21];
% Energy_val_b = [del_E21 del_E22];
% Energy_val_b 
%This algorithm always rejects bad nodes
% random_Gen2 = (randi([1, 100],1))/100 ;
random_Gen21 = (randi([1, 100],1))/100 ;
test_sigmoid_fun_current2 = sigmoid_fun_current2;
%if random_Gen2 = 0; sigmoid_func = 0.5; rejects bad nodes
%if random_Gen2 = 1; sigmoid_func = 0.5; accepts bad nodes
for i = 1:numel(new_nodes) ;
if (Energy_val_b(i) > 0) ;
%     nextMove2 = new_nodes(i);
     % End loop
    if (sigmoid_fun_current2 > random_Gen21); % if (Temperature <= 130);
        nextMove2 = new_nodes(i);
        flag_accept = 'accept';
    else (sigmoid_fun_current2 <= random_Gen21);
        nextMove2 = 0;
        flag_accept = 'reject';
%         idx = find(Energy_val_a == min(Energy_val_a(:)))
%         nextMove1 = node(idx)
    end
else (Energy_val_b(i) <= 0) ;
  %  flag_b = 1 ;
    % Pr of Rejection
    if ((sigmoid_fun_current2) < random_Gen21) 
        nextMove2 = 0 ;%nextMove_c; % Reject Generated neighbor and remain stationary
        %         Node_rejection_1 = Node_rejection_1 + 1 ;
        flag_accept = 'reject';
    else ((sigmoid_fun_current2) >= random_Gen21) ;
        %         nextMove1 = nextMove_a1;
        %         idx = randi(length(Energy_val_a)) ;
        %         nextMove1 = node(idx(:));
        nextMove2 = new_nodes(i) ; 
        flag_accept = 'reject';
         % End loop
    end
end
    if (nextMove2 ~= 0)
        break
    end
end
        node_i = i;
        node2 = node_i;
X2 = ['Purple Ghost: ','Pr. of Acceptance = ',num2str(sigmoid_fun_current2),' Temperature = ',num2str(Temperature22), ', node = ',num2str(flag_accept)];% ', distance = ',num2str(distance1)];
% disp(X2)
% nextMove2 = nextMove_b1;
%%
    if distance2 == 0 ;
        pack_threshold2 = T1;
    else
        pack_threshold2 = [T1*(rate1)^+t(distance2)]+separation; % Temperature,Low->High % Arbitrary Max distance 50
    end
pack21 = ((position2(1) - position1(1))^2 + (position2(2) - position1(2))^2)^0.5 ; 
pack23 = ((position2(1) - position3(1))^2 + (position2(2) - position3(2))^2)^0.5 ; 
pack24 = ((position2(1) - position4(1))^2 + (position2(2) - position4(2))^2)^0.5 ;
% pack_wolf = pack21 + pack23 + pack24 ;
pack_vec2 = [pack21 pack23 pack24] ;  
    idx = find(pack_vec2==min(pack_vec2));
    if (idx==1);
    square3 = position1;
    elseif (idx==2);
    square3 = position3;
    else (idx==3);
    square3 = position4;
    end
% square2 = pack_index1;
x12 = (abs(square1(1)-square3(1)))/1;
y12 = (abs(square1(2)-square3(2)))/1;
% enemies(1).x1 = x1;
% enemies(1).y1 = y1;
%         distance = x1 + y1
distance22 = x12 + y12; 
if ((pack_threshold2) >= distance22)
flag_repel = 2 ;
x1 = x12;
y1 = y12;
% enemies(2).x1 = x1;
% enemies(2).y1 = y1;
%         distance = x1 + y1
distance22 = x1 + y1; 
% enemies(2).distance2 = distance2;
x1a = ((square1(1)-square3(1)))/4;
y1a = ((square1(2)-square3(2)))/4;
% enemies(2).x1a = x1a;
% enemies(2).y1a = y1a;

%         if (x1a < 0)
%             x1_negative = x1a
%         end
if x1 >= y1;
    if x1a >= 0
        nextMove = 1;
    else
        nextMove = 3;
    end
else
    if y1a >= 0;
        nextMove = 4;
    else
        nextMove = 2;
    end
end
    corner = numel(possibleMoves);
    %% Node Selection Start : Completely avoids tunnel's nextMove
    tunnel = intersect(enemies(2).dir,enemies(2).possibleMoves);
    tunnel_out = isempty(tunnel);
%     if (corner==2) & (tunnel_out==0)  ;
%         nextMove = enemies(2).dir;  %      disp('tunnel')
%         % Node Selection End
%     else %any(corner > 1) ;%~any(possibleMoves==enemies(2).dir) && numel(enemies(2).possibleMoves)==numel(enemies(2).possibleMoves);
        total_possibleMoves = numel(enemies(2).possibleMoves) ;
        switch total_possibleMoves
            case 2   % Movement based on abs distance and non abs distance
                nextMove = intersect(nextMove,enemies(2).possibleMoves);
                if isempty(nextMove)  % possibleMoves does not match tentative nextMove
                    if (x1 >= y1) && (x1a>=0) ;
                        tentative_nextMove = [4] ;
                        nextMove = intersect(tentative_nextMove,enemies(2).possibleMoves);
                    elseif (x1 >= y1) && (x1a<=0) ;
                        tentative_nextMove = [2];
                        nextMove = intersect(tentative_nextMove,enemies(2).possibleMoves);
                    elseif (y1 >= x1) && (y1a>=0) ;
                        tentative_nextMove = [3];
                        nextMove = intersect(tentative_nextMove,enemies(2).possibleMoves);
                    else (y1 >= x1) && (y1a<=0) ;
                        tentative_nextMove = [1];
                        nextMove = intersect(tentative_nextMove,enemies(2).possibleMoves);
                    end
                end
                if isempty(nextMove)
                    if (x1 >= y1) && (x1a>=0) ;
                        tentative_nextMove = [2] ;
                        nextMove = intersect(tentative_nextMove,enemies(2).possibleMoves);
                    elseif (x1 >= y1) && (x1a<=0) ;
                        tentative_nextMove = [4];
                        nextMove = intersect(tentative_nextMove,enemies(2).possibleMoves);
                    elseif (y1 >= x1) && (y1a>=0) ;
                        tentative_nextMove = [1];
                        nextMove = intersect(tentative_nextMove,enemies(2).possibleMoves);
                    else (y1 >= x1) && (y1a<=0) ;
                        tentative_nextMove = [3];
                        nextMove = intersect(tentative_nextMove,enemies(2).possibleMoves);
                    end
                end
            case 3
                if x1 > y1 ;
                    if (x1a >= 0);
                        nextMove = 1;
                    else
                        nextMove = 3;
                    end
                    nextMove = intersect(enemies(2).possibleMoves,nextMove);
                    if isempty(nextMove)
                        if (y1a >= 0) ;
                            nextMove = 4;
                        else
                            nextMove = 2;
                        end
                    end
                else y1 > x1 ;
                    if (y1a >= 0);
                        nextMove = 4;
                    else
                        nextMove = 2;
                    end
                    nextMove = intersect(enemies(2).possibleMoves,nextMove);
                    if isempty(nextMove)
                        if (x1a >= 0) ;
                            nextMove = 1;
                        else
                            nextMove = 3;
                        end
                    end
                end
                Number_nextMove = numel(nextMove) ;
                if Number_nextMove > 1
                    if (nextMove == [1 3])
                        if (x1a >= 0)
                            nextMove = 1 ;
                        else
                            nextMove = 3 ;
                        end
                    else (nextMove == [2 4])
                        if (y1a >= 0)
                            nextMove = 4 ;
                        else
                            nextMove = 2 ;
                        end
                    end
                end
        end
%         end
nextMove2 = nextMove ; 
end
%test_nextMove1
end
%%
%%
function [nextMove3] = shortestPath3(square1,square2,entity)
    possibleMoves = allDirections{square1(1),square1(2)};
    enemies(3).possibleMoves = possibleMoves;
    %         Test_pacman = square2
    position3 = square1 ; 
    x1 = abs(square1(1)-square2(1));
    y1 = abs(square1(2)-square2(2));
    enemies(3).x1 = x1;
    enemies(3).y1 = y1;
    %         distance = x1 + y1
    distance3 = x1 + y1 ;
    enemies(3).distance3 = distance3;
    x1a = (square1(1)-square2(1));
    y1a = (square1(2)-square2(2));
    enemies(3).x1a = x1a;
    enemies(3).y1a = y1a;

    %         if (x1a < 0)
    %             x1_negative = x1a
    %         end
    if x1 >= y1;
        if x1a >= 0
            nextMove3a = 3;
        else
            nextMove3a = 1;
        end
    else
        if y1a >= 0;
            nextMove3a = 2;
        else
            nextMove3a = 4;
        end
    end
    nextMove3a_d10 = nextMove3a;
    %% Sigmoid function -> Simulated Annealing, from High Temp(Random walk) to Low Temperature(Hill Climbing)
    t = linspace(1,10^2,50);  % t inversely proportional to Temperature,
%     Therefore, Temperature Very Low-> Very High
    T_0 = 10^3;
    if distance3 == 0 ;
        Temperature32 = 1000 ;
    else
        Temperature32 = 10^3*(0.9500+0.0000)^t(distance3); % Temperature,Low->High % Arbitrary Max distance 50
        Temperature32';
    end
    distance3;
%     Temperature32 = 10000;
    sigmoid_fun_current3 = (1 + exp(-06*((distance3))/Temperature32))^(-1) - 0.4;
%     count1 = 0 ;
%     random_Gen = (randi([1, 100],1))/100;  % 0.5*max(sigmoid_function) = 0.250 ; % 50 % chance of selection 
%     if (sigmoid_function <= random_Gen); % if (Temperature <= 130);
%         count1 = count1 + 1 ;
%     end
%     Ghost_Distance = distance3;
%     Ghost_Temperature = Temperature;
%     Pr_1st_Ghost = sigmoid_function;
%     count1;
%% end Sigmoid function Max Distance = 40, Min Distance = 12;
% if (count1 == 1)
    %     flag10001 = 1
    corner = numel(possibleMoves);
    %% Node Selection Start : Completely avoids tunnel's nextMove3a
    tunnel = intersect(enemies(3).dir,enemies(3).possibleMoves);
    tunnel_out = isempty(tunnel);
    if (corner==2) & (tunnel_out==0)  ;
        nextMove3a = enemies(3).dir;  %      disp('tunnel')
        %% Node Selection End
    else %any(corner > 1) ;%~any(possibleMoves==enemies(3).dir) && numel(enemies(3).possibleMoves)==numel(enemies(3).possibleMoves);
        %       nextMove3a = nextMove3a;
        %         msize = numel(possibleMoves) ;
        %         idx = randperm(msize) ;
        %         nextMove3a = possibleMoves(idx(1:1)) ;
        % ** write code  1->Right 3->Left 2->Down 4->Up
        total_possibleMoves = numel(enemies(3).possibleMoves) ;
        switch total_possibleMoves
            %             case 1
            %                 ~any(possibleMoves==nextMove3a) ;
            %                 nextMove3a = possibleMoves ;  %Since numel(possibleMoves) is 1
            case 2   % Movement based on abs distance and non abs distance
                %                 disp('tunnel')
                %                 if (x1 >= y1) && (x1a>=0) ;
                %                     tentative_nextMove3a = [3] ;
                nextMove3a = intersect(nextMove3a,enemies(3).possibleMoves);
                %                 elseif (x1 >= y1) && (x1a<=0) ;
                %                     tentative_nextMove3a = [1];
                %                     nextMove3a = intersect(tentative_nextMove3a,possibleMoves);
                %                 elseif (y1 >= x1) && (y1a>=0) ;
                %                     tentative_nextMove3a = [2];
                %                     nextMove3a = intersect(tentative_nextMove3a,possibleMoves);
                %                 else (y1 >= x1) && (y1a<=0) ;
                %                     tentative_nextMove3a = [4];
                %                     nextMove3a = intersect(tentative_nextMove3a,possibleMoves);
                %                 end
                %            Number_nextMove3a = numel(nextMove3a) ;
                %            if (Number_nextMove3a > 1)
                %                if (nextMove3a == [1 3])
                %                    if (x1a >= 0)
                %                        nextMove3a = 3 ;
                %                    else
                %                        nextMove3a = 1 ;
                %                    end
                %                else (nextMove3a == [2 4])
                %                    if (y1a >= 0)
                %                        nextMove3a = 2 ;
                %                    else
                %                        nextMove3a = 4 ;
                %                    end
                %                end
                %            end
                if isempty(nextMove3a)  % possibleMoves does not match tentative nextMove3a
                    if (x1 >= y1) && (x1a>=0) ;
                        tentative_nextMove3a = [2] ;
                        nextMove3a = intersect(tentative_nextMove3a,enemies(3).possibleMoves);
                    elseif (x1 >= y1) && (x1a<=0) ;
                        tentative_nextMove3a = [4];
                        nextMove3a = intersect(tentative_nextMove3a,enemies(3).possibleMoves);
                    elseif (y1 >= x1) && (y1a>=0) ;
                        tentative_nextMove3a = [1];
                        nextMove3a = intersect(tentative_nextMove3a,enemies(3).possibleMoves);
                    else (y1 >= x1) && (y1a<=0) ;
                        tentative_nextMove3a = [3];
                        nextMove3a = intersect(tentative_nextMove3a,enemies(3).possibleMoves);
                    end
                end
                if isempty(nextMove3a)
                    if (x1 >= y1) && (x1a>=0) ;
                        tentative_nextMove3a = [4] ;
                        nextMove3a = intersect(tentative_nextMove3a,enemies(3).possibleMoves);
                    elseif (x1 >= y1) && (x1a<=0) ;
                        tentative_nextMove3a = [2];
                        nextMove3a = intersect(tentative_nextMove3a,enemies(3).possibleMoves);
                    elseif (y1 >= x1) && (y1a>=0) ;
                        tentative_nextMove3a = [3];
                        nextMove3a = intersect(tentative_nextMove3a,enemies(3).possibleMoves);
                    else (y1 >= x1) && (y1a<=0) ;
                        tentative_nextMove3a = [1];
                        nextMove3a = intersect(tentative_nextMove3a,enemies(3).possibleMoves);
                    end
                end
                flag100 = nextMove3a ;
            case 3
                %                 disp('T-junction')
                if x1 > y1 ;
                    if (x1a >= 0);
                        nextMove3a = 3;
                    else
                        nextMove3a = 1;
                    end
                    nextMove3a = intersect(enemies(3).possibleMoves,nextMove3a);
                    if isempty(nextMove3a)
                        if (y1a >= 0) ;
                            nextMove3a = 2;
                        else
                            nextMove3a = 4;
                        end
                    end
                else y1 > x1 ;
                    if (y1a >= 0);
                        nextMove3a = 2;
                    else
                        nextMove3a = 4;
                    end
                    nextMove3a = intersect(enemies(3).possibleMoves,nextMove3a);
                    if isempty(nextMove3a)
                        if (x1a >= 0) ;
                            nextMove3a = 3;
                        else
                            nextMove3a = 1;
                        end
                    end
                end
                Number_nextMove3a = numel(nextMove3a) ;
                if Number_nextMove3a > 1
                    if (nextMove3a == [1 3])
                        if (x1a >= 0)
                            nextMove3a = 3 ;
                        else
                            nextMove3a = 1 ;
                        end
                    else (nextMove3a == [2 4])
                        if (y1a >= 0)
                            nextMove3a = 2 ;
                        else
                            nextMove3a = 4 ;
                        end
                    end
                end
                %     if (nextMove3a==3) || (nextMove3a==1) ;
                %         tentative_nextMove3a = [1 3] ;
                %       if (any(possibleMoves==1));
                %         possibleMoves(possibleMoves == 1) = [];
                %       else (any(possibleMoves==3));
                %         possibleMoves(possibleMoves == 3) = [];
                %       end
                %         nextMove3a = possibleMoves(randperm((length(possibleMoves)),1)) ;
                %     else (nextMove3a==2) || (nextMove3a==4) ;
                %         tentative_nextMove3a = [2 4] ;
                %       if (any(possibleMoves==2));
                %         possibleMoves(possibleMoves == 2) = [];
                %       else (any(possibleMoves==4));
                %         possibleMoves(possibleMoves == 4) = [];
                %       end
                %         nextMove3a = possibleMoves(randperm((length(possibleMoves)),1)) ;
                %     end
                %                 Test_case_3 = nextMove3a ;
            case 4
                if x1 >= y1
                    if x1a >= 0
                        nextMove3a = 3;
                    else
                        nextMove3a = 1;
                    end
                else
                    if y1a >= 0
                        nextMove3a = 2;
                    else
                        nextMove3a = 4;
                    end
                end
        end
    end
    nextMove_c1 = nextMove3a;
    Heat = 'Low Temperature';
    X = ['Red Ghost = ',Heat,', Manhattan distance = ',num2str(distance3)];
%     disp(X)
% elseif (count1 == 0) ;% && (enemies(3).distance3 < 2);
%%
%     disp('Acceptance_Pr > 0.46')
    corner = numel(enemies(3).possibleMoves);   
    %% Node Selection Start : Completely avoids tunnel's nextMove3a
%     if any(corner==2) ;%&& numel(enemies(3).possibleMoves)==numel(enemies(3).possibleMoves);
%         nextMove3a = enemies(3).oldDir;
%         disp('tunnel')
    %% Node Selection End
%     else %any(corner > 1) ;%~any(possibleMoves==enemies(3).dir) && numel(enemies(3).possibleMoves)==numel(enemies(3).possibleMoves);
        %       nextMove3a = nextMove3a;
        %         msize = numel(possibleMoves) ;
        %         idx = randperm(msize) ;
        %         nextMove3a = possibleMoves(idx(1:1)) ;
        % ** write code  1->Right 3->Left 2->Down 4->Up
        nextMove3a = nextMove3a_d10 ;
        total_possibleMoves = numel(enemies(3).possibleMoves) ;
        switch total_possibleMoves
%             case 1
%                 ~any(possibleMoves==nextMove3a) ;
%                 nextMove3a = possibleMoves ;  %Since numel(possibleMoves) is 1 
            case 2   % Movement based on abs distance and non abs distance
                %                 disp('tunnel')
%                                 if (x1 >= y1) && (x1a>=0) ;
%                                     tentative_nextMove3a = [3] ;
                nextMove3a = intersect(nextMove3a,enemies(3).possibleMoves);
%                                 elseif (x1 >= y1) && (x1a<=0) ;
%                                     tentative_nextMove3a = [1];
%                                     nextMove3a = intersect(tentative_nextMove3a,possibleMoves);
%                                 elseif (y1 >= x1) && (y1a>=0) ;
%                                     tentative_nextMove3a = [2];
%                                     nextMove3a = intersect(tentative_nextMove3a,possibleMoves);
%                                 else (y1 >= x1) && (y1a<=0) ;
%                                     tentative_nextMove3a = [4];
%                                     nextMove3a = intersect(tentative_nextMove3a,possibleMoves);
%                                 end
%                            Number_nextMove3a = numel(nextMove3a) ;
%                            if (Number_nextMove3a > 1)
%                                if (nextMove3a == [1 3])
%                                    if (x1a >= 0)
%                                        nextMove3a = 3 ;
%                                    else
%                                        nextMove3a = 1 ;
%                                    end
%                                else (nextMove3a == [2 4])
%                                    if (y1a >= 0)
%                                        nextMove3a = 2 ;
%                                    else
%                                        nextMove3a = 4 ;
%                                    end
%                                end
%                            end
                if isempty(nextMove3a)  % possibleMoves does not match tentative nextMove3a
                    if (x1 >= y1) && (x1a>=0) ;
                        tentative_nextMove3a = [2] ;
                        nextMove3a = intersect(tentative_nextMove3a,enemies(3).possibleMoves);
                    elseif (x1 >= y1) && (x1a<=0) ;
                        tentative_nextMove3a = [4];
                        nextMove3a = intersect(tentative_nextMove3a,enemies(3).possibleMoves);
                    elseif (y1 >= x1) && (y1a>=0) ;
                        tentative_nextMove3a = [1];
                        nextMove3a = intersect(tentative_nextMove3a,enemies(3).possibleMoves);
                    else (y1 >= x1) && (y1a<=0) ;
                        tentative_nextMove3a = [3];
                        nextMove3a = intersect(tentative_nextMove3a,enemies(3).possibleMoves);
                    end
                end
                if isempty(nextMove3a)
                    if (x1 >= y1) && (x1a>=0) ;
                        tentative_nextMove3a = [4] ;
                        nextMove3a = intersect(tentative_nextMove3a,enemies(3).possibleMoves);
                    elseif (x1 >= y1) && (x1a<=0) ;
                        tentative_nextMove3a = [2];
                        nextMove3a = intersect(tentative_nextMove3a,enemies(3).possibleMoves);
                    elseif (y1 >= x1) && (y1a>=0) ;
                        tentative_nextMove3a = [3];
                        nextMove3a = intersect(tentative_nextMove3a,enemies(3).possibleMoves);
                    else (y1 >= x1) && (y1a<=0) ;
                        tentative_nextMove3a = [1];
                        nextMove3a = intersect(tentative_nextMove3a,enemies(3).possibleMoves);
                    end
                end
                flag100 = nextMove3a ;
            case 3
                %                 disp('T-junction')
                if x1 > y1 ;
                    if (x1a >= 0);
                        nextMove3a = 3;
                    else
                        nextMove3a = 1;
                    end
                    nextMove3a = intersect(enemies(3).possibleMoves,nextMove3a);
                    if isempty(nextMove3a)
                        if (y1a >= 0) ;
                            nextMove3a = 2;
                        else
                            nextMove3a = 4;
                        end
                    end
                else y1 > x1 ;
                    if (y1a >= 0);
                        nextMove3a = 2;
                    else
                        nextMove3a = 4;
                    end
                    nextMove3a = intersect(enemies(3).possibleMoves,nextMove3a);
                    if isempty(nextMove3a)
                        if (x1a >= 0) ;
                            nextMove3a = 3;
                        else
                            nextMove3a = 1;
                        end
                    end
                end
                Number_nextMove3a = numel(nextMove3a) ;
                if Number_nextMove3a > 1
                    if (nextMove3a == [1 3])
                        if (x1a >= 0)
                            nextMove3a = 3 ;
                        else
                            nextMove3a = 1 ;
                        end
                    else (nextMove3a == [2 4])
                        if (y1a >= 0)
                            nextMove3a = 2 ;
                        else
                            nextMove3a = 4 ;
                        end
                    end
                end
                %     if (nextMove3a==3) || (nextMove3a==1) ;
                %         tentative_nextMove3a = [1 3] ;
                %       if (any(possibleMoves==1));
                %         possibleMoves(possibleMoves == 1) = [];
                %       else (any(possibleMoves==3));
                %         possibleMoves(possibleMoves == 3) = [];
                %       end
                %         nextMove3a = possibleMoves(randperm((length(possibleMoves)),1)) ;
                %     else (nextMove3a==2) || (nextMove3a==4) ;
                %         tentative_nextMove3a = [2 4] ;
                %       if (any(possibleMoves==2));
                %         possibleMoves(possibleMoves == 2) = [];
                %       else (any(possibleMoves==4));
                %         possibleMoves(possibleMoves == 4) = [];
                %       end
                %         nextMove3a = possibleMoves(randperm((length(possibleMoves)),1)) ;
                %     end
                %                 Test_case_3 = nextMove3a ;
            case 4
                if x1 >= y1
                    if x1a >= 0
                        nextMove3a = 3;
                    else
                        nextMove3a = 1;
                    end
                else
                    if y1a >= 0
                        nextMove3a = 2;
                    else
                        nextMove3a = 4;
                    end
                end
%         end
    end
%%
%     Pincer_Moves = [0 nextMove3a];
%     idx = randi(length(Pincer_Moves)); % random index into x
%     nextMove3a2 = Pincer_Moves(idx);
    nextMove_c2 = nextMove3a;
Heat = 'High Temperature';   
X = ['Red Ghost = ',Heat,', Manhattan distance = ',num2str(distance3)];
% disp(X)
% end
%%
        corner = numel(enemies(3).possibleMoves);
%% Node Selection Start : Completely avoids tunnel's nextMove3a
    tunnel = intersect(enemies(3).dir,enemies(3).possibleMoves);
    tunnel_out = isempty(tunnel);
    if (corner==2) & (tunnel_out==0)  ;
        nextMove3a = enemies(3).dir;  %      disp('tunnel')
        %% Node Selection End
    else %any(corner > 1) ;%~any(possibleMoves==enemies(3).dir) && numel(enemies(3).possibleMoves)==numel(enemies(3).possibleMoves);
%         nextMove3a = nextMove3a_d10 ;

nextMove3a = enemies(3).possibleMoves ;
    if enemies(3).oldDir == 3;
    opposite_dir = [1];
    elseif enemies(3).oldDir == 1;
    opposite_dir = [3];
    elseif enemies(3).oldDir == 4;
    opposite_dir = [2];
    elseif enemies(3).oldDir == 2;
    opposite_dir = [4];
    end
nextMove3a = setxor(opposite_dir,nextMove3a);
nextMove3a = intersect(nextMove3a,enemies(3).possibleMoves);
    if (isempty(nextMove3a)==1);
%         idx = randi(length(enemies(3).possibleMoves)) ;
        nextMove3a = enemies(3).dir;
%     elseif (isempty(new_nodes)~=1);
%         new_nodes = intersect(new_nodes,possibleMoves);
    end
    if (isempty(nextMove3a)==1);
        idx = randi(length(enemies(3).possibleMoves)) ;
        nextMove3a = enemies(3).possibleMoves(idx(:));
%     elseif (isempty(new_nodes)~=1);
%         new_nodes = intersect(new_nodes,possibleMoves);
    end
idx = randi(length(nextMove3a)) ;
nextMove3a = nextMove3a(idx(:));
        total_possibleMoves = numel(enemies(3).possibleMoves) ;
        switch total_possibleMoves;
%             case 1
%                 ~any(possibleMoves==nextMove3a) ;
%                 nextMove3a = possibleMoves ;  %Since numel(possibleMoves) is 1 
            case 2   % Movement based on abs distance and non abs distance
                %                 disp('tunnel')
%                                 if (x1 >= y1) && (x1a>=0) ;
%                                     tentative_nextMove3a = [3] ;
%                 nextMove3a = intersect(nextMove3a,possibleMoves);

%                 idx = randi(length(possibleMoves)); 
%                 nextMove3a = enemies(3).possibleMoves(idx(:));
            nextMove3a = enemies(3).possibleMoves ;
            if enemies(3).oldDir == 3;
                opposite_dir = [1];
            elseif enemies(3).oldDir == 1;
                opposite_dir = [3];
            elseif enemies(3).oldDir == 4;
                opposite_dir = [2];
            elseif enemies(3).oldDir == 2;
                opposite_dir = [4];
            end
            nextMove3a = setxor(opposite_dir,nextMove3a);
            nextMove3a = intersect(nextMove3a,enemies(3).possibleMoves);
            idx = randi(length(nextMove3a));
            nextMove3a = nextMove3a(idx(:));
            if (isempty(nextMove3a)==1);
                idx = randi(length(enemies(3).possibleMoves)) ;
                nextMove3a = enemies(3).possibleMoves(idx(:));
                %     elseif (isempty(new_nodes)~=1);
                %         new_nodes = intersect(new_nodes,possibleMoves);
            end
%                                 elseif (x1 >= y1) && (x1a<=0) ;
%                                     tentative_nextMove3a = [1];
%                                     nextMove3a = intersect(tentative_nextMove3a,possibleMoves);
%                                 elseif (y1 >= x1) && (y1a>=0) ;
%                                     tentative_nextMove3a = [2];
%                                     nextMove3a = intersect(tentative_nextMove3a,possibleMoves);
%                                 else (y1 >= x1) && (y1a<=0) ;
%                                     tentative_nextMove3a = [4];
%                                     nextMove3a = intersect(tentative_nextMove3a,possibleMoves);
%                                 end
%                            Number_nextMove3a = numel(nextMove3a) ;
%                            if (Number_nextMove3a > 1)
%                                if (nextMove3a == [1 3])
%                                    if (x1a >= 0)
%                                        nextMove3a = 3 ;
%                                    else
%                                        nextMove3a = 1 ;
%                                    end
%                                else (nextMove3a == [2 4])
%                                    if (y1a >= 0)
%                                        nextMove3a = 2 ;
%                                    else
%                                        nextMove3a = 4 ;
%                                    end
%                                end
%                            end
%                 if isempty(nextMove3a);  % possibleMoves does not match tentative nextMove3a
%                     if (x1 >= y1) && (x1a>=0) ;
%                         tentative_nextMove3a = [2] ;
%                         nextMove3a = intersect(tentative_nextMove3a,possibleMoves);
%                     elseif (x1 >= y1) && (x1a<=0) ;
%                         tentative_nextMove3a = [4];
%                         nextMove3a = intersect(tentative_nextMove3a,enemies(3).possibleMoves);
%                     elseif (y1 >= x1) && (y1a>=0) ;
%                         tentative_nextMove3a = [1];
%                         nextMove3a = intersect(tentative_nextMove3a,enemies(3).possibleMoves);
%                     else (y1 >= x1) && (y1a<=0) ;
%                         tentative_nextMove3a = [3];
%                         nextMove3a = intersect(tentative_nextMove3a,enemies(3).possibleMoves);
%                     end
%                 end
%                 if isempty(nextMove3a);
%                     if (x1 >= y1) && (x1a>=0) ;
%                         tentative_nextMove3a = [4] ;
%                         nextMove3a = intersect(tentative_nextMove3a,enemies(3).possibleMoves);
%                     elseif (x1 >= y1) && (x1a<=0) ;
%                         tentative_nextMove3a = [2];
%                         nextMove3a = intersect(tentative_nextMove3a,enemies(3).possibleMoves);
%                     elseif (y1 >= x1) && (y1a>=0) ;
%                         tentative_nextMove3a = [3];
%                         nextMove3a = intersect(tentative_nextMove3a,enemies(3).possibleMoves);
%                     else (y1 >= x1) && (y1a<=0) ;
%                         tentative_nextMove3a = [1];
%                         nextMove3a = intersect(tentative_nextMove3a,enemies(3).possibleMoves);
%                     end
%                 end
%                 flag100 = nextMove3a ;
            case 3
%                 %                 disp('T-junction')
%                 if x1 > y1 ;
%                     if (x1a >= 0);
%                         nextMove3a = 3;
%                     else
%                         nextMove3a = 1;
%                     end
% %                     nextMove3a = intersect(possibleMoves,nextMove3a);
%                         idx = randi(length(possibleMoves)) ;
%                         nextMove3a = possibleMoves(idx(:));
%                     if isempty(nextMove3a);
%                         if (y1a >= 0) ;
%                             nextMove3a = 2;
%                         else
%                             nextMove3a = 4;
%                         end
%                     end
%                 else y1 > x1 ;
%                     if (y1a >= 0);
%                         nextMove3a = 2;
%                     else
%                         nextMove3a = 4;
%                     end
%                     %                     nextMove3a = intersect(possibleMoves,nextMove3a);
%                     idx = randi(length(possibleMoves)) ;
%                     nextMove3a = possibleMoves(idx(:));
%                     if isempty(nextMove3a);
%                         if (x1a >= 0) ;
%                             nextMove3a = 3;
%                         else
%                             nextMove3a = 1;
%                         end
%                     end
%                 end
%                 Number_nextMove3a = numel(nextMove3a) ;
%                 if Number_nextMove3a > 1;
%                     if (nextMove3a == [1 3]);
%                         if (x1a >= 0);
%                             nextMove3a = 3 ;
%                         else
%                             nextMove3a = 1 ;
%                         end
%                     else (nextMove3a == [2 4]);
%                         if (y1a >= 0);
%                             nextMove3a = 2 ;
%                         else
%                             nextMove3a = 4 ;
%                         end
%                     end
%                 end
            nextMove3a = enemies(3).possibleMoves ;
            if enemies(3).oldDir == 3;
                opposite_dir = [1 3];
            elseif enemies(3).oldDir == 1;
                opposite_dir = [1 3];
            elseif enemies(3).oldDir == 4;
                opposite_dir = [2 4];
            elseif enemies(3).oldDir == 2;
                opposite_dir = [2 4];
            end
            nextMove3a = setxor(opposite_dir,nextMove3a);
            nextMove3a = intersect(nextMove3a,enemies(3).possibleMoves);
            idx = randi(length(nextMove3a));
            nextMove3a = nextMove3a(idx(:));
%             if (isempty(nextMove3a)==1);
%                 idx = randi(length(enemies(3).possibleMoves)) ;
%                 nextMove3a = enemies(3).possibleMoves(idx(:));
%                 %     elseif (isempty(new_nodes)~=1);
%                 %         new_nodes = intersect(new_nodes,possibleMoves);
%             end
                
                %     if (nextMove3a==3) || (nextMove3a==1) ;
                %         tentative_nextMove3a = [1 3] ;
                %       if (any(possibleMoves==1));
                %         possibleMoves(possibleMoves == 1) = [];
                %       else (any(possibleMoves==3));
                %         possibleMoves(possibleMoves == 3) = [];
                %       end
                %         nextMove3a = possibleMoves(randperm((length(possibleMoves)),1)) ;
                %     else (nextMove3a==2) || (nextMove3a==4) ;
                %         tentative_nextMove3a = [2 4] ;
                %       if (any(possibleMoves==2));
                %         possibleMoves(possibleMoves == 2) = [];
                %       else (any(possibleMoves==4));
                %         possibleMoves(possibleMoves == 4) = [];
                %       end
                %         nextMove3a = possibleMoves(randperm((length(possibleMoves)),1)) ;
                %     end
                %                 Test_case_3 = nextMove3a ;
            case 4
%                 if x1 >= y1;
%                     if x1a >= 0;
%                         nextMove3a = 3;
%                     else
%                         nextMove3a = 1;
%                     end
%                 else
%                     if y1a >= 0;
%                         nextMove3a = 2;
%                     else
%                         nextMove3a = 4;
%                     end
%                 end
            nextMove3a = enemies(3).possibleMoves ;
            if enemies(3).oldDir == 3;
                opposite_dir = [1];
            elseif enemies(3).oldDir == 1;
                opposite_dir = [3];
            elseif enemies(3).oldDir == 4;
                opposite_dir = [2];
            elseif enemies(3).oldDir == 2;
                opposite_dir = [4];
            end
            nextMove3a = setxor(opposite_dir,nextMove3a);
            nextMove3a = intersect(nextMove3a,enemies(3).possibleMoves);
            idx = randi(length(nextMove3a));
            nextMove3a = nextMove3a(idx(:));
  
        end
    end
%%
    Pincer_Moves = [0 nextMove3a];
    idx = randi(length(Pincer_Moves)); % random index into x
%     nextMove3a2 = Pincer_Moves(idx);
    nextMove_c3 = nextMove3a;
Heat = 'High Temperature';   
X = ['Red Ghost = ',Heat,', Manhattan distance = ',num2str(distance3)];
% disp(X)
% end
%%  
% node = [nextMove_c3 nextMove_c1 nextMove_c2] ;
% new_nodes = [nextMove_c1 nextMove_c2] ;
new_nodes = [nextMove_c3] ;
coordinates1 = square1;
for i = 1:numel(new_nodes)
if (new_nodes(i)==1) ;
    coordinates1(1) = coordinates1(1) + 1;
elseif (new_nodes(i)== 3) ;
    coordinates1(1) = coordinates1(1) - 1;
elseif (new_nodes(i)== 4);
    coordinates1(2) = coordinates1(2) + 1;
elseif (new_nodes(i)== 2);
    coordinates1(2) = coordinates1(2) - 1;
else (new_nodes(i)== 0);
    coordinates1(1) = coordinates1(1) ;
end
% if (i == 1) ;
Energy_val_c1 = abs(coordinates1(1)-square2(1)) + abs(coordinates1(2)-square2(2));
% elseif (i == 2) ; 
% Energy_val_c2 = abs(coordinates1(1)-square2(1)) + abs(coordinates1(2)-square2(2));
% % elseif (i == 3) ; 
% % Energy_val_c1 = abs(coordinates1(1)-square2(1)) + abs(coordinates1(2)-square2(2));
% end
coordinates1 = square1;   %% ADD THIS LINE
end
% del_E33 = distance3 - Energy_val_c3 -2;
% del_E32 = distance3 - Energy_val_c2 +0;
del_E31 = distance3 - Energy_val_c1 +0;

% Energy_val_c = [del_E31 del_E32];
Energy_val_c = [del_E31];
% Energy_val_c 
% random_Gen3 = 0;%(randi([1, 100],1))/100 ;
random_Gen31 = (randi([1, 100],1))/100 ;
test_sigmoid_fun_current3 = sigmoid_fun_current3 ;
%if random_Gen3 = 0; sigmoid_func = 0.5; rejects bad nodes
%if random_Gen3 = 1; sigmoid_func = 0.5; accepts bad nodes
for i = 1:numel(new_nodes) ;
if (Energy_val_c(i) > 0) ;
    nextMove3 = new_nodes(i);
    flag_a = 1 ;
     % End loop
     if (sigmoid_fun_current3 > random_Gen31); % if (Temperature <= 130);
         nextMove3 = new_nodes(i);
         flag_aa3 = 1 ;
         flag_accept = 'accept';
     else (sigmoid_fun_current3 <= random_Gen31);
         nextMove3 = 0;
         flag_bb3 = 1 ;
         flag_accept = 'reject';
         % idx = find(Energy_val_a == min(Energy_val_a(:)))
         % nextMove1 = node(idx)
     end
else (Energy_val_c(i) <= 0) ;
    flag_b = 1 ;
    if ((sigmoid_fun_current3) < random_Gen31) ;
        nextMove3 = 0 ;%nextMove_c; % Reject Generated neighbor and remain stationary
        %         Node_rejection_1 = Node_rejection_1 + 1 ;
        flag_c = 1 ;
        flag_accept = 'reject';
    else ((sigmoid_fun_current3) >= random_Gen31) ;
        %         nextMove1 = nextMove_a1;
        %         idx = randi(length(Energy_val_c)) ;
        %         nextMove1 = node(idx(:));
        nextMove3 = new_nodes(i) ; 
         % End loop
        flag_d = 1 ;
        flag_accept = 'accept';
    end
end
    if (nextMove3 ~= 0)
        break
    end
test_nextMove3 = nextMove3;
end
node_i = i;
%     X3 = ['Cyan Ghost: ','No. of nodes = ',num2str(Energy_val_c), ', node accepted = ',num2str(i), ', distance = ',num2str(distance3)];
%     disp(X3)
X3 = ['Cyan Ghost: ','Pr. of Acceptance = ',num2str(sigmoid_fun_current3),' Temperature = ',num2str(Temperature32), ', node = ',num2str(flag_accept)];% ', distance = ',num2str(distance1)];
% disp(X3)
% nextMove3 = nextMove_c3;
% del_E31
% del_E32
% sigmoid_fun_current
%%
    if distance3 == 0 ;
        pack_threshold3 = T1;
    else
        pack_threshold3 = [T1*(rate2)^+t(distance3)]+separation; % Temperature,Low->High % Arbitrary Max distance 50
    end
pack31 = ((position3(1) - position1(1))^2 + (position3(2) - position1(2))^2)^0.5 ; 
pack32 = ((position3(1) - position2(1))^2 + (position3(2) - position2(2))^2)^0.5 ; 
pack34 = ((position3(1) - position4(1))^2 + (position3(2) - position4(2))^2)^0.5 ;
% pack_wolf = pack31 + pack32 + pack34 ;
pack_vec3 = [pack31 pack32 pack34] ;  
    idx = find(pack_vec3==min(pack_vec3));
    if (idx==1);
    square3 = position1;
    elseif (idx==2);
    square3 = position2;
    else (idx==3);
    square3 = position4;
    end
% square2 = pack_index1;
x12 = (abs(square1(1)-square3(1)))/1;
y12 = (abs(square1(2)-square3(2)))/1;
% enemies(3).x1 = x1;
% enemies(3).y1 = y1;
%         distance = x1 + y1
distance32 = x12 + y12; 
if ((pack_threshold3) >= distance32)
x1 = x12;
y1 = y12;
% enemies(3).distance3 = distance3;
distance32 = x1 + y1; 
x1a = ((square1(1)-square3(1)))/4;
y1a = ((square1(2)-square3(2)))/4;
% enemies(3).x1a = x1a;
% enemies(3).y1a = y1a;

%         if (x1a < 0)
%             x1_negative = x1a
%         end
if x1 >= y1;
    if x1a >= 0
        nextMove = 1;
    else
        nextMove = 3;
    end
else
    if y1a >= 0;
        nextMove = 4;
    else
        nextMove = 2;
    end
end
    corner = numel(possibleMoves);
    %% Node Selection Start : Completely avoids tunnel's nextMove
    tunnel = intersect(enemies(3).dir,enemies(3).possibleMoves);
    tunnel_out = isempty(tunnel);
%     if (corner==2) & (tunnel_out==0)  ;
%         nextMove = enemies(3).dir;  %      disp('tunnel')
%         % Node Selection End
%     else %any(corner > 1) ;%~any(possibleMoves==enemies(3).dir) && numel(enemies(3).possibleMoves)==numel(enemies(3).possibleMoves);
        total_possibleMoves = numel(enemies(3).possibleMoves) ;
        switch total_possibleMoves
            case 2   % Movement based on abs distance and non abs distance
                nextMove = intersect(nextMove,enemies(3).possibleMoves);
                if isempty(nextMove)  % possibleMoves does not match tentative nextMove
                    if (x1 >= y1) && (x1a>=0) ;
                        tentative_nextMove = [4] ;
                        nextMove = intersect(tentative_nextMove,enemies(3).possibleMoves);
                    elseif (x1 >= y1) && (x1a<=0) ;
                        tentative_nextMove = [2];
                        nextMove = intersect(tentative_nextMove,enemies(3).possibleMoves);
                    elseif (y1 >= x1) && (y1a>=0) ;
                        tentative_nextMove = [3];
                        nextMove = intersect(tentative_nextMove,enemies(3).possibleMoves);
                    else (y1 >= x1) && (y1a<=0) ;
                        tentative_nextMove = [1];
                        nextMove = intersect(tentative_nextMove,enemies(3).possibleMoves);
                    end
                end
                if isempty(nextMove)
                    if (x1 >= y1) && (x1a>=0) ;
                        tentative_nextMove = [2] ;
                        nextMove = intersect(tentative_nextMove,enemies(3).possibleMoves);
                    elseif (x1 >= y1) && (x1a<=0) ;
                        tentative_nextMove = [4];
                        nextMove = intersect(tentative_nextMove,enemies(3).possibleMoves);
                    elseif (y1 >= x1) && (y1a>=0) ;
                        tentative_nextMove = [1];
                        nextMove = intersect(tentative_nextMove,enemies(3).possibleMoves);
                    else (y1 >= x1) && (y1a<=0) ;
                        tentative_nextMove = [3];
                        nextMove = intersect(tentative_nextMove,enemies(3).possibleMoves);
                    end
                end
            case 3
                if x1 > y1 ;
                    if (x1a >= 0);
                        nextMove = 1;
                    else
                        nextMove = 3;
                    end
                    nextMove = intersect(enemies(3).possibleMoves,nextMove);
                    if isempty(nextMove)
                        if (y1a >= 0) ;
                            nextMove = 4;
                        else
                            nextMove = 2;
                        end
                    end
                else y1 > x1 ;
                    if (y1a >= 0);
                        nextMove = 4;
                    else
                        nextMove = 2;
                    end
                    nextMove = intersect(enemies(3).possibleMoves,nextMove);
                    if isempty(nextMove)
                        if (x1a >= 0) ;
                            nextMove = 1;
                        else
                            nextMove = 3;
                        end
                    end
                end
                Number_nextMove = numel(nextMove) ;
                if Number_nextMove > 1
                    if (nextMove == [1 3])
                        if (x1a >= 0)
                            nextMove = 1 ;
                        else
                            nextMove = 3 ;
                        end
                    else (nextMove == [2 4])
                        if (y1a >= 0)
                            nextMove = 4 ;
                        else
                            nextMove = 2 ;
                        end
                    end
                end
        end
%         end
nextMove3 = nextMove ; 
end
%test_nextMove3
end
%%
%%
function [nextMove4] = shortestPath4(square1,square2,entity)
    possibleMoves = allDirections{square1(1),square1(2)};
    position4 = square1 ; 
    enemies(4).possibleMoves = possibleMoves;
    %         Test_pacman = square2
    x1 = abs(square1(1)-square2(1));
    y1 = abs(square1(2)-square2(2));
    enemies(4).x1 = x1;
    enemies(4).y1 = y1;
    %         distance = x1 + y1
    distance4 = x1 + y1 ;
    enemies(4).distance4 = distance4;
    x1a = (square1(1)-square2(1));
    y1a = (square1(2)-square2(2));
    enemies(4).x1a = x1a;
    enemies(4).y1a = y1a;

    %         if (x1a < 0)
    %             x1_negative = x1a
    %         end
    if x1 >= y1;
        if x1a >= 0
            nextMove4a = 3;
        else
            nextMove4a = 1;
        end
    else
        if y1a >= 0;
            nextMove4a = 2;
        else
            nextMove4a = 4;
        end
    end
    nextMove4a_d10 = nextMove4a;
    %% Sigmoid function -> Simulated Annealing, from High Temp(Random walk) to Low Temperature(Hill Climbing)
    t = linspace(1,10^2,50);  % t inversely proportional to Temperature,
%     Therefore, Temperature Very Low-> Very High
    T_0 = 10^3;
     if distance4 == 0 ;
        Temperature42 = 1000 ;
    else
        Temperature42 = 10^3*(0.9500+0.0050)^t(distance4); % Temperature,Low->High % Arbitrary Max distance 50
        Temperature42';
    end
    distance4;
%     Temperature42 = 1;
    sigmoid_fun_current4 = (1 + exp(-06*((1*distance4-0))/Temperature42))^(-1) - 0.4;
%     count1 = 0 ;
%     random_Gen = (randi([1, 100],1))/100;  % 0.5*max(sigmoid_function) = 0.250 ; % 50 % chance of selection 
%     if (sigmoid_function <= random_Gen); % if (Temperature <= 130);
%         count1 = count1 + 1 ;
%     end
%     Ghost_Distance = distance4;
%     Ghost_Temperature = Temperature;
%     Pr_1st_Ghost = sigmoid_function;
%     count1;
%% end Sigmoid function Max Distance = 40, Min Distance = 12;
% if (count1 == 1)
    %     flag10001 = 1
    corner = numel(possibleMoves);
    %% Node Selection Start : Completely avoids tunnel's nextMove4a
    tunnel = intersect(enemies(4).dir,enemies(4).possibleMoves);
    tunnel_out = isempty(tunnel);
    if (corner==2) & (tunnel_out==0)  ;
        nextMove4a = enemies(4).dir;  %      disp('tunnel')
        %% Node Selection End
    else %any(corner > 1) ;%~any(possibleMoves==enemies(4).dir) && numel(enemies(4).possibleMoves)==numel(enemies(4).possibleMoves);
        %       nextMove4a = nextMove4a;
        %         msize = numel(possibleMoves) ;
        %         idx = randperm(msize) ;
        %         nextMove4a = possibleMoves(idx(1:1)) ;
        % ** write code  1->Right 3->Left 2->Down 4->Up
        total_possibleMoves = numel(enemies(4).possibleMoves) ;
        switch total_possibleMoves
            %             case 1
            %                 ~any(possibleMoves==nextMove4a) ;
            %                 nextMove4a = possibleMoves ;  %Since numel(possibleMoves) is 1
            case 2   % Movement based on abs distance and non abs distance
                %                 disp('tunnel')
                %                 if (x1 >= y1) && (x1a>=0) ;
                %                     tentative_nextMove4a = [3] ;
                nextMove4a = intersect(nextMove4a,enemies(4).possibleMoves);
                %                 elseif (x1 >= y1) && (x1a<=0) ;
                %                     tentative_nextMove4a = [1];
                %                     nextMove4a = intersect(tentative_nextMove4a,possibleMoves);
                %                 elseif (y1 >= x1) && (y1a>=0) ;
                %                     tentative_nextMove4a = [2];
                %                     nextMove4a = intersect(tentative_nextMove4a,possibleMoves);
                %                 else (y1 >= x1) && (y1a<=0) ;
                %                     tentative_nextMove4a = [4];
                %                     nextMove4a = intersect(tentative_nextMove4a,possibleMoves);
                %                 end
                %            Number_nextMove4a = numel(nextMove4a) ;
                %            if (Number_nextMove4a > 1)
                %                if (nextMove4a == [1 3])
                %                    if (x1a >= 0)
                %                        nextMove4a = 3 ;
                %                    else
                %                        nextMove4a = 1 ;
                %                    end
                %                else (nextMove4a == [2 4])
                %                    if (y1a >= 0)
                %                        nextMove4a = 2 ;
                %                    else
                %                        nextMove4a = 4 ;
                %                    end
                %                end
                %            end
                if isempty(nextMove4a)  % possibleMoves does not match tentative nextMove4a
                    if (x1 >= y1) && (x1a>=0) ;
                        tentative_nextMove4a = [2] ;
                        nextMove4a = intersect(tentative_nextMove4a,enemies(4).possibleMoves);
                    elseif (x1 >= y1) && (x1a<=0) ;
                        tentative_nextMove4a = [4];
                        nextMove4a = intersect(tentative_nextMove4a,enemies(4).possibleMoves);
                    elseif (y1 >= x1) && (y1a>=0) ;
                        tentative_nextMove4a = [1];
                        nextMove4a = intersect(tentative_nextMove4a,enemies(4).possibleMoves);
                    else (y1 >= x1) && (y1a<=0) ;
                        tentative_nextMove4a = [3];
                        nextMove4a = intersect(tentative_nextMove4a,enemies(4).possibleMoves);
                    end
                end
                if isempty(nextMove4a)
                    if (x1 >= y1) && (x1a>=0) ;
                        tentative_nextMove4a = [4] ;
                        nextMove4a = intersect(tentative_nextMove4a,enemies(4).possibleMoves);
                    elseif (x1 >= y1) && (x1a<=0) ;
                        tentative_nextMove4a = [2];
                        nextMove4a = intersect(tentative_nextMove4a,enemies(4).possibleMoves);
                    elseif (y1 >= x1) && (y1a>=0) ;
                        tentative_nextMove4a = [3];
                        nextMove4a = intersect(tentative_nextMove4a,enemies(4).possibleMoves);
                    else (y1 >= x1) && (y1a<=0) ;
                        tentative_nextMove4a = [1];
                        nextMove4a = intersect(tentative_nextMove4a,enemies(4).possibleMoves);
                    end
                end
                flag100 = nextMove4a ;
            case 3
                %                 disp('T-junction')
                if x1 > y1 ;
                    if (x1a >= 0);
                        nextMove4a = 3;
                    else
                        nextMove4a = 1;
                    end
                    nextMove4a = intersect(enemies(4).possibleMoves,nextMove4a);
                    if isempty(nextMove4a)
                        if (y1a >= 0) ;
                            nextMove4a = 2;
                        else
                            nextMove4a = 4;
                        end
                    end
                else y1 > x1 ;
                    if (y1a >= 0);
                        nextMove4a = 2;
                    else
                        nextMove4a = 4;
                    end
                    nextMove4a = intersect(enemies(4).possibleMoves,nextMove4a);
                    if isempty(nextMove4a)
                        if (x1a >= 0) ;
                            nextMove4a = 3;
                        else
                            nextMove4a = 1;
                        end
                    end
                end
                Number_nextMove4a = numel(nextMove4a) ;
                if Number_nextMove4a > 1
                    if (nextMove4a == [1 3])
                        if (x1a >= 0)
                            nextMove4a = 3 ;
                        else
                            nextMove4a = 1 ;
                        end
                    else (nextMove4a == [2 4])
                        if (y1a >= 0)
                            nextMove4a = 2 ;
                        else
                            nextMove4a = 4 ;
                        end
                    end
                end
                %     if (nextMove4a==3) || (nextMove4a==1) ;
                %         tentative_nextMove4a = [1 3] ;
                %       if (any(possibleMoves==1));
                %         possibleMoves(possibleMoves == 1) = [];
                %       else (any(possibleMoves==3));
                %         possibleMoves(possibleMoves == 3) = [];
                %       end
                %         nextMove4a = possibleMoves(randperm((length(possibleMoves)),1)) ;
                %     else (nextMove4a==2) || (nextMove4a==4) ;
                %         tentative_nextMove4a = [2 4] ;
                %       if (any(possibleMoves==2));
                %         possibleMoves(possibleMoves == 2) = [];
                %       else (any(possibleMoves==4));
                %         possibleMoves(possibleMoves == 4) = [];
                %       end
                %         nextMove4a = possibleMoves(randperm((length(possibleMoves)),1)) ;
                %     end
                %                 Test_case_3 = nextMove4a ;
            case 4
                if x1 >= y1
                    if x1a >= 0
                        nextMove4a = 3;
                    else
                        nextMove4a = 1;
                    end
                else
                    if y1a >= 0
                        nextMove4a = 2;
                    else
                        nextMove4a = 4;
                    end
                end
        end
    end
    nextMove_d1 = nextMove4a;
    Heat = 'Low Temperature';
    X = ['Red Ghost = ',Heat,', Manhattan distance = ',num2str(distance4)];
%     disp(X)
% elseif (count1 == 0) ;% && (enemies(4).distance4 < 2);
%%
%     disp('Acceptance_Pr > 0.46')
    corner = numel(enemies(4).possibleMoves);   
    %% Node Selection Start : Completely avoids tunnel's nextMove4a
%     if any(corner==2) ;%&& numel(enemies(4).possibleMoves)==numel(enemies(4).possibleMoves);
%         nextMove4a = enemies(4).oldDir;
%         disp('tunnel')
    %% Node Selection End
%     else %any(corner > 1) ;%~any(possibleMoves==enemies(4).dir) && numel(enemies(4).possibleMoves)==numel(enemies(4).possibleMoves);
        %       nextMove4a = nextMove4a;
        %         msize = numel(possibleMoves) ;
        %         idx = randperm(msize) ;
        %         nextMove4a = possibleMoves(idx(1:1)) ;
        % ** write code  1->Right 3->Left 2->Down 4->Up
        nextMove4a = nextMove4a_d10 ;
        total_possibleMoves = numel(enemies(4).possibleMoves) ;
        switch total_possibleMoves
%             case 1
%                 ~any(possibleMoves==nextMove4a) ;
%                 nextMove4a = possibleMoves ;  %Since numel(possibleMoves) is 1 
            case 2   % Movement based on abs distance and non abs distance
                %                 disp('tunnel')
%                                 if (x1 >= y1) && (x1a>=0) ;
%                                     tentative_nextMove4a = [3] ;
                nextMove4a = intersect(nextMove4a,enemies(4).possibleMoves);
%                                 elseif (x1 >= y1) && (x1a<=0) ;
%                                     tentative_nextMove4a = [1];
%                                     nextMove4a = intersect(tentative_nextMove4a,possibleMoves);
%                                 elseif (y1 >= x1) && (y1a>=0) ;
%                                     tentative_nextMove4a = [2];
%                                     nextMove4a = intersect(tentative_nextMove4a,possibleMoves);
%                                 else (y1 >= x1) && (y1a<=0) ;
%                                     tentative_nextMove4a = [4];
%                                     nextMove4a = intersect(tentative_nextMove4a,possibleMoves);
%                                 end
%                            Number_nextMove4a = numel(nextMove4a) ;
%                            if (Number_nextMove4a > 1)
%                                if (nextMove4a == [1 3])
%                                    if (x1a >= 0)
%                                        nextMove4a = 3 ;
%                                    else
%                                        nextMove4a = 1 ;
%                                    end
%                                else (nextMove4a == [2 4])
%                                    if (y1a >= 0)
%                                        nextMove4a = 2 ;
%                                    else
%                                        nextMove4a = 4 ;
%                                    end
%                                end
%                            end
                if isempty(nextMove4a)  % possibleMoves does not match tentative nextMove4a
                    if (x1 >= y1) && (x1a>=0) ;
                        tentative_nextMove4a = [2] ;
                        nextMove4a = intersect(tentative_nextMove4a,enemies(4).possibleMoves);
                    elseif (x1 >= y1) && (x1a<=0) ;
                        tentative_nextMove4a = [4];
                        nextMove4a = intersect(tentative_nextMove4a,enemies(4).possibleMoves);
                    elseif (y1 >= x1) && (y1a>=0) ;
                        tentative_nextMove4a = [1];
                        nextMove4a = intersect(tentative_nextMove4a,enemies(4).possibleMoves);
                    else (y1 >= x1) && (y1a<=0) ;
                        tentative_nextMove4a = [3];
                        nextMove4a = intersect(tentative_nextMove4a,enemies(4).possibleMoves);
                    end
                end
                if isempty(nextMove4a)
                    if (x1 >= y1) && (x1a>=0) ;
                        tentative_nextMove4a = [4] ;
                        nextMove4a = intersect(tentative_nextMove4a,enemies(4).possibleMoves);
                    elseif (x1 >= y1) && (x1a<=0) ;
                        tentative_nextMove4a = [2];
                        nextMove4a = intersect(tentative_nextMove4a,enemies(4).possibleMoves);
                    elseif (y1 >= x1) && (y1a>=0) ;
                        tentative_nextMove4a = [3];
                        nextMove4a = intersect(tentative_nextMove4a,enemies(4).possibleMoves);
                    else (y1 >= x1) && (y1a<=0) ;
                        tentative_nextMove4a = [1];
                        nextMove4a = intersect(tentative_nextMove4a,enemies(4).possibleMoves);
                    end
                end
                flag100 = nextMove4a ;
            case 3
                %                 disp('T-junction')
                if x1 > y1 ;
                    if (x1a >= 0);
                        nextMove4a = 3;
                    else
                        nextMove4a = 1;
                    end
                    nextMove4a = intersect(enemies(4).possibleMoves,nextMove4a);
                    if isempty(nextMove4a)
                        if (y1a >= 0) ;
                            nextMove4a = 2;
                        else
                            nextMove4a = 4;
                        end
                    end
                else y1 > x1 ;
                    if (y1a >= 0);
                        nextMove4a = 2;
                    else
                        nextMove4a = 4;
                    end
                    nextMove4a = intersect(enemies(4).possibleMoves,nextMove4a);
                    if isempty(nextMove4a)
                        if (x1a >= 0) ;
                            nextMove4a = 3;
                        else
                            nextMove4a = 1;
                        end
                    end
                end
                Number_nextMove4a = numel(nextMove4a) ;
                if Number_nextMove4a > 1
                    if (nextMove4a == [1 3])
                        if (x1a >= 0)
                            nextMove4a = 3 ;
                        else
                            nextMove4a = 1 ;
                        end
                    else (nextMove4a == [2 4])
                        if (y1a >= 0)
                            nextMove4a = 2 ;
                        else
                            nextMove4a = 4 ;
                        end
                    end
                end
                %     if (nextMove4a==3) || (nextMove4a==1) ;
                %         tentative_nextMove4a = [1 3] ;
                %       if (any(possibleMoves==1));
                %         possibleMoves(possibleMoves == 1) = [];
                %       else (any(possibleMoves==3));
                %         possibleMoves(possibleMoves == 3) = [];
                %       end
                %         nextMove4a = possibleMoves(randperm((length(possibleMoves)),1)) ;
                %     else (nextMove4a==2) || (nextMove4a==4) ;
                %         tentative_nextMove4a = [2 4] ;
                %       if (any(possibleMoves==2));
                %         possibleMoves(possibleMoves == 2) = [];
                %       else (any(possibleMoves==4));
                %         possibleMoves(possibleMoves == 4) = [];
                %       end
                %         nextMove4a = possibleMoves(randperm((length(possibleMoves)),1)) ;
                %     end
                %                 Test_case_3 = nextMove4a ;
            case 4
                if x1 >= y1
                    if x1a >= 0
                        nextMove4a = 3;
                    else
                        nextMove4a = 1;
                    end
                else
                    if y1a >= 0
                        nextMove4a = 2;
                    else
                        nextMove4a = 4;
                    end
                end
%         end
    end
%%
%     Pincer_Moves = [0 nextMove4a];
%     idx = randi(length(Pincer_Moves)); % random index into x
%     nextMove3a2 = Pincer_Moves(idx);    
nextMove_d2 = nextMove4a;
Heat = 'High Temperature';   
X = ['Red Ghost = ',Heat,', Manhattan distance = ',num2str(distance4)];
% disp(X)
% end
%%
        corner = numel(enemies(4).possibleMoves);
%% Node Selection Start : Completely avoids tunnel's nextMove4a
    tunnel = intersect(enemies(4).dir,enemies(4).possibleMoves);
    tunnel_out = isempty(tunnel);
    if (corner==2) & (tunnel_out==0)  ;
        nextMove4a = enemies(4).dir;  %      disp('tunnel')
        %% Node Selection End
    else %any(corner > 1) ;%~any(possibleMoves==enemies(4).dir) && numel(enemies(4).possibleMoves)==numel(enemies(4).possibleMoves);
%     nextMove4a = nextMove4a_d10 ;
    
    nextMove4a = enemies(4).possibleMoves ;
    if enemies(4).oldDir == 3;
    opposite_dir = [1];
    elseif enemies(4).oldDir == 1;
    opposite_dir = [3];
    elseif enemies(4).oldDir == 4;
    opposite_dir = [2];
    elseif enemies(4).oldDir == 2;
    opposite_dir = [4];
    end
nextMove4a = setxor(opposite_dir,nextMove4a);
nextMove4a = intersect(nextMove4a,enemies(4).possibleMoves);
    if (isempty(nextMove4a)==1);
        %     idx1 = randi(length(enemies(4).possibleMoves))
        nextMove4a = enemies(4).dir;
    end
    if (isempty(nextMove4a)==1);
        idx = randi(length(enemies(4).possibleMoves)) ;
        nextMove4a = enemies(4).possibleMoves(idx(:));
        %     elseif (isempty(new_nodes)~=1);
        %         new_nodes = intersect(new_nodes,possibleMoves);
    end
idx2 = randi(length(nextMove4a)) ;
nextMove4a = nextMove4a(idx2(:));
        total_possibleMoves = numel(enemies(4).possibleMoves) ;
        switch total_possibleMoves;
%             case 1
%                 ~any(possibleMoves==nextMove4a) ;
%                 nextMove4a = possibleMoves ;  %Since numel(possibleMoves) is 1 
            case 2   % Movement based on abs distance and non abs distance
                %                 disp('tunnel')
%                                 if (x1 >= y1) && (x1a>=0) ;
%                                     tentative_nextMove4a = [3] ;
%                 nextMove4a = intersect(nextMove4a,possibleMoves);

%                 idx = randi(length(possibleMoves)); 
%                 nextMove4a = enemies(4).possibleMoves(idx(:));           
            nextMove4a = enemies(4).possibleMoves ;
            if enemies(4).oldDir == 3;
                opposite_dir = [1];
            elseif enemies(4).oldDir == 1;
                opposite_dir = [3];
            elseif enemies(4).oldDir == 4;
                opposite_dir = [2];
            elseif enemies(4).oldDir == 2;
                opposite_dir = [4];
            end
            nextMove4a = setxor(opposite_dir,nextMove4a);
            nextMove4a = intersect(nextMove4a,enemies(4).possibleMoves);
            idx = randi(length(nextMove4a));
            nextMove4a = nextMove4a(idx(:));
            if (isempty(nextMove4a)==1);
                idx = randi(length(enemies(4).possibleMoves)) ;
                nextMove4a = enemies(4).possibleMoves(idx(:));
                %     elseif (isempty(new_nodes)~=1);
                %         new_nodes = intersect(new_nodes,possibleMoves);
            end
%                                 elseif (x1 >= y1) && (x1a<=0) ;
%                                     tentative_nextMove4a = [1];
%                                     nextMove4a = intersect(tentative_nextMove4a,possibleMoves);
%                                 elseif (y1 >= x1) && (y1a>=0) ;
%                                     tentative_nextMove4a = [2];
%                                     nextMove4a = intersect(tentative_nextMove4a,possibleMoves);
%                                 else (y1 >= x1) && (y1a<=0) ;
%                                     tentative_nextMove4a = [4];
%                                     nextMove4a = intersect(tentative_nextMove4a,possibleMoves);
%                                 end
%                            Number_nextMove4a = numel(nextMove4a) ;
%                            if (Number_nextMove4a > 1)
%                                if (nextMove4a == [1 3])
%                                    if (x1a >= 0)
%                                        nextMove4a = 3 ;
%                                    else
%                                        nextMove4a = 1 ;
%                                    end
%                                else (nextMove4a == [2 4])
%                                    if (y1a >= 0)
%                                        nextMove4a = 2 ;
%                                    else
%                                        nextMove4a = 4 ;
%                                    end
%                                end
%                            end
%                 if isempty(nextMove4a);  % possibleMoves does not match tentative nextMove4a
%                     if (x1 >= y1) && (x1a>=0) ;
%                         tentative_nextMove4a = [2] ;
%                         nextMove4a = intersect(tentative_nextMove4a,possibleMoves);
%                     elseif (x1 >= y1) && (x1a<=0) ;
%                         tentative_nextMove4a = [4];
%                         nextMove4a = intersect(tentative_nextMove4a,enemies(4).possibleMoves);
%                     elseif (y1 >= x1) && (y1a>=0) ;
%                         tentative_nextMove4a = [1];
%                         nextMove4a = intersect(tentative_nextMove4a,enemies(4).possibleMoves);
%                     else (y1 >= x1) && (y1a<=0) ;
%                         tentative_nextMove4a = [3];
%                         nextMove4a = intersect(tentative_nextMove4a,enemies(4).possibleMoves);
%                     end
%                 end
%                 if isempty(nextMove4a);
%                     if (x1 >= y1) && (x1a>=0) ;
%                         tentative_nextMove4a = [4] ;
%                         nextMove4a = intersect(tentative_nextMove4a,enemies(4).possibleMoves);
%                     elseif (x1 >= y1) && (x1a<=0) ;
%                         tentative_nextMove4a = [2];
%                         nextMove4a = intersect(tentative_nextMove4a,enemies(4).possibleMoves);
%                     elseif (y1 >= x1) && (y1a>=0) ;
%                         tentative_nextMove4a = [3];
%                         nextMove4a = intersect(tentative_nextMove4a,enemies(4).possibleMoves);
%                     else (y1 >= x1) && (y1a<=0) ;
%                         tentative_nextMove4a = [1];
%                         nextMove4a = intersect(tentative_nextMove4a,enemies(4).possibleMoves);
%                     end
%                 end
%                 flag100 = nextMove4a ;
            case 3
%                 %                 disp('T-junction')
%                 if x1 > y1 ;
%                     if (x1a >= 0);
%                         nextMove4a = 3;
%                     else
%                         nextMove4a = 1;
%                     end
% %                     nextMove4a = intersect(possibleMoves,nextMove4a);
%                         idx = randi(length(possibleMoves)) ;
%                         nextMove4a = possibleMoves(idx(:));
%                     if isempty(nextMove4a);
%                         if (y1a >= 0) ;
%                             nextMove4a = 2;
%                         else
%                             nextMove4a = 4;
%                         end
%                     end
%                 else y1 > x1 ;
%                     if (y1a >= 0);
%                         nextMove4a = 2;
%                     else
%                         nextMove4a = 4;
%                     end
%                     %                     nextMove4a = intersect(possibleMoves,nextMove4a);
%                     idx = randi(length(possibleMoves)) ;
%                     nextMove4a = possibleMoves(idx(:));
%                     if isempty(nextMove4a);
%                         if (x1a >= 0) ;
%                             nextMove4a = 3;
%                         else
%                             nextMove4a = 1;
%                         end
%                     end
%                 end
%                 Number_nextMove4a = numel(nextMove4a) ;
%                 if Number_nextMove4a > 1;
%                     if (nextMove4a == [1 3]);
%                         if (x1a >= 0);
%                             nextMove4a = 3 ;
%                         else
%                             nextMove4a = 1 ;
%                         end
%                     else (nextMove4a == [2 4]);
%                         if (y1a >= 0);
%                             nextMove4a = 2 ;
%                         else
%                             nextMove4a = 4 ;
%                         end
%                     end
%                 end
nextMove4a = enemies(4).possibleMoves ;
            if enemies(4).oldDir == 3;
                opposite_dir = [1 3];
            elseif enemies(4).oldDir == 1;
                opposite_dir = [1 3];
            elseif enemies(4).oldDir == 4;
                opposite_dir = [2 4];
            elseif enemies(4).oldDir == 2;
                opposite_dir = [2 4];
            end
            nextMove4a = setxor(opposite_dir,nextMove4a);
            nextMove4a = intersect(nextMove4a,enemies(4).possibleMoves);
            idx = randi(length(nextMove4a));
            nextMove4a = nextMove4a(idx(:));
%             if (isempty(nextMove4a)==1);
%                 idx = randi(length(enemies(4).possibleMoves)) ;
%                 nextMove4a = enemies(4).possibleMoves(idx(:));
%                 %     elseif (isempty(new_nodes)~=1);
%                 %         new_nodes = intersect(new_nodes,possibleMoves);
%             end
                
                %     if (nextMove4a==3) || (nextMove4a==1) ;
                %         tentative_nextMove4a = [1 3] ;
                %       if (any(possibleMoves==1));
                %         possibleMoves(possibleMoves == 1) = [];
                %       else (any(possibleMoves==3));
                %         possibleMoves(possibleMoves == 3) = [];
                %       end
                %         nextMove4a = possibleMoves(randperm((length(possibleMoves)),1)) ;
                %     else (nextMove4a==2) || (nextMove4a==4) ;
                %         tentative_nextMove4a = [2 4] ;
                %       if (any(possibleMoves==2));
                %         possibleMoves(possibleMoves == 2) = [];
                %       else (any(possibleMoves==4));
                %         possibleMoves(possibleMoves == 4) = [];
                %       end
                %         nextMove4a = possibleMoves(randperm((length(possibleMoves)),1)) ;
                %     end
                %                 Test_case_3 = nextMove4a ;
            case 4
%                 if x1 >= y1;
%                     if x1a >= 0;
%                         nextMove4a = 3;
%                     else
%                         nextMove4a = 1;
%                     end
%                 else
%                     if y1a >= 0;
%                         nextMove4a = 2;
%                     else
%                         nextMove4a = 4;
%                     end
%                 end
            nextMove4a = enemies(4).possibleMoves ;
            if enemies(4).oldDir == 3;
                opposite_dir = [1];
            elseif enemies(4).oldDir == 1;
                opposite_dir = [3];
            elseif enemies(4).oldDir == 4;
                opposite_dir = [2];
            elseif enemies(4).oldDir == 2;
                opposite_dir = [4];
            end
            nextMove4a = setxor(opposite_dir,nextMove4a);
            nextMove4a = intersect(nextMove4a,enemies(4).possibleMoves);
            idx = randi(length(nextMove4a));
            nextMove4a = nextMove4a(idx(:));
        end
    end
%%
    Pincer_Moves = [0 nextMove4a];
    idx = randi(length(Pincer_Moves)); % random index into x
%     nextMove3a2 = Pincer_Moves(idx);
    nextMove_d3 = nextMove4a;
Heat = 'High Temperature';   
X = ['Red Ghost = ',Heat,', Manhattan distance = ',num2str(distance4)];
% disp(X)
% end
%%  
% node = [nextMove3a_a3];% nextMove3a_a2 nextMove3a_a1] ;
% new_nodes = [nextMove_d1 nextMove_d2] ;
new_nodes = [nextMove_d3] ;
coordinates1 = square1;
for i = 1:numel(new_nodes)
if (new_nodes(i)==1) ;
    coordinates1(1) = coordinates1(1) + 1;
elseif (new_nodes(i)== 3) ;
    coordinates1(1) = coordinates1(1) - 1;
elseif (new_nodes(i)== 4);
    coordinates1(2) = coordinates1(2) + 1;
elseif (new_nodes(i)== 2);
    coordinates1(2) = coordinates1(2) - 1;
else (new_nodes(i)== 0);
    coordinates1(1) = coordinates1(1) ;
end
% if (i == 1) ;
Energy_val_d1 = abs(coordinates1(1)-square2(1)) + abs(coordinates1(2)-square2(2));
% elseif (i == 2) ; 
% Energy_val_d2 = abs(coordinates1(1)-square2(1)) + abs(coordinates1(2)-square2(2));
% % elseif (i == 3) ; 
% % Energy_val_d3 = abs(coordinates1(1)-square2(1)) + abs(coordinates1(2)-square2(2));
% end
% coordinates1 = square1;   %% ADD THIS LINE
end
% del_E43 = distance4 - Energy_val_d3 -0;
% del_E42 = distance4 - Energy_val_d2 +0;
del_E41 = distance4 - Energy_val_d1 +0;

% Energy_val_d = [del_E41 del_E42];
Energy_val_d = [del_E41];
% Energy_val_d 
% random_Gen4 = 0;%(randi([1, 100],1))/100 ;
random_Gen41 = (randi([1, 100],1))/100 ;
test_sigmoid_fun_current4 = sigmoid_fun_current4;
%if random_Gen4 = 0; sigmoid_func = 0.5; rejects bad nodes
%if random_Gen4 = 1; sigmoid_func = 0.5; accepts bad nodes
for i = 1:numel(new_nodes) ;
if (Energy_val_d(i) > 0) ;
    nextMove4 = new_nodes(i);
    flag_a = 1 ;
     % End loop
     if (sigmoid_fun_current4 > random_Gen41); % if (Temperature <= 130);
         nextMove4 = new_nodes(i);
         flag_aa4 = 1 ;
         flag_accept = 'accept';
     else (sigmoid_fun_current4 <= random_Gen41);
         nextMove4 = 0;
         flag_bb4 = 1 ;
         flag_accept = 'reject';
         % idx = find(Energy_val_a == min(Energy_val_a(:)))
         % nextMove1 = node(idx)
     end
else (Energy_val_d(i) <= 0) ;
    flag_b = 1 ;
    if (sigmoid_fun_current4 < random_Gen41) ;
        nextMove4 = 0 ;%nextMove_c; % Reject Generated neighbor and remain stationary
        %         Node_rejection_1 = Node_rejection_1 + 1 ;
        flag_c = 1 ;
        flag_accept = 'reject';
    else (sigmoid_fun_current4 >= random_Gen41) ;
        %         nextMove1 = nextMove_a1;
        %         idx = randi(length(Energy_val_d)) ;
        %         nextMove1 = node(idx(:));
        nextMove4 = new_nodes(i) ; 
         % End loop
        flag_d = 1 ;
        flag_accept = 'accept';
    end
end
    if (nextMove4 ~= 0)
        break
    end
% test_nextMove4 = nextMove4;
end
node_i = i;
%     X4 = ['Yellow Ghost: ','No. of nodes = ',num2str(Energy_val_d), ', node accepted = ',num2str(i)];% ', distance = ',num2str(distance4)];
%     disp(X4)
X4 = ['Yellow Ghost: ','Pr. of Acceptance = ',num2str(sigmoid_fun_current4),' Temperature = ',num2str(Temperature42), ', node = ',num2str(flag_accept)];% ', distance = ',num2str(distance1)];
% disp(X4)
% nextMove4 = nextMove_d3;
% del_E31
% del_E32
% sigmoid_fun_current
%%
    if distance4 == 0 ;
        pack_threshold4 = T1;
    else
        pack_threshold4 = [T1*(rate2)^+t(distance4)]+separation; % Temperature,Low->High % Arbitrary Max distance 50
    end
pack41 = ((position4(1) - position1(1))^2 + (position4(2) - position1(2))^2)^0.5 ; 
pack42 = ((position4(1) - position2(1))^2 + (position4(2) - position2(2))^2)^0.5 ; 
pack43 = ((position4(1) - position3(1))^2 + (position4(2) - position3(2))^2)^0.5 ;
% pack_wolf = pack41 + pack42 + pack43 ;
pack_vec4 = [pack41 pack42 pack43] ;  
    idx = find(pack_vec4==min(pack_vec4));
    if (idx==1);
    square3 = position1;
    elseif (idx==2);
    square3 = position2;
    else (idx==3);
    square3 = position3;
    end
x12 = (abs(square1(1)-square3(1)))/1;
y12 = (abs(square1(2)-square3(2)))/1;
distance42 = x12 + y12; 
if ((pack_threshold4) >= distance42)
% square2 = pack_index1;
x1 = x12;
y1 = y12;
% enemies(4).x1 = x1;
% enemies(4).y1 = y1;
%         distance = x1 + y1
distance42 = x1 + y1; 
% enemies(4).distance4 = distance4;
x1a = (square1(1)-square3(1));
y1a = (square1(2)-square3(2));
% enemies(4).x1a = x1a;
% enemies(4).y1a = y1a;

%         if (x1a < 0)
%             x1_negative = x1a
%         end
if x1 >= y1;
    if x1a >= 0
        nextMove = 3;
    else
        nextMove = 1;
    end
else
    if y1a >= 0;
        nextMove = 2;
    else
        nextMove = 4;
    end
end
    corner = numel(possibleMoves);
    %% Node Selection Start : Completely avoids tunnel's nextMove
    tunnel = intersect(enemies(4).dir,enemies(4).possibleMoves);
    tunnel_out = isempty(tunnel);
%     if (corner==2) & (tunnel_out==0)  ;
%         nextMove = enemies(4).dir;  %      disp('tunnel')
%         % Node Selection End
%     else %any(corner > 1) ;%~any(possibleMoves==enemies(4).dir) && numel(enemies(4).possibleMoves)==numel(enemies(4).possibleMoves);
        total_possibleMoves = numel(enemies(4).possibleMoves) ;
        switch total_possibleMoves
            case 2   % Movement based on abs distance and non abs distance
                nextMove = intersect(nextMove,enemies(4).possibleMoves);
                if isempty(nextMove)  % possibleMoves does not match tentative nextMove
                    if (x1 >= y1) && (x1a>=0) ;
                        tentative_nextMove = [4] ;
                        nextMove = intersect(tentative_nextMove,enemies(4).possibleMoves);
                    elseif (x1 >= y1) && (x1a<=0) ;
                        tentative_nextMove = [2];
                        nextMove = intersect(tentative_nextMove,enemies(4).possibleMoves);
                    elseif (y1 >= x1) && (y1a>=0) ;
                        tentative_nextMove = [3];
                        nextMove = intersect(tentative_nextMove,enemies(4).possibleMoves);
                    else (y1 >= x1) && (y1a<=0) ;
                        tentative_nextMove = [1];
                        nextMove = intersect(tentative_nextMove,enemies(4).possibleMoves);
                    end
                end
                if isempty(nextMove)
                    if (x1 >= y1) && (x1a>=0) ;
                        tentative_nextMove = [2] ;
                        nextMove = intersect(tentative_nextMove,enemies(4).possibleMoves);
                    elseif (x1 >= y1) && (x1a<=0) ;
                        tentative_nextMove = [4];
                        nextMove = intersect(tentative_nextMove,enemies(4).possibleMoves);
                    elseif (y1 >= x1) && (y1a>=0) ;
                        tentative_nextMove = [1];
                        nextMove = intersect(tentative_nextMove,enemies(4).possibleMoves);
                    else (y1 >= x1) && (y1a<=0) ;
                        tentative_nextMove = [3];
                        nextMove = intersect(tentative_nextMove,enemies(4).possibleMoves);
                    end
                end
            case 3
                if x1 > y1 ;
                    if (x1a >= 0);
                        nextMove = 1;
                    else
                        nextMove = 3;
                    end
                    nextMove = intersect(enemies(4).possibleMoves,nextMove);
                    if isempty(nextMove)
                        if (y1a >= 0) ;
                            nextMove = 4;
                        else
                            nextMove = 2;
                        end
                    end
                else y1 > x1 ;
                    if (y1a >= 0);
                        nextMove = 4;
                    else
                        nextMove = 2;
                    end
                    nextMove = intersect(enemies(4).possibleMoves,nextMove);
                    if isempty(nextMove)
                        if (x1a >= 0) ;
                            nextMove = 1;
                        else
                            nextMove = 3;
                        end
                    end
                end
                Number_nextMove = numel(nextMove) ;
                if Number_nextMove > 1
                    if (nextMove == [1 3])
                        if (x1a >= 0)
                            nextMove = 1 ;
                        else
                            nextMove = 3 ;
                        end
                    else (nextMove == [2 4])
                        if (y1a >= 0)
                            nextMove = 4 ;
                        else
                            nextMove = 2 ;
                        end
                    end
                end
        end
%         end
nextMove4 = nextMove ; 
end
%test_nextMove3
end
%%
%%
    function entity = pathWayLogic(entity,speed)
        possibleDirections_minus = allDirections{round(entity.pos(1)-0.45),round(entity.pos(2)-0.45)};
        possibleDirections_plus = allDirections{round(entity.pos(1)+0.45),round(entity.pos(2)+0.45)};
        
        switch entity.dir
            case 0
                entity.oldDir = 1;
            case 1
                if rem(round(entity.pos(2)/speed)*speed,1) == 0 && any(possibleDirections_minus==entity.dir)
                    entity.pos(2) = round(entity.pos(2)/speed)*speed;
                    entity.pos(1) = entity.pos(1)+speed;
                    entity.oldDir = 1;
                elseif entity.oldDir == 2 && any(possibleDirections_plus==entity.oldDir)
                    entity.pos(2) = entity.pos(2)-speed;
                elseif entity.oldDir == 4 && any(possibleDirections_minus==entity.oldDir)
                    entity.pos(2) = entity.pos(2)+speed;
                elseif entity.status > -2
                    entity.pos(2) = entity.pos(2)+speed;
                end
            case 2
                if rem(round(entity.pos(1)/speed)*speed,1) == 0 && any(possibleDirections_plus==entity.dir)
                    entity.pos(1) = round(entity.pos(1)/speed)*speed;
                    entity.pos(2) = entity.pos(2)-speed;
                    entity.oldDir = 2;
                elseif entity.oldDir == 1 && any(possibleDirections_minus==entity.oldDir)
                    entity.pos(1) = entity.pos(1)+speed;
                elseif entity.oldDir == 3 && any(possibleDirections_plus==entity.oldDir)
                    entity.pos(1) = entity.pos(1)-speed;
                elseif entity.status > -2
                    entity.pos(1) = entity.pos(1)-speed;
                end
            case 3
                if rem(round(entity.pos(2)/speed)*speed,1) == 0 && any(possibleDirections_plus==entity.dir)
                    entity.pos(2) = round(entity.pos(2)/speed)*speed;
                    entity.pos(1) = entity.pos(1)-speed;
                    entity.oldDir = 3;
                elseif entity.oldDir == 2 && any(possibleDirections_plus==entity.oldDir)
                    entity.pos(2) = entity.pos(2)-speed;
                elseif entity.oldDir == 4 && any(possibleDirections_minus==entity.oldDir)
                    entity.pos(2) = entity.pos(2)+speed;
                elseif entity.status > -2
                    entity.pos(2) = entity.pos(2)+speed;
                end
            case 4
                if rem(round(entity.pos(1)/speed)*speed,1) == 0 && any(possibleDirections_minus==entity.dir)
                    entity.pos(1) = round(entity.pos(1)/speed)*speed;
                    entity.pos(2) = entity.pos(2)+speed;
                    entity.oldDir = 4;
                elseif entity.oldDir == 1 && any(possibleDirections_minus==entity.oldDir)
                    entity.pos(1) = entity.pos(1)+speed;
                elseif entity.oldDir == 3 && any(possibleDirections_plus==entity.oldDir)
                    entity.pos(1) = entity.pos(1)-speed;
                elseif entity.status > -2
                    entity.pos(1) = entity.pos(1)-speed;
                end
        end
    end
    
    function KeyAction(~,evt)
%         animegraph13
        if strcmp(get(newGameButton,'Visible'),'on')
            newGameButtonFun
        end
        if pacman.dir > 0
            pacman.oldDir = pacman.dir;
        end
        switch evt.Key
            case {'d','rightarrow'}
                pacman.dir = 1;
            case {'s','downarrow'}
                pacman.dir = 2;
            case {'a','leftarrow'}
                pacman.dir = 3;
            case {'w','uparrow'}
                pacman.dir = 4;
        end
%         animegraph13
    end

%% Simulated Annealing Demo - Temperature and its corresponding Sig Func
distance_x = 1:50 ;
% distance_x = fliplr(distance_x) ;
tt = linspace(1,10^3,numel(distance_x));  % t inversely proportional to Temperature, Therefore, Temperature Very Low-> Very High
tt1 = linspace(1,10^3,numel(distance_x));  % t inversely proportional to Temperature, Therefore, Temperature Very Low-> Very High
h = numel(tt) ; %  number of iterations
h = numel(tt1) ; %  number of iterations
T_01 = 10^3;
% for jj = 1:numel(distance)
% % 10^3  = constant ; 0.9915 = theta^(-1) ; ^tt(nnn) = x ; 

for nnn = 1:h ;
Temperature_x1(nnn) = 10^3*((0.9800+0.0000)^+tt(nnn)); % Temperature,Low->High % Arbitrary Max distance 50
end
for nnn = 1:h ;
Temperature_x2(nnn) = 10^3*((0.9800+0.0050)^+tt(nnn)); % Temperature,Low->High % Arbitrary Max distance 50
end
for nnn = 1:h ;
Temperature_x3(nnn) = 10^3*((0.9800+0.0000)^+tt1(nnn)); % Temperature,Low->High % Arbitrary Max distance 50
end
for nnn = 1:h ;
Temperature_x4(nnn) = 10^3*((0.9800+0.0050)^+tt1(nnn)); % Temperature,Low->High % Arbitrary Max distance 50
end
% %  theta1 ~= theta 4 ; theta2, theta3 very high
% %  but typically theta2 >> theat3 ;
% Test_Temperature = Temperature_x' ;
figure
subplot(2,1,1)       % add first plot in 2 x 1 grid
hold on;
plot(1:nnn,Temperature_x1,'-.r*','linewidth',2);
plot(1:nnn,Temperature_x2,'-mo','linewidth',2);
plot(1:nnn,Temperature_x3,':c*','linewidth',2);
plot(1:nnn,Temperature_x4,'-yo','linewidth',2);
title('Monotonically Decreasing Temperature Functions')
ylabel('Temperature')
xlabel('Manhattan Distance')
xlim([1 20]);
ylim([0 1000]);
hold off;
grid on
Test_Temp = 5 ;
% T = 20 ;   
% del = linspace(-20,120,100);   
kkk = numel(distance_x);
% Test_Temperature = 1 ; 
for ii = 1:kkk;
    sigmoid_function_x1(ii) = (1 + exp(-6*((distance_x(ii))/Temperature_x1(ii))))^(-1);
%  Temperature_x(ii)
end
% %  06 = k(+ve constant), 
for ii = 1:kkk;
    sigmoid_function_x2(ii) = (1 + exp(-6*((distance_x(ii))/Temperature_x2(ii))))^(-1);
%  Temperature_x(ii)
end
for ii = 1:kkk;
    sigmoid_function_x3(ii) = (1 + exp(-6*((distance_x(ii))/Temperature_x3(ii))))^(-1) - 0.4 ;
%  Temperature_x(ii)
end
for ii = 1:kkk;
    sigmoid_function_x4(ii) = (1 + exp(-6*((distance_x(ii))/Temperature_x4(ii))))^(-1) - 0.4 ;
%  Temperature_x(ii)
end
% sigmoid_function';
hold on;
threshold1 = 0.40 * ones(1,length(distance_x)); % 0.43,0.4283,0.43,0.5069
threshold2 = 0.50 * ones(1,length(distance_x));
subplot(2,1,2)       % add second plot in 2 x 1 grid
hold on;
plot(1:ii,sigmoid_function_x1,'-.r*','linewidth',2) % probability - y axis;k - x axis; 
plot(1:ii,sigmoid_function_x2,'-mo','linewidth',2) % probability - y axis;k - x axis; 
plot(1:ii,sigmoid_function_x3,':c*','linewidth',2) % probability - y axis;k - x axis; 
plot(1:ii,sigmoid_function_x4,'-yo','linewidth',2) % probability - y axis;k - x axis; 
% plot(1:ii,threshold1,'--','Linewidth',2) 
% plot(1:ii,threshold2,'--','Linewidth',2) 
hold off;
xlim([1 14]);
ylabel('Probability')
title('Sigmoid Function')
xlabel('Manhattan Distance')
ylim([0 1])
grid on
%% Delete all previous output values and save all output as 0. Use debugging in line 815
% delete('out1.mat')
% delete('outout2.mat')
% delete('out3.mat')
% delete('out4.mat')
% delete('out5.mat')
% delete('out6.mat')
% delete('out7.mat')
% delete('out8.mat')
% delete('out9.mat')
% delete('outout10.mat')
% delete('out11.mat')
% delete('out12.mat')
% delete('out13.mat')
% delete('out14.mat')
% delete('out15.mat')
% delete('out16.mat')
% delete('out17.mat')
% delete('out18.mat')
% delete('out19.mat')
% delete('out20.mat')
% delete('dist_vec1.mat')
% d1 = 0; save('out1.mat','d1');
% d2 = 0; save('outout2.mat','d2');
% d3 = 0; save('out3.mat','d3');
% d4 = 0; save('out4.mat','d4');
% d5 = 0; save('out5.mat','d5');
% d6 = 0; save('out6.mat','d6');
% d7 = 0; save('out7.mat','d7');
% d8 = 0; save('out8.mat','d8');
% d9 = 0; save('out9.mat','d9');
% d10 = 0; save('outout10.mat','d10');
% d11 = 0; save('out11.mat','d11');
% d12 = 0; save('out12.mat','d12');
% d13 = 0; save('out13.mat','d13');
% d14 = 0; save('out14.mat','d14');
% d15 = 0; save('out15.mat','d15');
% d16 = 0; save('out16.mat','d16');
% d17 = 0; save('out17.mat','d17');
% d18 = 0; save('out18.mat','d18');
% d19 = 0; save('out19.mat','d19');
% d20 = 0; save('out20.mat','d20');

%%
% save('dist_vec17_1.mat','dist_vec')
% save('dist_vec17_2.mat','dist_vec')
% save('dist_vec17_3.mat','dist_vec')
% save('dist_vec17_4.mat','dist_vec')
% save('dist_vec17_5.mat','dist_vec')
% save('dist_vec17_6.mat','dist_vec')
%%
% save('dist_vec17_1a.mat','dist_vec')
% save('dist_vec17_2a.mat','dist_vec')
% save('dist_vec17_3a.mat','dist_vec')
% save('dist_vec17_4a.mat','dist_vec')
% save('dist_vec17_5a.mat','dist_vec')
%%
    function PacmanCloseFcn
        stop(myTimer)
        delete(myTimer)
        delete(pacman_Fig)
        delete(pacmanGhostCreator_Fig)
    end
end