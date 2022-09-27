
# Charity funding comparison 
# compare charity funding by year or all years
# + amount awarded
# vs program area 
# vs budget fund
# vs age group
# vs grant program


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

st.header("Charity Comparison")

charity_list = df['Organization name'].unique()
charity_list  = charity_list.astype('str')
charity_list.sort()
charity_choice_1 = st.selectbox("First Charity",charity_list,key=1)
charity_choice_2 = st.selectbox("Second Charity",charity_list,key=2)

charity_df_1 = df[(df['Organization name'] == charity_choice_1)]
charity_df_2 = df[(df['Organization name'] == charity_choice_2)]

col1, col2 = st.columns(2) 
with col1:
    charity_name = charity_df_1['Organization name'].unique()
    incorporation_number = charity_df_1['Incorporation Number'].unique()
    charitable_registration = charity_df_1['Charitable Registration Number'].unique()
    charity_description = charity_df_1['English Description'].unique()
    charity_identifier = charity_df_1['Identifier'].unique()

    if incorporation_number[0] is None or pd.isna(incorporation_number[0]):
        incorporation_number[0] = "--"

    if charitable_registration[0] is None or pd.isna(charitable_registration[0]):
        charitable_registration[0] = "--"
    st.markdown("**Charity Name**")
    st.write(charity_name[0])
    st.markdown("**Incorporation #**")
    st.write(incorporation_number[0])
    st.markdown("**Charitable Registration**")
    st.write(charitable_registration[0])
    st.markdown("**Identifier**")
    st.write(charity_identifier[0])
    st.markdown("**Charity Description**")
    st.write(charity_description[0])

with col2:
    charity_name = charity_df_1['Organization name'].unique()
    incorporation_number = charity_df_1['Incorporation Number'].unique()
    charitable_registration = charity_df_1['Charitable Registration Number'].unique()
    charity_description = charity_df_1['English Description'].unique()
    charity_identifier = charity_df_1['Identifier'].unique()

    if incorporation_number[0] is None or pd.isna(incorporation_number[0]):
        incorporation_number[0] = "--"

    if charitable_registration[0] is None or pd.isna(charitable_registration[0]):
        charitable_registration[0] = "--"
    st.markdown("**Charity Name**")
    st.write(charity_name[0])
    st.markdown("**Incorporation #**")
    st.write(incorporation_number[0])
    st.markdown("**Charitable Registration**")
    st.write(charitable_registration[0])
    st.markdown("**Identifier**")
    st.write(charity_identifier[0])
    st.markdown("**Charity Description**")
    st.write(charity_description[0])