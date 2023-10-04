%error candidates
%--------------------------------------------------------------------------

% shP=shP+1;shN=shN+1;shZ=shZ+1;%some points have no occurance (zero) so to avoid zero results in production we add by 1

   %get the seq R which has error
%     [dseq bitclk]= sqarithdecoflush(R,counts(1,:),N,Fmax,len,midFS);
%     D=bitclk(find(dseq==2,1,'first'));%edl
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
    B=B'/sum(B);%I'
    I=I(1:10);B=B(1:10);
%     I',i=D-X+1
%choose 10 biggest points as error candidates

%get them to tree decoder or Viterbi dec