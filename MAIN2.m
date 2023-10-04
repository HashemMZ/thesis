%MAIN
%--------------------------------------------------------------------------
%1 decode with SIMPLE viterbi decoder
%2 decode resulted path by AC
%3 if no error occurs go to 1
%4 else estimate error loc's with the path and tell all of them to LIST viterbi
%5 decode the list of stream by QAC decoder each one at a time until decoding success
%6 if no success take the best path's error candidates


clear all

while 1
      clc
      reply = input('Do you want continue last simulation? y/n [y]: ', 's');
      if isempty(reply) || reply=='y'
            eval( ['load F:\HD1\loader ']);         
            strt=siml+1;
            stp=siml+3000;
            break
      elseif reply == 'n';
            strt=input('start? ');
            stp=input('stop? ');
            param=input('param? '); 
            every=input('every? '); 
            cBlk=0;cBit=0;eBlk=0;eBit=0;PER=0;BER=0;           
            break
      end
end

eval( ['load F:\HD',int2str(param),'\est',int2str(param)']);
eval( ['load F:\HD',int2str(param),'\enctbl',int2str(param)']);

% load est1;
% load rate4_5;
% load rate8_9;

run trelo
len=100;snr=1;

strt=1;
stp=100000;
t=zeros(1,stp-strt+1);
% load data2
% shP=shP+1;shN=shN+1;shZ=shZ+1;%some points have no occurance (zero) so to avoid zero results in production we add by 1
for siml=strt:stp
    disp(['simulation: ',num2str(siml)])
    tic
    R=[];   
    seq=randsrc(1,len,[1 3;counts(1,[1 3])./sum(counts(1,[1 3]))]);%seq=randsrc(1,blklen,[[1 2]; prbs]) ;   
    [R,ST]=QAtblTrl(seq,trellis,N);    
    code= awgn(R*2-1,snr,'measured');
    rsrvCode=code;
    r_hrd=(sign(code)+1)/2;
    errpoints=find ( r_hrd ~= R )
    lenC=length(code)+1;%Viterbi needs

    %88888888888888888888888888888888888888888% Simple Viterbi
    L=1;notLflag=1;
    run vitSoft       
    bestseq=s_info(ind(1),lenC).path(in).dec;
    [dseq bitclk]= sqarithdecoflush(bestseq,counts,N,Fmax,len,1);
    D=bitclk(find(dseq==2,1,'first'));%edl
    if isempty(D)
        cBlk=cBlk+1;%add correct
        cBit=cBit+lenC-1;
        PER=eBlk/(eBlk+cBlk)
        BER=eBit/(eBit+cBit)
        t(siml) = toc;
        continue
    end
    %%

    %888888888888888888888888888888888888888%Run error candidates
    run errCandidates% I is the vector of 10 err candidates
    code=rsrvCode;
    code(D-I+1)=-(1+B).*code(D-I+1);
    %%

    %88888888888888888888888888888888888888888888888888888888888888888888888888%Iterative process
    cnt=1;OK=0;L=10;notLflag=0;
    while cnt<=4 || OK
        disp(['Iteration: ',num2str(cnt)])
        %888888888888888888888888888888888888 LVD & error loc estimate
        OK=0;
        run vitSoft
        pnt=[];pr=[];
        for No=1:length(highcost)%
            disp(['path No: ',num2str(No)])
            [dseq bitclk]= sqarithdecoflush(s_info(highcost(No),lenC).path(1).dec,counts,N,Fmax,len,midFS);
            D=bitclk(find(dseq==2,1,'first'));%edl
            if isempty(D)
                OK=1;                
                break
            end
            %888888888888888888888888888888888888 Run error candidates
            run errCandidates% I is the vector of 10 err candidates
            pnt=[pnt I];
            pr=[pr B];
        end
        if OK
            cBlk=cBlk+1;%add correct
            cBit=cBit+lenC-1;
            PER=eBlk/(eBlk+cBlk);
            BER=eBit/(eBit+cBit);
            break
        end
        %()()()(88888)()()()update code with pnt and pr code
        cnt=cnt+1;
    end
    if ~OK
        eBlk=eBlk+1;%add correct
        [dseq bitclk]= sqarithdecoflush(bestseq,counts,N,Fmax,len,midFS);
        eNo=sum(abs(dseq-seq));
        eBit=eBit+eNo;cBit=lenC-1-eNo;
        PER=eBlk/(eBlk+cBlk);
        BER=eBit/(eBit+cBit);
        eval( ['save F:\HD',int2str(param)','\decfail', int2str(siml)]);
    end
    %%
    clc
    siml
    %     sum(dseq-seq)
    pause(.000001)
    t(siml) = toc;
    if rem(siml,every)==0
        eval( ['save F:\HD',int2str(param),'\siml', int2str(siml),'par', int2str(param)]);
        eval( ['save F:\HD',int2str(param),'\loader ','siml',' cBlk',' cBit',' PER',' BER',' param',' every',' stp']);  
    end
    
end