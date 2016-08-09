function plotImage(dispImage,plotDetail,h)
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

    maxCondImg = (maxCond-1)/(nColors-1); %scale between 0 and 1, making sure that the first condition repeats
    maxCondImg = round(maxCondImg*63+1);

    if plotDetail.param1_circular
        ytlabel = [plotDetail.param1val; plotDetail.param1val(1)];
    else
        ytlabel = plotDetail.param1val;
    end

    image(maxCondImg,'CDataMapping','direct','AlphaData',mag,'AlphaDataMapping','none','parent',h);
    axis(h,'image');
    if plotDetail.param1_circular
        colormap('hsv');
    else
        colormap('jet');
    end
    cbar=colorbar('peer',h);
    yt=linspace(1,64,nColors);
    set(cbar,'YTick',yt,'YTicklabel',ytlabel)
    set(cbar,'YTick',yt,'YTicklabel',ytlabel)
    
    set(h,'xtick',[],'ytick',[]);
    box(h,'on');
end

