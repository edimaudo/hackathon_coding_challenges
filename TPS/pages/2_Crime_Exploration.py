# Libraries
from utils import * 

st.title(APP_NAME)
st.header(CRIME_NAME_HEADER)

with st.sidebar:
    year_options = st.multiselect('Year',YEAR,default=YEAR)
    month_options = st.multiselect('Month',MONTH,default=MONTH)
    dow_options = st.multiselect('Day of Week',DAY_OF_WEEK,default=DAY_OF_WEEK)
    mci_options = st.multiselect('Crime Type',MCI_CATEGORY,default=MCI_CATEGORY)
    premises_options = st.multiselect('Premises Type',PREMISES_TYPE,default =PREMISES_TYPE)

with st.container():
    overview_df = df[(df['OCC_YEAR'].isin(year_options)) & (df['OCC_MONTH'].isin(month_options)) & (df['OCC_DOW'].isin(dow_options)) & 
    (df['MCI_CATEGORY'].isin(mci_options)) & (df['PREMISES_TYPE'].isin(premises_options))] 

    st.subheader("Total Major crimes by Year")
    crimes_data = overview_df[['MCI_CATEGORY','OCC_YEAR']]
    crimes_data = crimes_data.groupby(['MCI_CATEGORY','OCC_YEAR']).agg(Total_reviews = ('MCI_CATEGORY', 'count')).reset_index()
    crimes_data.columns = ['MCI CATEGORY', 'Year','Major Crime Count']
    crimes_data.sort_values("Year", ascending=True)
    fig = px.line(crimes_data, x="Year", y="Major Crime Count",color='MCI CATEGORY')
    st.plotly_chart(fig)

    st.subheader("Total Major crimes by Month")
    crimes_data = overview_df[['MCI_CATEGORY','OCC_MONTH']]
    crimes_data = crimes_data.groupby(['MCI_CATEGORY','OCC_MONTH']).agg(Total_reviews = ('MCI_CATEGORY', 'count')).reset_index()
    crimes_data.columns = ['MCI CATEGORY', 'Month','Major Crime Count']
    month_dict = {'January':1,'February':2,'March':3, 'April':4, 'May':5, 'June':6, 'July':7, 
    'August':8, 'September':9, 'October':10, 'November':11, 'December':12}
    crimes_data = crimes_data.sort_values('Month', key = lambda x : x.apply (lambda x : month_dict[x]))
    fig = px.line(crimes_data, x="Month", y="Major Crime Count",color='MCI CATEGORY')
    st.plotly_chart(fig)

    st.subheader("Total Major crimes by Day of the Month")
    crimes_data = overview_df[['MCI_CATEGORY','OCC_DAY']]
    crimes_data = crimes_data.groupby(['MCI_CATEGORY','OCC_DAY']).agg(Total_reviews = ('MCI_CATEGORY', 'count')).reset_index()
    crimes_data.columns = ['MCI CATEGORY', 'Day','Major Crime Count']
    crimes_data.sort_values("Day", ascending=True)
    fig = px.line(crimes_data, x="Day", y="Major Crime Count",color='MCI CATEGORY')
    st.plotly_chart(fig)

    st.subheader("Total Major crimes by Day of Week")
    crimes_data = overview_df[['MCI_CATEGORY','OCC_DOW']]
    crimes_data = crimes_data.groupby(['MCI_CATEGORY','OCC_DOW']).agg(Total_reviews = ('MCI_CATEGORY', 'count')).reset_index()
    crimes_data.columns = ['MCI CATEGORY', 'Day of Week','Major Crime Count']
    dow_dict = {'Monday':1,'Tuesday':2,'Wednesday':3, 'Thursday':4, 'Friday':5, 'Saturday':6, 'Sunday':7}
    crimes_data = crimes_data.sort_values('Day of Week', key = lambda x : x.apply (lambda x : dow_dict[x]))
    fig = px.line(crimes_data, x="Day of Week", y="Major Crime Count",color='MCI CATEGORY')
    st.plotly_chart(fig)

    st.subheader("Total Major crimes by Hour")
    crimes_data = overview_df[['MCI_CATEGORY','OCC_HOUR']]
    crimes_data = crimes_data.groupby(['MCI_CATEGORY','OCC_HOUR']).agg(Total_reviews = ('MCI_CATEGORY', 'count')).reset_index()
    crimes_data.columns = ['MCI CATEGORY', 'Hour','Major Crime Count']
    crimes_data.sort_values("Hour", ascending=True)
    fig = px.line(crimes_data, x="Hour", y="Major Crime Count",color='MCI CATEGORY')
    st.plotly_chart(fig)




