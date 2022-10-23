function [dq,delta]=adeltamod(x)
%% Initializations made here for further use of them
% T=1/Fs; 
nmax=length(x); 
% t=[0:nmax-1]*T; % T = Time period ; % Sampling frequency = 1/ T
Vmin=min(x);%-0.1;
Vmax=max(x);%0.1;
N=2^8; % N = 2 Because DM uses 1 bit quantiser
delta_min=(Vmax-Vmin)/(2*N); % Width of the quantization interval = To avoid granular noise
delta(1) = delta_min;

%% User controlled channel
% You can make use of any other noise channels, just search in MATLAB help
% n_snr= input('Enter 1 if you need to add AWGN CHANNEL NOISE else enter 0 ');
% if (n_snr == 1)
% snr= input ('Enter signal to noise ratio = '); % SNR value
% end
% n_snr=0;
%% ADM Transmitter system %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for n=1:nmax
if n == 1
d(1) = x(1);
dq(1)= d(1);%delta(1)*sign(d(1));
mq(1)=dq(1);
else
d(n) = x(n)-mq(n-1);
dq(n)= sign(d(n));
delta(n) = delta(n-1)*(1.2^(dq(n)*dq(n-1))); % Width of the quantization interval = To avoid slope overload distortion
eq2(n) = delta(n)*dq(n); % step- size control
mq(n) = mq(n-1)+eq2(n);
end
end