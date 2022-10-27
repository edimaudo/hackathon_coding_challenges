# Libraries
import streamlit as st
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go

st.title('OTF Charity Insights')
@st.cache
def load_data():
    data = pd.read_excel(DATA_URL)
    return data

# Load data
DATA_URL = "OTF.xlsx"
df = load_data()
# Data Summary
st.header("Data Summary")
main_container = st.container()
metric_column1, metric_column2,metric_column3,metric_column4, metric_column5,metric_column6 = st.columns(6)
with main_container:
    metric_column1.metric("Charities",str( len(df['Identifier'].unique())))
    metric_column2.metric("No. of Years",str(len(df['Fiscal Year'].unique())))
    metric_column3.metric("Cities",str(len(df['City'].unique())))
    metric_column4.metric("Grant Programs",str(len(df['Grant Programme'].unique())))
    metric_column5.metric("Program Areas",str(len(df['Program Area'].unique())))
    metric_column6.metric("Age Groups",str(len(df['Age Group'].unique())))
# Funding Trend
st.subheader("Funding Trend")
df_total_grants = df[['Amount Awarded','Fiscal Year']]
df_total_grants_agg = df_total_grants.groupby('Fiscal Year').agg(Total_Amount_Awarded = 
                                                                        ('Amount Awarded', 'sum')).reset_index()
df_total_grants_agg.columns = ['Year', 'Amount Awarded (CAD)']
df_total_grants_agg.sort_values("Amount Awarded (CAD)", ascending=True)
fig = px.bar(df_total_grants_agg, x="Year", y="Amount Awarded (CAD)")
st.plotly_chart(fig)

# # City Funding Map
# st.subheader("OTF map")

# df_total_grants = df[['Amount Awarded','lng','lat','City']]
# df_total_grants_agg = df_total_grants.groupby(['lng','lat','City']).agg(Total_Amount_Awarded = 
#                                                                         ('Amount Awarded', 'sum')).reset_index()
# df_total_grants_agg.columns = ['lng','lat','City', 'Amount Awarded (CAD)']


# fig = go.Figure(data=go.Scattergeo(
#         lon = df_total_grants_agg['lng'],
#         lat = df_total_grants_agg['lat'],
#         text = df_total_grants_agg['City']),
#         mode = 'markers',
#         marker_color = df_total_grants_agg['Amount Awarded (CAD)'],
#         ))

# fig.update_layout(
#         geo_scope='north america',
#     )
# st.plotly_chart(fig)
