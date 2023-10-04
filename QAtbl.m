function [code,ST]=QAtbl(seq,sTable,out)
%encoding using the state transition matrix and out matrix

% seq=[3 1 3 1  3 3 3 1 3  1 1 3 1 1  3 3 1 3 1 3 3 1 1 3  1 1 1 3 1  1 3 3 ];
len=length(seq);
code=[];
%make lookup tables for N
ST=1;
for i=1:len
    %     [R,state] = sqarithencoflush(seq(i),counts,state,N,Fmax,midFS,EOB)
    
    if seq(i)==1
        next=6;
        R=out(ST(end)).sym1;
    else
        next=7;
        R=out(ST(end)).sym2;
    end
    ST=[ST sTable(ST(end),next)];
    code=[code R];
end
