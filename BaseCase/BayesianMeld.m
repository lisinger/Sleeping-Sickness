%% Load parameter samples
% Par = [];
% Lik = [];
% N = 10  % No of independent sample runs that I ran
% for i = 1:N
%     filename = sprintf('Sample%d.mat',i);
%     load(filename)
%     Par = vertcat(Par,params);
%     Lik = horzcat(Lik,Likelihood);
% end

load Sample
Lik = Likelihood;
Par = params;
M = length(Lik) % Total sample size
Data = [3,2,9.53;
        4,8, 0  ;
        7,13,0  ;
        3,4, 0 ];
SampSize = [1488,1488,1634;
            4514,4514,0;
            7708,7708,0;
            7788,7788,0];

%% Calculate 95% CI for data points
bnds1 = []; bnds2 = [];
for i = 1:4
    bnds1 = vertcat(bnds1,quantile(betarnd(Data(i,1),SampSize(i,1),10000,1), ...
                    [0.025,0.975]));
    bnds2 = vertcat(bnds2,quantile(betarnd(Data(i,2),SampSize(i,2),10000,1), ...
                    [0.025,0.975]));
end

bnds1 = abs(repmat(Data(:,1)./SampSize(:,1),1,2)-bnds1)
bnds2 = abs(repmat(Data(:,2)./SampSize(:,2),1,2)-bnds2)


%% Calculate Weights and discard zero Likelihood parameters
parfor i = 1:M
    weights(i) = Lik(i)/sum(Lik);
end

nonzeroind  = find(Lik ~=0);
SampleSize = length(nonzeroind)
parfor i = 1:length(nonzeroind)
    out = runHATmodel(Par(nonzeroind(i),:));
    A(i,:) = out{1};
    P(i,:) = out{2};
end
Lik = Lik(nonzeroind);
weights = weights(nonzeroind);
Par  = Par(nonzeroind,:);
length(Par)

% find maximum likelihood
%[a,b] = max(Lik);

%% Plots
% plot prevalences
% t = 1:4;
% fig1 = figure;
% subplot(1,2,1)
% plot(t,A(:,1:4));
% hold on;
% plot(t,A(b,1:4),'k','linewidth',2);
% errorbar(t,Data(:,1)./SampSize(:,1), bnds1(:,1),bnds1(:,2),'ko','linewidth',2)
% hold off;
% title('Stage I')
% ax = gca;
% ax.XTick = [1,2,3,4]
% ax.XTickLabel = {'2008', '2010','2012',' 2013'}
% subplot(1,2,2)
% plot(t,A(:,5:8));
% hold on;
% plot(t,A(b,5:8),'k','linewidth',2);
% errorbar(t,Data(:,2)./SampSize(:,2), bnds2(:,1),bnds2(:,2),'ko','linewidth',2)
% hold off;
% title('Stage II')
% ax = gca;
% ax.XTick = [1,2,3,4]
% ax.XTickLabel = {'2008', '2010','2012',' 2013'}

% fig2 = figure;
% scatter(A(:,9))
% title('Vector Prevalence (2008)')


% plot within confidence interval for year 2012 as well.
j = 1;
for i = 1:length(A)
    if A(i,4) >= 0.0001351 & A(i,4) <= 0.0008 & A(i,8) >= 0.0001433  & A(i,8) <= 0.0011117
        B(j,:) = A(i,:);
        out = A(i,:);
        Q(j,:) = P(i,:);
        L(j) = betapdf(out(1),Data(1,1),SampSize(1,1))* ...
               betapdf(out(4),Data(4,1),SampSize(4,1))*...
               betapdf(out(5),Data(1,2),SampSize(1,2))* ...
               betapdf(out(8),Data(4,2),SampSize(4,2));% ...
                                                       %               betapdf(out(9),Data(1,3),SampSize(1,3));
        % recalculating likelihood based on only 2 years
        j = j+1;
    end
end
save('initconds','B','Q');
[a,b] = max(L);

t = 1:4;
fig1 = figure;
subplot(1,2,1)
%Colorset = varycolor(1000);
%set(gca,'ColorOrder',Colorset)
%hold all
plot(t,B(:,1:4),'Color',[0.8,0.8,0.8]);
hold on;
plot(t,B(b,1:4),'r','linewidth',1);
errorbar(t,Data(:,1)./SampSize(:,1), bnds1(:,1),bnds1(:,2),'ko','linewidth',1.5)
hold off;
title('Stage I')
ax = gca;
ax.XTick = [1,2,3,4]
ax.XTickLabel = {'2008', '2010','2012',' 2013'}
subplot(1,2,2)
plot(t,B(:,5:8),'Color',[0.8,0.8,0.8]);
hold on;
plot(t,A(b,5:8),'r','linewidth',1);
errorbar(t,Data(:,2)./SampSize(:,2), bnds2(:,1),bnds2(:,2),'ko','linewidth',1.5)
hold off;
title('Stage II')
ax = gca;
ax.XTick = [1,2,3,4]
ax.XTickLabel = {'2008', '2010','2012',' 2013'}




% plot total prevalences
% Calculate Error bar for total prevalences
% bnds = [];
% for i = 1:4
%     bnds = vertcat(bnds,quantile(betarnd((Data(i,1)+Data(i,2)),SampSize(i,1),10000,1), ...
%                     [0.025,0.975]));
% end

% bnds = abs(repmat((Data(:,1)+Data(:,2))./SampSize(:,1),1,2)-bnds1)

% plot(t,B(:,1:4)+B(:,5:8),'Color',[0.8,0.8,0.8]);
% hold on;
% errorbar(t,(Data(:,1)+Data(:,2))./SampSize(:,1), bnds(:,1),bnds(:,2),'ko','linewidth',2)
% hold off;



%% Re-sampling based on weights (melding)
% % Posterior
% total = 200;

% j = 1;
% while j < total+1
%     k =randi(length(weights),1);
%     if(rand <weights(k))
%     param = Par(k,:);
%     A(j,:) = runHATmodel(param);
%     posterior(j,:)=param;
%      j = j+1;
%     end
% end

% % Posterior fits
% parfor i = 1:total
%     out = runHATmodel(posterior(i,:));
%     A(i,:) = out;
% end


% % Plot posterior

% fig3 = figure;
% for i = 1:4
%     subplot(2,2,i)
%     hist(posterior(:,i),20)
% end
