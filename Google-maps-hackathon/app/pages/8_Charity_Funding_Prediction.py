# Libraries
import streamlit as st
import pandas as pd
import plotly.express as px
import os, os.path
import sklearn
from sklearn import preprocessing
from sklearn import model_selection
from sklearn.metrics import mean_absolute_error, mean_squared_error,r2_score


st.title('OTF Charity Insights')
# Load data
@st.cache
def load_data():
    data = pd.read_excel(DATA_URL)
    return data
DATA_URL = "OTF.xlsx"
df = load_data()

st.header("Charity Funding Prediction")
charity_data = df[['Fiscal Year','City','Grant Programme','Planned Dates','Program Area','Age Group','Budget Fund','Amount Awarded']]

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

col1, col2 = st.columns(2)
with col1:
    year_choice = st.selectbox("Pick a Year",fiscal_year)
    city_choice = st.selectbox("Pick a City",city)
    grant_choice = st.selectbox("Pick a Grant Option",grant)
    program_area_choice = st.selectbox("Pick a Program Area",program_area)
    age_choice = st.selectbox("Pick an Age group",age)
    budget_fund_choice = st.selectbox("Pick a Budget Fund",budget_fund)
    planned_date_choice = st.selectbox("Pick a Planned Date",planned_dates)
    #clicked = st.button("Run Prediction")

with col2:
    output = 0##float("{:.2f}".format(y_pred_test[0]))
    output = str(output) + " CAD"
    st.write("Based on the metrics selected, the predicted funding amount will be: ")
    st.metric("Amount Awarded",output)

    

    # # Regression Model
    # import warnings
    # warnings.simplefilter(action='ignore', category=FutureWarning)
    # model=GradientBoostingRegressor()
    # # Data 
    # model_data = df[['Fiscal_year_update','Recipient_org_city_update','Grant_program',
    #              'Program_area_update','Age_group_update','Budget_fund_update','Amount_awarded']]
    # #Recode data
    # model_data["Recipient_org_city_update"] = model_data["Recipient_org_city_update"].astype('category')
    # model_data["Grant_program"] = model_data["Grant_program"].astype('category')
    # model_data["Program_area_update"] = model_data["Program_area_update"].astype('category')
    # model_data["Age_group_update"] = model_data["Age_group_update"].astype('category')
    # model_data["Budget_fund_update"] = model_data["Budget_fund_update"].astype('category')

    # model_data["Recipient_org_city_update_cat"] = model_data["Recipient_org_city_update"].cat.codes
    # model_data["Grant_program_cat"] = model_data["Grant_program"].cat.codes
    # model_data["Program_area_update_cat"] = model_data["Program_area_update"].cat.codes
    # model_data["Age_group_update_cat"] = model_data["Age_group_update"].cat.codes
    # model_data["Budget_fund_update_cat"] = model_data["Budget_fund_update"].cat.codes

    # # Create train and test data
    # X = model_data[['Fiscal_year_update','Recipient_org_city_update_cat','Grant_program_cat',
    #                 'Program_area_update_cat','Age_group_update_cat','Budget_fund_update_cat']]
    # Y = model_data['Amount_awarded']
    # X_train, X_test, y_train, y_test = train_test_split(X, Y, test_size=0.8, random_state=0)

    # regressor = model.fit(X_train, y_train)
    # y_pred = regressor.predict(X_test)

    # clicked = st.button("Run Prediction")

    # # Run Prediction
    # if clicked:
    #     prediction_df = model_data[(model_data.Recipient_org_city_update == city_choice)]
    #     prediction_df.reset_index(drop=True, inplace=True)
    #     city = prediction_df['Recipient_org_city_update_cat'][0]
    #     prediction_df = model_data[(model_data.Grant_program == grant_choice)]
    #     prediction_df.reset_index(drop=True, inplace=True)
    #     grant = prediction_df['Grant_program_cat'][0]
    #     prediction_df = model_data[(model_data.Program_area_update == program_area_choice)]
    #     prediction_df.reset_index(drop=True, inplace=True)
    #     program_area = prediction_df['Program_area_update_cat'][0]
    #     prediction_df = model_data[(model_data.Age_group_update == age_choice)]
    #     prediction_df.reset_index(drop=True, inplace=True)
    #     age_group = prediction_df['Age_group_update_cat'][0]
    #     prediction_df = model_data[(model_data.Budget_fund_update == budget_fund_choice)]
    #     prediction_df.reset_index(drop=True, inplace=True)
    #     budget_fund = prediction_df['Budget_fund_update_cat'][0]
    #     year = 2022

    #     info_df = pd.DataFrame(columns = ['Fiscal_year_update','Recipient_org_city_update',
    #     'Grant_program','Program_area_update','Age_group_update','Budget_fund_update'],
    #     index = ['a'])
    #     info_df.loc['a'] = [year, city, grant,program_area,age_group,budget_fund]
    #     y_pred_test = regressor.predict(info_df)
    #     output = float("{:.2f}".format(y_pred_test[0]))
    #     output = str(output) + " CAD"
    #     st.write("Based on the metrics selected the amount below is what is predicted for next year")
    #     st.metric("Amount Awarded",output)
