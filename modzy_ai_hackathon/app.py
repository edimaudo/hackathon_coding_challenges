import streamlit as st
import pandas as pd
import numpy as np
import plotly.express as px

st.title('OTF Insights')

## /Users/edima/Documents/Coding/hackathon-coding-challenges/modzy_ai_hackathon/
DATA_URL = "otf.xlsx"

@st.cache
def load_data():
	data = pd.read_excel(DATA_URL)
	return data

# Load data
data_load_state = st.text('Loading data...')
df= load_data()
data_load_state.text("Done!")

#if st.checkbox('Show raw data'):
#    st.subheader('Raw data')
#    st.write(data)

## Total grants by year
st.subheader('Total grants by year')
df_total_grants = df[['Amount_awarded','Fiscal_year_update']]
df_total_grants_agg = df_total_grants.groupby('Fiscal_year_update').agg(Total_Amount_Awarded = 
                                                                      ('Amount_awarded', 'sum')).reset_index()
df_total_grants_agg.columns = ['Fiscal_year_update', 'Total_Amount_Awarded']
df_total_grants_agg.sort_values("Total_Amount_Awarded", ascending=True)
fig = px.bar(df_total_grants_agg, x="Fiscal_year_update", y="Total_Amount_Awarded")
st.plotly_chart(fig)


## Total grants by program area
st.subheader('Total grants by Program area')
df_total_grants = df[['Amount_awarded','Program_area_update']]
df_total_grants_agg = df_total_grants.groupby('Program_area_update').agg(Total_Amount_Awarded = 
                                                                      ('Amount_awarded', 'sum')).reset_index()
df_total_grants_agg.columns = ['Program_area', 'Total_Amount_Awarded']
df_total_grants_agg = df_total_grants_agg.sort_values("Total_Amount_Awarded", ascending=True).reset_index()
fig = px.bar(df_total_grants_agg, x="Total_Amount_Awarded", y="Program_area", orientation='h')
st.plotly_chart(fig)


# Total grants by age group
st.subheader('Total grants by Age group')
df_total_grants = df[['Amount_awarded','Age_group_update']]
df_total_grants_agg = df_total_grants.groupby('Age_group_update').agg(Total_Amount_Awarded = 
                                                                      ('Amount_awarded', 'sum')).reset_index()
df_total_grants_agg.columns = ['Age_group_update', 'Total_Amount_Awarded']
df_total_grants_agg = df_total_grants_agg.sort_values("Total_Amount_Awarded", ascending=True).reset_index()
fig = px.bar(df_total_grants_agg, x="Total_Amount_Awarded", y="Age_group_update", orientation='h')
st.plotly_chart(fig)

## Total grands by budget fund
st.subheader('Total grants by Budget Fund')
df_total_grants = df[['Amount_awarded','Budget_fund_update']]
df_total_grants_agg = df_total_grants.groupby('Budget_fund_update').agg(Total_Amount_Awarded = 
                                                                      ('Amount_awarded', 'sum')).reset_index()
df_total_grants_agg.columns = ['Budget_fund', 'Total_Amount_Awarded']
df_total_grants_agg = df_total_grants_agg.sort_values("Total_Amount_Awarded", ascending=True).reset_index()
fig = px.bar(df_total_grants_agg, x="Total_Amount_Awarded", y="Budget_fund", orientation='h')
st.plotly_chart(fig)


## Total grants by recipient city top 10
st.subheader('Total grants by top 10 cities')
df_total_grants = df[['Amount_awarded','Recipient_org_city_update']]
df_total_grants_agg = df_total_grants.groupby('Recipient_org_city_update').agg(Total_Amount_Awarded = 
                                                                      ('Amount_awarded', 'sum')).reset_index()
df_total_grants_agg.columns = ['Recipient_city', 'Total_Amount_Awarded']
df_total_grants_agg = df_total_grants_agg.sort_values("Total_Amount_Awarded", ascending=False).reset_index()
df_total_grants_agg = df_total_grants_agg.head(10)
fig = px.bar(df_total_grants_agg, x="Total_Amount_Awarded", y="Recipient_city", orientation='h')
st.plotly_chart(fig)


## Total grants by year by program area
df_total_grants = df[['Amount_awarded','Program_area_update','Fiscal_year_update']]
df_total_grants_agg = df_total_grants.groupby(['Program_area_update','Fiscal_year_update']).agg(Total_Amount_Awarded = 
                                                                      ('Amount_awarded', 'sum')).reset_index()

df_total_grants_agg.columns = ['Program_area','Fiscal_year', 'Total_Amount_Awarded']

fig = px.bar(df_total_grants_agg, x="Fiscal_year", y="Total_Amount_Awarded", color='Program_area',
             height=400)
fig.show()


## Total grants by year by age group
df_total_grants = df[['Amount_awarded','Age_group_update','Fiscal_year_update']]
df_total_grants_agg = df_total_grants.groupby(['Age_group_update','Fiscal_year_update']).agg(Total_Amount_Awarded = 
                                                                      ('Amount_awarded', 'sum')).reset_index()

df_total_grants_agg.columns = ['Age_group','Fiscal_year', 'Total_Amount_Awarded']

fig = px.bar(df_total_grants_agg, x="Fiscal_year", y="Total_Amount_Awarded", color='Age_group',
             height=400)
fig.show()


# Total grants by Budget fund by year
df_total_grants = df[['Amount_awarded','Budget_fund_update','Fiscal_year_update']]
df_total_grants_agg = df_total_grants.groupby(['Budget_fund_update','Fiscal_year_update']).agg(Total_Amount_Awarded = 
                                                                      ('Amount_awarded', 'sum')).reset_index()

df_total_grants_agg.columns = ['Budget_fund','Fiscal_year', 'Total_Amount_Awarded']

fig = px.bar(df_total_grants_agg, x="Fiscal_year", y="Total_Amount_Awarded", color='Budget_fund',
             height=400)
fig.show()


