function TrainSystem(dispNet)

global param;

% testError = GetTestError(param.trainNet);
count = 0;
% it = param.startIter + 1;

% load validation data from mat
global IN;
IN.listTraining = dir([param.trainingData,'\Training*']);
IN.numImages= length(IN.listTraining);
IN.currImageBatches= 0;
currEpoch= param.startEpoch;
% validation data assignment
IN.listTesting = dir([param.trainingData,'\Testing*']);
IN.listTesting =IN.listTesting([3,4,6]);

IN.testSetIdx= [1:length(IN.listTesting)];
IN.trainSetIdx= [1:length(IN.listTraining)];
% IN.testPatchNum= 5000;

% load validation data
count=0;
IN.testData.INRAINMASK= [];
IN.testData.INSPMASK= []; 
IN.testData.INDATA= [];
IN.testData.INT1= [];
IN.testData.GTIM= [];
startInd= 1;
for nd= 1:length(IN.testSetIdx)
    fprintf(repmat('\b', [1, count]));
    count= fprintf('loading validation data %d/%d\n', nd,length(IN.testSetIdx));
    ni= IN.trainSetIdx(nd);	
    load([param.trainingData,IN.listTesting(ni).name]);
    endInd= startInd+ size(INRAINMASK,4)-1;
    IN.testData.INRAINMASK(:,:,:,startInd:endInd)= im2single(INRAINMASK);
    IN.testData.INSPMASK(:,:,:,startInd:endInd)= im2single(INSPMASK);
    IN.testData.INT1(:,:,:,startInd:endInd)= im2single(INT1);
    IN.testData.INT0(:,:,:,startInd:endInd)= im2single(INT0);
    IN.testData.INDATA(:,:,:,startInd:endInd)= im2single(INDATA);
    IN.testData.GTIM(:,:,:,startInd:endInd)= im2single(GTIM);
    startInd= endInd+1;
    clear INRAINMASK INSPMASK INT1 INT0 INDATA GTIM;
end
fprintf(repmat('\b', [1, count]));
fprintf('Validation data loaded.\n');
count=0;

testError=IN.error;
totalTrainedBatch= IN.totalTrainedBatch;

% load([param.trainingData,'training.mat']);
% maxNumPatches = size(INCONF,4);
% numImages = floor(maxNumPatches / param.batchSize) * param.batchSize;

startFlag= 1;

while (1)    % epoch loop
    % for ni=1:IN.numImages
%     if(startFlag==1)
%         startData= find(param.startData == IN.trainSetIdx);
%         if(isempty(startData)) % new added data
%             startData=1;
%         end
%     else
%         startData=1;
%     end  

    % set a different permutation of data index for each epoch
    IN.trainSetIdx= randi(length(IN.listTraining),[1,length(IN.listTraining)]);
    startData=1; % always start from the first data of current epoch
        
    for nd = startData:length(IN.trainSetIdx)
                
        ni= IN.trainSetIdx(nd);
        
        % train using current sequqnce
        load([param.trainingData,IN.listTraining(ni).name]);
        maxNumPatches = size(INSPMASK,4);
        IN.currImageBatches = floor(maxNumPatches / param.batchSize);
        
        if(startFlag==1)
            startBatch= param.startBatch;
        else
            startBatch=1;
        end
        
        for it=startBatch:IN.currImageBatches
            
            startFlag= 0;

            totalTrainedBatch= totalTrainedBatch+1;
            
            if (mod(it, param.printInfoIter) == 0)
                fprintf(repmat('\b', [1, count]));
                count = fprintf('Current batch %d (total %d) / data (%d/%d) epoch %d\n', it, totalTrainedBatch, ni, length(IN.trainSetIdx),currEpoch);
            end

          %% main optimization
            % startInd= mod((it-1) * param.batchSize, IN.currImageBatches) + 1;
            startInd= (it-1) * param.batchSize+ 1;

            inRainMask=     im2single(INRAINMASK(:,:,:,startInd:startInd+ param.batchSize-1));
            inSpMask=       im2single(INSPMASK(:,:,:,startInd:startInd+ param.batchSize-1));
            inT1=           im2single(INT1(:,:,:,startInd:startInd+ param.batchSize-1));
          	inT0=           im2single(INT0(:,:,:,startInd:startInd+ param.batchSize-1));
            inData=        	im2single(INDATA(:,:,:,startInd:startInd+ param.batchSize-1));
            gtIm=           im2single(GTIM(:,:,:,startInd:startInd+ param.batchSize-1));
            
            gtImSpMask=     gtIm.*inSpMask;
            inT1SpMask=  	padarray(inT1.*repmat(inSpMask,1,1,10,1),[param.mBorder,param.mBorder],'both');
         	inT0SpMask=  	padarray(inT0.*repmat(inSpMask,1,1,5,1),[param.mBorder,param.mBorder],'both');
            inDataSpMask=  	padarray(inData.*repmat(inSpMask,1,1,3,1),[param.mBorder,param.mBorder],'both');
            inRainMask=  	padarray(inRainMask,[param.mBorder,param.mBorder],'both'); 
            inSpMaskEx=       padarray(inSpMask,[param.mBorder,param.mBorder],'both');
            
            % figure;imshow([showLFIM(squeeze(inT1SpMask(:,:,:,1))),squeeze(inRainMask(:,:,:,1)),squeeze(gtImSpMask(:,:,:,1))])
            
            if (param.useGPU)
                inT1SpMask      = gpuArray(inT1SpMask);
                inT0SpMask      = gpuArray(inT0SpMask);
                inDataSpMask  	= gpuArray(inDataSpMask);
                inRainMask      = gpuArray(inRainMask);
                inSpMaskEx     	= gpuArray(inSpMaskEx);
                gtImSpMask      = gpuArray(gtImSpMask);
            end

            [dispRes] = EvaluateSystem(dispNet,inT1SpMask,inT0SpMask,inDataSpMask,inSpMaskEx,inRainMask,gtImSpMask,true,false);
            % curError = ComputeMaskedRMSE(dispRes(end).x, gtImSpMask(:,:,1,:), inSpMask);

            % dispNet = UpdateNet(dispNet, dispRes, it);
            % dispNet = UpdateNet(dispNet, dispRes, totalTrainedBatch);
            dispNet = UpdateNet(dispNet, dispRes, ceil(currEpoch/25));

            % if (mod(it, param.testNetIter) == 0)
            if (mod(totalTrainedBatch, param.testNetIter) == 0)
                % 1. perform validation
                % countTest = fprintf('\nStarting the validation process / test data %d\n', IN.testSetIdx);
                countTest = fprintf('\n Validating trained network\n');

                curError = TestDuringTraining(dispNet);
                testError = [testError; curError];
                plot(1:length(testError), testError);
                title(sprintf('SPAC Shuffle Avg T0T1 Current RMSE: %f', curError));
                drawnow;

                fprintf(repmat('\b', [1, countTest]));                
                % 2. save network
                [~, curNetName, ~] = GetFolderContent(param.trainNet, '.mat');
                fileName = sprintf('/Net-e%04d-d%04d-b%06d.mat', currEpoch, ni,it);
                save([param.trainNet, fileName], 'dispNet','testError','totalTrainedBatch');

                if (~isempty(curNetName))
                    curNetName = curNetName{1};
                    delete(curNetName);
                end
            end 
            
        end
    %     it = it + 1;   
    end
    
    currEpoch= currEpoch +1;
    
end
