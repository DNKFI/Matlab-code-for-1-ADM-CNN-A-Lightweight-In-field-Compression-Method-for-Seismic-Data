clear vars quan_D Dshot;
close all
start_time = clock;
%% Loading the raw seismic data and its header

load synthetic;dt=1/1000;if mod(size(syn,1),2)==1;Dshot=syn(1:end-1,:);else;Dshot=syn(1:end,:);end


parfor ii=1:size(Dshot,2)
[quan_D(:,ii) snrq(ii)] = quantization(Dshot(:,ii),ii,over_sample_tx,under_sample_tx);
end
quan_D=quan_D(1:size(Dshot,1),:);


Dshot=normalize(Dshot);
quan_D=normalize(quan_D);

SNR_cal(Dshot,quan_D);

