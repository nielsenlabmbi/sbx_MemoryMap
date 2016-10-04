function plotImage(dispImage,plotDetail,hFunc)
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

    cla(hFunc);
    image(maxCondImg,'CDataMapping','direct','AlphaData',mag,'AlphaDataMapping','none','parent',hFunc);
    
    axis(hFunc,'image');
    
    if plotDetail.param1_circular
        colormap('hsv');
    else
        colormap('jet');
    end
    cbar = colorbar('peer',hFunc);
    yt=linspace(1,64,nColors);
    set(cbar,'YTick',yt,'YTicklabel',ytlabel)
    set(cbar,'YTick',yt,'YTicklabel',ytlabel)
    
    set(hFunc,'xtick',[],'ytick',[]);
    box(hFunc,'on');
end
