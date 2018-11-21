function [M, Rain] = CSC_ADMM_CPU( FX, Filters, mu, MaxIter)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Please cite the following paper:
% Minghan Li, Qi Xie, Qian Zhao, Wei Wei, Shuhang Gu, Jing Tao, Deyu Meng*, 
% Video Rain Streak Removal By Multiscale Convolutional Sparse Coding. CVPR, 2018.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
max_lambda = 1e5;
tol = 1e-10;
[h, w, n, K] = size(Filters);

lambda = 1;iter = 1;Cond = 1;
mu=repmat(reshape(mu,[1,1,1,K]),[h,w,n,1]);
MU =  zeros(size(Filters));
Y = zeros(size(Filters));

C_Filters = conj(Filters);            % [h,w,n,K]
FTX = C_Filters.*repmat(FX,[1,1,1,K]);  % [h,w,n,K]Ds
FTF  = sum(C_Filters.*Filters,4);     % [h,w,n]

while(iter < MaxIter && Cond)
    FR = FTX+lambda*fft2(Y-MU);            % [h,w,n,K]
    FM = (FR-repmat( sum(Filters.*FR,4)./(lambda+FTF) , [1,1,1,K] ) .*C_Filters)./lambda;  % [h,w,n,K]    
    M = real(ifft2(FM));   % [h,w,n,K]
    Y = max(M+MU-mu/lambda,0);  % [h,w,n,K]
    MU = MU + M - Y;
    if(lambda < max_lambda)
        lambda = lambda*1.05;
    end
    if(mod(iter,10)==0)
        ConvergenceError = mean(mean(mean(mean((M-Y).^2))));
        Cond = (ConvergenceError>tol);
    end
    iter = iter+1;
end
% M = max(M,0); %??
M = double(Y);
Rain = double(real(ifft2(fft2(M).*Filters)));


