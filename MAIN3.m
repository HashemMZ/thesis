%MAIN
%--------------------------------------------------------------------------
clear all
while 1
    clc
    reply = input('Do you want continue last simulation? y/n [y]: ', 's');
    if isempty(reply) || reply=='y'
        param=input('param? ');
        snr=input('snr? ');
        eval( ['load F:\HD',int2str(param),'\loaderSnr', num2str(snr),'.mat']);
        strt=siml+1;
        stp=siml+3000;
        break
    elseif reply == 'n';
        strt=input('start? ');
        stp=input('stop? ');
        param=input('param? ');
        snr=input('snr? ');
        every=input('every? ');
        cBlk=0;cBit=0;eBlk=0;eBit=0;PER=0;BER=0;
        break
    end
end

eval( ['load F:\HD',int2str(param),'\est',int2str(param)']);
eval( ['load F:\HD',int2str(param),'\enctbl',int2str(param)']);
run trelo
len=30;%snr=1.5;
t=zeros(1,stp-strt+1);
%88888888888888888888888888888888888888888888 start simulation
for siml=strt:stp

    disp(['simulation: ',num2str(siml),' SNR: ',num2str(snr),' BER: ',num2str(BER),' PER: ',num2str(PER)])
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
    L=1;simpVit=1;
    run vitSoft
    bestseq=s_info(hCostind(1),lenC).path(in).dec;
    [dseq bitclk]= sqarithdecoflush(bestseq,counts,N,Fmax,len,1);
    D=bitclk(find(dseq==2,1,'first'));%edl
    if isempty(D) && isequal(seq,dseq)
        cBlk=cBlk+1;%add correct
        cBit=cBit+lenC-1;
        PER=eBlk/(eBlk+cBlk);
        BER=eBit/(eBit+cBit);
        t(siml) = toc;
        if rem(siml,every)==0
            DATA(siml/every,:)=[cBlk,cBit,eBlk,eBit,PER,BER];
            eval( ['save F:\HD',int2str(param),'\s', num2str(siml),'snr', num2str(snr),'.mat',' DATA']);
            eval( ['save F:\HD',int2str(param),'\loaderSnr', num2str(snr),'.mat',' siml',' cBlk',' cBit',' eBlk',' eBit',' PER',' BER',' param',' every',' stp',' DATA']);
        end
        continue
    end
    %%

    %88888888888888888888888888888888888888888888888888888888888888888888888888%Iterative process
    %     beep
    cnt=1;OK=0;L=10;simpVit=0;
    while cnt<=4 || OK
        disp(['Iteration: ',num2str(cnt)])
        %888888888888888888888888888888888888 LVD & error loc estimate
        OK=0;
        run vitSoft
        pnt=[];pr=[];
        for No=1:length(highcost)%
            if OK
                break;
            end
            disp(['path No: ',num2str(No)])
            [dseq bitclk]= sqarithdecoflush(s_info(hCostind(No),lenC).path(1).dec,counts,N,Fmax,len,midFS);
            D=bitclk(find(dseq==2,1,'first'));%edl
            if isempty(D) && isequal(seq,dseq)
                OK=1;
                break
            end
            %888888888888888888888888888888888888 Run error candidates
            run errCandidates% I is the vector of 10 err candidates
            for err=1:10
                dseqLV=s_info(hCostind(No),lenC).path(1).dec;
                %                 dseqLV(D-I(err)+1)=-(1+B(err)).*dseqLV(D-I(err)+1);%
                dseqLV(D-I(err)+1)=~dseqLV(D-I(err)+1);
                [dseq bitclk]= sqarithdecoflush(dseqLV,counts,N,Fmax,len,midFS);
                D=bitclk(find(dseq==2,1,'first'));%edl
                if isempty(D) && isequal(seq,dseq)
                    OK=1;
                    break
                end
            end
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
        eBlk=eBlk+1;%add not correct
        [dseq bitclk]= sqarithdecoflush(bestseq,counts,N,Fmax,len,midFS);
        eNo=sum(abs(dseq-seq));
        eBit=eBit+eNo;cBit=lenC-1-eNo;
        PER=eBlk/(eBlk+cBlk);
        BER=eBit/(eBit+cBit);
        eval( ['save F:\HD',int2str(param)','\decfail', int2str(siml)]);
    end
    %%
    %     clc
    %     siml
    %     sum(dseq-seq)
    %     pause(.000001)
    t(siml) = toc;
    if rem(siml,every)==0
        DATA(siml/every,:)=[cBlk,cBit,eBlk,eBit,PER,BER];
        eval( ['save F:\HD',int2str(param),'\s', num2str(siml),'snr', num2str(snr),'.mat',' DATA']);
        eval( ['save F:\HD',int2str(param),'\loaderSnr', num2str(snr),'.mat',' siml',' cBlk',' cBit',' eBlk',' eBit',' PER',' BER',' param',' every',' stp',' DATA']);
    end

end