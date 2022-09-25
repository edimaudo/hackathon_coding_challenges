import streamlit as st
import pandas as pd
import plotly.express as px

st.title('OTF Charity Insights')
df = st.session_state['df']
st.header("Map Insights")

    # Program area
    st.subheader("Program Area")
    program_area = df[['Amount Awarded','Program Area'.'City']]
    program_area_agg = program_area.groupby(['City','Program Area']).agg(Total_Amount_Awarded = 
                                                                        ('Amount Awarded', 'sum')).reset_index()
    program_area_agg.columns = ['City','Program Area', 'Amount Awarded (CAD)']
    #program_area_agg = program_area_agg.sort_values("Amount Awarded (CAD)", ascending=True).reset_index()
   
    



    # # Grant programs
    # st.subheader("Grant Programme")
    # grant_program = df[['Amount Awarded','Grant Programme']]
    # grant_program_agg = grant_program.groupby('Grant Programme').agg(Total_Amount_Awarded = 
    #                                                                     ('Amount Awarded', 'sum')).reset_index()
    # grant_program_agg.columns = ['Grant Programme', 'Amount Awarded (CAD)']
    # grant_program_agg = grant_program_agg.sort_values("Amount Awarded (CAD)", ascending=True).reset_index()
    # fig = px.bar(grant_program_agg, x="Amount Awarded (CAD)", y="Grant Programme", orientation='h')
    # st.plotly_chart(fig)

    # # budget fund
    # st.subheader("Budget Fund")
    # budget_fund = df[['Amount Awarded','Budget Fund']]
    # budget_fund_agg = budget_fund.groupby('Budget Fund').agg(Total_Amount_Awarded = 
    #                                                                     ('Amount Awarded', 'sum')).reset_index()
    # budget_fund_agg.columns = ['Budget Fund', 'Amount Awarded (CAD)']
    # budget_fund_agg = budget_fund_agg.sort_values("Amount Awarded (CAD)", ascending=True).reset_index()
    # fig = px.bar(budget_fund_agg, x="Amount Awarded (CAD)", y="Budget Fund", orientation='h')
    # st.plotly_chart(fig)