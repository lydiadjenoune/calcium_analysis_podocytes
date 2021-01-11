close all
disp ('Choose image acquisition file')
[image folder] = uigetfile('*.*');
imagefile = strcat(folder, image);

% If you want to manually select image to choose ROIs from, uncomment below
% 
disp ('Choose image to select ROIs')
[file2, folder2]= uigetfile('*.*');
StanDev = strcat(folder2, file2);

% StanDev = strcat(folder, 'AVG_', image);
nframes = input('How many frames is the image file? ');
freq = input('What is the frequency of acquisition in Hz? ');


M=multitiff2M(imagefile,1:nframes);
% Mr = registerfilm_ROI(M(:,:,1:nframes),1);
% flattenM = mean(M,3); 
x_dim = length(M(1,:,1));
y_dim = length(M(:,1,1));

figure;I=imread(StanDev);imshow(I);
disp('Choose first set of ROIs')
rois_v = getROIcell;
close all
    
% Generate mask from rois, calculate dff, find and threshold
% minima, fit poly to minima, subtract dff trace from poly function,
% calculate integral normalized per roi per minute

if isempty(rois_v);
    dff_v = []
    raw_v = []
    Mask_v = []
    int_v = [];
else;

for i=1:size(rois_v,2); 
    Mask_v{i} = roipoly(imread(imagefile),rois_v{i}(:,1),rois_v{i}(:,2));
end;

[dff_v, raw_v] = calc_dff(M, Mask_v, size(rois_v,2));
 
for i=1:size(rois_v,2); 
    
    [min_v, ind_v] = lmin(dff_v(:,i),100);
    [fit_v, gof_v, out_v] = fit(ind_v', min_v', 'poly2', 'Normalize', 'on');
    base_v (:,i) = feval(fit_v, [1:nframes])';
    adj_v(:,i) = dff_v(:,i)-base_v(:,i);
    int_v(:,i) = trapz(adj_v(:,i));
    int_v(:,i) = int_v(:,i)/nframes*freq*60;
    
end;
    int_v = int_v';
end


for i=1:length(rois_v);
    centroid_x_v(i) = [mean(rois_v{i}(:,1))];
end
centroid_x_v = centroid_x_v';

% Generate png/fig for mask of rois
figure; imshow(StanDev);
for i=1:length(rois_v);
    patch(rois_v{1,i}(:,1),rois_v{1,i}(:,2),'m','FaceAlpha',0.55);
    text(rois_v{1,i}(1,1),rois_v{1,i}(1,2),num2str(i),'Color','b');
    hold on;
end

title('ROIs','FontSize', 18);
rois = strcat(folder, 'ROIs');
saveas(gcf, rois,'fig'); 
saveas(gcf, rois,'png');
close all
    

lmax_v = NaN(50);

indmax_v = NaN(50);

prethresh_v = NaN(50);


figure; 
for i=1:size(rois_v,2); 
    subplot((round(size(rois_v,2)/2)),3,i);plot(raw_v(:,i),'k'); hold on; 
    plot(dff_v(:,i),'b'); plot(adj_v(:,i),'r'); 
    title(['ROI', num2str(i)]);
    hold off; 
end;
title('Vental dff','FontSize', 18);
vccd = strcat(folder, 'ventralcells_correctedDFF');
saveas(gcf,vccd,'fig');
saveas(gcf,vccd,'png');


figure; 
for i=1:size(int_v); plot(1,int_v,'ko','LineWidth',3); end; hold on; 

axis ([0 3 0 max(int_v(:,1)*2)]);
set(gca,'XTick',0:3,'XTickLabel', {'0', 'ventral cells', 'dorsal cells', ''},'FontSize',18)
title('Normalized integrals per ROI')
hold off
integral = strcat(folder, 'integral');
saveas (gcf, integral,'fig');
saveas (gcf, integral,'png');

allrois = [rois_v];
output = zeros(length(allrois), 3);
for i = 1:length(rois_v);
    output(i,1) = i;
    output(i,2) = 1;
    output(i,3) = int_v(i);
end



% output: column 1 is roi number, column 2 is 1 for ventral, 2 for dorsal,
% column 3 is integral normalized to one minute

save analysis