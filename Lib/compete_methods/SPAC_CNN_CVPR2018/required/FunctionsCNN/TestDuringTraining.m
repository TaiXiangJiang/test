function error = TestDuringTraining(dispNet)

global param;
global IN;

% sceneNames = param.testNames;
% fid = fopen([param.trainNet, '/error.txt'], 'at');

% numScenes = length(sceneNames);
error = 0;

IN.currImageBatches=0;

% load([param.trainingData,IN.list(5).name]);
% INDPMSP= IN.testData.INDPMSP;
% INCVIEW= IN.testData.INCVIEW;
% INCEDGE= IN.testData.INCEDGE;
% INCONF= IN.testData.INCONF;
% GTDP= IN.testData.GTDP;

maxNumPatches = size(IN.testData.INRAINMASK,4);
IN.currImageBatches = floor(maxNumPatches / param.batchSize);
        
% load([param.trainingData,'training.mat']);
% maxNumPatches = size(INDPMSP,4);
% numImages = floor(maxNumPatches / param.batchSize);

% INDPMED=[];
% for nn=1:maxNumPatches
%     INDPMED(:,:,1,nn)= medfilt2(IN.testData.INDPMSP(:,:,1,nn),[11,11]);
% end

% GTDPRES= IN.testData.GTIM;
% GTDPRES= IN.testData.GTDP- IN.testData.INDPMSP(:,:,2,:);

for it = 1 : IN.currImageBatches
    
    startInd= mod((it-1) * param.batchSize, IN.currImageBatches) + 1;
    %%% read input data
    inRainMask=     im2single(IN.testData.INRAINMASK(:,:,:,startInd:startInd+ param.batchSize-1));
    inSpMask=       im2single(IN.testData.INSPMASK(:,:,:,startInd:startInd+ param.batchSize-1));
    inT1=           im2single(IN.testData.INT1(:,:,:,startInd:startInd+ param.batchSize-1));
    inT0=           im2single(IN.testData.INT0(:,:,:,startInd:startInd+ param.batchSize-1));
    inData=           im2single(IN.testData.INDATA(:,:,:,startInd:startInd+ param.batchSize-1));
    gtIm=           im2single(IN.testData.GTIM(:,:,:,startInd:startInd+ param.batchSize-1));

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
  
    % [dispRes] = EvaluateSystem(dispNet,inDpMSP,inConf,inCView,inCEdge,gtDispRes,true,false); % this one is for training
    [dispRes] = EvaluateSystem(dispNet,inT1SpMask,inT0SpMask,inDataSpMask,inSpMaskEx,inRainMask,gtImSpMask,false,true);
    % curError = ComputePSNR(dispRes(end).x.*inSpMask, gtImSpMask(:,:,1,:));
    inAvgProc= CropImg(mean(inT1SpMask,3),param.mBorder);
    curError = ComputeMaskedRMSE(dispRes(end).x, gtImSpMask -inAvgProc, inSpMask);
            
    error = error + curError / IN.currImageBatches;
end

%fprintf(fid, '%f\n', error);
%fclose(fid);

error = gather(error);
