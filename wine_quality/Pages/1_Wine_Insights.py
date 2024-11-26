from utils import * 
st.title(APP_NAME)

st.header(OVERVIEW_HEADER)

wine_type = st.radio("Wine Type",['White Wine','Red Wine'])
if wine_type == "White Wine":
	df = white_df
else:
	df = red_df

st.subheader("**Data Preview**")
with st.expander(" "):
	st.dataframe(df.head(30))

st.subheader("**Data Visualization**")

