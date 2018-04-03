%% left and right for just ring
figure(1);
hold on;
axis([-1, 1, 0 0.4])



errorbar(-.1,0.2597,0.0199,'LineStyle','None','color',[237,94,252]./255,'linewidth',1.5);%left drag  %wind [14 23]
errorbar(.1,0.2585,0.0121,'LineStyle','None','color',[192,0,0]./255,'linewidth',1.5);%right drag % wind [11 26]

lgd=legend('Drag left $|F_{\perp}|$','Drag right $|F_{\perp}|$');
lgd.Interpreter='latex';
ylabel('Drag Force (N)');
figText(gcf,18);
%% ring drag

% smarticle-inback-leftdrag
0.4495,0.0121 %wind =[11 24] +

% smarticle-inback-rightdrag
0.4401, 0.0294 %wind=[10 24]

% smarticle-infront-leftdrag
0.4089, 0.0215 %wind=[11 24]

% smarticle-infront-rightdrag
0.4415, 0.0122 %wind=[11 24]

figure(2);

hold on;
errorbar(-.1,0.4495,0.0121,'LineStyle','None','color',[237,94,252]./255,'linewidth',1.5);%left back  %wind [14 23]
errorbar(.1,0.4401, 0.0294,'LineStyle','None','color',[192,0,0]./255,'linewidth',1.5);%right back  %wind [14 23]

errorbar(-.2,0.4089, 0.0215,'o','LineStyle','None','color',[237,94,252]./255,'linewidth',1.5);%left front 
errorbar(.2,0.4415, 0.0122,'o','LineStyle','None','color',[192,0,0]./255,'linewidth',1.5);%right front % wind


lgd2=legend('left $|F_{Back\perp}|$','right $|F_{Back\perp}|$',...
    'left $|F_{Front\perp}|$','right $|F_{Front\perp}|$');
lgd2.Interpreter='latex';
ylabel('Drag Force (N)');
figText(gcf,18);
axis([-1, 1, 0 0.6])