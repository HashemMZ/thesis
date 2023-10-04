%error candidates
%--------------------------------------------------------------------------
counts=[20 15 15];
N=8;Fmax=1;midFS=1;
len=200;

start=1;
stop=100000;
% load data2
% shP=shP+1;shN=shN+1;shZ=shZ+1;%some points have no occurance (zero) so to avoid zero results in production we add by 1

for siml=start:stop
%     rand('state', randseed);
    R=[];
    seq=randsrc(1,len,[1 3;counts(1,[1 3])./sum(counts(1,[1 3]))]);
    R = sqarithencoflushTot(seq, counts(1,:),N,Fmax,midFS);
    X=randsrc(1,1,30:length(R)-30);
    %     check=R;
    R(X)=~R(X);
    

    %get the seq R which has error
    [dseq bitclk]= sqarithdecoflush(R,counts(1,:),N,Fmax,len,midFS);
    D=bitclk(find(dseq==2,1,'first'));%edl
    SHFT=50;ENo=12;
    % do ENo experiments on seq to attain kE's
    Pmf=ones(SHFT,1);
    for E=2:2:ENo
        R(D-E)=~R(D-E);
        [dseq bitclk]= sqarithdecoflush(R,counts(1,:),N,Fmax,len,midFS);
        d=bitclk(find(dseq==2,1,'first'));
        k=d-D;
        %         if k>SHFT | k<-SHFT
        %             break;
        %         end
        %take out related pmf(i|k) from tables and compute pmf^(i|k)
        if k>0
            Pmf=Pmf.*shP(:,k,E);
        elseif k<0
            Pmf=Pmf.*shN(:,-k,E);
        elseif length(k)==0
            break
        else
            Pmf=Pmf.*shZ(:,E);
        end
        R(D-E)=~R(D-E);
        stem(Pmf)
    end
    [B,I] = sort([Pmf],'descend');
    B'/sum(B),I'
    I=I(1:10);
    I',i=D-X+1
    clc
    siml
    %     sum(dseq-seq)
    pause(.000001)
    %     close(h);
end



%choose 10 biggest points as error candidates

%get them to tree decoder or Viterbi dec