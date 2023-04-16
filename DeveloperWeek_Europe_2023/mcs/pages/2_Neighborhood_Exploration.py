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
    
    overview_df = df[(df['OCC_YEAR'].isin(year_options)) & (df['OCC_MONTH'].isin(month_options)) & (df['OCC_DOW'].isin(dow_options)) & 
    (df['MCI_CATEGORY'].isin(mci_options)) & (df['PREMISES_TYPE'].isin(premises_options))] 

# MCI crime breakdown 
# premise trend
# HEAT MAP BY CRIME TYPE table
# HEAT MAP FOR MCI 
# better than worse than avg in Toronto
# socio-economic profile