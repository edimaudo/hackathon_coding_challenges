from utils import * 

st.title(APP_NAME)
st.header(OVERVIEW_HEADER )

#MONTH
#YEAR
#DAY OF WEEK
#MCI CATEGORY
#NEIGHBORHOOD
#PREMISE TYPE




# Data munging
YEAR =  df['OCC_YEAR'].unique()
YEAR  = YEAR.astype('int')
YEAR.sort()

MONTH = df['OCC_MONTH'].unique()
MONTH  = MONTH.astype('str')
MONTH = pd.DataFrame(MONTH,columns = ['Month'])
month_dict = {'January':1,'February':2,'March':3, 'April':4, 'May':5, 'June':6, 'July':7, 
'August':8, 'September':9, 'October':10, 'November':11, 'December':12}
MONTH = MONTH.sort_values('Month', key = lambda x : x.apply (lambda x : month_dict[x]))
MONTH = MONTH['Month'].values.tolist()

DAY_OF_WEEK = df['OCC_DOW'].unique()
DAY_OF_WEEK   = DAY_OF_WEEK.astype('str')
DAY_OF_WEEK = pd.DataFrame(DAY_OF_WEEK,columns = ['DOW'])
dow_dict = {'Monday':1,'Tuesday':2,'Wednesday':3, 'Thursday':4, 'Friday':5, 'Saturday':6, 'Sunday':7}
DAY_OF_WEEK = DAY_OF_WEEK.sort_values('DOW', key = lambda x : x.apply (lambda x : dow_dict[x]))
DAY_OF_WEEK = DAY_OF_WEEK['DOW'].values.tolist()

MCI_CATEGORY = df['MCI_CATEGORY'].unique()
MCI_CATEGORY  = MCI_CATEGORY.astype('str')
MCI_CATEGORY.sort()

NEIGHBORHOOD = df['NEIGHBOURHOOD_158'].unique()
NEIGHBORHOOD = NEIGHBORHOOD.astype('str')
NEIGHBORHOOD.sort()

PREMISES_TYPE = df['PREMISES_TYPE'].unique()
PREMISES_TYPE  = PREMISES_TYPE.astype('str')
PREMISES_TYPE.sort()


with st.expander("Filters"):
    year_options = st.multiselect('Year',YEAR,default=YEAR)
    month_options = st.multiselect('Month',MONTH,default=MONTH)
    dow_options = st.multiselect('Day of Week',DAY_OF_WEEK,default=DAY_OF_WEEK)
    mci_options = st.multiselect('Crime Type',MCI_CATEGORY,default=MCI_CATEGORY)
    premise_options = st.multiselect('Premises Type',PREMISES_TYPE,default =PREMISES_TYPE)
        
#with container():
    


#TOTAL MCI BY YEAR
#Total MCI BY MONTH GRAPH
#Total MCI BY WEEK GRAPH
#Total MCI BY HOUR GRAPH
# Crime type heatmap
#Properties heatmap

