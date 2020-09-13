% FINAL PROJECT
% load MSCI indices returns from excel file

filename = 'C:\Users\likeb\Documents\Columbia Documents\Spring 2020\Multi-asset Portfolio Management\Final Project\Final_Project.xlsx';
[data,txt] = xlsread(filename, 'MARKOV_REGIME_SWITCHING_MODEL', 'M2:W498');
returns.header = txt(1,2:end);
returns.dates = txt(3:end,1);
returns.data = data;

windowLength = 36; % length of rolling window for COV estimation
% initialize COV data structure as 3-dim matrix, 3rd dimension is date
COV.header = returns.header; K = numel(COV.header);
COV.dates = returns.dates(windowLength:end); L = length(COV.dates);
COV.data = NaN(K,K,L);
% calculate COV matrix for each month t
for t = windowLength:length(returns.dates)
 RollingWindow = returns.data(t-windowLength+1:t,:);
 [~, ExpCovariance] = ewstats(RollingWindow,1,windowLength);
 COV.data(:,:,t+1-windowLength) = ExpCovariance*12;
end

turbulence(1:L-1) = 0;
for i = 1:L-1
    yt_minus_miu = returns.data(i+windowLength-1,:)-mean(returns.data(i+windowLength-1,:));
    turbulence(i) = yt_minus_miu*(COV.data(:,:,i)^(-1))*yt_minus_miu.';
end

%xlswrite(filename, turbulence.', 'turbulence(t)');

% calculate volatility for unadjusted portfolio holdings

[data2,~] = xlsread(filename, 'factor holdings', "B140:K498");
[data3,~] = xlsread(filename, 'factor holdings', "N140:W498");
weights2 = data2;
weights3 = data3;
[numRows2, ~] = size(data2);
rows2 = min(numRows2, L);
value2(1:rows2) = 0;
for i = 1:rows2
    a = weights2(i,:)*COV.data(:,:,100+i);
    value2(i) = sqrt(a*weights2(i,:).');
end

[numRows3, ~] = size(data3);
rows3 = min(numRows3, L);
value3(1:rows3) = 0;
for j = 1:rows3
    b = weights3(j,:)*COV.data(:,:,100+j);
    value3(j) = sqrt(b*weights3(j,:).');
end

xlswrite(filename, value2.', 'Volatilities1');
xlswrite(filename, value3.', 'Volatilities2');

xlswrite(filename, corrcov(COV.data(:,:,459)), 'Correlation final period1');
xlswrite(filename, corrcov(COV.data(:,:,459)), 'Correlation final period2');