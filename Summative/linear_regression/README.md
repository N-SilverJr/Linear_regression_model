# Student GPA Prediction - Linear Regression Summative

## Mission
To leverage machine learning to predict student academic performance (GPA) based on behavioral, demographic, and socioeconomic factors — enabling educators to identify at-risk students early and implement targeted academic interventions before failure occurs.

## Dataset
**Source:** [Students Performance Dataset – Kaggle (Rabie El Kharoua)](https://www.kaggle.com/datasets/rabieelkharoua/students-performance-dataset)  
**Size:** 2,392 students × 15 features  
**Features:** Study hours/week, absences, parental education, tutoring, extracurricular activities, parental support, sports, music, volunteering  
**Target:** `GPA` (0.0 - 4.0 scale)

## Repository Structure
```
Summative/
├── linear_regression/
│   ├── multivariate.ipynb       # EDA, models, evaluation
│   ├── best_model.pkl           # Saved best model
│   └── Student_performance_data _.csv
├── API/
│   ├── api.py                   # FastAPI application
│   └── requirements.txt         # Python dependencies
└── FlutterApp/
    ├── lib/main.dart            # Flutter app
    └── pubspec.yaml             # Flutter dependencies
```

## API Endpoint (Public)
**Base URL:** `https://linear-regression-model-riws.onrender.com`  
**Swagger UI:** `https://linear-regression-model-riws.onrender.com/docs`

## How to Run

### API
```bash
cd Summative/API
pip install -r requirements.txt
uvicorn api:app --host 0.0.0.0 --port 8000
```

### Flutter App
```bash
cd Summative/FlutterApp
flutter pub get
flutter run
```

## Model Performance
| Model | Test MSE | Test R² |
|-------|----------|---------|
| Linear Regression | 0.0387 | 0.9532 |
| Random Forest | 0.0630 | 0.9238 |
| Decision Tree | 0.1016 | 0.8772 |

**Best Model:** Linear Regression (lowest MSE)

## Video Demo
[YouTube Video Link] - 7-minute demonstration of model deployment
