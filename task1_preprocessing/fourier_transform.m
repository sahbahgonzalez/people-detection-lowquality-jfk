function fft_enhance_frames(inDir, outDir, fmt, quality, params)
% FFT_ENHANCE_FRAMES  Fourier-domain enhancement on a folder of frames (no preview).
% Steps (Y channel only): homomorphic (illumination flattening)
%   -> band-pass mid-frequency boost -> high-boost sharpening -> recombine & save.
%
% Usage (good defaults for JFK_1_frames):
%   fft_enhance_frames('JFK_1_frames','JFK_1_frames_FFT','jpg',92);
%
% Optional 'params' fields to override defaults:
%   params.homo.lowGain  (0.55)   params.homo.highGain (1.60)
%   params.homo.cutoff   (0.18)   params.homo.order    (2)
%   params.band.g        (0.35)   params.band.f1       (0.10)
%   params.band.f2       (0.30)   params.band.roll     (0.04)
%   params.boost.amount  (1.00)   params.boost.cutoff  (0.26)

if nargin < 3 || isempty(fmt),     fmt = 'jpg';  end
if nargin < 4 || isempty(quality), quality = 92; end
if nargin < 5, params = struct(); end

% ---- defaults ----
p.homo.lowGain  = 0.55;  p.homo.highGain = 1.60;  p.homo.cutoff = 0.18; p.homo.order = 2;
p.band.g        = 0.35;  p.band.f1 = 0.10;       p.band.f2 = 0.30;     p.band.roll  = 0.04;
p.boost.amount  = 1.00;  p.boost.cutoff  = 0.26;

p = nestedOverride(p, params);

fmt = lower(string(fmt));
assert(any(fmt==["jpg","jpeg","png"]), 'fmt must be jpg or png');
assert(isfolder(inDir), "Input folder not found: " + inDir);
if ~isfolder(outDir), mkdir(outDir); end

% collect frames
exts = {'*.png','*.jpg','*.jpeg','*.tif','*.bmp'};
files = [];
for k=1:numel(exts), files=[files; dir(fullfile(inDir,exts{k}))]; end %#ok<AGROW>
assert(~isempty(files), "No images found in: " + inDir);
[~,ord]=sort(lower({files.name})); files=files(ord);

fprintf('FFT enhance %d frames -> %s (fmt=%s)\n', numel(files), outDir, upper(fmt));
fprintf('Homo: low=%.2f high=%.2f fc=%.2f | Band: g=%.2f f1=%.2f f2=%.2f | Boost: amt=%.2f fc=%.2f\n', ...
    p.homo.lowGain, p.homo.highGain, p.homo.cutoff, p.band.g, p.band.f1, p.band.f2, p.boost.amount, p.boost.cutoff);

for i=1:numel(files)
    inPath = fullfile(inDir, files(i).name);
    [~,base,~] = fileparts(inPath);

    I  = im2double(ensureRGB(imread(inPath)));
    J  = enhanceY_fft(I, p);
    J  = clamp01(J);

    if fmt=="png"
        outPath = fullfile(outDir, base + "_FFT.png");
        try
            imwrite(J, outPath);
        catch ME
            warning('PNG write failed (%s). Falling back to JPEG.', ME.message);
            outPath = fullfile(outDir, base + "_FFT.jpg");
            imwrite(im2uint8(J), outPath, 'Quality', quality);
        end
    else
        outPath = fullfile(outDir, base + "_FFT.jpg");
        imwrite(im2uint8(J), outPath, 'Quality', quality);
    end

    if mod(i,50)==0 || i==numel(files)
        fprintf('Processed %d/%d: %s\n', i, numel(files), files(i).name);
    end
end
fprintf('Done. Saved to %s\n', outDir);
end

% ================= Helpers =================
function J = enhanceY_fft(I, p)
YCC = rgb2ycbcr(I);
Y = YCC(:,:,1); Cb = YCC(:,:,2); Cr = YCC(:,:,3);

Y = homomorphicY(Y, p.homo.lowGain, p.homo.highGain, p.homo.cutoff, p.homo.order);
Y = bandpassBoostY(Y, p.band.g, p.band.f1, p.band.f2, p.band.roll);
Y = highboostY(Y, p.boost.amount, p.boost.cutoff);

J = ycbcr2rgb(cat(3, clamp01(Y), Cb, Cr));
end

function Yout = homomorphicY(Y, lowG, highG, fc, order)
Y = clamp01(Y) + 1e-6; L = log(Y);
[H,W] = size(L);
[u,v] = meshgrid( (-floor(W/2):ceil(W/2)-1)/W, (-floor(H/2):ceil(H/2)-1)/H );
R = sqrt(u.^2 + v.^2);
LP = exp(-(R.^2)/(fc^2));
LPo = LP.^order;
Hmask = lowG .* LPo + highG .* (1 - LPo);
F = fftshift(fft2(L));
L2 = real(ifft2(ifftshift(F .* Hmask)));
Yout = clamp01(mat2gray(exp(L2)));
end

function Yout = bandpassBoostY(Y, g, f1, f2, roll)
[H,W] = size(Y);
[u,v] = meshgrid( (-floor(W/2):ceil(W/2)-1)/W, (-floor(H/2):ceil(H/2)-1)/H );
R = sqrt(u.^2 + v.^2);
edge = @(r0) 0.5*(1+cos(pi*max(0,min(1,(abs(R)-r0)/roll))));
Lo = edge(f1); Hi = 1 - edge(f2);
Band = max(0, min(Lo, Hi));
Gain = 1 + g*Band;
F  = fftshift(fft2(Y));
Yout = real(ifft2(ifftshift(F .* Gain)));
Yout = clamp01(mat2gray(Yout));
end

function Yout = highboostY(Y, amount, fc)
[H,W] = size(Y);
[u,v] = meshgrid( (-floor(W/2):ceil(W/2)-1)/W, (-floor(H/2):ceil(H/2)-1)/H );
R = sqrt(u.^2 + v.^2);
LP = exp(-(R.^2)/(fc^2));
F  = fftshift(fft2(Y));
Y_lp = real(ifft2(ifftshift(F .* LP)));
Y_hp = Y - Y_lp;
Yout = clamp01(Y + amount * Y_hp);
end

function out = ensureRGB(in)
if size(in,3)==1, out = repmat(in,1,1,3); else, out = in(:,:,1:3); end
end
function A = clamp01(A), A(A<0)=0; A(A>1)=1; end
function s = nestedOverride(s, o)
fn = fieldnames(o);
for k=1:numel(fn)
    if isstruct(o.(fn{k})), s.(fn{k}) = nestedOverride(s.(fn{k}), o.(fn{k}));
    else, s.(fn{k}) = o.(fn{k});
    end
end
end
