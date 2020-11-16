%%
clear all
clc
%% Read the file that have the time series backscattering coefficient for each wind turbines
data = csvread('BS.csv');
time = data(:,1)
tt=[];
for m=2:7113
    value = data(:,m)
    [ z, sl, lcl, ucl ] = mk( value )
    % where z = Mann-Kendall Statistic
    % sl = Sen's Slope Estimate
    % lcl = Lower Confidence Limit of sl
    % ucl = Upper Confidence Limit of sl
    [ufk,ubk]= mkabrpt(value,1)
    c=[time,ufk,ubk]
    [M,I]=min(abs(ufk-ubk));
    t=time(I)
    tt=[tt,t]
end