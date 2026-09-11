from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
import numpy as np
import pickle
import os

app = FastAPI(
    title="Dianova Prediction API",
    description="ML-powered diabetes risk prediction",
    version="1.0.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

model = None
scaler = None

@app.on_event("startup")
async def load_model():
    global model, scaler
    if os.path.exists("diabetes_model.pkl"):
        with open("diabetes_model.pkl", "rb") as f:
            model = pickle.load(f)
        with open("scaler.pkl", "rb") as f:
            scaler = pickle.load(f)
        print("✅ Model loaded successfully")
    else:
        print("⚠️ No model found. Run train.py first.")


class PredictionRequest(BaseModel):
    pregnancies: float = Field(..., ge=0, le=20)
    glucose: float = Field(..., ge=0, le=300)
    blood_pressure: float = Field(..., ge=0, le=200)
    skin_thickness: float = Field(..., ge=0, le=100)
    insulin: float = Field(..., ge=0, le=900)
    bmi: float = Field(..., ge=0, le=70)
    diabetes_pedigree: float = Field(..., ge=0, le=3)
    age: float = Field(..., ge=1, le=120)


class PredictionResponse(BaseModel):
    diabetic: bool
    probability: float
    risk_level: str
    confidence: float
    feature_importance: dict
    recommendations: list[str]


@app.get("/health")
async def health():
    return {"status": "healthy", "model_loaded": model is not None}


@app.post("/predict", response_model=PredictionResponse)
async def predict(request: PredictionRequest):
    if model is None:
        raise HTTPException(status_code=503, detail="Model not loaded. Run train.py first.")

    features = np.array([[
        request.pregnancies, request.glucose, request.blood_pressure,
        request.skin_thickness, request.insulin, request.bmi,
        request.diabetes_pedigree, request.age
    ]])

    features_scaled = scaler.transform(features)
    prediction = model.predict(features_scaled)[0]
    probabilities = model.predict_proba(features_scaled)[0]
    probability = float(probabilities[1])

    if probability < 0.25:
        risk_level = "Low"
    elif probability < 0.50:
        risk_level = "Moderate"
    elif probability < 0.75:
        risk_level = "High"
    else:
        risk_level = "Very High"

    feature_names = [
        "Pregnancies", "Glucose", "BloodPressure", "SkinThickness",
        "Insulin", "BMI", "DiabetesPedigree", "Age"
    ]
    importances = dict(zip(feature_names, model.feature_importances_.tolist()))
    recommendations = generate_recommendations(request, probability)

    return PredictionResponse(
        diabetic=bool(prediction),
        probability=round(probability, 4),
        risk_level=risk_level,
        confidence=round(float(max(probabilities)), 4),
        feature_importance=importances,
        recommendations=recommendations
    )


def generate_recommendations(req, probability):
    recs = []
    if req.glucose > 140:
        recs.append("Glucose is high. Reduce sugary foods and monitor regularly.")
    elif req.glucose > 100:
        recs.append("Glucose is borderline. Reduce refined carbohydrates.")
    if req.bmi > 30:
        recs.append("BMI indicates obesity. Aim for gradual weight loss.")
    elif req.bmi > 25:
        recs.append("BMI is overweight. Regular exercise can reduce risk.")
    if req.blood_pressure > 90:
        recs.append("Blood pressure is high. Reduce sodium and manage stress.")
    if req.age > 45:
        recs.append("Age is a risk factor. Annual diabetes screening is advised.")
    if req.diabetes_pedigree > 0.5:
        recs.append("Family history detected. Maintain a healthy lifestyle.")
    if probability > 0.5:
        recs.append("High risk detected. Consult a healthcare professional.")
    else:
        recs.append("Keep up regular exercise and a balanced diet.")
    return recs[:4]