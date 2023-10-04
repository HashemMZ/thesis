% function code=BQA(seq,leftprb)
%dependant from source model  codes the symbol 0 or 1 according to
%probablity of left symbol

%generate QA sequence and ad noise to it
clear all,clc
% load data1
% seq=SEQ;
format

% load data
% seq='10101110010010101001010101101011101110110100000000000000100101010101011010111111111111110010100101010010101';%0101010';
% sq=[1 0 1 0 1 1 1 0 0 1 0 1 0 1 1 0 1 0 1 0 1 1 0 0 1 0 1 0 0 1 0 1 0 1 0 0 1 0 1 0 1**** 0 1 1 0 1 0 1 1 1 0 1 1 0 1 0 1 0 1 0 0 1 0 1 0 1];
% seq=[1 1 3 3 1 1 1 3 3 3 1 3 3 1 3 1 1 1 1 3 1 3 1 1 3 1 1 1 1 3 3 1 3 1 3 1 3 3 3 1 3 3 3 3 3 3 3 3 3 3 3 3 3 1 1 1 1 1 1 1 1 1 1 1 3 1 1 3 1 1 1 1 3 1 3 1 3 1 3 1 3 1 3 3 3 1 3 3 1 3 1 1 1 1 1 1 1 1 1 1 1 3 1 3 1 1 1 1 1 1  1 3 3 1 1 1 3 3 3 1 3 3 1 3 1 1 1 3 3 3 3 3 3 3 3 3 3 3 3 3 1 1 1 1 1 1 1 1 1 1 1 3 1 1 3 1 1 1 1 3 1 3 1 3 1 3 1 3 1 3 3 3 1 3 3 1 3 1 1 1 1 1 1 1 1 1 1 1 1 3 1 3 1 1 3 1 1 1 1 3 3 1 3 1 3 1 3 3 3 1 3 3 1 3 1 1 1 1 1 1 1 1 1 1 1 1 3 1 3 1 1 3 1 1 1 1 3  1 1 3 1 3   1 1 3 1 3 3 3 1 3 3 1 3 1 1 1 3 1 3 1 1 3 1 1 1 1 3 1 3 1 3 1 3 1 3 1 1 3 1 3 1 3 1 1 1 3 1 1 3 1 3 1 1 3 1 3 1 3 1 1 1 3 1 1 3 1  3 3 3 3 3 3 ];
% seq=[1 3 1 3 1 3 1 3 1 3 1 3 1 3 1 3 1 1 1 1 3 1 3 1 1 ];
% seq=[1 2 1 2 1 1 1 1 2 1 2 2 2 1 1 1 2 1 2 1 1 2 1 2 1 1 1 2 1 2  1 2 1 2 1 1 2 1 2 2 2 1 1 2 1 2 1 2 2 2 2 2 2 2 2 2 2 2 1 2 1 2 1 2  1 2 1 2 2 1 1 2 1 2 1 2 1 2 1 2 1 2 1 2 2 1 1 1 1 2 2 1 1 1 2 1 2 1 1 ];
seq=randsrc(1,200,[[1 2 3]; [0.5 0 0.5]]) ;
len=length(seq);
% counts=[.15 0.85 ];
counts=[102 76 76;6 2 2;2 6 2; 3 3 4];
% counts=[5 3;3 3;3 3;3 3;4 2];
% P0=[0.6 0.5 0.5 0.5 0.6];
R=[];
N=8;Fmax=3;midFS=1;


R = sqarithencoflushTot(seq, counts(1,:),N,Fmax,midFS);
% Es=1;
% r= awgn(Es*(R*2-1),6,'measured');
% errpoints=find ( (sign(r)+1)/2 ~= R )
% errate=length(errpoints)/length(r)
% n=length(r);
% error=zeros(1,n);error(errpoints)=1;
% % stem(1:n,error)
% stem((R*2-1))
% hold on;
% plot(r,'r')
% dseq = sqarithdeco(R,counts,N,2,len),seq-dseq-1
% dseq = qarithdeco(R,counts(1,:),N,len)
% dseq =sqarithdeco4(R,counts(1,:),N,Fmax,len)
% dseq =tqarithdeco(R,N,len)
R(100)=~R(100);
 dseq = sqarithdecoflush(R,counts(1,:),N,Fmax,len,midFS);
seq,
% dseq-seq
sum(dseq-seq~=0)