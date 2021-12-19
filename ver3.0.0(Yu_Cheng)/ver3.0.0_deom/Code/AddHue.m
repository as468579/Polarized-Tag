function sum = AddHue(h0,h1)
    sum = h0+h1;
    if ~isempty( find(sum >=1 ))
         sum(sum >=1 ) = abs(1-sum(sum >=1 ));
    end
end