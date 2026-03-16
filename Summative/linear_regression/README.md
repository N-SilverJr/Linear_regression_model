# 🎓 Predicting Student GPA — Linear Regression Summative

## Mission
To leverage machine learning to predict student academic performance (GPA) based on behavioral, demographic, and socioeconomic factors — enabling educators to identify at-risk students early and implement targeted academic interventions before failure occurs.

## Dataset
**Source:** [Students Performance Dataset – Kaggle (Rabie El Kharoua)](https://www.kaggle.com/datasets/rabieelkharoua/students-performance-dataset)  
**Size:** 2,392 students × 15 features  
**Features include:** Study hours/week, absences, parental education, tutoring, extracurricular activities, parental support, sports, music, volunteering  
**Target Variable:** `GPA` (continuous — regression task)

## Repository Structure

```
linear_regression_model/
│
├── summative/
│   ├── linear_regression/
│   │   ├── multivariate.ipynb       ← Main notebook (EDA, models, evaluation)
│   │   ├── best_model.pkl           ← Saved best-performing model
│   │   ├── scaler.pkl               ← Saved StandardScaler
│   │   └── Student_performance_data _.csv  ← Dataset (download from Kaggle)
│   ├── API/                         ← (To be completed)
│   └── FlutterApp/                  ← (To be completed)
│
└── README.md
```

## Models Trained
| Model | Description |
|---|---|
| Linear Regression | Closed-form solution via scikit-learn |
| Linear Regression (GD) | Gradient descent via SGDRegressor — loss curve plotted |
| Decision Tree | Depth-limited regressor |
| **Random Forest** | **Best performer** — 200 estimators |

## How to Run
1. Download the dataset from the Kaggle link above
2. Place `Student_performance_data _.csv` in `summative/linear_regression/`
3. Open `multivariate.ipynb` in Jupyter and run all cells
4. The best model is automatically saved as `best_model.pkl`
