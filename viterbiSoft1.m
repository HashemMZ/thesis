%Viterbi with soft decision with tail bitting technique
% the paths with L most costs are put out
clc
% run trelo
clear s_info
len= 256 ;
% seq=randsrc(1,len,[1 3;counts(1,[1 3])./sum(counts(1,[1 3]))]);%seq=randsrc(1,blklen,[[1 2]; prbs]) ;
% crc=CRC((seq-1)/2);
% seqcrc=[1+2*crc seq];
% % len=length(seqcrc);
% [R,ST]=QAtblTrl(seqcrc,trellis,N);
% 
% code= awgn(R*2-1,6,'measured');
r_hrd=(sign(code)+1)/2;
errpoints=find ( r_hrd ~= R ) 
simpVit=0;

lenC=length(code)+1;%code frame bit length
L=10;

%   {cost,instates,intime,hasin}=s_info(st,t) different input states into (st,t) and
%   their times and costs are attained in s_info, 'hasin' shows whether this
%   (state,time) has input or not. ex: instates=[1 1 2 3 3], intime=[1 2 1 1 3].
%
%   {outstate,out.code,tout,outNo}=trellis(st) output states(=outstate) their
%   code(=out.code),their time(=tout), and their number(=outNo) are given
%   for state st

% %filling the state information struct
for t=1:lenC
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
for t=1:lenC
    disp(['  t= ',int2str(t)])
    chng=[];
    for s_i=1:sNo
%         disp(['  t= ',int2str(t),'  st= ',int2str(s_i)])
        if s_info(s_i,t).hasin~=1%if this state is not passed before so its outputs are not important
            continue
        end
        %888888888888888888888888888888888888888888888 output states
        for j=1:trellis(s_i).outNo
            s_j=trellis(s_i).outstate(j);tj=t+trellis(s_i).tout(j);codej= trellis(s_i).out(j).code;% select output states s_j from state s_i
%             [tj,s_j]
            if tj>lenC || (tj==lenC && (s_j~=trellis(s_i).outstate(1) || tj~=t+trellis(s_i).tout(1)))%ignore final transitions that will go further than the whole frame OR don't obey the tail bitting
                continue
            end

            %88888888888888888888888888888888888 Input states
            ind=length(s_info(s_j,tj).instates);
            for k=1:(length(s_info(s_i,t).instates)-simpVit*(length(s_info(s_i,t).instates)-1))
                ind=ind+1;
                s_info(s_j,tj).instates(ind)=s_i;
                s_info(s_j,tj).intime(ind)=t;
                s_info(s_j,tj).cost(ind)=s_info(s_i,t).cost(k)+sum((((trellis(s_i).out(j).code*2-1).*code(t:tj-1))));%computing cost
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
        [sortedC,map]=sort(tmpcost,'descend');%sorting the costs
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
highcost=[];k=1;
for state=1:sNo%show costs    
    for in=1:length(s_info(state,t).instates)
        if isequal(s_info(state,t).path(in).dec,R)
            disp(['state=',num2str(state),' time=',num2str(t),' input=',num2str(in)])                        
        end        
        highcost(k).state=state;
        highcost(k).cost=s_info(state,t).cost(in);%sum([s_info(state,t).cost]/length(s_info(state,t).cost));
        highcost(k).instate=s_info(state,t).instates(in);
        highcost(k).intime=s_info(state,t).intime(in);
        highcost(k).path=s_info(state,t).path(in).dec;
        highcost(k).in=in;
        k=k+1;
    end      
end

[sortedC,sortedind]=sort([highcost.cost],'descend');
highcost=highcost(sortedind);
highcost(L+1:end)=[];
% [S,index]=sort(temp,'descend');