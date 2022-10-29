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



st.header("About")
with st.expander(" "):
    st.write("""
    WebSocialytics is a fast-growing social media company that
has a business model similar to yelp. The company focuses on collecting
customer reviews of different products manufactured by different vendors
and sold by different retailers in different cities.
Every review filled out by the customer online and collected and
maintained by WebSocialytics has the fields listed below and stored in its
database in the CustomerReviews table.
Reviews can be used by retailers, manufacturers, and consulting firms
to create effective output report in order to support the decision
making process for analytical scenarios
    """)

st.header('Data Exploration')
