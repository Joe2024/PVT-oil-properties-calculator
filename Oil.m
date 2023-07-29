%%%%%%%%%%%%%%%%%%%%%%%Density:
%Train
u1=[petrol(1:72,1),petrol(1:72,3:7)];
y1=[petrol(1:72,29)];
%Test
u2=[petrol(137:152,1),petrol(137:152,3:7)];
y2=petrol(137:152,29);
%Validate=121:136
in =[petrol(153:168,1),petrol(153:168,3:7)];
%in=[petrol(153:168,1),petrol(153:168,4:7)];
out= petrol(153:168,29);

dataC=iddata(y2,u2,1);
dataV=iddata(out,in,1);
dataT=iddata(y1,u1,1);
tic
Model = nlarx(dataT,[1  [1 1 1 1 1 1]  [0 0 0 0 0 0]],'wavenet');
toc
compare (dataT, Model)
figure
compare (dataC, Model)
figure
compare (dataV, Model)

% Model=Density8;
x0 = findstates(Model,[y2 u2],[],'sim');
XX = iddata([],in,1);
tic
Mout=sim(Model,XX,x0);
toc
mout=Mout.OutputData;

yout(1,:)=[];
er=yout(:,1)-yout(:,2)

%% %%%%%%%%%%%%%%%%%%%%%%%%%BO:
%train
u1=[petrol(1:152,1:7);petrol(161:end,1:7)];
y1=[petrol(1:152,27);petrol(161:end,27)];
%Test
u2=petrol(153:160,1:7);
y2=petrol(153:160,27);
% %Validate=153:168
% in =petrol(153:168,1:7);
% out= petrol(153:168,27);

dataC=iddata(y2,u2,1);
% dataV=iddata(out,in,1);
dataT=iddata(y1,u1,1);
tic
Model =nlhw(dataT,[[1 1 1 1 1 1 1] [3 3 3 3 3 3 3] [0 0 0 0 0 0 0]],poly1d(2),poly1d(1));
toc
compare (dataT, Model)
figure
compare (dataC, Model);
% figure
% compare (dataV, Model)

% Model=BO6;
% x0 = findstates(Model,[y1(136-7:136,:) u2]);
x0 = findop(Model,'steady',u2(2,:),NaN);
% x0 = findop(Model,'snapshot',8,u2,x0);
XX = iddata([],u2,1);
tic
Mout=sim(Model,XX,'InitialState',x0);
toc
mout=Mout.OutputData;

%% %%%%%%%%%%%%%%%%%%%%%%%%CO:
%train
u1=petrol(1:136,1:26);
y1=petrol(1:136,28);
%Test
u2=petrol(137:152,1:26);
y2=petrol(137:152,28);
%Validate=121:136!
%Validate:[petrol(1:120,1:7),petrol(1:120,10:11),petrol(1:120,13:14),petrol(1:120,16),petrol(1:120,17:26)]
%Test:[petrol(121:128,1:7),petrol(121:128,10:11),petrol(121:128,13:14),petrol(121:128,16),petrol(121:128,17:26)]
%Test6:[petrol(121:128,1:7),petrol(121:128,10:14),petrol(121:128,16),petrol(121:128,19),petrol(121:128,22:23),petrol(121:128,25)]

%Validate=153:168
in = petrol(153:168,1:7);
out= petrol(153:168,28);

Model=CO17;
x0 = findstates(Model,[out in]);
XX = iddata(out,in,1);
Mout=sim(Model,XX,x0);
mout=Mout.OutputData;

er8=CO(:,1)-CO(:,2);
%%%%%%%%%%%%%%%%%%%%%%%%%Viscosity:
in = viscos(121:128,1:7);
out= viscos(121:128,11);

x0 = findstates(VIS2,[out in]);
XX = iddata(out,in,1);
Mout=sim(Model,XX,x0);
mout=Mout.OutputData;

yout(9,:)=[];

%%%%%%%%%%%%%%%%%%%%%%%%Error
for i=1:24
    er=((Viscosity(i,1)-Viscosity(i,2))/Viscosity(i,2))*100;
    eror(i)=er;
end
eror=eror';

sigma=0;
for i=1:24
    er=abs((yout(i,2)-yout(i,1))/yout(i,2));
    sigma=sigma+er;
    error=sigma*(100/24);
end

ma=0;
for i=1:16
    m=abs((petrol(120+i,27)-error(i,2))/petrol(120+i,27));
    ma=ma+m;
    mae=(100/16)*ma;
end

na=0;
for i=1:16
    n=(petrol(120+i,27)-error(i,2))^2;
    na=na+n;
    nae=(1/16)*na;
end

%% NewData
% Order of data= Temp | Rsi | API | Gas gravity | OFVF(Bo) | Pb

% Data cited in Table5 of Ghiasi's paper for comparison:
% Row= 5|662|416|121|486|117|530|65|295|329|422|381|250|110|106|354|361|213|102|605|492|603|699|180|203


u1=TData(:,1:4);
y1=TData(:,6);

% u2=[dtrend(NewData(:,1)),dtrend(NewData(:,2)),dtrend(NewData(:,3)),NewData(:,4)];
u2=VData(:,1:4);
y2=VData(:,6);

u3=NewData(:,1:4);
y3=NewData(:,6);


Model=nlarx22;
x0 = findstates(Model,[y3 u3],[],'prediction'); %NARX
% x0 = findstates(Model,[y3 u3]); %HW
% x0 = findop(Model,'steady',u2(1,:),y2(1)); %HW
% Row=1:end;
XX = iddata([],u3,1);
tic
Mout=sim(Model,XX,x0);
toc
mout=Mout.OutputData;
out=y3;

[n,~]=size(out);
ARD=0;
for i=1:n
    ARD=ARD+((out(i)-mout(i))/out(i));
end
ARD=ARD*(100/n)

AARD=0;
for i=1:n
    AARD=AARD+abs(((out(i)-mout(i))/out(i)));
end
AARD=AARD*(100/n)

% ARD=((out-mout)/out)*100

% Selected model: nlhw6 nlhw10 nlhw11 nlhw12



% % Separating 604 data for training and 151 data for validation
% [n,~]=size(NewData);
% z=1; y=0;
% TData=zeros(604,6);
% VData=zeros(151,6);
% for i=4:5:n;
%     if i==4
%          TData(1:3,:)=NewData(i-3:i-1,:);
%     else TData(y:y+3,:)=NewData(i-4:i-1,:);
%     end
%     VData(z,:)=NewData(i,:);
%     z=z+1;
%     y=y+4;
%     if i==754
%         TData(y,:)=NewData(end,:);
%     end
% end
% clear n z y i


