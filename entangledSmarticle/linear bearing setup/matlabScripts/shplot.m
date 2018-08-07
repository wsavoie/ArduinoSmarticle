function H = shplot(x,y,e,varargin)
%% shplot(x,y,e,opt,varargin)
% Striped down version of shplot
% Based on a code by Rob Campbell
% Written by Marcin Konowalczyk
% Timmel Group @ Oxford University

x = x(:); y = y(:);
isheld = ishold; if ~isheld; cla; hold on; end;
H.main_line = plot(x,y,varargin{:});

eu = y + e; el = y - e;
col = 0.15*get(H.main_line,'color') + 0.85; ecol = 3*col-2;
set(gcf,'renderer','painters');
H.patch = patch([x ;flipud(x)],[el ;flipud(eu)],1,'facecolor',col,'edgecolor','none','facealpha',1);
H.edge_u = plot(x,eu,'-','color',ecol);
H.edge_l = plot(x,el,'-','color',ecol);

uistack(H.main_line,'top');
if ~isheld; hold off; end;
end