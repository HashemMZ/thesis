%Viterbi with Hamming cost
clc
% run trelo
clear s_info
% code = sqarithencoflushTot([1 3 1 1 3 1 3 3 1 1 1 3 1 1  3 3 1 3 1],counts,N,Fmax,midFS);
% code = sqarithencoflushTot([ 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 2 1 1 2 1 1 1 2 1 2  1 2 1 1   1  1 2 1 1 1 2 1 2  1 2 1 2 1 2 1 1 1 2 1 2  1 2 1 1   1  1 2 1 1 1 2 1 2   1  2 1 2 2 1 2 1 1 1 2 1 2  1 2 1 1   1  1 2 1 1 1 2 1 2  1 2 1 2 1 2 1 1 1 2 1 2  1 2 1 1   1  1 2 1 1 1 2 1 2   1  2 1 2  1 2 1 1 2 2  1 2 1 1 1 2 2  1 2 1],counts,N,Fmax,midFS);
lenC=length(code);%code frame bit length
L=20;
%   {cost,instates,intime,hasin}=s_info(st,t) different input states into (st,t) and
%   their times and costs are attained in s_info, 'hasin' shows whether this
%   (state,time) has input or not. ex: instates=[1 1 2 3 3], intime=[1 2 1 1 3].
%
%   {outstate,out.code,tout,outNo}=trellis(st) output states(=outstate) their
%   code(=out.code),their time(=tout), and their number(=outNo) are given
%   for state st

% %filling the state information struct
for t=1:lenC+1
    for stat=1:sNo
        s_info(stat,t).cost=0;
        s_info(stat,t).instates=[];
        s_info(stat,t).intime=0;
        s_info(stat,t).path.dec=[];
        s_info(stat,t).hasin=0;
    end
end

%initial state in  trellis is t=1 NOT t=0
t=1;
s_info(1,t).cost=0;
s_info(1,t).instates=0;
s_info(1,t).intime=0; 
s_info(1,t).path.dec=[];
s_info(1,t).hasin=1;

%viterbi
for t=1:lenC+1
    chng=[];
    for s_i=1:sNo        
        disp(['  t= ',int2str(t),'  st= ',int2str(s_i)])
        if s_info(s_i,t).hasin~=1%if this state is not passed before so its outputs are not important
            continue
        end
        %888888888888888888888888888888888888888888888 output states
        for j=1:trellis(s_i).outNo
            s_j=trellis(s_i).outstate(j);tj=t+trellis(s_i).tout(j);codej= trellis(s_i).out(j).code;% select output states s_j from state s_i
%             [tj,s_j]
            if tj>lenC+1%ignore final transitions that will go further than the whole frame
                continue
            end

            %88888888888888888888888888888888888 Input states
            ind=length(s_info(s_j,tj).instates);
            for k=1:length(s_info(s_i,t).instates)
                ind=ind+1;
                s_info(s_j,tj).instates(ind)=s_i;
                s_info(s_j,tj).intime(ind)=t;
                s_info(s_j,tj).cost(ind)=s_info(s_i,t).cost(k)+sum(abs((trellis(s_i).out(j).code-code(t:tj-1))));%computing Hamming cost
                s_info(s_j,tj).path(ind).dec=[s_info(s_i,t).path(k).dec codej];
            end
%             s_info(s_j,tj)
            %88888888888888888888888888888888888

            if length(s_info(s_j,tj).instates)==0
                s_info(s_j,tj).hasin=0;
            else
                s_info(s_j,tj).hasin=1;
                chng(s_j,tj)=1;
            end
        end
        %888888888888888888888888888888888888888888888
    end
    %finds (state,times) that are changed, sort their input and limit to L
    % first ones
    for ind=1:sum(sum(chng))
        [chgs,chgt]=find(chng==1,ind);chgs=chgs(end);chgt=chgt(end);
        tmpstate=s_info(chgs,chgt).instates;
        tmpcost=s_info(chgs,chgt).cost;
        tmptime=s_info(chgs,chgt).intime;
        for q=1:length(s_info(chgs,chgt).instates)
            tmpdecoded.path(q).dec=s_info(chgs,chgt).path(q).dec;
        end
        [sortedC,map]=sort(tmpcost);%sorting the costs
        for in=1:min(L, length(s_info(chgs,chgt).instates))
            s_info(chgs,chgt).instates(in)=tmpstate(map(in));
            s_info(chgs,chgt).intime(in)=tmptime(map(in));
            s_info(chgs,chgt).cost(in)=sortedC(in);
            s_info(chgs,chgt).path(in).dec=tmpdecoded.path(map(in)).dec;
        end
        if L< length(s_info(chgs,chgt).instates)% constrain input numbers to L
            s_info(chgs,chgt).instates(L+1:end)=[];
            s_info(chgs,chgt).intime(L+1:end)=[];
            s_info(chgs,chgt).cost(L+1:end)=[];
            s_info(chgs,chgt).path(L+1:end)=[];
        end

    end
end
for state=1:sNo%show costs
    s_info(state,t).cost
end
for state=1:sNo%show costs    
    for input=1:length(s_info(state,t).instates)
        if isequal(s_info(state,t).path(input).dec,R)
            disp(state),disp(input)
        end
    end    
end   