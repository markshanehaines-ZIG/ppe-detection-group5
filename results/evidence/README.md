# Evidence Pack

This folder contains visual evidence of the model's performance.

## Subfolders

| Folder | Contents |
|---|---|
| `annotation_examples/` | Screenshots showing original dataset annotations (bounding boxes on training images) |
| `validation_predictions/` | Model predictions overlaid on validation set images |
| `new_image_predictions/` | Model predictions on previously unseen construction site images |

## How to Generate

All evidence images are generated automatically by the training notebook (`notebooks/PPE_Detection_Training.ipynb`). After running the notebook end-to-end, download the prediction images from the Colab output and place them here.

> **TODO:** Add screenshot images after running the notebook.
