# Libraries
import streamlit as st
import pandas as pd
import plotly.express as px
import os, os.path
import warnings
import numpy as np
from datetime import datetime
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


st.header("Text Analysis of Reviews")