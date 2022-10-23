function [qDn snrq]=quantization(D,trno,over_sample_tx,under_sample_tx)

over_sample_Rx=1;
obs=over_sample_Rx;

min_D=0;
D_scaled=D-min_D;
max_D=max(D_scaled(:));
D_scaled=D_scaled/max_D;
fs=2000;
input.signals.dimensions = 1;
input.time = 1/fs*[1:length(D_scaled)];
Leng_ip=length(input.time);

for ii=1:obs
    ii;
    input.signals.values =D_scaled(:,1);
    y(:,ii)=input.signals.values;
    yad=resample(y(:,ii),over_sample_tx,under_sample_tx);
    [yd,delta]=adeltamod(yad);%adaptive delta
    temp=yd;
    ze_len=length(find((yd<1)&(yd>-1)));
    yd(yd<0)=0;yd(yd>0)=1;
end

in=temp.';
qD=adeltademod(in.',delta,length(yad(:,1))).';
[Xa,Ya,Delay] = alignsignals(yad,qD);Delay=(Delay);
qD=resample(qD,under_sample_tx,over_sample_tx);
qD=qD/max(qD);
qDn=qD*max_D;
qDn=qDn+min_D;
snrq=SNR_cal(D(:,1),qDn(1:length(D(:,1))));
