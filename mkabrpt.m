function [ufk,ubk]= mkabrpt(x,sy)
N=length(x);
ufk=smk(x);
y=flipud(x);
ubk=smk(y);
ubk=-ubk;
ubk=flipud(ubk);

ey=sy+N-1;
htx=[sy:ey];

a=ceil(abs(max([ufk;ubk]))+2);
b=floor(min([ufk;ubk])-1);

if a<5
    a=5
end

if b>-4
    b=-4
end

figure(2)
plot(htx,ufk,'r-','linewidth',1.5);
hold on
plot(htx,ubk,'b-','linewidth',1.5);
plot(htx,1.96*ones(N,1),':','linewidth',1);
axis([sy,ey,b,a]);

legend('UFK统计量','UBK统计量','0.05显著水平');
xlabel('年度','FontName','TimesNewRoman','FontSize',16);
ylabel('统计量','FontName','TimesNewRoman','Fontsize',16);
%grid on
hold on
plot(htx,0*ones(N,1),'-.','linewidth',1);
plot(htx,1.96*ones(N,1),':','linewidth',1);
plot(htx,-1.96*ones(N,1),':','linewidth',1);

