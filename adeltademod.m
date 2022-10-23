function [xn]=adeltademod(dq,delta,len)

%% ADM Receiver system %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Yn = dq.*delta;
Xn(1) = Yn(1);
for k=2:len,
Xn(k) = Yn(k)+Xn(k-1);
end

%% Received information in the receiver
% [B,A] = fir1(48,.4,'low');
% lowpass = @(S) filter(B,A,S);
xn = Xn;%lowpass(Xn);
