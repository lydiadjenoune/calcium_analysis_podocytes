figure; 
for i=1:size(int_clocheMO); scatter(1,int_clocheMO,'ko','LineWidth',3); end; hold on; 
for i=1:size(int_CTL), scatter(2,int_CTL,'bo','LineWidth',4); end; hold on;
axis ([0 3 0 max(int_CTL(:,1)*2)]);
set(gca,'XTick',0:3,'XTickLabel', {'0', 'cloche', 'CTL', ''},'FontSize',18)
title('Normalized integrals per ROI')
hold off
integral = strcat(folder, 'integral');
saveas (gcf, integral,'fig');
saveas (gcf, integral,'png');

