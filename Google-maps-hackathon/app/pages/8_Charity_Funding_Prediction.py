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

st.title('OTF Charity Insights')
# Load data
@st.cache
def load_data():
    data = pd.read_excel(DATA_URL)
    return data
DATA_URL = "OTF.xlsx"
df = load_data()

st.header("Charity Funding Prediction")
charity_data = df[['Fiscal Year','City','Grant Programme','Planned Dates',
'Program Area','Age Group','Budget Fund','Amount Awarded']]

fiscal_year = [2022,2023,2024,2025]

city = charity_data['City'].unique()
city  = city.astype('str')
city.sort()

grant = charity_data['Grant Programme'].unique()
grant  = grant.astype('str')
grant.sort()

program_area = charity_data['Program Area'].unique()
program_area  = program_area.astype('str')
program_area.sort()

age = charity_data['Age Group'].unique()
age  = age.astype('str')
age.sort()

planned_dates = charity_data['Planned Dates'].unique()
planned_dates  = planned_dates.astype('int')
planned_dates.sort()

budget_fund = charity_data['Budget Fund'].unique()
budget_fund  = budget_fund.astype('str')
budget_fund.sort()

year_choice = st.selectbox("Pick a Year",fiscal_year)
city_choice = st.selectbox("Pick a City",city)
grant_choice = st.selectbox("Pick a Grant Option",grant)
program_area_choice = st.selectbox("Pick a Program Area",program_area)
age_choice = st.selectbox("Pick an Age group",age)
budget_fund_choice = st.selectbox("Pick a Budget Fund",budget_fund)
planned_date_choice = st.selectbox("Pick a Plan Date",planned_dates)
clicked = st.button("Run Prediction")

# Loading model to compare the results
model = pickle.load(open('model.pkl','rb'))


# Data munging
model_data = df[['Fiscal Year','City','Grant Programme','Planned Dates',
    'Program Area','Age Group','Budget Fund','Amount Awarded']]
model_data["City"] = model_data["City"].astype('category')
model_data["Grant Programme"] = model_data["Grant Programme"].astype('category')
model_data["Program Area"] = model_data["Program Area"].astype('category')
model_data["Age Group"] = model_data["Age Group"].astype('category')
model_data["Budget Fund"] = model_data["Budget Fund"].astype('category')
model_data["City_cat"] = model_data["City"].cat.codes
model_data["Grant_program_cat"] = model_data["Grant Programme"].cat.codes
model_data["Program_area_cat"] = model_data["Program Area"].cat.codes
model_data["Age_group_cat"] = model_data["Age Group"].cat.codes
model_data["Budget_fund_cat"] = model_data["Budget Fund"].cat.codes


# Run model
year = year_choice
prediction_df = model_data[(model_data.City == city_choice)]
prediction_df.reset_index(drop=True, inplace=True)
city = prediction_df['City_cat'][0]       
prediction_df = model_data[(model_data['Grant Programme'] == grant_choice)]
prediction_df.reset_index(drop=True, inplace=True)
grant = prediction_df['Grant_program_cat'][0]
prediction_df = model_data[(model_data['Planned Dates'] == planned_date_choice)]
prediction_df.reset_index(drop=True, inplace=True)
planned_date = prediction_df['Planned Dates'][0]
prediction_df = model_data[(model_data['Program Area'] == program_area_choice)]
prediction_df.reset_index(drop=True, inplace=True)
program_area = prediction_df['Program_area_cat'][0]  
prediction_df = model_data[(model_data['Age Group'] == age_choice)]
prediction_df.reset_index(drop=True, inplace=True)
age_group = prediction_df['Age_group_cat'][0]      
prediction_df = model_data[(model_data['Budget Fund'] == budget_fund_choice)]
prediction_df.reset_index(drop=True, inplace=True)
budget_fund = prediction_df['Budget_fund_cat'][0]
info_df = pd.DataFrame(columns = ['Fiscal Year','City','Grant Programme','Planned Dates',
    'Program Area','Age Group','Budget Fund'],
index = ['a'])
info_df.loc['a'] = [year, city, grant,planned_date,program_area,age_group,budget_fund]
y_pred_test = model.predict(info_df)

if clicked:
    output = float("{:.2f}".format(y_pred_test[0]))
    output = str(output) + " CAD"
    st.markdown("Based on the metrics selected, the estimated **Amount Awarded** could be: ")
    st.metric(" ",output)
        





