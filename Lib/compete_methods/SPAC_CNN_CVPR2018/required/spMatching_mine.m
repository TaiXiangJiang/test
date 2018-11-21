function output = spMatching_mine(im, imBuf, spMatchParams)
% function output = spMatching(im, imBuf, f_splabel, f_mask, search_y, search_x, useSpMask, useInputMask)

f_splabel=      spMatchParams.f_splabel;
f_mask=         spMatchParams.f_mask;
search_y=       spMatchParams.search_y;
search_x=       spMatchParams.search_x;
useSpMask=      spMatchParams.useSpMask;
useInputMask=   spMatchParams.useInputMask;

% requires opencv DLLs, visual studio 2015 runtime DLL
% requires matlab DLLs in system path

% check inputs
assert(isa(im, 'uint8'));
% assert(isa(imBuf,'cell'));
% assert(isa(imBuf{1},'uint8'));
if(~isa(imBuf,'uint8'))
    imBuf= im2uint8(imBuf);
end
if(~isa(imBuf,'cell'))
    [s3,s4,s1,s2]= size(imBuf);
    tempBuf= imBuf; 
    clear imBuf;
    if(s2==1) % input grayscale sequqnce
        for n=1:s1
            imBuf{n}= tempBuf(:,:,n);
        end
    elseif(s1==3)
        for n=1:s1
            imBuf{n}= tempBuf(:,:,:,n);
        end
    else
        fprintf('input imBuf format wrong!');
    end
    % imBuf= {imBuf(:,:,1),imBuf(:,:,2),imBuf(:,:,3),imBuf(:,:,4)};
    % imBuf= {imBuf(:,:,:,1),imBuf(:,:,:,2),imBuf(:,:,:,3),imBuf(:,:,:,4)};
end

assert(ndims(im) == ndims(imBuf{1}));

% spLabel
if(~isa(f_splabel,'int32'))
    f_splabel = int32(f_splabel);
end

% change f_mask to 0 or 255
if(~isa(f_mask,'uint8'))
    f_mask = uint8(f_mask);
end

if(any(f_mask(:)==1)) 
    f_mask = f_mask*255;
end
assert(all(f_mask(:)==0 | f_mask(:)==255));

if(~isa(search_x,'int32'))
    search_x = int32(search_x);
end

if(~isa(search_y,'int32'))
    search_y = int32(search_y);
end

if(~islogical(useSpMask))
    useSpMask = logical(useSpMask);
end

if(~islogical(useInputMask))
    useInputMask = logical(useInputMask);
end

output = spMatching_mex(im, imBuf, f_splabel, f_mask, search_y, search_x, useSpMask, useInputMask);

% clear spMatching_mex