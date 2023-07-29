%% Best models
%-------------Density
% selected=ro_fis3
% Best model: clust='auto'&Iter=98&epoch=15
% Best model: clust=10&Iter=100&epoch=15
% Best model: clust=12&Iter=91&epoch=20

%-------------Bo
% inmftype=char('trimf','trimf','trimf','trimf','trimf','trimf','trimf');
% outmftype=('constant');
% inmftype=char('trimf','trimf','gaussmf','trimf','trimf','trimf','trimf');
% inmftype=char('trimf','trimf','gaussmf','gaussmf','trimf','trimf','trimf');
% inmftype=char('trimf','trimf','pimf','trimf','trimf','trimf','trimf');
% inmftype=char('trimf','trimf','gbellmf','trimf','trimf','gbellmf','trimf');
% inmftype=char('psigmf','psigmf','psigmf','psigmf','psigmf','trimf','psigmf');
%% Density:
%Train
u1=[petrol(1:24,1),petrol(1:24,3:7)];
y1=petrol(1:24,29);
%Test
u2=[petrol(137:152,1),petrol(137:152,3:7)];
y2=petrol(137:152,29);
%Validate=121:136
in = [petrol(153:168,1),petrol(153:168,3:7)];
%in=[petrol(153:168,1),petrol(153:168,4:7)];
out= petrol(153:168,29);

% sugeno,in=(1,3:7)

%% BO:
%train
u1=petrol(1:32,1:7);
y1=petrol(1:32,27);
%Test
u2=petrol(137:152,1:7);
y2=petrol(137:152,27);
%Validate=153:168
in = petrol(153:168,1:7);
out= petrol(153:168,27);

%% Pb:
%train
u1=TData(:,1:4);
y1=TData(:,6);
%Test
u2=VData(:,1:4);
y2=VData(:,6);
%Validate
in=NewData(:,1:4);
out=NewData(:,6);

%% ANFIS
%--train data
trnData=[u1,y1];
% avg1=mean(y1);
[n,~]=size(trnData);

x1=trnData(:,1:end-1);
y1=trnData(:,end);

%--checking data set for overfitting model validation
chkData=[u2,y2];
% avg2=mean(y2);
[n2,~]=size(chkData);

x2=chkData(:,1:end-1);
y2=chkData(:,end);
%If you use chkData, you must also supply chkFis and chkErr

%--building FIS
% numMFs = [2 2 2 2];
% mfType = 'gaussmf';
% %gaussmf|gbellmf|trimf|pimf|trapmf|psigmf|dsigmf|zmf|smf|sigmf
% outmftype= ('linear');  %linear or constant
% in_fis = genfis1(trnData,numMFs,mfType,outmftype);

numMFs = [2 2 2 2];
inmftype = char('dsigmf','dsigmf','dsigmf','dsigmf');
%gaussmf|gbellmf|trimf|pimf|trapmf|psigmf|dsigmf
outmftype= ('linear');  %linear or constant
in_fis = genfis1(trnData,numMFs,inmftype,outmftype);

% radii = [0.1 0.1 0.1 0.1 0.1];
% in_fis = genfis2(x1,y1,radii);
% %radii specifies that the ranges of influence in each columns of data
% %if IN has two columns and out has one column->radii = [0.5 0.4 0.3]

% cluster_n='auto'; %='auto' best=10,11,12,13,14
% fcmoptions=[nan;nan;nan;1];
% %options(1): Exponent for the partition matrix U. Default: 2.0.
% %options(2): Maximum number of iterations. Default: 100.
% %options(3): Minimum amount of improvement. Default: 1e-5.
% %options(4): Information displayed during iteration. Default: 1.
% in_fis = genfis3(x1,y1,'sugeno',cluster_n,fcmoptions);
% %type is either 'mamdani' or 'sugeno'

%--train options
trnOpt=[20 0 0.01 0.9 1.1];
% trnOpt(1): training epoch number (default: 10)
% trnOpt(2): training error goal (default: 0)
% trnOpt(3): initial step size (default: 0.01)
% trnOpt(4): step size decrease rate (default: 0.9)
% trnOpt(5): step size increase rate (default: 1.1)

%--display options
dispOpt=[1 1 1 1];
% dispOpt(1): ANFIS information, such as numbers of input and output membership functions, and so on (default: 1)
% dispOpt(2): error (default: 1)
% dispOpt(3): step size at each parameter update (default: 1)
% dispOpt(4): final results (default: 1)

%--optional optimization method
optMethod=1;
% The default method is the hybrid method = 1
% either 1 for the hybrid method or 0 for the backpropagation method

%--estimate ANFIS output
[ofis,~,~,chkFis,~]=anfis(trnData,in_fis,trnOpt,dispOpt,chkData,optMethod);

figure;
s(1) = subplot(3,1,1); 
s(2) = subplot(3,1,2);
s(3) = subplot(3,1,3);
plot(s(1),1:size(y1,1),y1,1:size(y1,1),evalfis(x1,ofis),'LineWidth',1); grid on; legend('real','model');
plot(s(2),1:size(y2,1),y2,1:size(y2,1),evalfis(x2,ofis),'LineWidth',1); grid on; legend('real','model');

mout=evalfis(in,ofis);

plot(s(3),1:size(out,1),out,1:size(out,1),mout,'LineWidth',1); grid on; legend('real','model');
% plot(s(3),1:size(out,1),mout-out); grid on;

% mout(:,2)=mout(:,1)-out;
z6=(1/n)*(sum(mout(:,1)));
r2=corr(out,mout(:,1))^2
R2=1-((sum((out-mout(:,1)).^2))/(sum((out-z6).^2)))

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

