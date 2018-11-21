% clear all
% close all


% load rain frames
% The programme works on 5 consectutive frames to derain the central frame.
% fileContents= dir(['rainFrames/*jpg']);
% for nf=1:length(fileContents)
%     rainFrames(:,:,:,nf)= im2uint8(imread(['rainFrames/',fileContents(nf).name]));
% end
clear rainFrames
for nf=1:size(Rainy,4)
    rainFrames(:,:,:,nf)= im2uint8(Rainy(:,:,:,nf));
end




paramsIn.useGPU= true; % false

paramsIn.numSP= round(288*size(rainFrames,1)*size(rainFrames,2)/(640*480)); % recommended 288 for VGA resolution images. adjust proptionately for different resolutions.

% Input: rainFrames: mxnxNF
% Output: derainFrames mxnxNF (note the first and last two frames are left as empty) 
clear derainFrames
tStart = tic;
derainFrames= derainFunction(rainFrames, paramsIn);
time_SPAC = toc(tStart);
B_SPAC = double(derainFrames(:,:,:,3:end-2))/255;
B_clean_SPAC = B_clean(:,:,:,3:end-2);
[PSNR3D,PSNRV,MPSNR,SSIMV,MSSIM,FSIMV,MFSIM,VIFV,MVIF,UQIV,MUQI,GMSDV,MGMSD] = QuanAsse(B_SPAC,B_clean_SPAC);
[PSNR3D,MPSNR,MSSIM,MFSIM,MVIF,MUQI,MGMSD]