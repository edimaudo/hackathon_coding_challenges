import streamlit as st
import pandas as pd
import plotly.express as px


st.title('OTF Charity Insights')
st.header("Year Insights")
df = st.session_state['df']

with st.expander(" "): 
    year_list = df['Fiscal Year'].unique()
    year_list  = year_list.astype('int')
    year_list.sort()
    year_choice = st.selectbox("Year",year_list)
    
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

    # Population served
    st.subheader("Population Served")
    population_served = charity_year[['Amount Awarded','Population Served']]
    population_served_agg = population_served.groupby('Population Served').agg(Total_Amount_Awarded = 
                                                                        ('Amount Awarded', 'sum')).reset_index()
    population_served_agg.columns = ['Population Served', 'Amount Awarded (CAD)']
    population_served_agg = population_served_agg.sort_values("Amount Awarded (CAD)", ascending=True).reset_index()
    fig = px.bar(population_served_agg, x="Amount Awarded (CAD)", y="Population Served", orientation='h')
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

    # budget fund
    st.subheader("Budget Fund")
    budget_fund = charity_year[['Amount Awarded','Budget Fund']]
    budget_fund_agg = budget_fund.groupby('Budget Fund').agg(Total_Amount_Awarded = 
                                                                        ('Amount Awarded', 'sum')).reset_index()
    budget_fund_agg.columns = ['Budget Fund', 'Amount Awarded (CAD)']
    budget_fund_agg = budget_fund_agg.sort_values("Amount Awarded (CAD)", ascending=True).reset_index()
    fig = px.bar(budget_fund_agg, x="Amount Awarded (CAD)", y="Budget Fund", orientation='h')
    st.plotly_chart(fig)

    # Cities
    st.subheader("Cities")
    recipient_org_city_update = charity_year[['Amount Awarded','City']]
    recipient_org_city_update_agg = recipient_org_city_update.groupby('City').agg(Total_Amount_Awarded = 
                                                                        ('Amount Awarded', 'sum')).reset_index()
    recipient_org_city_update_agg.columns = ['City', 'Amount Awarded (CAD)']
    recipient_org_city_update_agg = recipient_org_city_update_agg.sort_values("Amount Awarded (CAD)", ascending=True).reset_index()
    fig = px.bar(recipient_org_city_update_agg, x="Amount Awarded (CAD)", y="City", orientation='h')
    st.plotly_chart(fig) 

    # Geographical Area Served
    St.subheader("Geographical area served")
    geo_area_update = charity_year[['Amount Awarded','Geographical Area Served']]
    geo_area_update_agg = geo_area_update.groupby('Geographical Area Served').agg(Total_Amount_Awarded = 
                                                                        ('Amount Awarded', 'sum')).reset_index()
    geo_area_update_agg.columns = ['Geographical Area Served', 'Amount Awarded (CAD)']
    geo_area_update_agg = geo_area_update.sort_values("Amount Awarded (CAD)", ascending=True).reset_index()
    fig = px.bar(geo_area_update_agg, x="Amount Awarded (CAD)", y="Geographical Area Served", orientation='h')
    st.plotly_chart(fig) 