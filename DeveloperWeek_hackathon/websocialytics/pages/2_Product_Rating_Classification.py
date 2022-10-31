# classification
#Product Classification
#How likely a certain product will receive a bad rating in certain zip
#code

# Libraries
import streamlit as st
import pandas as pd
import plotly.express as px
import os, os.path
import geopandas
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

st.title('WebSocialytics Insights')

# Load data
@st.cache(allow_output_mutation=True)
def load_data():
    data = pd.read_csv(DATA_URL)
    return data
DATA_URL = "CustomerReviews2000.csv"
df = load_data()

st.header("Product Classification")

nlp_retailer_list = df['RetailerName'].unique()
nlp_retailer_list  = nlp_retailer_list.astype('str')
nlp_retailer_list.sort()

nlp_manufacturer_list = df['ManufacturerName'].unique()
nlp_manufacturer_list = nlp_manufacturer_list.astype('str')
nlp_manufacturer_list.sort()

nlp_product_cat_list = df['ProductCategory'].unique()
nlp_product_cat_list  = nlp_product_cat_list.astype('str')
nlp_product_cat_list.sort()

nlp_retailer_city_list = df['RetailerCity'].unique()
nlp_retailer_city_list  = nlp_retailer_city_list.astype('str')
nlp_retailer_city_list.sort()

with st.sidebar:
    nlp_manufacturer_choice = st.multiselect("Manufacturer",nlp_manufacturer_list,['Samsung','Microsoft'])
    nlp_retailer_choice = st.multiselect("RetailerName",nlp_retailer_list, ['Bestbuy','Walmart'])
    nlp_city_choice = st.multiselect("City",nlp_retailer_city_list, ['Los Angeles','San Francisco'])

clicked = st.button("Explore")
if clicked:
    nlp_analysis = df[(df.ManufacturerName.isin(nlp_manufacturer_choice)) & 
                (df.RetailerName.isin(nlp_retailer_choice)) & 
                (df.RetailerCity.isin(nlp_city_choice))]