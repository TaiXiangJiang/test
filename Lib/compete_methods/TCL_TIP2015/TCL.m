%% Introduction
% This script is to run the method in Video deraining and desnowing using
% temporal correlation and low-rank matrix completion TIP 2015 
% Please download the code from http://mcl.korea.ac.kr/~jhkim/deraining/deraining code with example.zip
% and extract the files in the folder '...\FastDeRain\Lib\compete_methods\TCL_TIP2015'.
% Then install it with the instructions. 
% We sincerely appreciate the generous sharing of the code form the
% authors of this paper.
%% 
% For simplify the comparison with our FastDeRain, we make some minor
% changes with the files:
% rainmap_ext       -> rainmap_ext_new
% rain_removal_lra  -> rain_removal_lra_new
% blurring          -> blurring_new

frame_num = size(Rainy,4);
rainmap_ext_new(filename, 'rainmap/', 3, frame_num-2);
rain_removal_lra_new(filename,  'rainmap/', 'outs', 5,frame_num-4, 'r', 2000);
B_TCL = blurring_new('outs/', 'outs/', 5, frame_num-4); 
B_TCL_clean = B_clean(:,:,:,5:frame_num-4);
