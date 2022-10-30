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

NOW = dt.datetime(2022,12,1)
df['ReviewDate'] = pd.to_datetime(df['ReviewDate'])
# RFM model
rfmTable = df.groupby('ProductModelName').agg({'ReviewDate': lambda x: (NOW - x.max()).days,
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

# Add rfm
segmented_rfm['RFMScore'] = segmented_rfm.r_quartile.map(str) + segmented_rfm.f_quartile.map(str) + segmented_rfm.m_quartile.map(str)
st.dataframe(segmented_rfm)

rfm_final = pd.concat(segmented_rfm, rfm_score, how='inner')
st.dataframe(frm_final)



#divisions<-rfm_segment(report, segment_titles, r_low, r_high, f_low, f_high, m_low, m_high)

#division_count <- divisions %>% count(segment) %>% arrange(desc(n)) %>% rename(Segment = segment, Count = n)

#ProductModelName	ProductCategory	ProductPrice	RetailerName	RetailerZip	RetailerCity	RetailerState	ProductOnSale	ManufacturerName	ManufacturerRebate	UserID	UserAge	UserGender	UserOccupation	ReviewRating	ReviewDate	ReviewText


