# Libraries
import streamlit as st
import pandas as pd
import plotly.express as px
import os, os.path
import warnings
import numpy as np
warnings.simplefilter(action='ignore', category=FutureWarning)


st.title('Kiva Insights')
# Load data
@st.cache
def load_data():
    data = pd.read_csv(DATA_URL)
    return data
DATA_URL = "loans.csv"
df = load_data()

st.header('Kiva Loan Impact')

funding_status = ['funded','fundRaising']

country = df['COUNTRY_NAME'].unique()
country  = country.astype('str')
country.sort()

sector = df['SECTOR_NAME'].unique()
sector  = sector.astype('str')
sector.sort()

country_choice = st.multiselect("Countries",country,['United States','Costa Rica'])
sector_choice = st.multiselect("Sectors",sector,['Agriculture','Entertainment'])
year_choice =  st.slider('Year', 1, 15, 1)
reduction_choice =  st.slider('Reduction Rate (%)', 0.0, 1.0, 0.01)
discount_choice =  st.slider('Discount Rate (%)', 0.0, 1.0, 0.05)
clicked = st.button("Calculate Loan Impact")

if clicked:
    activity_df = df[(df['COUNTRY_NAME'].isin(country_choice)) & (df['STATUS'].isin(funding_status)) & (df['SECTOR_NAME'].isin(sector))]
    activity_df_agg = activity_df.groupby('ACTIVITY_NAME').agg(FUNDED_AMOUNT = ('FUNDED_AMOUNT', 'sum')).reset_index()
    activity_df_agg.columns = ['ACTIVITY NAME', 'FUNDED AMOUNT']

    sroi = 0
  
    activity_info = []
    loan_info = []
    npv_data = []
    reduction_info = []
    
    activity_info = activity_df_agg['ACTIVITY NAME']
    loan_info = activity_df_agg['FUNDED AMOUNT']

    year_data = list(range(1,year_choice+1))

    # Calculate reduction value
    for loan_value in loan_info:
        temp = []
        for index, year_value in enumerate(year_data):
            if year_value == 1:
                temp.append(loan_value)
            else:
                temp.append(temp[index-1] * (1 - reduction_choice))
        reduction_info.append(temp)
   
    # Calculate NPV
    for value in reduction_info:
        npv_data.append(np.npv(discount_choice,value))
    
    # get total npv -> sum of all npv
    total_npv = sum(npv_data)
    # investment value is  is average of total funds
    investment_value = activity_df_agg['FUNDED AMOUNT'].mean()
    # Social Impact value = total npv - investment value
    social_impact_value  = total_npv - investment_value 
    # SROI = Social Impact Value/Investment value
    sroi = social_impact_value / investment_value
    sroi = float("{:.2f}".format(sroi))

    st.metric("Social Return $ for $", sroi)
    st.write(" ")
    if sroi < 0:
        st.error('This does not have positive impact')
    else:
        st.success('This has positive impact')

    
      


