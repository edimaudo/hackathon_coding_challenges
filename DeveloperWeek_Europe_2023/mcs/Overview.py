from utils import * 

st.title(APP_NAME)
st.header(OVERVIEW_HEADER)

with st.expander(APP_FILTERS):
    year_options = st.multiselect('Year',YEAR,default=YEAR)
    month_options = st.multiselect('Month',MONTH,default=MONTH)
    dow_options = st.multiselect('Day of Week',DAY_OF_WEEK,default=DAY_OF_WEEK)
    mci_options = st.multiselect('Crime Type',MCI_CATEGORY,default=MCI_CATEGORY)
    premises_options = st.multiselect('Premises Type',PREMISES_TYPE,default =PREMISES_TYPE)
    
with st.container():
    overview_df = df[(df['OCC_YEAR'].isin(year_options)) & (df['OCC_MONTH'].isin(month_options)) & (df['OCC_DOW'].isin(dow_options)) & 
    (df['MCI_CATEGORY'].isin(mci_options)) & (df['PREMISES_TYPE'].isin(premises_options))] 
    st.subheader("Total Major crimes by Year")

    st.subheader("Total Major crimes by Month")

    st.subheader("Total Major crimes by Week")

    st.subheader("Total Major crimes by Hour")

    st.subheader("Crime Type heat map")

    st.subheader("Properties impacted heatmap")


