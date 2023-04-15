# Libraries
import streamlit as st

st.title(APP_NAME)

# Load data
@st.cache_data
def load_data(DATA_URL):
    data = pd.read_csv(DATA_URL)
    return data

DATA_URL = "Major_Crime_Indicators_Open_Data.csv"    
df = load_data(DATA_URL)


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