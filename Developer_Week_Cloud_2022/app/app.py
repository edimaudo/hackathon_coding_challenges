# Libraries
import streamlit as st
import pandas as pd
import plotly.express as px
import os, os.path

st.image("trillium-logo.jpeg")
st.title('OTF Charity Insights')
st.header("About")
st.write("The goal is to use open data from Ontario Trillium Foundation to analyze charity information")
st.write("The Ontario Trillium Foundation (OTF) is an agency of the Government of Ontario and one of Canada’s " + 
"leading granting foundations. Our investments in communities across the province help build healthy and vibrant communities." + 
"Our key funder, the Ministry of Heritage, Sport, Tourism and Culture Industries enables us to provide grants that can make the greatest impact. " +
"OTF also administers grants on behalf of the Ministry of Children, Community and Social Services. Last year, $115 million was invested into more than" + 
"644 projects in communities across the province")
st.write("https://otf.ca/who-we-are/about-us/our-story")

@st.cache
def load_data():
    data = pd.read_excel(DATA_URL)
    return data

# Load data
DATA_URL = "otf.xlsx"
df = load_data()

st.header("Overview")
# Metrics
top_container = st.container()
bottom_container = st.container()
metric_column1, metric_column2,metric_column3,metric_column4, metric_column5,metric_column6 = st.columns(6)

with top_container:
    metric_column1.metric("# of Charities ",str(df['Identifier'].unique())) #len(pd.unique(df['height'])
    metric_column2.metric("# of Years ",str(df['Fiscal_year_update'].unique()))
    metric_column3.metric("# of Cities ",str(df['Recipient_org_city_update'].unique()))
with bottom_container:
    metric_column4.metric("# of Grant Programs",str(df['Grant_program'].unique()))
    metric_column5.metric("# of Program Areas",str(df['Program_area_update'].unique()))
    metric_column6.metric("# of Age Groups Served",str(df['Age_group_update'].unique()))

# Funding Trends
df_total_grants = df[['Amount_awarded','Fiscal_year_update']]
df_total_grants_agg = df_total_grants.groupby('Fiscal_year_update').agg(Total_Amount_Awarded = 
                                                                      ('Amount_awarded', 'sum')).reset_index()
df_total_grants_agg.columns = ['Year', 'Amount Awarded (CAD)']
df_total_grants_agg.sort_values("Amount Awarded (CAD)", ascending=True)
fig = px.bar(df_total_grants_agg, x="Year", y="Amount Awarded (CAD)")
st.plotly_chart(fig)

# Charity Insights
st.header("Charity Insights")
charity_top_container = st.container()
charity_bottom_container = st.container()
charity_metric_column1, charity_metric_column2,charity_metric_column3,charity_metric_column4 = st.columns(4)
with st.expander("Charity Insights"):
    #charity_choices = st.selectbox("")

    st.subheader("Charity Overview")
    ## build metrics
    ##English description
    ##incorporation #
    ##registration #
    ##Number of cities

    ## build year trend
    ##Funding Trend
    st.subheader("Yearly Insights")
    #year_choices = st.selectbox("")

    ##Age breakdown
##population served
##grant programs
##funded category 
##budget fund
##top 10 funded cities
##area served map (https://stackoverflow.com/questions/58043978/display-data-on-real-map-based-on-postal-code)

# City Insights