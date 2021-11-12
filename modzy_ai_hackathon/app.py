#================
# OTF Insights
# Application applies modzy sdk to perform text analytics
# Also uses plotly to generate bar charts
#================


# Load libraries
import streamlit as st
import pandas as pd
import plotly.express as px
from modzy import ApiClient, error
import json, datetime, requests
from pandas.io.json import json_normalize
import os, os.path

st.title('OTF Insights')

@st.cache
def load_data():
	data = pd.read_excel(DATA_URL)
	return data


# Load data
DATA_URL = "otf.xlsx"
df = load_data()
df_backup = df
INPUT_TEXT = "test.txt"


# Text Description data
english_info_df = df[['Organization_name','English_description']]
english_info_df = english_info_df.groupby(['Organization_name', 'English_description']).first()

english_description_info = df['English_description'].unique()
english_description_info = english_description_info.astype('str')
english_description_info = english_description_info.tolist()

english_info_df = df[['Organization_name','English_description']]
english_info_df = english_info_df.groupby(['Organization_name', 'English_description']).first()

#=================
# Dropdowns values
#=================
# Geographical area 
geographical_area_info = df['Recipient_org_city_update'].unique()
geographical_area_info = geographical_area_info.astype('str')
geographical_area_info = geographical_area_info.tolist()
geographical_area_info.sort()
geographical_area_info.insert(0, "All") #add All

# Year
fiscal_year_info = df['Fiscal_year_update'].unique()
fiscal_year_info = fiscal_year_info.astype('int')
fiscal_year_info = fiscal_year_info.tolist()
fiscal_year_info.sort()

# Sidebar
geo_area_selectbox = st.sidebar.selectbox('City',geographical_area_info)
fiscal_year_slider = st.sidebar.slider('Fiscal Year',fiscal_year_info[0],
	fiscal_year_info[-1],fiscal_year_info[-1])
submit_checkbox = st.sidebar.checkbox('UPDATE')


#==================
# Submit logic
#==================
if submit_checkbox:
    if geo_area_selectbox != "All":
        df = df[(df['Fiscal_year_update'] <= fiscal_year_slider ) & (df['Recipient_org_city_update'] == geo_area_selectbox)]
    else:
        df = df[(df['Fiscal_year_update'] <= fiscal_year_slider)]
    english_description_info = df['English_description'].unique() #generate text
    english_description_info = pd.DataFrame(english_description_info)
    os.remove("input.txt")
    english_description_info.to_csv("input.txt")
else:
    df = df_backup

#================
# Metrics logic
#================
df_metrics_geo_agg = df.groupby(['Geographical_area_served']).agg(Total_Amount_Awarded = 
                                                                       ('Amount_awarded', 'sum')).reset_index()
df_metrics_geo_agg.columns = ['Geographical_area_served','Total Amount Awarded']
geo_count = df_metrics_geo_agg['Geographical_area_served'].count()


df_metrics_org_agg = df.groupby(['Organization_name']).agg(Total_Amount_Awarded = 
                                                                       ('Amount_awarded', 'sum')).reset_index()
df_metrics_org_agg.columns = ['Organization Name','Total Amount Awarded']
org_count = df_metrics_org_agg['Organization Name'].count()
amount_awarded = df_metrics_org_agg['Total Amount Awarded'].sum()
amount_awarded = "{:,}".format(amount_awarded)

#==================
# Metrics setup
#==================
metric_col1, metric_col2, metric_col3 = st.columns(3)

metric_col1.metric("# of organizations", str(geo_count))
metric_col2.metric("Areas Served", str(org_count))
metric_col3.metric("Amount Awarded (CAD)", str(amount_awarded))

#================
# Text analytics logic
#================
API_URL = "https://app.modzy.com/api"
API_KEY = "81RXRBBjPDUaGDuCrC38.ZNGC6q7LmLhtoIiPwTiT"

# setup our API Client
client = ApiClient(base_url=API_URL, api_key=API_KEY)

# Sentiment analysis model
sentiment_model_info = client.models.get_by_name("Sentiment Analysis")

# Topic modelling model
topic_model_info = client.models.get_by_name("Text Topic Modeling")

# function to flatten JSON
def flatten_json(y):
    out = {}

    def flatten(x, name=''):
        if type(x) is dict:
            for a in x:
                flatten(x[a], name + a + '_')
        elif type(x) is list:
            i = 0
            for a in x:
                flatten(a, name + str(i) + '_')
                i += 1
        else:
            out[name[:-1]] = x

    flatten(y)
    return out

def sentiment_analysis(input_text):
    job = client.jobs.submit_text('ed542963de', '1.0.1', {'input.txt': input_text})
    result = client.results.block_until_complete(job, timeout=None)
    return (result['results']['job']['results.json']['data']['result'])

#json_output_df = st.dataframe("")
if submit_checkbox:
    json_output = sentiment_analysis(INPUT_TEXT)
    json_output_flat = flatten_json(json_output)
    json_output_df = json_normalize(json_output_flat)
    json_output_df = st.dataframe(json_output_df)

# def topic_analysis(input_text):
#     job = client.jobs.submit_text('m8z2mwe3pt', '1.0.1', {'input.txt': input_text})
#     result = client.results.block_until_complete(job, timeout=None)
#     return (result['results']['job']['results.json'])


#================
# Text analytics setup
#================
text_analysis_column1, text_analysis_column2, text_analysis_column3 = st.columns(3)
text_analysis_column1.header("Topic Modeling")
if submit_checkbox:
    text_analysis_column1.dataframe(json_output_df)
text_analysis_column2.header("Sentiment analysis")
text_analysis_column3.header("Named Entity Recognition")



#==================
# Visualization logic
#==================
## Total grants by year
# df_total_grants = df[['Amount_awarded','Fiscal_year_update']]
# df_total_grants_agg = df_total_grants.groupby('Fiscal_year_update').agg(Total_Amount_Awarded = 
#                                                                       ('Amount_awarded', 'sum')).reset_index()
# df_total_grants_agg.columns = ['Fiscal Year', 'Total Amount Awarded']
# df_total_grants_agg.sort_values("Total Amount Awarded", ascending=True)
# grant_fig = px.bar(df_total_grants_agg, x="Fiscal Year", y="Total Amount Awarded")

# ## Total grants by program area
# df_total_grants = df[['Amount_awarded','Program_area_update']]
# df_total_grants_agg = df_total_grants.groupby('Program_area_update').agg(Total_Amount_Awarded = 
#                                                                       ('Amount_awarded', 'sum')).reset_index()
# df_total_grants_agg.columns = ['Program Area', 'Total Amount Awarded']
# df_total_grants_agg = df_total_grants_agg.sort_values("Total Amount Awarded", ascending=True).reset_index()
# program_fig = px.bar(df_total_grants_agg, x="Total Amount Awarded", y="Program Area", orientation='h')

# ## Total grants by age group
# df_total_grants = df[['Amount_awarded','Age_group_update']]
# df_total_grants_agg = df_total_grants.groupby('Age_group_update').agg(Total_Amount_Awarded = 
#                                                                       ('Amount_awarded', 'sum')).reset_index()
# df_total_grants_agg.columns = ['Age Group', 'Total Amount Awarded']
# df_total_grants_agg = df_total_grants_agg.sort_values("Total Amount Awarded", ascending=True).reset_index()
# age_group_fig = px.bar(df_total_grants_agg, x="Total Amount Awarded", y="Age Group", orientation='h')

# ## Total grands by budget fund
# df_total_grants = df[['Amount_awarded','Budget_fund_update']]
# df_total_grants_agg = df_total_grants.groupby('Budget_fund_update').agg(Total_Amount_Awarded = 
#                                                                       ('Amount_awarded', 'sum')).reset_index()
# df_total_grants_agg.columns = ['Budget Fund', 'Total Amount Awarded']
# df_total_grants_agg = df_total_grants_agg.sort_values("Total Amount Awarded", ascending=True).reset_index()
# budget_fund_fig = px.bar(df_total_grants_agg, x="Total Amount Awarded", y="Budget Fund", orientation='h')

# ## Total grants by Grant Program

# ## Total grants by year by program area
# df_total_grants = df[['Amount_awarded','Program_area_update','Fiscal_year_update']]
# df_total_grants_agg = df_total_grants.groupby(['Program_area_update','Fiscal_year_update']).agg(Total_Amount_Awarded = 
#                                                                       ('Amount_awarded', 'sum')).reset_index()
# df_total_grants_agg.columns = ['Program Area','Fiscal Year', 'Total Amount Awarded']
# if not df_total_grants_agg.empty:
# 	grant_program_fig = px.bar(df_total_grants_agg, x="Fiscal Year", y="Total Amount Awarded",
# color='Program Area',height=400)
# else:
# 	grant_program_fig = ""
# ## Total grants by year by age group
# df_total_grants = df[['Amount_awarded','Age_group_update','Fiscal_year_update']]
# df_total_grants_agg = df_total_grants.groupby(['Age_group_update','Fiscal_year_update']).agg(Total_Amount_Awarded = 
#                                                                       ('Amount_awarded', 'sum')).reset_index()

# df_total_grants_agg.columns = ['Age Group','Fiscal Year', 'Total Amount Awarded']
# if not df_total_grants_agg.empty:
# 	grant_age_group_fig = px.bar(df_total_grants_agg, x="Fiscal Year", y="Total Amount Awarded", 
# 	color='Age Group',height=400)

# # Total grants by Budget fund by year
# df_total_grants = df[['Amount_awarded','Budget_fund_update','Fiscal_year_update']]
# df_total_grants_agg = df_total_grants.groupby(['Budget_fund_update','Fiscal_year_update']).agg(Total_Amount_Awarded = 
#                                                                       ('Amount_awarded', 'sum')).reset_index()
# df_total_grants_agg.columns = ['Budget Fund','Fiscal Year', 'Total Amount Awarded']
# if not df_total_grants_agg.empty:
# 	grant_budget_fig = px.bar(df_total_grants_agg, x="Fiscal Year", y="Total Amount Awarded", 
# 	color='Budget Fund',height=400)

# # Total grants by Grant Program by year








#================
# Visualization setup
#================

# col1 = st.beta_container()
# col1.header("Total Grants")
# col1.subheader('Total Grants by Program area')
# col1.plotly_chart(program_fig)
# col1.subheader('Total Grants by Age group')
# col1.plotly_chart(age_group_fig)
# col1.subheader('Total Grants by Budget Fund')
# col1.plotly_chart(budget_fund_fig)

# col2 = st.beta_container()
# col2.header("Total Grants by Year")
# col2.subheader('Total Grants by Program Area & Year')
# if not df_total_grants_agg.empty:
# 	col2.plotly_chart(grant_program_fig)
# col2.subheader('Total Grants by Age group & Year')
# if not df_total_grants_agg.empty:
# 	col2.plotly_chart(grant_age_group_fig)
# col2.subheader('Total Grants by Budget Fund & Year')
# if not df_total_grants_agg.empty:
# 	col2.plotly_chart(grant_budget_fig)




