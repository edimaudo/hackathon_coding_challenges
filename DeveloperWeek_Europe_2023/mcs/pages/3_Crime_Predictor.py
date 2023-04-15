# Libraries
from utils import * 
import streamlit as st
import warnings
warnings.simplefilter(action='ignore', category=FutureWarning)
import random
import pickle
from pycaret.classification import *
import datetime

st.title(APP_NAME)

# Load data
@st.cache_data
def load_data(DATA_URL):
    data = pd.read_csv(DATA_URL)
    return data

DATA_URL = "Major_Crime_Indicators_Open_Data.csv"    
df = load_data(DATA_URL)

