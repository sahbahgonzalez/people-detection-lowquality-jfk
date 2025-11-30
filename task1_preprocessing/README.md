# Task 1 – Preprocessing

This folder includes the preprocessing steps used to enhance the low-quality
historical JFK footage.

## Contents
- `FFT_ENHANCE_FRAMES.m`  
  MATLAB script applying frequency-domain sharpening and denoising.

- `Interactive_Real_ESRGAN.ipynb`  
  Google Colab notebook for super-resolution using Real-ESRGAN.

- `sample_before_after/`  
  A few example frames before/after processing.

## How to Run
1. Run MATLAB script on your frame directory:
   This outputs enhanced frames with improved edge clarity.

2. Optionally apply Real-ESRGAN to super-resolve frames.

The output is used as input to detection in Task 2.
