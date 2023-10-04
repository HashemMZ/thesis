%produces al states and their next states due to input
clear all
% counts=[2/11 9/11];EOB=0;N=4;Fmax=1;midFS=0;%Pep=.3;counts=[counts-counts*Pep Pep];
% counts=[20 15 15];EOB=0;N=8;Fmax=1;midFS=1;
 counts=[10 15];EOB=0;N=6;Fmax=1;midFS=0;
% counts=[7 6 3];EOB=0;N=4;Fmax=1;midFS=1;
%counts=[ 10 10 12];EOB=0;N=5;Fmax=1;midFS=1;
% counts=[7 20 5];EOB=0;N=5;Fmax=1;midFS=0;
%  counts=[5 3];EOB=0;N=3;Fmax=1;midFS=0;
%1 start from s0 in list one , set its check=0

ST=2:4;NX1=6;NX2=7;check=5;FS=8;
s(1,:)=[0 0 2^N-1 0 0 0 0 0];%[sNo L H F check NX1 NX2 FS]

%2 extend all entries in list one which has check~=0 then set its check to 1 if no entry exits
%finish
i=1;
while i<=size(s,1)

    s(i,check)=1;% this state is being checked
    %%%%%%%%%first symbol
    [code,state] = sqarithencoflush(1, counts(1,:),s(i,ST),N,Fmax,midFS,EOB);
    out(i).sym1=code;

    k=find( sum(repmat(state,size(s,1),1)==s(:,ST),2) ==3);%if L H F exist in previous states
    if length(k)==0%No
        s(i,NX1)=size(s,1);
        s(size(s,1)+1,:)=[size(s,1) state 0 0 0 0];
    else%Yes
        s(i,NX1)=k-1;
    end

    %%%%%%%%%% second symbol
    [code,state] = sqarithencoflush(2+midFS, counts(1,:),s(i,ST),N,Fmax,midFS,EOB);
    out(i).sym2=code;

    k=find(sum(repmat(state,size(s,1),1)==s(:,ST),2)==3);
    if length(k)==0
        s(i,NX2)=size(s,1);
        s(size(s,1)+1,:)=[size(s,1) state 0 0 0 0];
    else
        s(i,NX2)=k-1;
    end
    
    %%%%%%%%%% FS symbol
    [code,state] = sqarithencoflush(3-midFS, counts(1,:),s(i,ST),N,Fmax,midFS,EOB);
    out(i).sym3=code;

    k=find(sum(repmat(state,size(s,1),1)==s(:,ST),2)==3);
    if length(k)==0
        s(i,FS)=size(s,1);
        s(size(s,1)+1,:)=[size(s,1) state 0 0 0 0];
    else
        s(i,FS)=k-1;
    end

    clc    
    pause(0.0000005);
    i=i+1
end

for i=1:size(s,1)
    disp([num2str(s(i,:)),'  >  ',num2str(out(i).sym1),' / ',num2str(out(i).sym2),' / ',num2str(out(i).sym3)])
end
disp(['low precision problem [',num2str(find(s(:,3)-s(:,2)<1)-1),']'])
clear NX1 NX2 ST check code i k state EOB