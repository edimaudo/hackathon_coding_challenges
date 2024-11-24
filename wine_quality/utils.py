# Libraries
import streamlit as st
import pandas as pd
import plotly.express as px
import datetime
import os, os.path
import warnings
import random
import pickle
from pycaret.classification import *
from pycaret.regression import *
import datetime
from sklearn import preprocessing
from sklearn.metrics import accuracy_score
from sklearn import model_selection
from sklearn.metrics import mean_squared_error
from sklearn.model_selection import cross_val_score
from sklearn.preprocessing import LabelEncoder, MinMaxScaler, StandardScaler, OneHotEncoder

# Dashboard text
APP_NAME = 'WINE QUALITY INSIGHTS'
ABOUT_HEADER = 'ABOUT'
OVERVIEW_HEADER = 'OVERIEW'
PREDICTION_NAME_HEADER = 'WINE QUALITY PREDICTION'
WINE_EXPLORATION_HEADER = 'WINE QUALITY EXPLORATION'
APP_FILTERS = 'FILTERS'
ABOUT_APP_TEXT = "The app analyzes red and white wine samples to provide insights into quality.  The two datasets are related to red and white variants of the Portuguese "Vinho Verde" wine"

warnings.simplefilter(action='ignore', category=FutureWarning)
st.set_page_config( 
    page_title=APP_NAME,
)

# Load data
@st.cache_data
def load_data(DATA_URL):
    data = pd.read_csv(DATA_URL)
    return data

white_df = load_data("data/Whitewine.csv.csv")
red_df = load_data("data/Redwine.csv")