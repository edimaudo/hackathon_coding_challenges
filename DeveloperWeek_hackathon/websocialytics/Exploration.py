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
import re, string

st.title('WebSocialytics Insights')

# Load data
@st.cache(allow_output_mutation=True)
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

    #- top 10 products, bottom 10 products by ratings
    #- top 10 products, bottom 10 products by # of reviews
    #- top 10 products, bottom 10 products by city
    # cateogry
    #- sales trend


