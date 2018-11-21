



[l1,l2,l3] = size(O_Rainy);
O_Rainy1 = biger(O_Rainy,padsize);
Shiftdata = gpuArray.ones(l1+10,(l1+l2+20-1),l3+10);
for i = 1:(l1+10)
    Shiftdata(i,i:(i+l2+10-1),:) = O_Rainy1(i,:,:);
end
%%% FastDeRain
tStart =  tic;
[B_S,R_S,iter] = FastDeRain_GPU(Shiftdata,optsS);
timeS = toc(tStart);
%%% shift back
for j = 1:(l1+10)
    B_Sb(j,:,:) = B_S(j,j:(j+l2+10-1),:);
end
B_1 = smaller(B_Sb,padsize);
B_1c = gray2color_hsv(O_hsv,gather(B_1));
implay(B_1c);
