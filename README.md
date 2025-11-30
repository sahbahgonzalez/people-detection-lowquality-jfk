This repository contains the complete implementation, experiments, and documentation for Assignment #2 of CAP 5415 (Computer Vision). The goal is to detect and count people in low-quality historical JFK assassination footage.

# People Detection & Counting in Low-Quality Video (JFK Footage)
**CAP 5415 – Computer Vision – Assignment #2**  
**Student:** Sahbah Gonzalez  
**Instructor:** Dr. Islam  

This project implements a full pipeline for detecting and counting people in
low-quality historical video footage. The JFK footage is used as the test case,
and multiple computer vision methods (preprocessing, super-resolution,
object detection, counting, and robustness analysis) are applied.

The assignment is split into 5 tasks, each implemented in its own folder.

---

## 📁 Project Structure
### Task Folders
- **Task 1 – Preprocessing** → `task1_preprocessing/`
- **Task 2 – People Detection (YOLOv8)** → `task2_detection/`
- **Task 3 – Counting & MAE Evaluation** → `task3_counting/`
- **Task 4 – Detection Evaluation (Precision/Recall/F1)** → `task4_detection_eval/`
- **Task 5 – Robustness to Degradation** → `task5_robustness/`
- **Final Report** → `final_report/report.pdf`


Full datasets (CrowdHuman, JFK full frames, ESRGAN models)  
**are NOT included** due to size limits. See `data/NOTE.md`.

---

## 🔧 Requirements

- Python 3.10+
- PyTorch + CUDA (recommended)
- MATLAB (for FFT enhancement)
- Jupyter / Google Colab
- Ultralytics YOLOv8
- OpenCV, Albumentations, NumPy, Matplotlib

---

## 🚀 How to Run

Each task contains its own `README.md` explaining:
- Dependencies  
- Input/output structure  
- How to run the notebook  
- Expected results  

---

## 📊 Summary of Results

### **Counting Accuracy**
- **MAE = 1.72** on 50 hand-counted frames  
- Excellent performance due to detection + heatmap smoothing

### **Detection Metrics (IoU ≥ 0.5, person class)**
- Precision: **0.267**
- Recall: **0.178**
- F1-score: **0.213**

### **Robustness**
| Degradation | MAE |
|------------|-----|
| Original | **1.72** |
| Gaussian Blur | **1.84** |
| Down→Up Sampling | **4.20** |
| Noise | **10.70** |

---

## 📄 Final Report
The PDF report (4–6 pages, IEEE-style) is included in:  
`final_report/report.pdf`
---

## 📝 Notes
This repository includes **all code**, but excludes all large datasets and model
weights. Instructions for downloading datasets are provided in `data/NOTE.md`.

### Dataset Citation
If you use the CrowdHuman dataset, please cite:

CrowdHuman: A Benchmark for Detecting Human in a Crowd.  
Shao et al., arXiv:1805.00123.

---

## 📬 Contact
If you need anything or have questions:  
**Email:** sahbahgonzalez3276@eagle.fgcu.edu


