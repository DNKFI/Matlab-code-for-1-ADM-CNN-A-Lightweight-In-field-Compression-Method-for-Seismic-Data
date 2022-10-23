function [targets1,predictors1] = HelperSEQ(clean,noisy, numOutput,NumSegments)

cleanSignal = clean.';

noisySTFT = noisy.';
noisySTFTAugmented   = [zeros(numOutput,ceil(NumSegments/2-1)) noisySTFT zeros(numOutput,ceil(NumSegments/2-1))]; 

Segments = zeros( numOutput, NumSegments , size(noisySTFTAugmented,2) - NumSegments + 1);

for index     = 1 : size(noisySTFTAugmented,2) - NumSegments + 1
    Segments(:,:,index) = noisySTFTAugmented(:,index:index+NumSegments-1);
end


targets1    = cleanSignal;
predictors1 = Segments;