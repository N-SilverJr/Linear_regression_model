"""
FastAPI for Student GPA Prediction
Mission: Predict student academic performance (GPA) for early intervention
"""

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field, field_validator
from typing import List
import joblib
import numpy as np
import os

app = FastAPI(
    title="Student GPA Prediction API",
    description="API for predicting student GPA based on behavioral, demographic, and socioeconomic factors",
    version="1.0.0"
)

origins = [
    "http://localhost:3000",
    "http://localhost:8080",
    "https://student-gpa-predictor.onrender.com",
    "https://*.render.com",
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE", "OPTIONS"],
    allow_headers=["Authorization", "Content-Type", "Accept"],
)

MODEL_PATH = "best_model.pkl"
model = None


def load_model():
    global model
    if os.path.exists(MODEL_PATH):
        model = joblib.load(MODEL_PATH)
        return True
    return False


load_model()


class PredictionInput(BaseModel):
    Age: int = Field(..., ge=15, le=18, description="Student age (15-18)")
    Gender: int = Field(..., ge=0, le=1, description="Gender (0=Male, 1=Female)")
    Ethnicity: int = Field(..., ge=0, le=3, description="Ethnicity (0-3)")
    ParentalEducation: int = Field(..., ge=0, le=4, description="Parental education level (0-4)")
    StudyTimeWeekly: float = Field(..., ge=0.0, le=20.0, description="Weekly study hours (0-20)")
    Absences: int = Field(..., ge=0, le=30, description="Number of absences (0-30)")
    Tutoring: int = Field(..., ge=0, le=1, description="Tutoring status (0=No, 1=Yes)")
    ParentalSupport: int = Field(..., ge=0, le=4, description="Parental support level (0-4)")
    Extracurricular: int = Field(..., ge=0, le=1, description="Extracurricular activities (0=No, 1=Yes)")
    Sports: int = Field(..., ge=0, le=1, description="Sports participation (0=No, 1=Yes)")
    Music: int = Field(..., ge=0, le=1, description="Music activities (0=No, 1=Yes)")
    Volunteering: int = Field(..., ge=0, le=1, description="Volunteering (0=No, 1=Yes)")

    @field_validator('Age', 'Gender', 'Ethnicity', 'ParentalEducation', 'Absences', 
                     'Tutoring', 'ParentalSupport', 'Extracurricular', 'Sports', 'Music', 'Volunteering')
    @classmethod
    def check_integer(cls, v):
        if not isinstance(v, int) or isinstance(v, bool):
            raise ValueError(f"Expected integer, got {type(v).__name__}")
        return v

    class Config:
        json_schema_extra = {
            "example": {
                "Age": 16,
                "Gender": 1,
                "Ethnicity": 2,
                "ParentalEducation": 3,
                "StudyTimeWeekly": 10.5,
                "Absences": 5,
                "Tutoring": 1,
                "ParentalSupport": 3,
                "Extracurricular": 0,
                "Sports": 1,
                "Music": 0,
                "Volunteering": 1
            }
        }


class PredictionOutput(BaseModel):
    predicted_gpa: float
    message: str


class RetrainInput(BaseModel):
    new_data_path: str = Field(None, description="Path to new CSV data file")
    
    class Config:
        json_schema_extra = {
            "example": {
                "new_data_path": "new_student_data.csv"
            }
        }


class RetrainOutput(BaseModel):
    success: bool
    message: str
    previous_mse: float = None
    new_mse: float = None


class ModelStatus(BaseModel):
    model_loaded: bool
    model_type: str = None
    features: List[str] = None


@app.get("/", tags=["Health"])
async def root():
    return {"message": "Student GPA Prediction API is running", "version": "1.0.0"}


@app.get("/status", tags=["Status"], response_model=ModelStatus)
async def get_status():
    if model is None:
        return ModelStatus(model_loaded=False)
    
    model_name = type(model.named_steps['model']).__name__
    feature_names = list(model.named_steps['preprocessor'].feature_names_in_)
    
    return ModelStatus(
        model_loaded=True,
        model_type=model_name,
        features=feature_names
    )


@app.post("/predict", tags=["Prediction"], response_model=PredictionOutput)
async def predict(input_data: PredictionInput):
    if model is None:
        raise HTTPException(status_code=503, detail="Model not loaded. Please retrain the model first.")
    
    try:
        input_dict = input_data.model_dump()
        feature_names = [
            'Age', 'Gender', 'Ethnicity', 'ParentalEducation', 'StudyTimeWeekly',
            'Absences', 'Tutoring', 'ParentalSupport', 'Extracurricular', 
            'Sports', 'Music', 'Volunteering'
        ]
        
        features = np.array([[input_dict[feat] for feat in feature_names]])
        
        prediction = model.predict(features)[0]
        
        prediction = max(0.0, min(4.0, prediction))
        
        return PredictionOutput(
            predicted_gpa=round(float(prediction), 4),
            message="Prediction successful"
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Prediction error: {str(e)}")


@app.post("/retrain", tags=["Model Management"], response_model=RetrainOutput)
async def retrain_model(input_data: RetrainInput = None):
    """
    Retrain the model with new data.
    If new_data_path is provided, uses that data.
    Otherwise, retrains on the original dataset.
    """
    global model
    
    try:
        from sklearn.model_selection import train_test_split
        from sklearn.metrics import mean_squared_error
        from sklearn.preprocessing import StandardScaler
        from sklearn.linear_model import LinearRegression
        from sklearn.pipeline import Pipeline
        from sklearn.compose import ColumnTransformer
        import pandas as pd
        
        if input_data and input_data.new_data_path and os.path.exists(input_data.new_data_path):
            df = pd.read_csv(input_data.new_data_path)
        else:
            csv_path = "Student_performance_data _.csv"
            if not os.path.exists(csv_path):
                return RetrainOutput(
                    success=False,
                    message=f"Original dataset not found at {csv_path}. Please provide new_data_path."
                )
            df = pd.read_csv(csv_path)
        
        if model is not None:
            from sklearn.metrics import mean_squared_error
            X_test_sample = None
            y_test_sample = None
            
            if hasattr(model, 'named_steps'):
                temp_features = [
                    'Age', 'Gender', 'Ethnicity', 'ParentalEducation', 'StudyTimeWeekly',
                    'Absences', 'Tutoring', 'ParentalSupport', 'Extracurricular', 
                    'Sports', 'Music', 'Volunteering'
                ]
                if all(f in df.columns for f in temp_features):
                    X_temp = df[temp_features]
                    y_temp = df['GPA']
                    X_train_s, X_test_s, y_train_s, y_test_s = train_test_split(
                        X_temp, y_temp, test_size=0.2, random_state=42
                    )
                    prev_pred = model.predict(X_test_s)
                    previous_mse = mean_squared_error(y_test_s, prev_pred)
                else:
                    previous_mse = None
            else:
                previous_mse = None
        else:
            previous_mse = None
        
        id_cols = [c for c in df.columns if c.lower() in ['studentid', 'id', 'student_id']]
        if id_cols:
            df.drop(columns=id_cols, inplace=True)
        
        if 'GradeClass' in df.columns:
            df.drop(columns=['GradeClass'], inplace=True)
        
        numeric_cols = [c for c in df.columns if c != 'GPA']
        
        X = df[numeric_cols]
        y = df['GPA']
        
        X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
        
        preprocessor = ColumnTransformer(
            transformers=[('num', StandardScaler(), numeric_cols)],
            remainder='drop'
        )
        
        new_pipeline = Pipeline(steps=[
            ('preprocessor', preprocessor),
            ('model', LinearRegression())
        ])
        
        new_pipeline.fit(X_train, y_train)
        y_pred = new_pipeline.predict(X_test)
        new_mse = mean_squared_error(y_test, y_pred)
        
        joblib.dump(new_pipeline, MODEL_PATH)
        model = new_pipeline
        
        return RetrainOutput(
            success=True,
            message="Model retrained successfully",
            previous_mse=round(previous_mse, 4) if previous_mse else None,
            new_mse=round(new_mse, 4)
        )
        
    except ImportError as e:
        raise HTTPException(status_code=500, detail=f"Missing dependency: {str(e)}")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Retraining error: {str(e)}")


@app.get("/predict_form", tags=["Prediction"])
async def predict_form():
    return {
        "features": [
            {"name": "Age", "type": "integer", "min": 15, "max": 18},
            {"name": "Gender", "type": "integer", "min": 0, "max": 1},
            {"name": "Ethnicity", "type": "integer", "min": 0, "max": 3},
            {"name": "ParentalEducation", "type": "integer", "min": 0, "max": 4},
            {"name": "StudyTimeWeekly", "type": "float", "min": 0.0, "max": 20.0},
            {"name": "Absences", "type": "integer", "min": 0, "max": 30},
            {"name": "Tutoring", "type": "integer", "min": 0, "max": 1},
            {"name": "ParentalSupport", "type": "integer", "min": 0, "max": 4},
            {"name": "Extracurricular", "type": "integer", "min": 0, "max": 1},
            {"name": "Sports", "type": "integer", "min": 0, "max": 1},
            {"name": "Music", "type": "integer", "min": 0, "max": 1},
            {"name": "Volunteering", "type": "integer", "min": 0, "max": 1},
        ]
    }


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
