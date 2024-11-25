from utils import * 
st.title(APP_NAME)

st.subheader(WINE_EXPLORATION_HEADER)


with st.container():
    wine_type = st.radio("Wine Type",['White Wine','Red Wine'])
    if wine_type == "White Wine":
    	df = white_df
    else:
    	df = red_df

    