function [refl, refl_cr, wavelength, rgb_img, rgb_img_he] = preprocess_envi_spectra(datafile, whitereffile, darkreffile, compute_cr, short_range)

% Read ENVI files and compute the relative reflectance and the continuum
% removal

refl_file = strcat(datafile(1:end-4), '_refl', datafile(end-3:end));
refl_hdr_file = strcat(datafile(1:end-4), '_refl', '.hdr');
refl_cr_file = strcat(datafile(1:end-4), '_reflCR', datafile(end-3:end));
refl_cr_hdr_file = strcat(datafile(1:end-4), '_reflCR', '.hdr');
refl_rgb_file = strcat(datafile(1:end-4), '_refl', '.png');
% Read header file
file_hdr = strcat(datafile(1:end-4), '.hdr');

if (exist(refl_file))   %the reflectance was already computed
    fprintf('The reflectance existed \n')
    info = ReadEnviHdr(refl_hdr_file);
    wavelength = info.Wavelength;
    lines = info.lines;
    samples = info.samples;
    bands = info.bands;
    refl = multibandread(refl_file, [lines, samples, bands],'single',0, 'bil','ieee-le' );  
else        
    info = ReadEnviHdr(file_hdr);
    lines = info.lines;
    samples = info.samples;
    bands = info.bands;
    wavelength_org = info.Wavelength;
    % Read the white, dark and sample data
    data = multibandread(datafile, [lines, samples, bands],'uint16',0, 'bil','ieee-le' );
    data_white = multibandread(whitereffile,[90, samples, bands],'uint16',0, 'bil','ieee-le' ); 
    data_dark = multibandread(darkreffile,[90, samples, bands],'uint16',0, 'bil','ieee-le' ); 

    % Calibration correction, compute relative reflectance
    data_dark_ave = mean(data_dark,1);
    data_white_ave = mean(data_white,1);
    data_dark_ave_rep = repmat(data_dark_ave,lines,1, 1);
    data_white_ave_rep = repmat(data_white_ave,lines, 1,1);

    reflectance = (data-data_dark_ave_rep)./(data_white_ave_rep-data_dark_ave_rep + eps);
    if(mean(wavelength_org) > 1100)
        if(short_range)
            short_range_idx = find(wavelength_org >=1050 & wavelength_org <=2450);
        else
            short_range_idx = find(wavelength_org >=1000 & wavelength_org <=2500);
        end
    else
        short_range_idx = find(wavelength_org >=400 & wavelength_org <=1000);
    end
    
    refl = reflectance(:,:,short_range_idx);
    refl(refl<0) = 0;
    refl(refl>1) = 1;
    wavelength = wavelength_org(short_range_idx);
    info.Wavelength = wavelength;
    if(exist('info.fwhm'))
        info.fwhm = info.fwhm(short_range_idx);
    end
    info.bands = length(wavelength);
    % Write file
    multibandwrite(refl, refl_file, 'bil', 'precision', 'single'); % specify the precision is very important
    WriteEnviHdr(info, refl_hdr_file);
end
% Display the false-color image of the sample
%R_WL = 1250; G_WL = 1500; B_WL = 1750; 
if(mean(wavelength > 1100))
    R_WL = 2000; G_WL = 2200; B_WL = 2350; 
else
    R_WL = 700; G_WL = 600; B_WL = 500; 
end
Resolution = (max(wavelength)-min(wavelength))/length(wavelength);
R_index = round((R_WL-min(wavelength))/Resolution);
G_index = round((G_WL-min(wavelength))/Resolution);
B_index = round((B_WL-min(wavelength))/Resolution);
R = refl(:,:,R_index); G = refl(:,:,G_index); B = refl(:,:,B_index);

rgb_img = cat(3,R,G,B);
rgb_img_norm = rgb_img;
rgb_img_norm(:,:,1) = normalize(rgb_img_norm(:,:,1));
rgb_img_norm(:,:,2) = normalize(rgb_img_norm(:,:,2));
rgb_img_norm(:,:,3) = normalize(rgb_img_norm(:,:,3));
rgb_img_he = zeros(size(rgb_img));
rgb_img_he(:,:,1) = histeq(rgb_img(:,:,1));
rgb_img_he(:,:,2) = histeq(rgb_img(:,:,2));
rgb_img_he(:,:,3) = histeq(rgb_img(:,:,3));

figure, subplot 131, imshow(rgb_img), title('False color image')
subplot 132, imshow(rgb_img_norm), title('Normalized image')
subplot 133, imshow(rgb_img_he), title('HEq Image')
imwrite(rgb_img_he, refl_rgb_file);

NN = size(refl);
refl_cr = zeros(NN);
%% Computer CR on refl data and write it to file
if (compute_cr)
    for i = 1: NN(1)
        for ii = 1:NN(2)
            [refl_cr(i,ii,:), temp] = ContinuumRemoval(wavelength, refl(i,ii,:));
        end
    end
    multibandwrite(refl_cr, refl_cr_file, 'bil', 'precision', 'single'); % specify the precision is very important
    WriteEnviHdr(info, refl_cr_hdr_file);
end


