%set up OUTWARD trellis from transitions

clear trellis
%making a dummy struct for trellis with entries all set to 0
for i=1:sNo
    trellis(i).outstate=0;%out states of state i
    trellis(i).outNo=0;%number of out states from state i
    trellis(i).in(1).code=0;%input needed to go from i to output states
    trellis(i).out(1).code=0;%output produced when going from i to output states
    trellis(i).tout=0;% output states time different with state i
    trellis(i).fol=0;%next interval state that encoder goes by this transitions but only low and follow
end
%filling struct with correct info
cnt=ones(1,sNo);
for i=1:length(Tr)    
    trellis(Tr(i).st(1)).outstate(cnt(Tr(i).st(1)))=Tr(i).st(2);
    trellis(Tr(i).st(1)).outNo=cnt(Tr(i).st(1));  
    trellis(Tr(i).st(1)).in(cnt(Tr(i).st(1))).code=Tr(i).in;
    trellis(Tr(i).st(1)).out(cnt(Tr(i).st(1))).code=Tr(i).out;
    trellis(Tr(i).st(1)).tout(cnt(Tr(i).st(1)))=length(Tr(i).out); 
    trellis(Tr(i).st(1)).fol=Tr(i).fol;     
    cnt(Tr(i).st(1))=cnt(Tr(i).st(1))+1;
end
clear temp cnt A I i
disp('trellis OK')
