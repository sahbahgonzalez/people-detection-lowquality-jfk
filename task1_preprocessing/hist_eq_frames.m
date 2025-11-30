function hist_eq_frames(inDir, outDir, method)
% HIST_EQ_FRAMES  Histogram equalization on a folder of frames.
% Only luminance (Y) is equalized; color (Cb/Cr) is preserved.
%
% Usage:
%   hist_eq_frames('JFK_1_frames','JFK_1_frames_HEQ','clahe');   % adaptive (recommended)
%
% inDir  : folder containing original frames (png/jpg/jpeg/tif/bmp)
% outDir : folder to write processed frames (created if missing)
% method : 'clahe' (adapthisteq) or 'global' (histeq)

if nargin < 3 || isempty(method), method = 'clahe'; end
method = lower(string(method));
assert(isfolder(inDir), "Input folder not found: " + inDir);

if ~isfolder(outDir), mkdir(outDir); end

% Collect images
exts = {'*.png','*.jpg','*.jpeg','*.tif','*.bmp'};
files = [];
for k = 1:numel(exts)
    files = [files; dir(fullfile(inDir, exts{k}))]; %#ok<AGROW>
end
assert(~isempty(files), "No images found in: " + inDir);

% Sort by name
[~, order] = sort(lower({files.name}));
files = files(order);

fprintf('Found %d frames in %s\n', numel(files), inDir);
fprintf('Method: %s (Y channel only)\n', upper(method));

for i = 1:numel(files)
    inPath  = fullfile(inDir, files(i).name);
    [~, base, ~] = fileparts(inPath);
    outPath = fullfile(outDir, base + "_HEQ.png");  % write PNGs

    I = imread(inPath);
    I = ensureRGB(I);
    I = im2double(I);

    % RGB -> YCbCr
    YCbCr = rgb2ycbcr(I);
    Y  = YCbCr(:,:,1);
    Cb = YCbCr(:,:,2);
    Cr = YCbCr(:,:,3);

    % Histogram equalization on luminance
    switch method
        case "clahe"
            % Adaptive histogram equalization (CLAHE) for safer contrast
            % Tweak NumTiles/ClipLimit if needed
            Yeq = adapthisteq(Y, 'NumTiles',[8 8], 'ClipLimit',0.01);
        case "global"
            % Classic global equalization
            Yeq = histeq(Y);
        otherwise
            error('Unknown method: %s (use "clahe" or "global")', method);
    end

    % Recombine and save
    out = ycbcr2rgb(cat(3, Yeq, Cb, Cr));
    out = clamp01(out);
    imwrite(out, outPath);

    if mod(i,50)==0 || i==numel(files)
        fprintf('Processed %d/%d: %s\n', i, numel(files), files(i).name);
    end
end

fprintf('Done. Wrote frames to %s\n', outDir);
end

% --------- helpers ----------
function img = ensureRGB(img)
if size(img,3)==1
    img = repmat(img,1,1,3);
elseif size(img,3)>3
    img = img(:,:,1:3);
end
end

function A = clamp01(A)
A(A<0) = 0; A(A>1) = 1;
end
