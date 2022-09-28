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


st.title('OTF Charity Insights')
# Load data
@st.cache
def load_data():
    data = pd.read_excel(DATA_URL)
    return data
DATA_URL = "OTF.xlsx"
df = load_data()

st.header("Charity Funding Prediction")

