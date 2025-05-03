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

# Plot 1: Fixed Acidity vs Volatile Acidity
fig1 = px.scatter(df, x='fixed acidity', y='volatile acidity',
                  title='Fixed Acidity vs Volatile Acidity',
                  labels={'fixed acidity': 'Fixed Acidity', 'volatile acidity': 'Volatile Acidity'})
st.plotly_chart(fig1, use_container_width=True)

# Plot 2: Free Sulfur Dioxide vs Total Sulfur Dioxide
fig2 = px.scatter(df, x='free sulfur dioxide', y='total sulfur dioxide',
                  title='Free vs Total Sulfur Dioxide',
                  labels={'free sulfur dioxide': 'Free SO₂', 'total sulfur dioxide': 'Total SO₂'})
st.plotly_chart(fig2, use_container_width=True)

# Plot 3: Sulphates vs Chlorides
fig3 = px.scatter(df, x='sulphates', y='chlorides',
                  title='Sulphates vs Chlorides',
                  labels={'sulphates': 'Sulphates', 'chlorides': 'Chlorides'})
st.plotly_chart(fig3, use_container_width=True)

# Plot 4: Density vs pH
fig4 = px.scatter(df, x='density', y='pH',
                  title='Density vs pH',
                  labels={'density': 'Density', 'pH': 'pH Level'})
st.plotly_chart(fig4, use_container_width=True)