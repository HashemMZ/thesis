for k=330:30:1500
%     clear all
%     eval( ['load siml', int2str(k),'.mat']);
    stem3(1:50,1:50,P(1:50,1:50,2),'fill')
    view(-25,30)
    pause(0.5)
end