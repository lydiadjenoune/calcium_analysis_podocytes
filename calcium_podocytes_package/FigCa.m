figure;
for i=1:size(rois,2); hold on;
plot((dff_v(:,i)/100)-i,'k','linewidth',2);
end;