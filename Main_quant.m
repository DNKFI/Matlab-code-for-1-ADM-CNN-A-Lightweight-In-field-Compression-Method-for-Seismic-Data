% Iqbal, Naveed. "1-ADM-CNN: A Lightweight In-field Compression Method for Seismic Data." IEEE Transactions on Circuits and Systems II: Express Briefs (2022).
clear all
load s
rng(s)
start_time1 = clock;
% var1=[ 1 2 1 5 3  7 2];
% var2=[ 2 3 1 4 2  4 1];
var1=[ 1 1 2];
var2=[ 2 1 1];

% var1=[8 1];% 100 CR and 96 CR
% var2=[25 3];% 100 CR and 96 CR
SN1=[];
SN2=[];
% SN3=[];
sn1=[];
sn2=[];
for nn=1:1
for mm=1:length(var1)
  mm

over_sample_tx=var1(mm);
under_sample_tx=var2(mm);
comp_r(mm)=32*var2(mm)/var1(mm);

disp(['compression ratio = ',num2str(comp_r(mm))])

Data_generation %1-ADM and dequantized
% for training
training_Dshot=Dshot(:,1:1000); % Dshot is the raw data
training_quan_D=quan_D(:,1:1000);%quan)D is the data after recovering (dequantization)
save training_seismic_syn training_Dshot training_quan_D
% for testing
testing_Dshot=Dshot(:,1001:end);
testing_quan_D=quan_D(:,1001:end);
save testing_seismic_syn testing_Dshot testing_quan_D

%training and testing CNN
SEQ_to_SEQ_regression_segments

SN1(mm,:)=snr1;

SN2(mm,:)=snr2;

end
sn1(nn,:)=SN1;
sn2(nn,:)=SN2;

end
figure(10)
plot(comp_r,mean(sn1,1))
hold on
plot(comp_r,mean(sn2,1))

axis tight
xlabel('Compression Ratio')
ylabel('SNR (dB)')
legend('SNR before CNN','SNR after CNN')
%%
end_time = clock;
elapsed_time = etime(end_time,start_time1);
elapsed_hours = floor(elapsed_time/3600);
elapsed_minutes = floor((elapsed_time - 3600*elapsed_hours)/60);
elapsed_seconds = elapsed_time - 3600*elapsed_hours - 60*elapsed_minutes;
fprintf('Total execution time is %d hours, %d minutes, %3.1f seconds\n',...
    elapsed_hours,elapsed_minutes,elapsed_seconds)