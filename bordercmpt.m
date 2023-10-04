function counts=bordercmpt(state,P0)
% computes borders of sub intervals in an Quasi arithmetic scheme to
% achieve least  redudancy
W=state(2)-state(1)+1;
for i=1:W-2
    p1=i/W;p2=(i+1)/W;
    prob(i)=1/(1+((log(p2/p1))/log((1-p1)/(1-p2))));
end
prob=[0 prob 1];
counts(1)=find(prob<P0,1,'last');
counts(2)=state(2)-state(1)-counts(1)+1;