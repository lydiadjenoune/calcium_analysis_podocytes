figure;
for i=1:size(rois,2); hold on; plot((dff_v_cloche(:,i)/100)-i,'k','linewidth',2); end; hold on;
for i=1:size(rois,2); hold on; plot((dff_v_CTL(:,i)/100)-i,'k','linewidth',4); end; hold on;



