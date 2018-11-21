function tmp = dic2images(D)

V=1;
[n K] = size(D);

sizeEdge=sqrt(n/V);
if floor(sizeEdge) ~= sizeEdge
   V=3;
   sizeEdge=sqrt(n/V);
end

for (ii = 1:size(D,2))
   if (D(1,ii) > 0)
      D(:,ii) = -D(:,ii);
   end
end

p=4.5;
        M=max((D(:)));
        m=min((D(:)));
        if (m >= 0)
           me=0;
           sig=sqrt(mean(((D(:))).^2));
        else
           me=mean(D(:));
           sig=sqrt(mean(((D(:)-me)).^2));
        end
        D=D-me;
        D=min(max(D,-p*sig),p*sig);
        M=max((D(:)));
        m=min((D(:)));
       D=(D-m)/(M-m);
  %     D=1-D;

nBins=floor(sqrt(K));

tmp = zeros(sizeEdge*nBins,sizeEdge*nBins,V);
patch = zeros(sizeEdge,sizeEdge,1);
mm=sizeEdge*sizeEdge;
for ii = 1:nBins
   for jj = 1:nBins
      patchCol=(D(1:n,(ii-1)*nBins+jj));
      patchCol=reshape(patchCol, [sizeEdge,sizeEdge V]);

      M=max((patchCol(:)));
      m=min((patchCol(:)));
  %    patchCol=1.0*(patchCol-m)/(M-m)+0.0;


      tmp((ii-1)*sizeEdge+1:ii*sizeEdge, (jj-1)*sizeEdge+1:jj*sizeEdge,:)=patchCol;
   end
end



