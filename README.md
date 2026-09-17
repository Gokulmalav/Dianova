# Dianova – Diabetes Prediction App

Dianova is a machine-learning-based project that estimates diabetes risk using a set of health-related inputs. It combines a Python prediction API with a Flutter app so users can enter values and view a prediction result.

> **Disclaimer:** Dianova is an academic project and is not a medical device. Its output is not a diagnosis or a substitute for advice from a qualified healthcare professional.

## What it does

- Accepts health-related input values through the app.
- Sends the input to a backend prediction API.
- Uses a trained machine learning model to generate a prediction.
- Displays the result in the Flutter interface.
- Includes a history screen for viewing previous results within the app.

## Tech Stack

**Machine Learning & Backend**
- Python
- Pandas, NumPy
- Scikit-learn
- Random Forest Classifier
- FastAPI
- Pydantic

**Frontend**
- Flutter
- Dart

## Project Structure

```text
Dianova/
├── backend/
│   ├── diabetes.csv
│   ├── diabetes_model.pkl
│   ├── scaler.pkl
│   ├── graphs.py
│   ├── main.py
│   ├── requirements.txt
│   └── train.py
├── flutter_app/
│   ├── lib/
│   ├── android/
│   ├── ios/
│   ├── web/
│   └── ...
├── research_results.png
├── .gitignore
└── README.md
```

## How the prediction works

1. The dataset is loaded and prepared for training.
2. Missing/invalid zero values in selected medical measurements are handled using median imputation.
3. The features are scaled using `StandardScaler`.
4. A `RandomForestClassifier` is trained on the prepared data.
5. The trained model and scaler are saved and loaded by the FastAPI backend.
6. The Flutter app sends user-entered values to the API and displays the returned prediction.

The training script uses an 80/20 train-test split with stratification and a fixed random seed for reproducibility.

## Getting Started

### 1. Clone the repository

```bash
git clone https://github.com/Gokulmalav/Dianova.git
cd Dianova
```

### 2. Set up the backend

Open a terminal in the backend folder:

```bash
cd backend
```

Create and activate a virtual environment (recommended):

**Windows**
```bash
python -m venv venv
venv\Scripts\activate
```

**macOS / Linux**
```bash
python3 -m venv venv
source venv/bin/activate
```

Install the dependencies:

```bash
pip install -r requirements.txt
```

Start the FastAPI server:

```bash
uvicorn main:app --reload
```

The API's interactive documentation is usually available at:

```text
http://127.0.0.1:8000/docs
```

Keep the backend running while using the app. If the Flutter app uses a configured API base URL, make sure it points to the address reachable from your device or emulator.

### 3. Run the Flutter app

Open another terminal:

```bash
cd flutter_app
flutter pub get
flutter run
```

Choose a connected device or emulator when prompted. Flutter platform setup may be required depending on the device you use.

## Dataset

This project uses the **Pima Indians Diabetes Dataset**.

Dataset source: [Kaggle – Pima Indians Diabetes Dataset](https://www.kaggle.com/datasets/jamaltariqcheema/pima-indians-diabetes-dataset)

## Model Training

To retrain the model, run the training script from the backend directory:

```bash
python train.py
```

The script saves the trained model and scaler as:

- `diabetes_model.pkl`
- `scaler.pkl`

These files are used by the backend for prediction.

## Notes

- The backend and Flutter app need to be configured to communicate with each other.
- Do not use real patient information in a public demo or repository.
- Model performance depends on the dataset and training setup; predictions may be incorrect.
- This repository is shared for learning and academic demonstration.

## Author

**Gokul Malav**

MCA Student | Artificial Intelligence & Data Science
