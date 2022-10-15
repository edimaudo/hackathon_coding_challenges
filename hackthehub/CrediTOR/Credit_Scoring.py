# Libraries
import streamlit as st
import pandas as pd
import plotly.express as px
import os, os.path
import sklearn
from sklearn import preprocessing
from sklearn import model_selection
from sklearn.metrics import mean_absolute_error, mean_squared_error,r2_score
from sklearn.model_selection import cross_val_score,train_test_split, TimeSeriesSplit, GridSearchCV, RandomizedSearchCV
from sklearn.preprocessing import LabelEncoder, MinMaxScaler, StandardScaler, OneHotEncoder
from sklearn.linear_model import LinearRegression
from sklearn import ensemble
from sklearn.ensemble import RandomForestRegressor,GradientBoostingRegressor, VotingRegressor
from sklearn.neighbors import KNeighborsRegressor
import warnings
warnings.simplefilter(action='ignore', category=FutureWarning)
import random
import pickle
from pycaret.classification import *

st.set_page_config(
    page_title="CrediTOR",
    page_icon="loan.png"
)

st.title('CrediTOR')
st.image("loan.png")
st.set_option('deprecation.showPyplotGlobalUse', False)

st.header("About")
with st.expander(" "):
    st.write(""" 
        Credit Scoring tool for analysts.
    """)

st.header("Credit Scoring")
age_choice = st.slider('Select Age', 0, 130, 1)
number_dependent_choice = st.slider('# of Dependents', 0, 30, 1)
monthly_income_choice = st.number_input("Montly Income",min_value=0, max_value=10000000)
debt_ratio_choice = st.number_input("Debt Ratio",min_value=0, max_value=100000)
revolving_credit_choice = st.number_input("Select revolving credit",min_value=0, max_value=10000)
open_credit_choice = st.slider('# of Credit Lines / Loans', 0, 100, 1)
real_estate_choice = st.slider('# of Real Estate Loans Or Lines', 0, 100, 1)
past_due_30_choice = st.slider('# of Times 30-59 Days Past Due', 0, 100, 1)
past_due_60_choice = st.slider('# of Times 60-89 Days Past Due', 0, 100, 1)
past_due_90_choice = st.slider('# of Times 90 Days Past Due', 0, 100, 1)
clicked = st.button("Run Scoring Model")

if clicked:
    info_df = pd.DataFrame(columns = ['RevolvingUtilizationOfUnsecuredLines','age','NumberOfTime30-59DaysPastDueNotWorse',
    'DebtRatio','MonthlyIncome','NumberOfOpenCreditLinesAndLoans','NumberOfTimes90DaysLate','NumberRealEstateLoansOrLines',
    'NumberOfTime60-89DaysPastDueNotWorse','NumberOfDependents'],index = ['a'])
    info_df.loc['a'] = [revolving_credit_choice,age_choice,past_due_30_choice,debt_ratio_choice,monthly_income_choice,
    open_credit_choice,past_due_90_choice,real_estate_choice,past_due_60_choice,number_dependent_choice]
    # load model
    saved_final_lgbm = load_model('Final LGBM')
    # Prediction
    new_prediction = predict_model(saved_final_lgbm, data=info_df)
    
    #st.markdown("Based on the metrics selected, the client is: ")
    ## a choice information
    #if btn_predict:
    #    pred = model.predict_proba(user_input)[:, 1]

    #if pred[0] < 0.78:
    #    st.error('Warning! The applicant has a high risk to not pay the loan back!')
    #else:
    #    st.success('It is green! The aplicant has a high probability to pay the loan back!')

    			




