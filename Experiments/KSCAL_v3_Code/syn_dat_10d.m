%% data generation, [X truth] = DataSimulation_v1(n, K, P)
[X truth] = DataSimulation_v1(200, 2, 10);
N = size(X,1);
K = 2;


%% plot the curve with different b
T = 100;
mem = round(rand(1,N)*K + 0.5)';

[asmt tot_re nmi1] = KSCAL_v2(X,K,.8,mem,T,1,truth);
[asmt tot_re nmi5] = KSCAL_v2(X,K,.8,mem,T,5,truth);
[asmt tot_re nmi10] = KSCAL_v2(X,K,.8,mem,T,10,truth);


% plot against iterations 
plot(decimal(nmi1,2))
hold on
plot(decimal(nmi5,2))
hold on
plot(decimal(nmi10,2))
xlabel('Iterations') 
ylabel('NMI') 
legend({'b = 1','b = 5', 'b = 10'},'Location','southeast')
hold off


%% plot against proportion of queried points
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


%%
plot(xaxis,nmi_b1)
hold on
plot(xaxis,nmi_b5)
hold on
plot(xaxis,nmi_b10)
xlabel('Pct. of queried data objects') 
ylabel('NMI') 
legend({'b = 1','b = 5', 'b = 10'},'Location','southeast')
hold off