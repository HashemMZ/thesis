%MAIN4
%--------------------------------------------------------------------------
clear all
format long
while 1
    clc
    reply = input('Do you want continue last simulation? y/n [y]: ', 's');
    if isempty(reply) || reply=='y'
        param=input('param? ');
        snr=input('snr? ');
        disp(['now siml=',num2str(siml)])
        stp=input('stop? ');
        eval( ['load  F:\VCRC\',int2str(param),'_',num2str(snr),'\loader']);
        strt=siml+1;
        stp=siml+3000;
        break
    elseif reply == 'n';
        strt=input('start? ');
        stp=input('stop? ');
        param=input('param? ');
        snr=input('snr? ');
        every=input('every? ');
        cBlk=0;cBit=0;eBlk=0;eBit=0;PER=0;BER=0;SER=0;eSym=0;cSym=0;rate=0;
        break
    end
end

% eval( ['load F:\VCRC',int2str(param),'\est',int2str(param)']);
eval( ['load  F:\VCRC\',int2str(param),'_',num2str(snr),'\enctbl']);
% t=zeros(1,stp-strt+1);
%88888888888888888888888888888888888888888888 start simulation
for siml=strt:stp

    disp(['simulation: ',num2str(siml),' every=',num2str(every), ' SNR =',num2str(snr),' BER =',num2str(BER),' PER =',num2str(PER),' SER =',num2str(SER)])
%     tic
    R=[];len=256;
    seq=randsrc(1,len,[1 3;counts(1,[1 3])./sum(counts(1,[1 3]))]);%seq=randsrc(1,blklen,[[1 2]; prbs]) ;
    crc=CRC((seq-1)/2);
    seqcrc=[1+2*crc seq];
    lencrc=length(seqcrc);
    [R,ST]=QAtblTrl(seqcrc,trellis,N);    
    code= awgn(R*2-1,snr,'measured');
    %     rsrvCode=code;
    r_hrd=(sign(code)+1)/2;
    errpoints=find ( r_hrd ~= R );
    lenC=length(code)+1;%Viterbi needs
    rate=rate+(len/(lenC-1));
    %88888888888888888888888888888888888888888%  Viterbi
    L=10;simpVit=0;
    format;
    [highcost,s_info]=LVD(R,code,trellis,L,simpVit);
    format long;
    crcOK=0;
    for pth=1:L
        [dseq bitclk]= sqarithdecoflush(highcost(pth).path,counts,N,Fmax,lencrc,midFS);
        if ~ismember(2,dseq)
            if isequal(dseq(1:16),1+2*CRC((dseq(17:end)-1)/2)) && isequal(dseq(17:end),seq)
                cBlk=cBlk+1;%add correct
                cBit=cBit+lenC-1;
                cSym=cSym+len;
                PER=eBlk/(eBlk+cBlk);
                SER=eSym/(eSym+cSym);
                BER=eBit/(eBit+cBit);                
%                 t(siml) = toc;
                if rem(siml,every)==0
                    DATA(siml/every,:)=[cBlk,cBit,cSym,eBlk,eBit,eSym,PER,BER,SER];
                    eval( ['save F:\VCRC\',int2str(param),'_',num2str(snr),'\s', num2str(siml),' DATA']);
                    eval( ['save F:\VCRC\',int2str(param),'_',num2str(snr),'\loader',' siml',' cBlk',' cBit',' eBlk',' eBit',' eSym',' cSym',' PER',' BER',' SER',' param',' every',' stp',' DATA',' rate']);
                end
                crcOK=1;
                break;
            end
        end
    end
    if crcOK
        continue;
    end

    %888888888888888888888888888888888888888888888888888888 decoded seq || CRC not OK
    [dseq bitclk]= sqarithdecoflush(highcost(1).path,counts,N,Fmax,lencrc,midFS);
    eSym=eSym+sum((dseq(17:end)~=seq));
    cSym=cSym+len-sum((dseq(17:end)~=seq));
    eBit=eBit+sum(xor(highcost(1).path,R));
    cBit=cBit+lenC-1-sum(xor(highcost(1).path,R));
    eBlk=eBlk+1;
    PER=eBlk/(eBlk+cBlk);
    BER=eBit/(eBit+cBit);
    SER=eSym/(eSym+cSym);
    eval( ['save  F:\VCRC\',int2str(param),'_',num2str(snr),'\decfail', int2str(siml)]);

    %     clc,siml,sum(dseq-seq) ,pause(.000001)
%     t(siml) = toc;
    if rem(siml,every)==0
        DATA(siml/every,:)=[cBlk,cBit,cSym,eBlk,eBit,eSym,PER,BER,SER];
        eval( ['save  F:\VCRC\',int2str(param),'_',num2str(snr),'\s', num2str(siml),' DATA']);
        eval( ['save  F:\VCRC\',int2str(param),'_',num2str(snr),'\loader',' siml',' cBlk',' cBit',' eBlk',' eBit',' eSym',' cSym',' PER',' BER',' SER',' param',' every',' stp',' DATA',' rate']);
    end

end