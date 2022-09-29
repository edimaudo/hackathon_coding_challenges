import streamlit as st
import pandas as pd
import plotly.express as px

st.title('OTF Charity Insights')

# Load data
@st.cache
def load_data():
    data = pd.read_excel(DATA_URL)
    return data
DATA_URL = "OTF.xlsx"
df = load_data()

st.header("Year Insights")
year_list = df['Fiscal Year'].unique()
year_list  = year_list.astype('int')
year_list.sort()
year_choice = st.selectbox("Year",year_list)
with st.expander(" "): 
    charity_year = df[(df['Fiscal Year'] == year_choice)]
    st.subheader("Age Breakdown")
    # Age breakdown
    age_group = charity_year[['Amount Awarded','Age Group']]
    age_group_agg = age_group.groupby('Age Group').agg(Total_Amount_Awarded = 
                                                                        ('Amount Awarded', 'sum')).reset_index()
    age_group_agg.columns = ['Age Group', 'Amount Awarded (CAD)']
    age_group_agg = age_group_agg.sort_values("Amount Awarded (CAD)", ascending=True).reset_index()
    fig = px.bar(age_group_agg, x="Amount Awarded (CAD)", y="Age Group", orientation='h')
    st.plotly_chart(fig)
    # Program area
    st.subheader("Program Area")
    program_area = charity_year[['Amount Awarded','Program Area']]
    program_area_agg = program_area.groupby('Program Area').agg(Total_Amount_Awarded = 
                                                                        ('Amount Awarded', 'sum')).reset_index()
    program_area_agg.columns = ['Program Area', 'Amount Awarded (CAD)']
    program_area_agg = program_area_agg.sort_values("Amount Awarded (CAD)", ascending=True).reset_index()
    fig = px.bar(program_area_agg, x="Amount Awarded (CAD)", y="Program Area", orientation='h')
    st.plotly_chart(fig)
    # Grant programs
    st.subheader("Grant Programme")
    grant_program = charity_year[['Amount Awarded','Grant Programme']]
    grant_program_agg = grant_program.groupby('Grant Programme').agg(Total_Amount_Awarded = 
                                                                        ('Amount Awarded', 'sum')).reset_index()
    grant_program_agg.columns = ['Grant Programme', 'Amount Awarded (CAD)']
    grant_program_agg = grant_program_agg.sort_values("Amount Awarded (CAD)", ascending=True).reset_index()
    fig = px.bar(grant_program_agg, x="Amount Awarded (CAD)", y="Grant Programme", orientation='h')
    st.plotly_chart(fig)
    # Budget fund
    st.subheader("Budget Fund")
    budget_fund = charity_year[['Amount Awarded','Budget Fund']]
    budget_fund_agg = budget_fund.groupby('Budget Fund').agg(Total_Amount_Awarded = 
                                                                        ('Amount Awarded', 'sum')).reset_index()
    budget_fund_agg.columns = ['Budget Fund', 'Amount Awarded (CAD)']
    budget_fund_agg = budget_fund_agg.sort_values("Amount Awarded (CAD)", ascending=True).reset_index()
    fig = px.bar(budget_fund_agg, x="Amount Awarded (CAD)", y="Budget Fund", orientation='h')
    st.plotly_chart(fig)
    # Geographical Area Served
    st.subheader("Geographical area served")
    geo_area_update = charity_year[['Amount Awarded','Geographical Area Served']]
    geo_area_update_agg = geo_area_update.groupby('Geographical Area Served').agg(Total_Amount_Awarded = 
                                                                        ('Amount Awarded', 'sum')).reset_index()
    geo_area_update_agg.columns = ['Geographical Area Served', 'Amount Awarded (CAD)']
    geo_area_update_agg = geo_area_update_agg.sort_values("Amount Awarded (CAD)", ascending=True).reset_index()
    fig = px.bar(geo_area_update_agg, x="Amount Awarded (CAD)", y="Geographical Area Served", orientation='h')
    st.plotly_chart(fig) 

    # Map
    st.subheader("Cities")


st.header("Trend Insights")
with st.expander(" "): 
    # Age breakdown
    st.subheader("Age Breakdown")
    age_group = df[['Fiscal Year','Amount Awarded','Age Group']]
    age_group_agg = age_group.groupby(['Age Group','Fiscal Year']).agg(Total_Amount_Awarded = 
                                                                        ('Amount Awarded', 'sum')).reset_index()
    age_group_agg.columns = ['Age Group','Fiscal Year', 'Amount Awarded (CAD)']
    fig = px.line(age_group_agg, x="Fiscal Year", y="Amount Awarded (CAD)", 
    color_discrete_sequence=px.colors.qualitative.Alphabet,color="Age Group")
    st.plotly_chart(fig)
    # Program area
    st.subheader("Program Area")
    age_group = df[['Fiscal Year','Amount Awarded','Program Area']]
    age_group_agg = age_group.groupby(['Program Area','Fiscal Year']).agg(Total_Amount_Awarded = 
                                                                        ('Amount Awarded', 'sum')).reset_index()
    age_group_agg.columns = ['Program Area','Fiscal Year', 'Amount Awarded (CAD)']
    fig = px.line(age_group_agg, x="Fiscal Year", y="Amount Awarded (CAD)", 
    color_discrete_sequence=px.colors.qualitative.Alphabet,color="Program Area")
    st.plotly_chart(fig)
    # Grant Program
    st.subheader("Grant Programme")
    age_group = df[['Fiscal Year','Amount Awarded','Grant Programme']]
    age_group_agg = age_group.groupby(['Grant Programme','Fiscal Year']).agg(Total_Amount_Awarded = 
                                                                        ('Amount Awarded', 'sum')).reset_index()
    age_group_agg.columns = ['Grant Programme','Fiscal Year', 'Amount Awarded (CAD)']
    fig = px.bar(age_group_agg, x="Fiscal Year", y="Amount Awarded (CAD)", color="Grant Programme")
    st.plotly_chart(fig)
    # Budget fund
    st.subheader("Budget Fund")
    age_group = df[['Fiscal Year','Amount Awarded','Budget Fund']]
    age_group_agg = age_group.groupby(['Budget Fund','Fiscal Year']).agg(Total_Amount_Awarded = 
                                                                        ('Amount Awarded', 'sum')).reset_index()
    age_group_agg.columns = ['Budget Fund','Fiscal Year', 'Amount Awarded (CAD)']
    fig = px.bar(age_group_agg, x="Fiscal Year", y="Amount Awarded (CAD)", 
    color_discrete_sequence=px.colors.qualitative.Alphabet,color="Budget Fund")
    st.plotly_chart(fig)

    # Map
    st.subheader("Cities")
