%computing of the error shift in arithmetic decoding by introducing an
%extra error
%1-rate 2/3
close all
% clear all,clc
% load data
% format
counts=[20 15 15];ENo=12;%counts=[2/11 9/11];%Pep=.5;counts=[counts-counts*Pep Pep]*2^N-1;
SHFT=50;shP=zeros(SHFT,SHFT,ENo);shN=zeros(SHFT,SHFT,ENo);shZ=zeros(SHFT,ENo);
N=8;Fmax=1;midFS=1;fi=zeros(1,SHFT);
len=200;

while 1
    clc
    reply = input('Do you want continue last simulation? y/n [y]: ', 's');
    if isempty(reply) || reply=='y'
        eval( ['F:\1\load loader1 ']);
        eval( ['F:\1\load siml', int2str(siml)]);
        start=siml+1
        stop=input('stop? ');
        break
    elseif reply == 'n';
        start=input('start? ');
        stop=input('stop? ');
        every=input('every? ');
        break
    end
end

rand('state', randseed);
siml=start;
while siml<=stop

    R=[];
    seq=randsrc(1,len,[1 3;counts(1,[1 3])./sum(counts(1,[1 3]))]);
    R = sqarithencoflushTot(seq, counts(1,:),N,Fmax,midFS);

    clc
    siml
    pause(.000001)

    X=randsrc(1,1,30:length(R)-30);
    %     check=R;
    R(X)=~R(X);
    [dseq bitclk]= sqarithdecoflush(R,counts(1,:),N,Fmax,len,midFS);
    D=bitclk(find(dseq==2,1,'first'));%error detec loc
    i=D-X+1;%diff bw error loc and detec
    if i>SHFT
        siml=siml-1;
        continue
    end
    fi(i)=fi(i)+1;

    %eperiments for PMF
    for E=1:1:ENo
        R(D-E)=~R(D-E);
        [dseq bitclk]= sqarithdecoflush(R,counts(1,:),N,Fmax,len,midFS);
        d=bitclk(find(dseq==2,1,'first'));%new edl
        k=d-D;%error detec shift
        if k>SHFT | k<-SHFT| length(k)==0     
            siml=siml-1;
            continue;
        end
        if k>0
            shP(i,k,E)=shP(i,k,E)+1;
        elseif k<0
            shN(i,-k,E)=shN(i,-k,E)+1;
        elseif k==0
            shZ(i,E)=shZ(i,E)+1;

        end
        R(D-E)=~R(D-E);
    end
    %     stem3(1:50,1:50,shP(1:50,1:50,2),'fill')
    %     view(-25,30)
    %     pause(0.5)
    if rem(siml,every)==0
        eval( ['save F:\1\siml', int2str(siml),' siml shP shN shZ fi every']);
        eval( ['save F:\1\loader1 ','siml']);
        figure(1);
        subplot 331;stem(fi),title('fi')
        subplot 332;stem(shP(3,:,1)),title('shP(3,:,1)')
        subplot 333;stem(shP(3,:,2)),title('shP(3,:,2)')
        subplot 334;stem(shP(3,:,3)),title('shP(3,:,3)')
        subplot 335;stem(shP(3,:,4)),title('shP(3,:,4)')
        subplot 336;stem(shP(3,:,5)),title('shP(3,:,5)')
        subplot 337;stem(shP(3,:,6)),title('shP(3,:,6)')
        subplot 338;stem(shP(3,:,7)),title('shP(3,:,7)')
        subplot 339;stem(shP(3,:,12)),title('shP(3,:,12)')
        figure(2);
        subplot 331;stem(shZ(3,:)),title('shZ(3,:)')
        subplot 332;stem(shN(3,:,1)),title('shN(3,:,1)')
        subplot 333;stem(shN(3,:,2)),title('shN(3,:,2)')
        subplot 334;stem(shN(3,:,3)),title('shN(3,:,3)')
        subplot 335;stem(shN(3,:,4)),title('shN(3,:,4)')
        subplot 336;stem(shN(3,:,5)),title('shN(3,:,5)')
        subplot 337;stem(shN(3,:,6)),title('shN(3,:,6)')
        subplot 338;stem(shN(3,:,7)),title('shN(3,:,7)')
        subplot 339;stem(shN(3,:,12)),title('shN(3,:,12)')

        %         eval( ['delete siml', int2str(siml-30),'.mat']);
    end
    %     close(h);
     siml=siml+1;
end
shP=shP+1;shN=shN+1;shZ=shZ+1;%some points have no occurance (zero) so to avoid zero results in production we add by 1