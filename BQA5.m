%computing of the error shift in arithmetic decoding by introducing an
%extra error

close all
clear all,clc
% load data
% format
counts=[20 15 15];
N=5;Fmax=3;midFS=1;
len=200;

start=1;
stop=100000;



for siml=start:stop
    rand('state', randseed);
a=rand('state');
a'
%     clc
%     siml
%     sum(dseq-seq)
    pause(.3)

    
%     close(h);
end