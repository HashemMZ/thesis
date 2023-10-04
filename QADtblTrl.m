function [seq]=QADtblTrl(code,trellis,N,len)
%decoding using trellis of code
ST=1;seq=[];
lenC=length(code);
t=1;
while length(seq)<len 
    last=1;
        for i=1: trellis(ST(end)).outNo
            last=max(last,length(trellis(ST(end)).out(i).code));
        end
    out=code(t:t+last-1);
    ok=0;
    while ~ok      
        for i=1: trellis(ST(end)).outNo
            if isequal(out,trellis(ST(end)).out(i).code)%find proper output branch of trellis                
                dec=trellis(ST(end)).in(i).code;
                ST=[ST trellis(ST(end)).outstate(i)];
                seq=[seq dec];
                ok=1;
                t=t+length(out);
                break
            end
        end
        out(end)=[];
%         if ~ok %if proper output branch needs more input bits
%             out=[out code(t)];%
%         end
    end   
end