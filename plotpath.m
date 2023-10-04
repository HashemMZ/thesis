hold on;
s=50;T=122;
tindex=[];sindex=[];
for time=T:-1:1    
    tindex(time)=s_info(s,T).intime;
    sindex(time)=s_info(s,T).instates;
    s=sindex(time);
    T=tindex(time);
    if T==1
        break
    end
end
line(tindex,-sindex)