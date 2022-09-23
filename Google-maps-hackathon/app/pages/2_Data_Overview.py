# Libraries
import streamlit as st
import pandas as pd
import plotly.express as px

st.title('OTF Charity Insights')
df = st.session_state['df']
# Data preview
st.header("Data Preview")
with st.expander(" "):
    st.dataframe(df.head(10))
# Data Summary
st.header("Data Summary")
top_container = st.container()
metric_column1, metric_column2,metric_column3,metric_column4, metric_column5,metric_column6 = st.columns(6)
with top_container:
    metric_column1.metric("Charities",str( len(df['Identifier'].unique()))) #len(pd.unique(df['height'])
    metric_column2.metric("No. of Years",str(len(df['Fiscal Year'].unique())))
    metric_column3.metric("Cities",str(len(df['City'].unique())))
    metric_column4.metric("Grant Programs",str(len(df['Grant Programme'].unique())))
    metric_column5.metric("Program Areas",str(len(df['Program Area'].unique())))
    metric_column6.metric("Age Groups",str(len(df['Age Group'].unique())))#
# Funding Trend
st.subheader("Funding Trend")
df_total_grants = df[['Amount Awarded','Fiscal Year']]
df_total_grants_agg = df_total_grants.groupby('Fiscal Year').agg(Total_Amount_Awarded = 
                                                                        ('Amount Awarded', 'sum')).reset_index()
df_total_grants_agg.columns = ['Year', 'Amount Awarded (CAD)']
df_total_grants_agg.sort_values("Amount Awarded (CAD)", ascending=True)
fig = px.bar(df_total_grants_agg, x="Year", y="Amount Awarded (CAD)")
st.plotly_chart(fig)

