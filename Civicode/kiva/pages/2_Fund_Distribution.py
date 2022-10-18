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

st.title('Kiva Insights')
# Load data
@st.cache
def load_data():
    data = pd.read_csv(DATA_URL)
    return data
DATA_URL = "loans.csv"
df = load_data()

st.header('Portfolio Breakdown')

funding_status = ['funded','fundRaising']

# country list
country = df['COUNTRY_NAME'].unique()
country  = country.astype('str')
country.sort()

country_choice = st.multiselect("Countries",country,['United States','Costa Rica'])

fund_df = df[(df['COUNTRY_NAME'].isin(country_choice)) & (df['STATUS'].isin(funding_status))] #& (df['SECTOR_NAME'].isin(sector))
fund_df['DISBURSE_TIME'] = pd.to_datetime(fund_df['DISBURSE_TIME']).dt.date
fund_df_agg = fund_df.groupby(['SECTOR_NAME', 'DISBURSE_TIME']).agg(TOTAL_FUNDED_AMOUNT = ('FUNDED_AMOUNT', 'sum')).reset_index()
fund_df_agg.columns = ['SECTOR NAME', 'DISBURSE TIME', 'TOTAL FUNDED AMOUNT']

# sector
sector_count = len(fund_df_agg['SECTOR NAME'].unique())

# CREATE Pivot data
fund_df_agg_pivot = pd.pivot_table(data=fund_df_agg,values ='TOTAL FUNDED AMOUNT',columns=['SECTOR NAME'] ,index=['DISBURSE TIME'])
fund_df_agg_pivot = fund_df_agg_pivot.fillna(0)

# mean daily loans
mean_ret = fund_df_agg_pivot.mean(axis=0)
# covariance matrix with annualization
cov_mat = np.cov(fund_df_agg_pivot, bias=True) * 252
#simulation of 10000 portfolios
num_port = 10000
# Creating a matrix to store the weights
all_wts  = []
# Portfolio returns
port_returns = []
# Portfolio Standard deviation
port_risk = []
# Portfolio Sharpe Ratio
sharpe_ratio = []

random.seed(10)
# Simulation
sim_data = list(range(1,num_port+1))
#for value in sim_data:
wts = np.random.uniform(0,1,sector_count)
wts = wts/sum(wts)
st.write(sum(wts))

st.subheader("Minimum Variance Portfolio")

##st.write("""
##A minimum variance portfolio is an investing method that helps you maximize returns and minimize risk. It involves diversifying your holdings to reduce volatility, or such that investments that may be risky on their own balance each other out when held together.
##""")

st.subheader("Efficient Portfolio")

##st.write("""
##investable assets are combined in a way that produces the best possible expected level of return for their level of risk—or the lowest risk for a target return
##""")
