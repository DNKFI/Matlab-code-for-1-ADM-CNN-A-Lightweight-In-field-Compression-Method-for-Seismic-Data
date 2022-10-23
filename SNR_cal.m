function [snr]=SNR_cal(x,y)

SNR=0;
for ii=1:size(x,2)  
SNR(ii)=mean(x(:,ii).^2)./mean((y(:,ii)-x(:,ii)).^2);

end
snr=10*log10(sum(SNR)/ii);
