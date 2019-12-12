%% add necessary paths
addpath('../');

% add OPC to path
opc_path = '/home/hankui/Downloads/MATLAB_OPC';
addpath(genpath(opc_path));

% path to my routine MAC
mac_path = '/home/hankui/Dropbox/Clustering/WorkLog/By_Language/MATLAB/Minimum_Angle_Clustering_MAC';
addpath(genpath(mac_path));

% add MyToolBox to path
mytools = '/home/hankui/Dropbox/Clustering/WorkLog/By_Language/MATLAB/0_MyToolBox';
addpath(genpath(mytools));

% path to LRR code
lrr_path = '/home/hankui/Dropbox/Clustering/WorkLog/By_Language/MATLAB/Low_Rank_Representation_LRR';
addpath(genpath(lrr_path));

% path to SSC code
ssc_path = '/home/hankui/Dropbox/Clustering/WorkLog/By_Language/MATLAB/Sparse Subspace Clustering_SSC';
addpath(genpath(ssc_path));

%path to K-Subspaces code
ksub_path = '/home/hankui/Dropbox/Clustering/WorkLog/By_Language/MATLAB/K-Subspaces';
addpath(genpath(ksub_path));

% path to SCAL code
scal_path = '/home/hankui/Dropbox/Clustering/WorkLog/By_Algorithm/SCAL';
addpath(genpath(scal_path))

clear opc_path mac_path mytools lrr_path ssc_path ksub_path scal_path


%% borrow the data example from Illustrative_ex.m
x = .01*(-100:100);
x = [x(1:100), x(102:201)];
N = size(x,2);

S1 = 5*x + 2;
noise1 = 5.*rand(1, N);
S1n = S1 + noise1;
X1 = [x;S1n]';

S2 = -10*x - 2;
X2 = [x;S2]';

X = [X1;X2];
K = 2;
truth = [ones(1,N) 2.*ones(1,N)]';

clear x X1 X2 S1 S2 S1n noise1


%% alternative data generation
%[X truth] = DataSimulation_v1(200, 2, 10);
[X truth] = DataSimulation(.2,2);


%% initial parameters
K = 2; 
pct = 0.9; 
T = 10;
b = 5;
N = size(X,1);
mem = round(rand(1,N)*K + 0.5)';


%% AL framework
mem0 = round(rand(1,N)*K + 0.5)';
mem = zeros(N,1);
if mode(mem0(1:201)) ~= 1
    mem(mem0==2) = 1;
    mem(mem0==1) = 2;
else
    mem = mem0;
end

[asmt tot_re nmi] = KSCAL(X,2,.9,mem,50,1,truth);
plot(decimal(nmi,2))


%% plot the curve with different b
T = 10;
mem = round(rand(1,N)*K + 0.5)';

[asmt tot_re nmi1] = KSCAL_v3(X,K,.8,mem,T,1,truth);
[asmt tot_re nmi5] = KSCAL_v3(X,K,.8,mem,T,5,truth);
[asmt tot_re nmi10] = KSCAL_v3(X,K,.8,mem,T,10,truth);


%% plot against iterations 
plot(decimal(nmi1,2))
hold on
plot(decimal(nmi5,2))
hold on
plot(decimal(nmi10,2))
xlabel('Iterations') 
ylabel('NMI') 
legend({'b = 1','b = 5', 'b = 10'},'Location','southeast')
hold off


%% plot against no. of questions asked
questions = 500;

curve1 = [decimal(nmi1,2), ones(1,450)]';

curve2 = zeros(questions,1);
for i = 1:(T-1)
    curve2(5*i+1:5*i+5) = nmi5(i);
end
curve2(5*T+1:questions) = 1;

curve3 = zeros(questions,1);
for i = 1:(T-1)
    curve3(10*i+1:10*i+10) = nmi10(i);
end

% plot against number of questions asked
plot(decimal(curve1,2))
hold on
plot(decimal(curve2,2))
hold on
plot(decimal(curve3,2))
hold on
xlabel('No. of questions asked') 
ylabel('NMI') 
legend({'b = 1','b = 5', 'b = 10'},'Location','southeast')
hold off


%% plot against proportion of points queried
xaxis = (0.01:0.01:1)';
nmi_b1 = zeros(size(xaxis,1),1);
nmi_b5 = zeros(size(xaxis,1),1);
nmi_b10 = zeros(size(xaxis,1),1);

for i=1:size(xaxis,1)
    n_i = round(N*xaxis(i));
    nmi_b1(i) = nmi1(n_i);
    nmi_b5(i) = nmi5(floor(n_i/5)+1);
    nmi_b10(i) = nmi10(floor(n_i/10)+1);
end


%
plot(xaxis,nmi_b1)
hold on
plot(xaxis,nmi_b5)
hold on
plot(xaxis,nmi_b10)
xlabel('Pct. of queried data objects') 
ylabel('NMI') 
legend({'b = 1','b = 5', 'b = 10'},'Location','southeast')
hold off