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
charity_choice_2 = st.selectbox("Second Charity",charity_list,key=2,index=2)

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

    program_area = charity_df_1['Program Area'].unique()
    program_area.sort()
    age_group = charity_df_1['Age Group'].unique()
    age_group.sort()
    budget_fund = charity_df_1['Budget Fund'].unique()
    budget_fund.sort()
    grant_program = charity_df_1['Grant Programme'].unique()
    grant_program.sort()
    city = charity_df_1['City'].unique()
    city.sort()
    st.markdown("**Program Area**")
    for value in program_area:
        st.write("- " + value)
    st.markdown("**Age Group**")
    for value in age_group:
        st.write("- " + value)
    st.markdown("**Budget Fund**")
    for value in budget_fund:
        st.write("- " + value)
    st.markdown("**Grant Program**")
    for value in grant_program:
        st.write("- " + value)
    st.markdown("**Cities Served**")
    for value in city:
        st.write("- " + value)

with col2:
    charity_name = charity_df_2['Organization name'].unique()
    incorporation_number = charity_df_2['Incorporation Number'].unique()
    charitable_registration = charity_df_2['Charitable Registration Number'].unique()
    charity_description = charity_df_2['English Description'].unique()
    charity_identifier = charity_df_2['Identifier'].unique()

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

    program_area = charity_df_2['Program Area'].unique()
    program_area.sort()
    age_group = charity_df_2['Age Group'].unique()
    age_group.sort()
    budget_fund = charity_df_2['Budget Fund'].unique()
    budget_fund.sort()
    grant_program = charity_df_2['Grant Programme'].unique()
    grant_program.sort()
    city = charity_df_2['City'].unique()
    city.sort()
    st.markdown("**Program Area**")
    for value in program_area:
        st.write("- " + value)
    st.markdown("**Age Group**")
    for value in age_group:
        st.write("- " + value)
    st.markdown("**Budget Fund**")
    for value in budget_fund:
        st.write("- " + value)
    st.markdown("**Grant Program**")
    for value in grant_program:
        st.write("- " + value)
    st.markdown("**Cities Served**")
    for value in city:
        st.write("- " + value)