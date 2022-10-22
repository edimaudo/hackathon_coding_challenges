# Libraries
import streamlit as st
import pandas as pd
import os, os.path

st.title('Kiva Insights')
# Load data
@st.cache
def load_data():
    data = pd.read_csv(DATA_URL)
    return data
DATA_URL = "loans.csv"
df = load_data()

st.header("About")
with st.expander(" "):
    st.write("""
The application leverages Kiva's data snapshot to build financial tool that analyzes loan information and helps the analyst find the which sectors are providing the best return on investment for the users.
The application focuses on three key areas:
- **Sector Insights**: Attribtutes by sectors.  This is done by country
- **Fund distribution**: How might we optimize fund distribution to borrowers? This is done by country
- **Loan impact**: How might we show the impact of the loans? This leverages the SROI framework
    """)

st.header("Data Overview")
with st.expander(" "):
    st.subheader("Here is a preview of the data")
    st.dataframe(df.head(35))
st.header("Data Summary")
top_container = st.container()
middle_container = st.container()
bottom_container = st.container()
metric_column1, metric_column2,metric_column3 = st.columns(3)
with top_container:
    with metric_column1:
        st.metric("Status",str(len(df['STATUS'].unique())))
    with metric_column2:
        st.metric("# of Languages",str(len(df['ORIGINAL_LANGUAGE'].unique())))
with middle_container:
    with metric_column1:
        st.metric("# of Sectors",str(len(df['SECTOR_NAME'].unique())))
    with metric_column2:
        st.metric("# of Countries",str(len(df['COUNTRY_NAME'].unique())))
    with metric_column3:
        st.metric("# of Currencies",str(len(df['CURRENCY'].unique())))
with bottom_container:
    with metric_column1:
        st.metric("Average Loan Amount",str(df['LOAN_AMOUNT'].mean()))
    with metric_column2:
        st.metric("# of Lender Terms",str(len(df['LENDER_TERM'].unique())))
    with metric_column3:
        st.metric("# of Currency Policies",str(len(df['CURRENCY_POLICY'].unique())))




