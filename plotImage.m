function funcImage = plotImage(dispImage,plotDetail,hFunc)
    [maxResp,maxCond] = max(dispImage,[],3);
    minResp = min(dispImage,[],3);

    mag = maxResp - minResp;
    mag = mag - min(mag(:));
    mag = mag / max(mag(:));

    if plotDetail.param1_circular || plotDetail.param1_modulo
        nColors = length(plotDetail.param1val) + 1;
    else
        nColors = length(plotDetail.param1val);
    end
    
    maxCondImg = (maxCond-1)/(nColors-1);
    maxCondImg = round(maxCondImg*63+1);
    
    funcImage.image = maxCondImg;
    funcImage.mag = mag;
    funcImage.nColors = nColors;

    cla(hFunc);
    image(maxCondImg,'CDataMapping','direct','AlphaData',mag,'AlphaDataMapping','none','parent',hFunc);
    
    axis(hFunc,'image');

    if plotDetail.param1_circular
        colormap('hsv');
        ytlabel = [plotDetail.param1val; plotDetail.param1val(1)];
    else
        colormap('jet');
        ytlabel = plotDetail.param1val;
    end
    cbar = colorbar('peer',hFunc);
    yt=linspace(1,64,nColors);
    set(cbar,'YTick',yt,'YTicklabel',ytlabel)
    set(cbar,'YTick',yt,'YTicklabel',ytlabel)
    
    set(hFunc,'xtick',[],'ytick',[]);
    box(hFunc,'on');
end
