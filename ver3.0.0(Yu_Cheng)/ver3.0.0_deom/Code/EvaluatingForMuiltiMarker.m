function ID =  EvaluatingForMuiltiMarker(L,X,Y_orig,dict) 
    map = zeros(size(Y_HSV,1),size(Y_HSV,2));
    idx =  sub2ind(size(map),round(X(1,:)),round(X(2,:)),ones(1,size(X,2)));
    map(idx) = L(:);
end