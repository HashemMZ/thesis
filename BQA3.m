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
rand('state', randseed);


for siml=start:stop
    
    R=[];
    seq=randsrc(1,len,[1 3;counts(1,[1 3])./sum(counts(1,[1 3]))]);
    R = sqarithencoflushTot(seq, counts(1,:),N,Fmax,midFS);
    X=randsrc(1,1,30:length(R)-30);
%     check=R;
    R(X)=~R(X);
    [dseq bitclk]= sqarithdecoflush(R,counts(1,:),N,Fmax,len,midFS);
    if(dseq~=seq)
        disp('failure')
    end
    clc
    siml
%     sum(dseq-seq)
    pause(.000001)

    
%     close(h);
end