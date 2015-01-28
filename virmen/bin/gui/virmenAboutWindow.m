function virmenAboutWindow

fig = figure;
scr = get(0,'screensize');
wd = 500;
hg = 300;
set(fig,'position',[scr(3)/2-wd/2 scr(4)/2-hg/2 wd hg],'resize','off', ...
    'menubar','none','name','About ViRMEn','numbertitle','off');

txt = text(0,1,'{\color{red}{\bfVi}}rtual {\color{red}{\bfR}}eality {\color{red}{\bfM}}atlab {\color{red}{\bfEn}}gine');
set(txt,'horizontalalignment','center','verticalalignment','top','fontsize',20);

txt = text(0,.6,'by Dmitriy Aronov, 2011');
set(txt,'horizontalalignment','center','verticalalignment','middle','fontsize',12);

mfile = mfilename('fullpath');
path = fileparts(mfile);
load([path filesep 'virmenVersion.mat']);
txt = text(0,.4,['{\bfCurrent version:} ' str]);
set(txt,'horizontalalignment','center','verticalalignment','middle','fontsize',12);

global versionText

versionText = text(0,.2,'{\bfLatest available version:} \color[rgb]{.5 .5 .5}[click to check]');
set(versionText,'horizontalalignment','center','verticalalignment','middle','fontsize',12, ...
    'buttondownfcn',@checkVersion);

uicontrol('style','pushbutton','units','normalized', ...
    'position',[.3 .05 .4 .1],'string','Update ViRMEn...','callback',@updateVirmen);

xlim([-1 1]);
ylim([0 1]);
axis off

function checkVersion(varargin)

global versionText

if ~ishandle(versionText)
    return
end

set(versionText,'string','{\bfLatest available version:} \color[rgb]{.5 .5 .5}[checking...]');
drawnow
[str status] = urlread('https://www.dropbox.com/sh/gtxdb8oronlucoa/JP1-GVL6vD/ViRMEN.zip');
set(versionText,'string','{\bfLatest available version:} \color[rgb]{.5 .5 .5}[click to check]');

if status == 0
    errordlg('Could not connect to the ViRMEn website','Error');
    return
end

f = strfind(str,'ago');
g = strfind(str,'>');
g = g(g<f);
str = str(g(end)+1:f-1);

f = strfind(str,' ');
num = str2double(str(1:f(1)-1));

units = {'s','mi','h','d','w','mo','y'};
values = [1/(24*60*60),1/(24*60),1/24,1,7,30,365];

val = 0;
for ndx = 1:length(units)
    if strcmpi(str(f(1)+1:f(1)+length(units{ndx})),units{ndx})
        val = values(ndx);
    end
end
val = val*num;

dt = datestr(now-val,'dd-mmm-yyyy');
set(versionText,'string',['{\bfLatest available version:} ' dt]);

function updateVirmen(varargin)

web('https://www.dropbox.com/sh/gtxdb8oronlucoa/JP1-GVL6vD/ViRMEN.zip?dl=1');