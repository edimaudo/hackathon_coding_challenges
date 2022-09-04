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

@st.cache
def load_data():
    data = pd.read_csv(DATA_URL)
    return data

# Load data
DATA_URL = "reviews.csv"
df = load_data()

st.title('Printer Insights')

# About
st.header("About")
with st.expander("About"):
    st.write("Printers! We all have a love-hate relationship with them.  When things are going well it is perfect.  Just one glitch or driver issue and all hell breaks lose")
    st.write("There has been a proliferation of printer apps to make the printing process easier.")
    st.write("The goal is analyze printer app information scraped from the Google Play store")

# Overview
st.header("Overview")
with st.expander("overview"):
    st.write("")
    st.write("")
    st.write("")


# Analysis
st.header("Analysis")
with st.expander("analysis"):
    st.write("")
    st.write("")
    st.write("")

# NLP
st.header("NLP")
with st.expander("NLP"):
    st.write("")
    st.write("")
    st.write("")
