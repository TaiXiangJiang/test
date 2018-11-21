=======================================================================================
Video deraining and desnowing using temporal correlation and low-rank matrix completion
=======================================================================================
Distributed Version 1.0
This software implements the following paper
Jin-Hwan Kim, Jae-Young Sim, and Chang-Su Kim, ¡°Video deraining and desnowing using temporal correlation and low-rank matrix completion,¡± to appear in IEEE Trans. Image Process., 2015.
The executable has been tested on 64-bit windows 8 with Matlab 2014 and is for non-commercial use only.
Copyright 2015, Korea Uniersity

=======================================================================================
INSTALLATION & EXECUTION
=======================================================================================

We already downloaded and included essential tools, i.e. optical flow estimation, SVM, sparse representation, and graphcut optimization.
You may download them by each homepage. 

Next, you should apply each tool.

1. 
Apply optical flow estimation algorithm
Extract the "OpticalFlow.zip" into current directory 
Go to "mex" folder and compile mex files.

e.g) mex Coarse2FineTwoFrames.cpp OpticalFlow.cpp GaussianPyramid.cpp

Copy the created file, Coarse2FineTwoFrames.mexw64 to the root directory

2. 
Apply graphcut optimization algorithm
Extract the "gco-v3.0.zip" into "gco" directory
Go to "gco/matlab" folder
Run the "GCO_UnitTest.m"

3. 
Apply sparse representation algorithm 
Extract the "spams-matlab-v2.5-svn2014-07-04.tar.gz" into current directory 
Addpath the "spams-matlab" 
Compile the "complie.m". Please check your complie and modify 18th line in "complie.m".

4. 
Apply libsvm algorithm
Extract the "libsvm-3.20.zip" into current directory
Go to "libsvm-3.20/matlab" folder and run "make.m"

Note that we partly include the "PROPACK" toolkit. If you have problems to execute "reorth.mexw64" or "bdsqr.mexw64", plase apply the PROPACK toolkit in "http://sun.stanford.edu/~rmunk/PROPACK/"
(Or use m file instead of mex file.)

Run the example code "RUN_ALGORITHM_WHOLEPROCESSING.m"