function [xreduced, ureduced] = featureReduction(X)
% Data dimensionality reduction using PCA

% Author: Thanh Bui (thanh.bui@erametgroup.com)

n= size(X);
sigma = 1/n(1) * (X') *X;
[u,s,~] = svd(sigma);

sDiag = diag(s);
%figure, plot(sDiag)
for k = 1:n(1)
    if(sum(sDiag(1:k))/sum(sDiag) >= 0.9999 ) % 99.99% of variance is retained
        break
    end
end
ureduced = u(:,1:k);
xreduced = X*ureduced;
    

