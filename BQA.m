% function code=BQA(seq,leftprb)
%dependant from source model  codes the symbol 0 or 1 according to
%probablity of left symbol

%generate QA sequence and ad noise to it
% clear all,clc
% format
% symbs='01$#';% miws$';eof=#  FS=$
% seq='10101110010101101010110010100101010010101011010111011010101001010101010110101110010101101010110010100101010010101';%0101010';
% sq=[1 0 1 0 1 1 1 0 0 1 0 1 0 1 1 0 1 0 1 0 1 1 0 0 1 0 1 0 0 1 0 1 0 1 0 0 1 0 1 0 1 0 1 1 0 1 0 1 1 1 0 1 1 0 1 0 1 0 1 0 0 1 0 1 0 1];
seq=[3 1 3 1  3 3 3 1 3  1 1 3 1 1  3 3 1 3 1 3 3 1 1 3  1 1 1 3 1  1 3 3 ];
len=length(seq);
counts=[8 2 6];R=[];EOB=0;midFS=1;
N=4;interval=[0 2^N-1] ;flw=0;state=[interval,flw];Fmax=1;lastsym=1;
%make lookup tables for N 
ST=1;
for i=1:len
    %lookup probs table to convert them to determined probs as counts
%     sym_ind=find(symbs==seq(i));%for each symbol in stream finds its number in table
%     [code,state] = sqarithenco(sym_ind, counts,state,N,Fmax);%for each symbol in stream finds its subinterval
%     [code,state] = sqarithencoflush(seq(i),counts,state,N,Fmax,midFS,EOB)
if seq(i)==1
    next=6;
    code=out(ST).sym1;
else
    next=7;
    code=out(ST).sym2;
end

ST=snew(ST,next)

%     [code,state] = qarithenco(seq(i), counts,state,N);%for each symbol in stream finds its subinterval
%     [code,state] = sqarithenco1(sym_ind,lastsym,counts,state,N,Fmax);%for each symbol in stream finds its subinterval
%     lastsym=sym_ind;    
    R=[R code]
end
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
% dseq = qarithdeco(R,counts,N,len)
