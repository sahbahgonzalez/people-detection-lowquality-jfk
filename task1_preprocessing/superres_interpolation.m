function sr_interpolation_frames(inDir, outDir, scale, method, fmt, quality)
% SR_INTERPOLATION_FRAMES  Plain interpolation-based super-resolution.
% - Y (luminance) upscaled with chosen method (default: bicubic)
% - Cb/Cr (chroma) upscaled with bilinear (avoids color halos)
% - Writes enhanced frames to a new folder (PNG or JPEG)
%
% Usage:
%   sr_interpolation_frames('JFK_1_frames','JFK_1_frames_SR',2,'bicubic','jpg',92)

if nargin < 3 || isempty(scale),  scale  = 2;         end
if nargin < 4 || isempty(method), method = 'bicubic'; end
if nargin < 5 || isempty(fmt),    fmt    = 'jpg';     end   % 'png' or 'jpg'
if nargin < 6 || isempty(quality),quality = 92;       end   % JPEG quality 1–100

method = lower(string(method));
fmt    = lower(string(fmt));
assert(any(method==["nearest","bilinear","bicubic"]), 'method must be nearest|bilinear|bicubic');
assert(any(fmt==["png","jpg","jpeg"]), 'fmt must be png or jpg');
assert(isfolder(inDir), "Input folder not found: " + inDir);
if ~isfolder(outDir), mkdir(outDir); end

% Collect frames
exts = {'*.png','*.jpg','*.jpeg','*.tif','*.bmp'};
files = [];
for k = 1:numel(exts)
    files = [files; dir(fullfile(inDir, exts{k}))]; %#ok<AGROW>
end
assert(~isempty(files), "No images found in: " + inDir);
[~, order] = sort(lower({files.name}));
files = files(order);

fprintf('Found %d frames. Scale=%dx, method=%s, format=%s\n', numel(files), scale, upper(method), upper(fmt));

for i = 1:numel(files)
    inPath = fullfile(inDir, files(i).name);
    [~, base, ~] = fileparts(inPath);

    % Read & prepare
    rgb = im2double(ensureRGB(imread(inPath)));
    ycb = rgb2ycbcr(rgb);
    Y  = ycb(:,:,1); Cb = ycb(:,:,2); Cr = ycb(:,:,3);

    % Upscale
    Ho = size(Y,1)*scale;  Wo = size(Y,2)*scale;
    Y_up  = imresize(Y,  [Ho, Wo], char(method));  % detail-sensitive
    Cb_up = imresize(Cb, [Ho, Wo], 'bilinear');    % safer for color
    Cr_up = imresize(Cr, [Ho, Wo], 'bilinear');

    out = clamp01(ycbcr2rgb(cat(3, Y_up, Cb_up, Cr_up)));

    % Write
    if fmt == "png"
        outPath = fullfile(outDir, base + "_SR.png");
        imwrite(out, outPath);
    else
        outPath = fullfile(outDir, base + "_SR.jpg");
        imwrite(im2uint8(out), outPath, 'Quality', quality);
    end

    if mod(i,50)==0 || i==numel(files)
        fprintf('Processed %d/%d: %s\n', i, numel(files), files(i).name);
    end
end

fprintf('Done. Enhanced frames saved to: %s\n', outDir);
end

% ---- helpers ----
function img = ensureRGB(img)
if size(img,3)==1, img = repmat(img,1,1,3); end
if size(img,3)>3,  img = img(:,:,1:3);      end
end

function A = clamp01(A)
A(A<0)=0; A(A>1)=1;
end
