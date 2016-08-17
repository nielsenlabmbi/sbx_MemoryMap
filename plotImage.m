function plotImage(dispImage,plotDetail,hImage)
    [maxResp,maxCond] = max(dispImage,[],3);
    minResp = min(dispImage,[],3);

    %also compute response strength if - difference between best and worst
    %condition
    mag = maxResp-minResp;
    mag = mag-min(mag(:));
    mag = mag/max(mag(:));

    %convert into color
    if plotDetail.param1_circular || plotDetail.param1_modulo
        nColors = length(plotDetail.param1val) + 1;
    else
        nColors = length(plotDetail.param1val);
    end

%     maxCond = smoothImage(maxCond,plotDetail.filterPx);
    
    maxCondImg = (maxCond-1)/(nColors-1); %scale between 0 and 1, making sure that the first condition repeats
    maxCondImg = round(maxCondImg*63+1);

    if plotDetail.param1_circular
        ytlabel = [plotDetail.param1val; plotDetail.param1val(1)];
    else
        ytlabel = plotDetail.param1val;
    end

    cla(hImage);
    if plotDetail.showAnatomy
        if plotDetail.param1_circular; cid = jet; else cid = hsv; end
        imout = repmat(mag(:),1,3).*cid(maxCondImg(:),:);
        imout1(:,:,1) = reshape(imout(:,1),size(mag));
        imout1(:,:,2) = reshape(imout(:,2),size(mag));
        imout1(:,:,3) = reshape(imout(:,3),size(mag));
        imout = imout1 + repmat(plotDetail.anatomy,[1 1 3]);
        imout = imout/max(imout(:));
        
        image(imout,'CDataMapping','direct','AlphaDataMapping','none','parent',hImage);
    else
        image(maxCondImg,'CDataMapping','direct','AlphaData',mag,'AlphaDataMapping','none','parent',hImage);
    end
    
    axis(hImage,'image');
    
    if plotDetail.param1_circular
        colormap('hsv');
    else
        colormap('jet');
    end
    cbar = colorbar('peer',hImage);
    yt=linspace(1,64,nColors);
    set(cbar,'YTick',yt,'YTicklabel',ytlabel)
    set(cbar,'YTick',yt,'YTicklabel',ytlabel)
    
    set(hImage,'xtick',[],'ytick',[]);
    box(hImage,'on');
end
