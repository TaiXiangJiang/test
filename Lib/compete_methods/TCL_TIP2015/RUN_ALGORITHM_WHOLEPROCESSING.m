% % rainmap_ext('data/niagara_rain2.avi', 'rainmap/', 3, 30);
% %rain_removal_lra('data/niagara_rain2.avi',  'rainmap/', 'outs', 5, 25, 'r', 2000);
% blurring('outs/', 'outs/', 5, 25); 

tStart = tic;
filename = 'highway_rainy3555.mat';
rainmap_ext(filename, 'rainmap/', 3, 158);
rain_removal_lra(filename,  'rainmap/', 'outs', 5,156, 'r', 2000);
B_TIP15 = blurring('outs/', 'outs/', 5, 156); 
time_TIP15 = toc(tStart);
% implay(B_clean)
B_cleantip = B_clean(:,:,:,5:156);
psnr(B_TIP15 (:),B_cleantip(:),max(B_cleantip(:)))
% save high2wayTIP1020.mat time_TIP15 B_TIP15 B_cleantip
% 
% tStart = tic;
% filename = 'high2way_rainy2535.mat';
% rainmap_ext(filename, 'rainmap/', 3, 98);
% rain_removal_lra(filename,  'rainmap/', 'outs', 5,96, 'r', 2000);
% B_TIP15 = blurring('outs/', 'outs/', 5, 96); 
% time_TIP15 = toc(tStart);
% implay(B_clean)
% B_cleantip = B_clean(:,:,:,5:96);
% 
% save high2wayTIP2535.mat time_TIP15 B_TIP15 B_cleantip
% 
% tStart = tic;
% filename = 'high2way_rainy4050.mat';
% rainmap_ext(filename, 'rainmap/', 3, 98);
% rain_removal_lra(filename,  'rainmap/', 'outs', 5,96, 'r', 2000);
% B_TIP15 = blurring('outs/', 'outs/', 5, 96); 
% time_TIP15 = toc(tStart);
% implay(B_clean)
% B_cleantip = B_clean(:,:,:,5:96);
% 
% save high2wayTIP4050.mat time_TIP15 B_TIP15 B_cleantip