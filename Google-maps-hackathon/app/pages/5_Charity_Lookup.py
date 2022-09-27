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

st.header("Charity Lookup")
charity_list = df['Organization name'].unique()
charity_list  = charity_list.astype('str')
charity_list.sort()
charity_choice = st.selectbox("Charity Name",charity_list)

charity_df = df[(df['Organization name'] == charity_choice)]

charity_name = charity_df['Organization name'].unique()
incorporation_number = charity_df['Incorporation Number'].unique()
charitable_registration = charity_df['Charitable Registration Number'].unique()
charity_description = charity_df['English Description'].unique()
charity_identifier = charity_df['Identifier'].unique()

if incorporation_number[0] is None or pd.isna(incorporation_number[0]):
     incorporation_number[0] = "--"

if charitable_registration[0] is None or pd.isna(charitable_registration[0]):
     charitable_registration[0] = "--"

with st.container():
    st.metric("Charity Name",charity_name[0])
    st.metric("Incorporation #",incorporation_number[0])
    st.metric("Charitable Registration",charitable_registration[0])
    st.metric("Identifier",charity_identifier[0])
    st.markdown("**Charity Description**")
    st.write(charity_description[0])

with st.container():
    col1, col2, col3, col4 = st.columns(4)  
    program_area = charity_df['Program Area'].unique()
    program_area.sort()
    age_group = charity_df['Age Group'].unique()
    age_group.sort()
    budget_fund = charity_df['Budget Fund'].unique()
    budget_fund.sort()
    grant_program = charity_df['Grant Programme'].unique()
    grant_program.sort()
    with col1:
        st.subheader("Program Area")
        for value in program_area:
            st.write("- " + value)
    with col2:
        st.subheader("Age Group")
        for value in age_group:
            st.write("- " + value)
    with col3:
        st.subheader("Budget Fund")
        for value in budget_fund:
            st.write("- " + value)
    with col4:
        st.subheader("Grant Program")
        for value in grant_program:
            st.write("- " + value)

with st.container():
    col1, col2 = st.columns(2)
    with col1:
        st.subheader("Amount Awarded Trend")
        df_total_grants = charity_df[['Amount Awarded','Fiscal Year']]
        df_total_grants_agg = df_total_grants.groupby('Fiscal Year').agg(Total_Amount_Awarded = 
                                                                        ('Amount Awarded', 'sum')).reset_index()
        df_total_grants_agg.columns = ['Year', 'Amount Awarded (CAD)']
        df_total_grants_agg.sort_values("Amount Awarded (CAD)", ascending=True)
        fig = px.bar(df_total_grants_agg, x="Year", y="Amount Awarded (CAD)")
        st.plotly_chart(fig)


with st.container():
    st.subheader("City served Map")
    # city served by amount