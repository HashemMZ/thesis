clear all,color=[':r*';':mo';':bs'];color2=['--r*';'--mo';'--bs'];
for param=1:3
    for snr=1:2:7        
        eval( ['load  F:\VCRC\',int2str(param),'_',num2str(snr),'\loader']);
        tB(param,1+(snr-1)/2)=BER;
        tP(param,1+(snr-1)/2)=PER;
        tS(param,1+(snr-1)/2)=SER;
        tcB(param,1+(snr-1)/2)=cBER;
        tcP(param,1+(snr-1)/2)=cPER;
        tcS(param,1+(snr-1)/2)=cSER;
        Rt(param,1+(snr-1)/2)=rate/siml;
    end
 figure(1)
 semilogy(1:2:7,tB(param,:),color(param,:))
 hold on
 semilogy(1:2:7,tcB(param,:),color2(param,:))
 xlabel('SNR'),ylabel('BER')
 grid,axis([0 8  10^-5 1])
legend('\epsilon=0.1,simple Viterbi ','\epsilon=0.1,LVD+CRC','\epsilon=0.3,simple Viterbi ','\epsilon=0.3,LVD+CRC','\epsilon=0.5,simple Viterbi ','\epsilon=0.5,LVD+CRC',3);
 figure(2)
 semilogy(1:2:7,tP(param,:),color(param,:))
 hold on
 semilogy(1:2:7,tcP(param,:),color2(param,:))
 xlabel('SNR'),ylabel('PER')
 grid,axis([0 8  10^-3 1])
 legend('\epsilon=0.1,simple Viterbi ','\epsilon=0.1,LVD+CRC','\epsilon=0.3,simple Viterbi ','\epsilon=0.3,LVD+CRC','\epsilon=0.5,simple Viterbi ','\epsilon=0.5,LVD+CRC',3);
 figure(3)
 semilogy(1:2:7,tS(param,:),color(param,:))
 hold on
 semilogy(1:2:7,tcS(param,:),color2(param,:))
 xlabel('SNR'),ylabel('SER')
 grid,axis([0 8  10^-3 1])
 legend('\epsilon=0.1,simple Viterbi ','\epsilon=0.1,LVD+CRC','\epsilon=0.3,simple Viterbi ','\epsilon=0.3,LVD+CRC','\epsilon=0.5,simple Viterbi ','\epsilon=0.5,LVD+CRC',3);

 
end
%    
