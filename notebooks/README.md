# Notebooks

This folder contains the end-to-end training and evaluation notebook.

## Files

| Notebook | Description |
|----------|-------------|
| `MAICEN_1125_M4_U4_Group_5_Assignment.ipynb` | Full pipeline: data loading → pseudo-labeling → training → evaluation → predictions |

## How to Run

1. Click the notebook file above
2. Click the **"Open in Colab"** badge at the top of the notebook
3. Set runtime to **GPU** (Runtime → Change runtime type → T4 GPU)
4. Upload `best.pt` from [GitHub Releases v1.0](https://github.com/markshanehaines-ZIG/ppe-detection-group5/releases/tag/v1.0)
5. **Runtime → Restart runtime and run all**
6. Expected runtime: ~10 minutes (verification) or ~2-3 hours (full training)

⚠️ The notebook is designed to run in both Google Colab and locally in VS Code. All dependencies are installed automatically in Colab via Cell 0.0.
