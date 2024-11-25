from utils import * 
st.title(APP_NAME)

st.header(WINE_EXPLORATION_HEADER)


with st.container():
    wine_type = st.radio("Wine Type",['White Wine','Red Wine'])
    if wine_type == "White Wine":
    	df = white_df
    else:
    	df = red_df


    st.subheader("**Correlation**")
    df_corr = df.corr().round(1)
    # Mask to matrix
	mask = np.zeros_like(df_corr, dtype=bool)
	mask[np.triu_indices_from(mask)] = True
	# Viz
	df_corr_viz = df_corr.mask(mask).dropna(how='all').dropna('columns', how='all')
	fig = px.imshow(df_corr_viz, text_auto=True)
	#fig = px.imshow(df_corr,text_auto=True)
    st.plotly_chart(fig)


    #st.subheader("**Wine Clusters**")