# Libraries
import streamlit as st
import pandas as pd
import plotly.express as px
import os, os.path

@st.cache
def load_data():
    data = pd.read_excel(DATA_URL)
    return data

# Load data
DATA_URL = "otf.xlsx"
df = load_data()

st.title('OTF Charity Insights')
# About
st.header("About")
with st.expander("About"):
    st.image("trillium-logo.jpeg")
    st.write("The goal is to use open data from Ontario Trillium Foundation to analyze charity data")
    st.write("The Ontario Trillium Foundation (OTF) is an agency of the Government of Ontario and one of Canada’s " + 
    "leading granting foundations. Our investments in communities across the province help build healthy and vibrant communities." + 
    "Our key funder, the Ministry of Heritage, Sport, Tourism and Culture Industries enables us to provide grants that can make the greatest impact. " +
    "OTF also administers grants on behalf of the Ministry of Children, Community and Social Services. Last year, $115 million was invested into more than" + 
    "644 projects in communities across the province")
    st.write("https://otf.ca/who-we-are/about-us/our-story")

# Overview
st.header("Overview")
with st.expander("Overview"):
    top_container = st.container()
    metric_column1, metric_column2,metric_column3,metric_column4, metric_column5,metric_column6 = st.columns(6)
    with top_container:
        metric_column1.metric("Charities",str( len(df['Identifier'].unique()))) #len(pd.unique(df['height'])
        metric_column2.metric("No. of Years",str(len(df['Fiscal_year_update'].unique())))
        metric_column3.metric("Cities",str(len(df['Recipient_org_city_update'].unique())))
        metric_column4.metric("Grant Programs",str(len(df['Grant_program'].unique())))
        metric_column5.metric("Program Areas",str(len(df['Program_area_update'].unique())))
        metric_column6.metric("Age Groups",str(len(df['Age_group_update'].unique())))#
    # Funding Trend
    df_total_grants = df[['Amount_awarded','Fiscal_year_update']]
    df_total_grants_agg = df_total_grants.groupby('Fiscal_year_update').agg(Total_Amount_Awarded = 
                                                                        ('Amount_awarded', 'sum')).reset_index()
    df_total_grants_agg.columns = ['Year', 'Amount Awarded (CAD)']
    df_total_grants_agg.sort_values("Amount Awarded (CAD)", ascending=True)
    fig = px.bar(df_total_grants_agg, x="Year", y="Amount Awarded (CAD)")
    st.plotly_chart(fig)

# Charity Insights
st.header("Charity Insights")

with st.expander("Charity Insights"):
    charity_list = df['Organization_name'].unique()
    charity_list  = charity_list.astype('str')
    charity_list.sort()
    charity_choice = st.selectbox("Pick a Charity",charity_list)

    st.subheader("Charity Overview")
    charity_container = st.container()
    charity_metric_column1, charity_metric_column2,charity_metric_column3,charity_metric_column4 = st.columns(4)
    with charity_container:
        charity = df[(df.Organization_name == charity_choice)]
        # English description
        charity_name = charity['Organization_name'].unique()
        # Incorporation #
        charity_incorporation = charity['Recipient_org_incorporation_number'].unique()
        # registration #
        charity_registration = charity['Recipient_org_registration_number'].unique()
        # Number of cities
        charity_cities = len(charity['Organization_name'].unique())
        charity_metric_column1.subheader("Name")
        charity_metric_column1.write(str(charity_name[0]))
        charity_metric_column2.subheader("Registration #")
        charity_metric_column2.write(str(charity_registration[0]))
        charity_metric_column3.subheader("# of Cities")
        charity_metric_column3.write(str(charity_cities))
        
        charity_grants = charity[['Amount_awarded','Fiscal_year_update']]
        charity_grants = charity_grants.groupby('Fiscal_year_update').agg(Total_Amount_Awarded = 
                                                                        ('Amount_awarded', 'sum')).reset_index()
        charity_grants.columns = ['Year', 'Amount Awarded (CAD)']
        charity_grants.sort_values("Amount Awarded (CAD)", ascending=True)
        fig = px.bar(charity_grants, x="Year", y="Amount Awarded (CAD)")
        st.plotly_chart(fig)

    st.subheader("Yearly Insights")
    year_container =  st.container()
    with year_container:
        year_list = df['Fiscal_year_update'].unique()
        year_list  = year_list.astype('int')
        year_list.sort()
        year_choice = st.selectbox("year",year_list)
        charity_year = df[(df.Organization_name == charity_choice)& (df.Fiscal_year_update == year_choice)]
    
        # Age breakdown 
        age_group = charity_year[['Amount_awarded','Age_group_update']]
        age_group_agg = age_group.groupby('Age_group_update').agg(Total_Amount_Awarded = 
                                                                        ('Amount_awarded', 'sum')).reset_index()
        age_group_agg.columns = ['Age Group', 'Amount Awarded (CAD)']
        age_group_agg = age_group_agg.sort_values("Amount Awarded (CAD)", ascending=True).reset_index()
        fig = px.bar(age_group_agg, x="Amount Awarded (CAD)", y="Age Group", orientation='h')
        st.plotly_chart(fig)
        
        # program area
        program_area = charity_year[['Amount_awarded','Program_area_update']]
        program_area_agg = program_area.groupby('Program_area_update').agg(Total_Amount_Awarded = 
                                                                        ('Amount_awarded', 'sum')).reset_index()
        program_area_agg.columns = ['Program Area', 'Amount Awarded (CAD)']
        program_area_agg = program_area_agg.sort_values("Amount Awarded (CAD)", ascending=True).reset_index()
        fig = px.bar(program_area_agg, x="Amount Awarded (CAD)", y="Program Area", orientation='h')
        st.plotly_chart(fig)
        # population served
        # grant programs
        # funded category 
        # budget fund
        # top 10 funded cities
        # area served map (https://stackoverflow.com/questions/58043978/display-data-on-real-map-based-on-postal-code)

# City Insights


# Prediction


# NLP