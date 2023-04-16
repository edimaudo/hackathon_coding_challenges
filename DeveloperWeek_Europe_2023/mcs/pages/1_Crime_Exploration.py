# Libraries
from utils import * 

st.title(APP_NAME)
st.header(CRIME_NAME_HEADER)

with st.expander(APP_FILTERS):
    year_options = st.multiselect('Year',YEAR,default=YEAR)
    month_options = st.multiselect('Month',MONTH,default=MONTH)
    dow_options = st.multiselect('Day of Week',DAY_OF_WEEK,default=DAY_OF_WEEK)
    mci_options = st.multiselect('Crime Type',MCI_CATEGORY,default=MCI_CATEGORY)
    premises_options = st.multiselect('Premises Type',PREMISES_TYPE,default =PREMISES_TYPE)

with st.container():

#crime breakdown
# crime trend
# by Year
# by month
# by day of the month 
# by day of week
# by hour


