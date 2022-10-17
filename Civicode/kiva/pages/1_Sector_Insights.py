# Libraries
import streamlit as st
import pandas as pd
import plotly.express as px
import datetime
import os, os.path
import warnings
warnings.simplefilter(action='ignore', category=FutureWarning)

st.title('Kiva Insights')
# Load data
@st.cache
def load_data():
    data = pd.read_csv(DATA_URL)
    return data
DATA_URL = "loans.csv"
df = load_data()

st.header('Kiva Sector Insights')

# Dropdown
country = df['COUNTRY_NAME'].unique()
country  = country.astype('str')
country.sort()
country_choice = st.selectbox("Pick a Country",country)

funding_status = ['funded','fundRaising']
sector_df = df[(df['COUNTRY_NAME'] == country_choice) & df['STATUS'].isin(funding_status)]
sector_df['year'] = pd.DatetimeIndex(sector_df['DISBURSE_TIME']).year

# Sector Count
st.subheader("**Sector Count**")
sector_count_df = sector_df[['SECTOR_NAME','LOAN_ID']]
sector_count_df_agg = sector_count_df.groupby('SECTOR_NAME').agg(Count = ('LOAN_ID', 'count')).reset_index()
sector_count_df_agg.columns = ['Sector Name', 'Count']
sector_count_df_agg = sector_count_df_agg.sort_values("Count", ascending=True).reset_index()
fig = px.bar(sector_count_df_agg, x="Count", y="Sector Name", orientation='h')
st.plotly_chart(fig)

# Average # of lenders by sector
st.subheader("**Avg. # of Lenders**")
sector_count_df = sector_df[['SECTOR_NAME','NUM_LENDERS_TOTAL']]
sector_count_df_agg = sector_count_df.groupby('SECTOR_NAME').agg(Lenders = ('NUM_LENDERS_TOTAL', 'mean')).reset_index()
sector_count_df_agg.columns = ['Sector Name', 'Avg # of Lenders']
sector_count_df_agg = sector_count_df_agg.sort_values("Avg # of Lenders", ascending=True).reset_index()
fig = px.bar(sector_count_df_agg, x="Avg # of Lenders", y="Sector Name", orientation='h')
st.plotly_chart(fig)

# AVG LENDER TERM BY SECTOR
st.subheader("**Avg. # of Lender Term**")
sector_count_df = sector_df[['SECTOR_NAME','LENDER_TERM']]
sector_count_df_agg = sector_count_df.groupby('SECTOR_NAME').agg(Lenders = ('LENDER_TERM', 'mean')).reset_index()
sector_count_df_agg.columns = ['Sector Name', 'Avg Lender Term']
sector_count_df_agg = sector_count_df_agg.sort_values("Avg Lender Term", ascending=True).reset_index()
fig = px.bar(sector_count_df_agg, x="Avg Lender Term", y="Sector Name", orientation='h')
st.plotly_chart(fig)

# AVG FUNDED AMOUNT BY SECTOR
st.subheader("**Avg. Funded Amount**")
sector_count_df = sector_df[['SECTOR_NAME','FUNDED_AMOUNT']]
sector_count_df_agg = sector_count_df.groupby('SECTOR_NAME').agg(Lenders = ('FUNDED_AMOUNT', 'mean')).reset_index()
sector_count_df_agg.columns = ['Sector Name', 'FUNDED AMOUNT']
sector_count_df_agg = sector_count_df_agg.sort_values("FUNDED AMOUNT", ascending=True).reset_index()
fig = px.bar(sector_count_df_agg, x="FUNDED AMOUNT", y="Sector Name", orientation='h')
st.plotly_chart(fig)

# DISTRIBUTION MODEL BY SECTOR
st.subheader("**Distribution Model**")
sector_count_df = sector_df[['SECTOR_NAME','DISTRIBUTION_MODEL']]
sector_count_df_agg = sector_count_df.groupby('SECTOR_NAME').agg(Lenders = ('DISTRIBUTION_MODEL', 'count')).reset_index()
sector_count_df_agg.columns = ['Sector Name', 'DISTRIBUTION MODEL']
sector_count_df_agg = sector_count_df_agg.sort_values("DISTRIBUTION MODEL", ascending=True).reset_index()
fig = px.bar(sector_count_df_agg, x="DISTRIBUTION MODEL", y="Sector Name", orientation='h')
st.plotly_chart(fig)

# REPAYMENT INTERVAL
st.subheader("**Repayment Interval**")
sector_count_df = sector_df[['SECTOR_NAME','REPAYMENT_INTERVAL']]
sector_count_df_agg = sector_count_df.groupby('SECTOR_NAME').agg(Lenders = ('REPAYMENT_INTERVAL', 'count')).reset_index()
sector_count_df_agg.columns = ['Sector Name', 'REPAYMENT INTERVAL']
sector_count_df_agg = sector_count_df_agg.sort_values("REPAYMENT INTERVAL", ascending=True).reset_index()
fig = px.bar(sector_count_df_agg, x="REPAYMENT INTERVAL", y="Sector Name", orientation='h')
st.plotly_chart(fig)

# FUNDED LOANS BY YEAR AND SECTOR
st.subheader("**Funderd Loans by year**")
sector_count_df = sector_df[['SECTOR_NAME','year','FUNDED_AMOUNT']]
sector_count_df_agg = sector_count_df.groupby(['SECTOR_NAME','year']).agg(Lenders = ('FUNDED_AMOUNT', 'mean')).reset_index()
sector_count_df_agg.columns = ['Sector Name', 'Year','FUNDED AMOUNT']
sector_count_df_agg = sector_count_df_agg.sort_values("Year", ascending=True).reset_index()
fig = px.line(sector_count_df_agg, x="Year", y="FUNDED AMOUNT", color_discrete_sequence=px.colors.qualitative.Alphabet,color="Sector Name")
st.plotly_chart(fig)
