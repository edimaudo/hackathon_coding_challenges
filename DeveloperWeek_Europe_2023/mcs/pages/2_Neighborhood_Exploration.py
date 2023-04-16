# Libraries
from utils import * 
import streamlit as st

st.title(APP_NAME)
st.header(NEIGHBOUR_NAME_HEADER)

#Load neighbourhood data
@st.cache_data
def load_data(DATA_URL):
    data = pd.read_csv(DATA_URL)
    return data

DATA_URL = "wellbeing-toronto-economics.csv"    
neighbourhood_df = load_data(DATA_URL)

with st.expander(APP_FILTERS):
    neighourhood_options = st.selectbox('Neighbourhood',NEIGHBORHOOD)
    year_options = st.multiselect('Year',YEAR,default=YEAR)
    month_options = st.multiselect('Month',MONTH,default=MONTH)
    dow_options = st.multiselect('Day of Week',DAY_OF_WEEK,default=DAY_OF_WEEK)
    mci_options = st.multiselect('Crime Type',MCI_CATEGORY,default=MCI_CATEGORY)
    premises_options = st.multiselect('Premises Type',PREMISES_TYPE,default=PREMISES_TYPE)

col1, col2 = st.columns([3, 1]) 
with col2:
    overview_df = df[(df['OCC_YEAR'].isin(year_options)) & (df['OCC_MONTH'].isin(month_options)) & (df['OCC_DOW'].isin(dow_options)) & (df['MCI_CATEGORY'].isin(mci_options)) & (df['PREMISES_TYPE'].isin(premises_options)) & (df['NEIGHBOURHOOD_158'] == neighourhood_options)] 
    # MCI crime breakdown 
# premise trend
# HEAT MAP BY CRIME TYPE table
# HEAT MAP FOR MCI 

with col1:
    top_container = st.container()
    bottom_container = st.container()
    neighour_df = neighbourhood_df[(neighbourhood_df['Neighbourhood'] == neighourhood_options)]
    st.subheader("Socio economic Profile")
    st.metric("Neighborhood Name",0)
    col3, col4,col5 = st.columns(3)
    with top_container:
        with col3:
            st.metric("No. of Businesses",0)
        with col4:
            st.metric("No. of Child Care Spaces",0)
        with col5:
            st.metric("Debt Risk Score",0)
    col6,col7, col8 = st.columns(3)
    with bottom_container:
        with col6:
            st.metric("Home Prices",0)
        with col7:
            st.metric("Local Employment",0)
        with col8:
            st.metric("No. of Social Assistance Recipients",0)


