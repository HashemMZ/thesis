Rate=[];
len=100;
for i=1:10000
    seq=randsrc(1,len,[1 3;counts(1,[1 3])./sum(counts(1,[1 3]))]);%seq=randsrc(1,blklen,[[1 2]; prbs]) ;
   [R,ST]=QAtblTrl(seq,trellis,N);
   Rate(i)=len/length(R);
   mean(Rate)
%     clc
%     i
    pause(.0001)
end