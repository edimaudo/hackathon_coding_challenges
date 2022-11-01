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
import datetime

st.title('WebSocialytics Insights')

# Load data
@st.cache(allow_output_mutation=True)
def load_data():
    data = pd.read_csv(DATA_URL)
    return data
DATA_URL = "CustomerReviews2000.csv"
df = load_data()

st.header("Product Classification")

model_df = df[['ProductCategory','ProductPrice',
               'RetailerName','RetailerCity','RetailerState',
               'ManufacturerName','UserAge','UserGender','UserOccupation',
               'ReviewDate','ReviewRating']]
               
model_df['Month'] = pd.to_datetime(df['ReviewDate']).dt.month_name()
model_df['Year'] = pd.DatetimeIndex(df['ReviewDate']).year

#drop down
nlp_product_cat_list = model_df['ProductCategory'].unique()
nlp_product_cat_list  = nlp_product_cat_list.astype('str')
nlp_product_cat_list.sort()

nlp_retailer_list = model_df['RetailerName'].unique()
nlp_retailer_list  = nlp_retailer_list.astype('str')
nlp_retailer_list.sort()

nlp_retailer_city_list = model_df['RetailerCity'].unique()
nlp_retailer_city_list  = nlp_retailer_city_list.astype('str')
nlp_retailer_city_list.sort()

nlp_manufacturer_list = model_df['ManufacturerName'].unique()
nlp_manufacturer_list = nlp_manufacturer_list.astype('str')
nlp_manufacturer_list.sort()

nlp_gender_list = model_df['UserGender'].unique()
nlp_gender_list = nlp_gender_list.astype('str')
nlp_gender_list.sort()

nlp_occupation_list = model_df['UserOccupation'].unique()
nlp_occupation_list = nlp_occupation_list.astype('str')
nlp_occupation_list.sort()

nlp_month_list = model_df['Month'].unique()
nlp_month_list = pd.DataFrame(nlp_month_list,columns = ['Month'])
month_dict = {'January':1,'February':2,'March':3, 'April':4, 'May':5, 'June':6, 'July':7, 
'August':8, 'September':9, 'October':10, 'November':11, 'December':12}
nlp_month_list = nlp_month_list.sort_values('Month', key = lambda x : x.apply (lambda x : month_dict[x]))

model_data = model_df[['ProductCategory','ProductPrice',
               'RetailerName','RetailerCity','RetailerState',
               'ManufacturerName','UserAge','UserGender','UserOccupation',
               'Month','Year','ReviewRating']]
# Recode
model_data["ProductCategory"] = model_data["ProductCategory"].astype('category')
model_data["RetailerName"] = model_data["RetailerName"].astype('category')
model_data["RetailerCity"] = model_data["RetailerCity"].astype('category')
model_data["ManufacturerName"] = model_data["ManufacturerName"].astype('category')
model_data["UserGender"] = model_data["UserGender"].astype('category')
model_data["UserOccupation"] = model_data["UserOccupation"].astype('category')
model_data["Month"] = model_data["Month"].astype('category')

model_data["ProductCategory_cat"] = model_data["ProductCategory"].cat.codes
model_data["RetailerName_cat"] = model_data["RetailerName"].cat.codes
model_data["RetailerCity_cat"] = model_data["RetailerCity"].cat.codes
model_data["ManufacturerName_cat"] = model_data["ManufacturerName"].cat.codes
model_data["UserGender_cat"] = model_data["UserGender"].cat.codes
model_data["UserOccupation_cat"] = model_data["UserOccupation"].cat.codes
model_data["Month_cat"] = model_data["Month"].cat.codes


with st.sidebar:
    nlp_month_choice = st.selectbox("Month",nlp_month_list)
    nlp_year_choice = st.selectbox('Year', [2012,2013,2014,2015,2016,2017,2018,2019,2020,2021,2022])
    nlp_price_choice = st.slider('Price', 100, 2500, 50)
    nlp_category_choice = st.selectbox("Category",nlp_product_cat_list)
    nlp_retailer_choice = st.selectbox("Retailer",nlp_retailer_list)
    nlp_manufacturer_choice = st.selectbox("Manufacturer",nlp_manufacturer_list)
    nlp_city_choice = st.selectbox("City",nlp_retailer_city_list)
    nlp_occupation_choice = st.selectbox("Occupation",nlp_occupation_list)
    nlp_gender_choice = st.selectbox("Gender",nlp_gender_list)
    nlp_age_choice = st.slider('Age', 18,70 , 18)

clicked = st.button("Predict Rating")
if clicked:
        
    model_info = model_data[(model_data.ProductCategory == nlp_category_choice)]
    model_info.reset_index(drop=True, inplace=True)
    product_category = model_info['ProductCategory_cat'][0]

    model_info = model_data[(model_data.RetailerName == nlp_category_choice)]
    model_info.reset_index(drop=True, inplace=True)
    retailer = model_info['RetailerName_cat'][0]

    model_info = model_data[(model_data.RetailerCity == nlp_city_choice)]
    model_info.reset_index(drop=True, inplace=True)
    city = model_info['RetailerCity_cat'][0]

    model_info = model_data[(model_data.ManufacturerName == nlp_manufacturer_choice)]
    model_info.reset_index(drop=True, inplace=True)
    manufacturer = model_info['ManufacturerName_cat'][0]

    model_info = model_data[(model_data.UserGender == nlp_gender_choice)]
    model_info.reset_index(drop=True, inplace=True)
    gender = model_info['UserGender_cat'][0]

    model_info = model_data[(model_data.UserOccupation == nlp_occupation_choice)]
    model_info.reset_index(drop=True, inplace=True)
    occupation = model_info['UserOccupation_cat'][0]

    model_info = model_data[(model_data.Month == nlp_month_choice)]
    model_info.reset_index(drop=True, inplace=True)
    month = model_info['Month_cat'][0]
    

    info_df = pd.DataFrame(columns = ['ProductCategory_cat','ProductPrice','RetailerName_cat','RetailerCity_cat',
    'ManufacturerName_cat','UserAge','UserGender_cat','UserOccupation_cat','Month_cat','Year'],index = ['a'])
    info_df.loc['a'] = [product_category,nlp_price_choice,retailer,city,manufacturer,
    nlp_age_choice,gender,occupation,month,nlp_year_choice]
    # load model
    saved_final_ridge = load_model('Final ridge')
    # Prediction
    new_prediction = predict_model(saved_final_ridge, data=info_df)
    rating = new_prediction['ReviewRating'][0]
    st.metric("Predicted Rating: ",rating)