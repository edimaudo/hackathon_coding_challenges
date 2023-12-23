"""
Libraries
"""
import streamlit as st
import pandas as pd
import plotly.express as px
import os, os.path
import warnings
import numpy as np
import random
from datetime import datetime
import math 

"""
Application Text
"""
APP_NAME = 'Spotified'
APP_ABOUT = 'About'
APP_MUSIC = 'Music'
APP_PODCAST = 'Podcasts'
APP_DEMOGRAPHICS = 'Demographics'
APP_PREDICTION = 'Predictions'

"""
Application Title
"""
st.set_page_config( 
    page_title=APP_NAME,
)

@st.cache_data
def load_data():
    data = pd.read_csv(DATA_URL)
    return data
DATA_URL = "spotify_data.csv"
df = load_data()

"""
Dropdowns
"""
age = ['6-12','12-20','20-35','35-60','60+']	

gender = df['Gender'].unique()
gender = gender.astype('str')
gender.sort()

usage = ['Less than 6 months','6 months to 1 year','1 year to 2 years','More than 2 years']

subscription = df['spotify_subscription_plan'].unique()
subscription = subscription.astype('str')
subscription.sort()





    
      


