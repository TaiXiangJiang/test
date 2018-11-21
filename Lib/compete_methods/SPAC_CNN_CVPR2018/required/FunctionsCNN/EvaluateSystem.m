% function [finalImg, depthRes, colorRes] = EvaluateSystem(depthNet, colorNet, images, refPos, isTraining, depthFeatures, reference, isTestDuringTraining)
function [dispRes] = EvaluateSystem(dispNet,inT1SpMask,inT0SpMask,inDataSpMask,inSpMask,inRainMask,gtImSpMask,isTraining,isTestDuringTraining)

global param;

if (~exist('isTraining', 'var') || isempty(isTraining))
    isTraining = false;
end

if (~exist('isTestDuringTraining', 'var') || isempty(isTestDuringTraining))
    isTestDuringTraining = false;
end

%% Estimating the depth (section 3.1)
% if (~isTraining)
%     fprintf('Estimating depth\n');
%     fprintf('------------\n');
% 
%     fprintf('Extracting depth features ');
%     dfTime = tic;
%     deltaY = inputView.Y - refPos(1, :); 
%     deltaX = inputView.X - refPos(2, :);
%     depthFeatures = PrepareDepthFeatures(images, deltaY, deltaX);
% 
%     if (param.useGPU)
%         depthFeatures = gpuArray(depthFeatures);
%     end
% 
%     fprintf(repmat('\b', 1, 5));
%     fprintf('Done in %f seconds\n', toc(dfTime));
% end

% inAvgProc= mean(inT1SpMask,3).*inRainMask+ inDataSpMask(:,:,1,:).*(~inRainMask);
inAvgProc= mean(inT1SpMask,3);

inT0SpMask(:,:,5,:)= inAvgProc.*inRainMask+ inT0SpMask(:,:,5,:).*(~inRainMask);

inFeatures(:,:,1:10,:)      = inT1SpMask - repmat(inAvgProc,1,1,10,1);
inFeatures(:,:,11:15,:)       = inT0SpMask- repmat(inAvgProc,1,1,5,1);

% EVALUATE ONLY F1
% inFeatures(:,:,10,:)      = repmat(inT0SpMask(:,:,5,:),1,1,1,1) - repmat(inAvgProc,1,1,1,1);
% inFeatures(:,:,11:15,:)       = repmat(inT0SpMask(:,:,5,:),1,1,5,1)- repmat(inAvgProc,1,1,5,1);
% EVALUATE ONLY F1

% inFeatures(:,:,1,:)         = inAvgProc;
% inFeatures(:,:,2,:)      	= inDataSpMask(:,:,1,:);
% inFeatures(:,:,3,:)         = inRainMask;
%{
nt=23;
imshow(repmat(showLFIM(inFeatures(:,:,:,nt)),1,1,3));
imshow([repmat(showLFIM(inFeatures(:,:,1:10,nt)),1,1,3),inFeatures(:,:,11:13,nt)]);
%}
% outRainMask= CropImg(inRainMask,param.mBorder);
% outSpMask= CropImg(inSpMask,param.mBorder);

if(isTraining)   
    gtImRes= gpuArray(gtImSpMask- CropImg(inAvgProc,param.mBorder));
end

if (param.useGPU)
	inFeatures = gpuArray(inFeatures);
end

dispRes = EvaluateNet(dispNet, inFeatures, [], true);
finalOut= dispRes(end).x;

%% Backpropagation    
if(isTraining && ~isTestDuringTraining)   
    dzdx = vl_nnpdist(finalOut, gtImRes, 2, 1, 'noRoot', true, 'aggregate', true); % /length(find(inSpMask));
%     dzdx = vl_nnpdist(finalOut.*outRainMask.*outSpMask, ...
%                     gtImSpMask.*outRainMask.*outSpMask, 2, 1, ...
%                     'noRoot', true, 'aggregate', true);% /length(find(outSpMask.*outRainMask));
    dispRes(end).dzdx = dzdx;
    dispRes = EvaluateNet(dispNet,inFeatures, dispRes, false);    
end

%{
figure;
for n=1:param.batchSize
    numIm= 4;
    subplot(numIm,param.batchSize,n);imshow(inImgs(:,:,:,n)/255);
	subplot(numIm,param.batchSize,n+1*param.batchSize);imshow(finalOut(:,:,1,n));  
    subplot(numIm,param.batchSize,n+2*param.batchSize);imshow(finalImg(:,:,1,n));
    subplot(numIm,param.batchSize,n+3*param.batchSize);imshow(bgrf(:,:,:,n));
end
%}
