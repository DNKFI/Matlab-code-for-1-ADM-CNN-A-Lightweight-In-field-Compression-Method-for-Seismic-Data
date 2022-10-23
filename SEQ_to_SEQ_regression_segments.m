clear vars
%%
% clear all
close all
load s
Fs=4000;
dt=1/Fs;

% rng(s)
numOutput  = 1;
numSegments  = 15;


targets=[];predictors=[];cs=200;

load training_seismic_syn 
   

training_Dshot = [training_Dshot(:,1:50:end)];
training_quan_D = [training_quan_D(:,1:50:end)];

seq=1:size(training_Dshot,1);

training_Dshot=training_Dshot ./ max(abs(training_Dshot), [], 1);
training_quan_D=training_quan_D ./ max(abs(training_quan_D), [], 1);

training_Dshot(isnan(training_Dshot))=0;
training_quan_D(isnan(training_quan_D))=0;
predictors =[];targets =[];
for nn=1:max(1,ceil(size(training_Dshot,2)/cs))
    Temp1=num2cell(training_Dshot(seq,((nn-1)*cs+1):min(size(training_Dshot,2),cs*nn)),1).';
    T1=tall(Temp1);
    Temp2=num2cell(training_quan_D(seq,((nn-1)*cs+1):min(size(training_Dshot,2),cs*nn)),1).';
    T2=tall(Temp2);
    [temp_targets,temp_predictors] = cellfun(@(x,y)HelperSEQ(x,y,...
        numOutput,numSegments), T1,T2,"UniformOutput",false);
    [temp_targets,temp_predictors] = gather(temp_targets,temp_predictors);
    targets=[targets;temp_targets];
    predictors=[predictors;temp_predictors];
end
predictors    = cat(3,predictors{:});
targets       = cat(2,targets{:});

noisyMean     = mean(predictors(:));
noisyStd      = std(predictors(:));
predictors(:) = (predictors(:) - noisyMean)/noisyStd;


cleanMean     = mean(targets(:));
cleanStd      = std(targets(:));
targets(:)    = (targets(:) - cleanMean)/cleanStd;


predictors = reshape(predictors,size(predictors,1),size(predictors,2),1,size(predictors,3));
targets    = reshape(targets,1,1,size(targets,1),size(targets,2));


inds                = randperm(size(predictors,4));
L                   = round(.80 * size(predictors,4));
trainPredictors     = (predictors(:,:,:,inds(1:L)));
trainTargets        = (targets(:,:,:,inds(1:L)));
trainTargets =permute(trainTargets ,[2 1 3 4]);
trainPredictors  =permute(trainPredictors ,[2 1 3 4]);

validatePredictors  = (predictors(:,:,:,inds(L+1:end)));
validateTargets     = (targets(:,:,:,inds(L+1:end)));
validateTargets  =permute(validateTargets ,[2 1 3 4]);
validatePredictors  =permute(validatePredictors ,[2 1 3 4]);

%%
numResponses = 1;
featureDimension = numSegments;
numHiddenUnits = 125;

layers = [ ...
    imageInputLayer([featureDimension 1 1],'Name','ip')
     convolution2dLayer([3 1],8,"Stride",1,"Padding","same",'Name','Cl')
% %          batchNormalizationLayer('Name','B1')
        leakyReluLayer('Name','r1') 
                
% %                         
          convolution2dLayer([5 1],16,"Stride",1,"Padding","same",'Name','C2' )
%          batchNormalizationLayer('Name','B2')
         leakyReluLayer('Name','r2')
                
% %                             
          convolution2dLayer([3 1],32,"Stride",1,"Padding","same",'Name','C3' )
%         batchNormalizationLayer('Name','B3') 
        leakyReluLayer('Name','r3')
                
    fullyConnectedLayer(numResponses,'Name','op','BiasInitializer','narrow-normal','BiasL2Factor',2,'WeightsInitializer','orthogonal' )
    regressionLayer('Name','re')];
 
layers = layerGraph(layers); 

% analyzeNetwork(layers)

miniBatchSize = 512;
LearnRate = 1e-4;
options = trainingOptions("adam", ...
    "MaxEpochs",50, ...
    'ValidationPatience',5,...
    "InitialLearnRate",LearnRate,...
    "MiniBatchSize",miniBatchSize, ...
    "Shuffle","every-epoch", ...  
   'L2Regularization',0.00005,...
    "Verbose",0, ...
    "Plots","training-progress", ...
     'ExecutionEnvironment','Auto',...
    "VerboseFrequency",floor(size(predictors,4)/miniBatchSize), ...
    "ValidationFrequency",3*floor(size(trainPredictors ,4)/miniBatchSize), ...
    "ValidationData",{validatePredictors,validateTargets});
net = trainNetwork(trainPredictors,trainTargets,layers,options);


%% Test the Denoising Networks

load testing_seismic_syn




testing_Dshot=testing_Dshot ./ max(abs(testing_Dshot), [], 1);
testing_quan_D=testing_quan_D ./ max(abs(testing_quan_D), [], 1);

for ii=1:size(testing_Dshot,2)
    tr=ii;

    cleanSignal  = testing_Dshot(:,tr).';
    cleanSignal = (cleanSignal  - mean(cleanSignal(:))) / max(abs(cleanSignal(:)));
    cleanSignal = (cleanSignal  - noisyMean) / noisyStd;
    
    noisySignal  = testing_quan_D(:,tr).';
    noisySignal  = (noisySignal(1:numOutput,:));

    noisySignal  = [zeros(numOutput,ceil(numSegments/2-1)) noisySignal zeros(numOutput,ceil(numSegments/2-1))];
    predictors = zeros( numOutput, numSegments , size(noisySignal,2) - numSegments + 1);
    for index = 1 : size(noisySignal,2) - numSegments + 1
        predictors(:,:,index) = noisySignal(:,index:index + numSegments - 1);
    end
    predictors(:) =(predictors(:) -mean(predictors(:) ))/max(abs(predictors(:) ));
    predictors(:) = (predictors(:) - noisyMean) / noisyStd;

    %
    predictors = reshape(predictors, [numSegments,1,1,size(predictors,3)]);
    predictors =(predictors);
    Reconstructed =   (predict(net,predictors));
    Reconstructed(:)     =   cleanStd * Reconstructed(:) + cleanMean;
    denoised    = Reconstructed;

    CS(:,ii)=     testing_Dshot(:,tr);
    NS(:,ii)=     testing_quan_D(:,tr);
    DE(:,ii)=    real(denoised);

%     CS(:,ii)=CS(:,ii)/max(abs(CS(:,ii)));
%     NS(:,ii)=NS(:,ii)/max(abs(NS(:,ii)));
%     DE(:,ii)=DE(:,ii)/max(abs(DE(:,ii)));

end


[SNR_cal(CS,NS) SNR_cal(CS,DE)]
snr1=SNR_cal(CS,NS);
snr2=SNR_cal(CS,DE);

