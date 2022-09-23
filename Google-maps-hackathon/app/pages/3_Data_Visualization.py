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
    # Age breakdown
    age_group = charity_year[['Amount Awarded','Age Group']]
    age_group_agg = age_group.groupby('Age Group').agg(Total_Amount_Awarded = 
                                                                        ('Amount Awarded', 'sum')).reset_index()
    age_group_agg.columns = ['Age Group', 'Amount Awarded (CAD)']
    age_group_agg = age_group_agg.sort_values("Amount Awarded (CAD)", ascending=True).reset_index()
    fig = px.bar(age_group_agg, x="Amount Awarded (CAD)", y="Age Group", orientation='h')
    st.plotly_chart(fig)


    # program area
    program_area = charity_year[['Amount Awarded','Program Area']]
    program_area_agg = program_area.groupby('Program Area').agg(Total_Amount_Awarded = 
                                                                        ('Amount Awarded', 'sum')).reset_index()
    program_area_agg.columns = ['Program Area', 'Amount Awarded (CAD)']
    program_area_agg = program_area_agg.sort_values("Amount Awarded (CAD)", ascending=True).reset_index()
    fig = px.bar(program_area_agg, x="Amount Awarded (CAD)", y="Program Area", orientation='h')
    st.plotly_chart(fig)