from utils import * 

st.title(APP_NAME)
st.header(NEIGHBOUR_NAME_HEADER)

with st.sidebar:
    neighourhood_options = st.selectbox('Neighbourhood',NEIGHBORHOOD)
    year_options = st.multiselect('Year',YEAR,default=YEAR)
    month_options = st.multiselect('Month',MONTH,default=MONTH)
    dow_options = st.multiselect('Day of Week',DAY_OF_WEEK,default=DAY_OF_WEEK)
    mci_options = st.multiselect('Crime Type',MCI_CATEGORY,default=MCI_CATEGORY)
    premises_options = st.multiselect('Premises Type',PREMISES_TYPE,default=PREMISES_TYPE)   

with st.container():
    top_container = st.container()
    middle_container = st.container()
    bottom_container = st.container()
    #economics #Businesses	Child Care Spaces	Debt Risk Score	Home Prices	Local Employment	Social Assistance Recipients
    #equity #City Grants Funding $	Neighbourhood Equity Score	Salvation Army Donors	Walk Score	Watermain Breaks
    #health #Breast Cancer Screenings	Cervical Cancer Screenings	DineSafe Inspections	Female Fertility	Health Providers	Premature Mortality	Student Nutrition
    #Transport #TTC Stops	TTC Overcrowded Routes	Pedestrian/Other Collisions	Traffic Collisions	Road Kilometres	Road Volume
    #culture #Linguistic Diversity Index

    # neighour_df = NEIGHBORHOOD[(NEIGHBORHOOD['Neighbourhood'] == neighourhood_options)]
    # st.subheader("Socio economic Profile*")
    # st.metric("Neighborhood Name",neighourhood_options)
    # col3, col4,col5 = st.columns(3)
    # with top_container:
    #     with col3:
    #         st.metric("No. of Businesses",neighour_df['Businesses'])
    #     with col4:
    #         st.metric("No. of Child Care Spaces",neighour_df['Child Care Spaces'])
    #     with col5:
    #         st.metric("Debt Risk Score",neighour_df['Debt Risk Score'])
    # col6,col7, col8 = st.columns(3)
    # with bottom_container:
    #     with col6:
    #         st.metric("Home Prices",neighour_df['Home Prices'])
    #     with col7:
    #         st.metric("Local Employment",neighour_df['Local Employment'])
    #     with col8:
    #         st.metric("No. of Social Assistance Recipients",neighour_df['Social Assistance Recipients'])
    # st.markdown("*" "Information as of 2011")

with st.container():
    overview_df = df[(df['OCC_YEAR'].isin(year_options)) & (df['OCC_MONTH'].isin(month_options)) & (df['OCC_DOW'].isin(dow_options)) & (df['MCI_CATEGORY'].isin(mci_options)) & (df['PREMISES_TYPE'].isin(premises_options)) & (df['NEIGHBOURHOOD_158'] == neighourhood_options)] 
    
    st.subheader("Crime Type Breakdown")
    crimes_data = overview_df[['MCI_CATEGORY']]
    crimes_data = crimes_data.groupby('MCI_CATEGORY').agg(Total_reviews = ('MCI_CATEGORY', 'count')).reset_index()
    crimes_data.columns = ['MCI CATEGORY', 'Major Crime Count']
    fig = px.pie(crimes_data, values="Major Crime Count", names="MCI CATEGORY")
    st.plotly_chart(fig) 

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






			