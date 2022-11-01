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
model_df = model_df[['ProductCategory','ProductPrice',
               'RetailerName','RetailerCity','RetailerState',
               'ManufacturerName','UserAge','UserGender','UserOccupation',
               'Month','Year','ReviewRating']]

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
    nlp_age_choice = st.slider('Age', 18,70 , 1)

clicked = st.button("Generate Rating")
if clicked:
    info_df = pd.DataFrame(columns = ['ProductCategory','ProductPrice','RetailerName','RetailerCity',
    'ManufacturerName','UserAge','UserGender','UserOccupation', 'Month','Year'],index = ['a'])
    info_df.loc['a'] = [nlp_category_choice,nlp_price_choice,nlp_retailer_choice,nlp_city_choice,
    nlp_manufacturer_choice,nlp_age_choice,nlp_gender_choice,nlp_occupation_choice,nlp_month_choice,nlp_year_choice]
    # load model
    saved_final_lr = load_model('Final lr')
    # Prediction
    new_prediction = predict_model(saved_final_lr, data=info_df)
    rating = new_prediction['ReviewRating'][0]
    st.metric("Predicted Rating: ",rating)