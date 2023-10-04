%set up trellis from transitions

%sorting according to output state
temp=[];
for i=1:length(Tr)
    temp(i)=Tr(i).st(2);
end
[A,I]=sort(temp);
Tr=Tr(I);

%making trellis
trellis=[];
%making a dummy struct for trellis with 0 entries
for i=1:sNo
    trellis(i).in=0;
    trellis(i).inNo=0;
    trellis(i).out(1).code=0;
    trellis(i).tin=0;    
end
%filling struct with correct info
cnt=ones(1,sNo);
for i=1:length(Tr)    
    trellis(Tr(i).st(2)).in(cnt(Tr(i).st(2)))=Tr(i).st(1);
    trellis(Tr(i).st(2)).inNo=cnt(Tr(i).st(2));    
    trellis(Tr(i).st(2)).out(cnt(Tr(i).st(2))).code=Tr(i).in;
    trellis(Tr(i).st(2)).tin(cnt(Tr(i).st(2)))=length(Tr(i).in);    
    cnt(Tr(i).st(2))=cnt(Tr(i).st(2))+1;
end
disp('trellis OK')
