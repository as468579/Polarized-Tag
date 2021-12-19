function result = DiscardNonPolarizedPoint(Img,s_thre,v_thre)
    result = Img;
    for i = 1:size(Img,1)
        for j = 1:size(Img,2)
            if(Img(i,j,2)<s_thre || Img(i,j,3)<v_thre)
                result(i,j,:) = 0;
            end
        end
    end
end