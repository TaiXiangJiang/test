
function output = spMatching(im, imBuf, f_splabel, f_mask, search_y, search_x, useSpMask, useInputMask)

% requires opencv DLLs, visual studio 2015 runtime DLL
% requires matlab DLLs in system path

% check inputs
assert(isa(im, 'uint8'));
assert(isa(imBuf,'cell'));
assert(isa(imBuf{1},'uint8'));

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