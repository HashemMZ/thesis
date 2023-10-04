% it makes two transition for each entry in lookup table and removes mute
% ones by combining them with next transitions
NX1=6;NX2=7;Tmute=[];T=[]; flw=4;LH=[2 3];
%                             in/out
%making transitions T: st(1)---------->st(2)  
for i=1:size(s,1)
    T(i).st=[s(i,1) s(i,NX1)];%making first transition T(i) from state s=[sNo L H F check NX1 NX2]
    T(i).in=1;
    T(i).code=out(i).sym1;
    T(i).fol=s(i,flw) ;%fol=follow of next state
    T(i).int=s(i,LH) ;
    if length(out(i).sym1)==0% also saving mute transition indexes
        Tmute=[Tmute i];
    end
    T(size(s,1)+i).st=[s(i,1) s(i,NX2)];% making 2nd trans T(end of list)
    T(size(s,1)+i).in=2+midFS;
    T(size(s,1)+i).code=out(i).sym2;
    T(size(s,1)+i).fol=s(i,flw) ;%fol=follow of next state
    T(size(s,1)+i).int=s(i,LH) ;
    if length(out(i).sym2)==0
        Tmute=[Tmute size(s,1)+i];
    end
end
% Tmute=sort(Tmute,'descend');
% remove mute transitions Txy by convrting it into Txyz so that x->y->z
i=1;
while length(Tmute)~=0
%     last=length(T(i).st);
    mute=Tmute(1);
    y=T(mute).st(2);%y, output of mute trans
    j=1;
    while j<=length(T)%for all trans that go from output of mute trans
        if T(j).st(1)==y
            T(length(T)+1).st(1)=T(mute).st(1);%create new T
            T(end).st(2)=T(j).st(2);%copy yz to xz
            T(end).code=T(j).code;%copy yz to xz
            T(end).in=[T(mute).in T(j).in];
            T(end).fol=T(mute).fol;
            T(end).int=T(mute).int;
            if length(T(end).code)==0
                Tmute=[length(T) Tmute];
            end
        end        
        
        j=j+1;
    end
    T(mute)=[];%delete mute T
    Tmute(Tmute==mute)=[];%
    Tmute(Tmute>mute)=Tmute(Tmute>mute)-1;
%     Tmute=sort(Tmute,'descend');
    i=i+1;
    clc
    Tmute
    pause(.000001)
end
for i=1:length(T)
    temp(i)=T(i).st(1);
end
[A,I]=sort(temp);
T=T(I);
snew=s;snew(:,[1 NX1 NX2])=s(:,[1 NX1 NX2])+1;
save Trans T
run RemoveNullStates
clear A Do_iter I IN NX1 NX2 Tmute ans i ia ib j lastDim  mute newst ok temp y flw T
run trelo