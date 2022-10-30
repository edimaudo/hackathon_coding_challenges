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
@st.cache(allow_output_mutation=True)
def load_data():
    data = pd.read_csv(DATA_URL)
    return data
DATA_URL = "CustomerReviews2000.csv"
df = load_data()

def load_data_excel(filename):
    data = pd.read_excel(filename)
    return data
rfm_score = load_data_excel("rfm_score.xlsx")

st.header("Product segmentation")
nlp_manufacturer_list = df['ManufacturerName'].unique()
nlp_manufacturer_list = nlp_manufacturer_list.astype('str')
nlp_manufacturer_list.sort()


nlp_product_cat_list = df['ProductCategory'].unique()
nlp_product_cat_list  = nlp_product_cat_list.astype('str')
nlp_product_cat_list.sort()

nlp_retailer_city_list = df['RetailerCity'].unique()
nlp_retailer_city_list  = nlp_retailer_city_list.astype('str')
nlp_retailer_city_list.sort()

nlp_rating_list = df['ReviewRating'].unique()
nlp_rating_list  = nlp_rating_list.astype('int')
nlp_rating_list.sort()

with st.sidebar:
    nlp_manufacturer_choice = st.multiselect("Manufacturer",nlp_manufacturer_list,['Samsung','Microsoft'])
    nlp_city_choice = st.multiselect("City",nlp_retailer_city_list, ['Los Angeles','San Francisco'])
    nlp_product_cat_choice = st.multiselect("Product Category",nlp_product_cat_list , ['Tablet'])
    nlp_rating_choice = st.multiselect("Ratings",nlp_rating_list, [4,5])

st.write(" ")
clicked = st.button("Generate Segment")
segment_df = df[(df.ManufacturerName.isin(nlp_manufacturer_choice)) & 
                (df.RetailerCity.isin(nlp_city_choice)) & 
                (df.ProductCategory.isin(nlp_product_cat_choice)) &
                (df.ReviewRating.isin(nlp_rating_choice))]
if clicked:

    NOW = dt.datetime(2022,12,1)
    segment_df['ReviewDate'] = pd.to_datetime(df['ReviewDate'])
    # RFM model
    rfmTable = segment_df.groupby('ProductModelName').agg({'ReviewDate': lambda x: (NOW - x.max()).days,
                                                    'ReviewText': lambda x: len(x), 
                                                    'ProductPrice': lambda x: x.sum()})

    rfmTable['ReviewDate'] = rfmTable['ReviewDate'].astype(int)
    rfmTable.rename(columns={'ReviewDate': 'recency', 
                            'ReviewText': 'frequency', 
                            'ProductPrice': 'monetary_value'}, inplace=True)

    # Split quantiles
    quantiles = rfmTable.quantile(q=[0.2,0.4,0.6,0.8])
    quantiles = quantiles.to_dict()
    segmented_rfm = rfmTable

    def RScore(x,p,d):
        if x <= d[p][0.20]:
            return 1
        elif x <= d[p][0.40]:
            return 2
        elif x <= d[p][0.60]: 
            return 3
        elif x <= d[p][0.80]: 
            return 4
        else:
            return 5
        
    def FMScore(x,p,d):
        if x <= d[p][0.20]:
            return 5
        elif x <= d[p][0.40]:
            return 4
        elif x <= d[p][0.60]: 
            return 3
        elif x <= d[p][0.80]: 
            return 2
        else:
            return 1

    # Segment the data
    segmented_rfm['r_quartile'] = segmented_rfm['recency'].apply(RScore, args=('recency',quantiles,))
    segmented_rfm['f_quartile'] = segmented_rfm['frequency'].apply(FMScore, args=('frequency',quantiles,))
    segmented_rfm['m_quartile'] = segmented_rfm['monetary_value'].apply(FMScore, args=('monetary_value',quantiles,))
    segmented_rfm = segmented_rfm.reset_index(level=['ProductModelName'])

    # Add rfm
    segmented_rfm['RFMScore'] = segmented_rfm.r_quartile.map(str) + segmented_rfm.f_quartile.map(str) + segmented_rfm.m_quartile.map(str)
    segmented_rfm['RFMScore'] = segmented_rfm['RFMScore'].astype(int)
    rfm_final = pd.merge(segmented_rfm, rfm_score, on='RFMScore', how='left')
    rfm_final= rfm_final[['ProductModelName','segment']]
    rfm_final.columns = ['Product', 'Segment']
    st.table(rfm_final)




