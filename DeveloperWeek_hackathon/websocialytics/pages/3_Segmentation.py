# Libraries
import pandas as pd
import numpy as np
import seaborn as sns
import streamlit as st
import plotly.express as px
import os, os.path
import sklearn
import plotly.express as px
import os, os.path
import warnings
import datetime as dt
import random
warnings.simplefilter(action='ignore', category=FutureWarning)
import math 

st.title('WebSocialytics Insights')

# Load data
@st.cache
def load_data():
    data = pd.read_csv(DATA_URL)
    return data
DATA_URL = "CustomerReviews2000.csv"
df = load_data()

# RFM

# Cohort 

