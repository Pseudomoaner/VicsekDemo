%Implementation of the model described in Vicsek et al 1995: Novel Type of Phase Transition in a System of Self-Driven Particles

clear all
close all

addpath(genpath('C:\Users\OliLocal\Google Drive\Twork\Code\Vicsek Model'))

exportSite = 'C:\Users\ph1ojm\Desktop\GayBerneModelTest\Vicsek';

%Parameters of model

%Parameters used in Solon et al (2015) to get travelling bands (Fig. 1)
fieldWidth = 200;
fieldHeight = 25;
v = 0.5;
rho = 1.93;
R = 1;
eta = 0.8*pi;
dt = 1;
timeSteps = 100000;
scale = 1;

fig = figure(1);
fig.Units = 'Normalized';
fig.Position = [0.1,0.3,0.8,0.4];

ax = gca;
ax.XTick = [];
ax.YTick = [];
ax.Box = 'on';

%Initiate model and draw initial state

Field = VicsekField(fieldWidth,fieldHeight,R,dt);
Field = Field.changeRho(rho);
Field.drawFieldFancy(ax);

pause(0.01)

%Update model for the given number of time states and draw each state

for i = 1:timeSteps
    Field = Field.stepModel(eta,v);
    
    Field = Field.setColours('Orientation');
    Field.drawFieldFancy(ax);
    pause(0.01)
    
    export_fig(fullfile(exportSite,sprintf('Frame_%04d.tif',i)))
end