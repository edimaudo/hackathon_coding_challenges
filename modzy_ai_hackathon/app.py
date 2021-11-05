import streamlit as st
import pandas as pd
import numpy as np
import plotly.express as px

st.title('OTF Insights')

DATA_URL = "otf.xlsx"

@st.cache
def load_data():
	data = pd.read_excel(DATA_URL)
	return data

# Load data
#data_load_state = st.text('Loading data...')
df = load_data()
df_backup = df
#data_load_state.text("Done!")

#=====================
# Text Description data
#=====================
english_description_info = df['English_description'].unique()
english_description_info = english_description_info.astype('str')
english_description_info = english_description_info.tolist()

#=================
# Dropdowns values
#=================
# Program area
program_area_info = df['Program_area_update'].unique()
program_area_info = program_area_info.astype('str')
program_area_info = program_area_info.tolist()
program_area_info.sort()

# Geographical area 
geographical_area_info = df['Recipient_org_city_update'].unique()
geographical_area_info = geographical_area_info.astype('str')
geographical_area_info = geographical_area_info.tolist()
geographical_area_info.sort()

# Age group
age_group_info = df['Age_group_update'].unique()
age_group_info = age_group_info.astype('str')
age_group_info = age_group_info.tolist()
age_group_info.sort()

# Budget fund
budget_fund_info = df['Budget_fund_update'].unique()
budget_fund_info = budget_fund_info.astype('str')
budget_fund_info = budget_fund_info.tolist()
budget_fund_info.sort()

# Add a selectbox to the sidebar:
program_area_selectbox = st.sidebar.selectbox("Program Area",program_area_info)
geo_area_selectbox = st.sidebar.selectbox('Recipient City',geographical_area_info)
age_group_selectbox = st.sidebar.selectbox('Age Group',age_group_info)
budget_fund_selectbox = st.sidebar.selectbox('Budget Fund',budget_fund_info)
submit_button = st.sidebar.button("Submit")
reset_button = st.sidebar.button("  Reset  ")


#==================
# Updated dataframe based on selection
#==================
if submit_button:
	df = df[(df['Program_area_update'] == program_area_selectbox) & 
              (df['Recipient_org_city_update'] == geo_area_selectbox) & 
              (df['Age_group_update'] == age_group_selectbox) & 
              (df['Budget_fund_update'] == budget_fund_selectbox)]
if reset_button:
	df = df_backup

#==================
# Visualization setup
#==================
## Total grants by year
df_total_grants = df[['Amount_awarded','Fiscal_year_update']]
df_total_grants_agg = df_total_grants.groupby('Fiscal_year_update').agg(Total_Amount_Awarded = 
                                                                      ('Amount_awarded', 'sum')).reset_index()
df_total_grants_agg.columns = ['Fiscal Year', 'Total Amount Awarded']
df_total_grants_agg.sort_values("Total Amount Awarded", ascending=True)
grant_fig = px.bar(df_total_grants_agg, x="Fiscal Year", y="Total Amount Awarded")

## Total grants by program area
df_total_grants = df[['Amount_awarded','Program_area_update']]
df_total_grants_agg = df_total_grants.groupby('Program_area_update').agg(Total_Amount_Awarded = 
                                                                      ('Amount_awarded', 'sum')).reset_index()
df_total_grants_agg.columns = ['Program Area', 'Total Amount Awarded']
df_total_grants_agg = df_total_grants_agg.sort_values("Total Amount Awarded", ascending=True).reset_index()
program_fig = px.bar(df_total_grants_agg, x="Total Amount Awarded", y="Program Area", orientation='h')

## Total grants by age group
df_total_grants = df[['Amount_awarded','Age_group_update']]
df_total_grants_agg = df_total_grants.groupby('Age_group_update').agg(Total_Amount_Awarded = 
                                                                      ('Amount_awarded', 'sum')).reset_index()
df_total_grants_agg.columns = ['Age Group', 'Total Amount Awarded']
df_total_grants_agg = df_total_grants_agg.sort_values("Total Amount Awarded", ascending=True).reset_index()
age_group_fig = px.bar(df_total_grants_agg, x="Total Amount Awarded", y="Age Group", orientation='h')

## Total grands by budget fund
df_total_grants = df[['Amount_awarded','Budget_fund_update']]
df_total_grants_agg = df_total_grants.groupby('Budget_fund_update').agg(Total_Amount_Awarded = 
                                                                      ('Amount_awarded', 'sum')).reset_index()
df_total_grants_agg.columns = ['Budget Fund', 'Total Amount Awarded']
df_total_grants_agg = df_total_grants_agg.sort_values("Total Amount Awarded", ascending=True).reset_index()
budget_fund_fig = px.bar(df_total_grants_agg, x="Total Amount Awarded", y="Budget Fund", orientation='h')

## Total grants by year by program area
df_total_grants = df[['Amount_awarded','Program_area_update','Fiscal_year_update']]
df_total_grants_agg = df_total_grants.groupby(['Program_area_update','Fiscal_year_update']).agg(Total_Amount_Awarded = 
                                                                      ('Amount_awarded', 'sum')).reset_index()
df_total_grants_agg.columns = ['Program Area','Fiscal Year', 'Total Amount Awarded']
if not df_total_grants_agg.empty:
	grant_program_fig = px.bar(df_total_grants_agg, x="Fiscal Year", y="Total Amount Awarded",color='Program Area',height=400)
else:
	grant_program_fig = ""
## Total grants by year by age group
df_total_grants = df[['Amount_awarded','Age_group_update','Fiscal_year_update']]
df_total_grants_agg = df_total_grants.groupby(['Age_group_update','Fiscal_year_update']).agg(Total_Amount_Awarded = 
                                                                      ('Amount_awarded', 'sum')).reset_index()

df_total_grants_agg.columns = ['Age Group','Fiscal Year', 'Total Amount Awarded']
if not df_total_grants_agg.empty:
	grant_age_group_fig = px.bar(df_total_grants_agg, x="Fiscal Year", y="Total Amount Awarded", 
	color='Age Group',height=400)

# Total grants by Budget fund by year
df_total_grants = df[['Amount_awarded','Budget_fund_update','Fiscal_year_update']]
df_total_grants_agg = df_total_grants.groupby(['Budget_fund_update','Fiscal_year_update']).agg(Total_Amount_Awarded = 
                                                                      ('Amount_awarded', 'sum')).reset_index()
df_total_grants_agg.columns = ['Budget Fund','Fiscal Year', 'Total Amount Awarded']
if not df_total_grants_agg.empty:
	grant_budget_fig = px.bar(df_total_grants_agg, x="Fiscal Year", y="Total Amount Awarded", 
	color='Budget Fund',height=400)



#================
# Text analytics display
#================
column1, column2, column3 = st.beta_columns(3)
column1.header("Topic Modeling")
column2.header("Sentiment analysis")
column3.header("Named Entity Recognition")

#================
# Visualization display
#================

col1 = st.beta_container()
col1.header("Total Grants")
col1.subheader('Total Grants by Program area')
col1.plotly_chart(program_fig)
col1.subheader('Total Grants by Age group')
col1.plotly_chart(age_group_fig)
col1.subheader('Total Grants by Budget Fund')
col1.plotly_chart(budget_fund_fig)

col2 = st.beta_container()
col2.header("Total Grants by Year")
col2.subheader('Total Grants by Program Area & Year')
if not df_total_grants_agg.empty:
	col2.plotly_chart(grant_program_fig)
col2.subheader('Total Grants by Age group & Year')
if not df_total_grants_agg.empty:
	col2.plotly_chart(grant_age_group_fig)
col2.subheader('Total Grants by Budget Fund & Year')
if not df_total_grants_agg.empty:
	col2.plotly_chart(grant_budget_fig)




