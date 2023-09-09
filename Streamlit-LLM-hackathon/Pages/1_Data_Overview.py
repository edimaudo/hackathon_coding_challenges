from utils import * 

st.title(APP_NAME)
st.header(APP_OVERVIEW)

metric_column1, metric_column2,metric_column3,metric_column4 = st.columns(4)
metric_column1.metric("Number of Apps",str( len(df['appId'].unique())))
metric_column2.metric("Number of reviewers",str(len(df['userName'].unique())))
metric_column3.metric("Number of reviews",str(len(df['reviewId'].unique())))
metric_column4.metric("Average Score",str(float("{:.2f}".format(df['score'].mean()))))

st.subheader("Data Snapshot")
with st.expander(" "):
    st.dataframe(df.head(10))

st.subheader("Average Printer Score over time")
printer_score_time = df_analysis[['app','score','Date']]
printer_score_time_agg = printer_score_time.groupby(['app','Date']).agg(Total = ('score', 'mean')).reset_index()
printer_score_time_agg.columns = ['Companion App', 'Date','Score']
printer_score_time_agg = printer_score_time_agg.sort_values("Date")
fig = px.line(printer_score_time_agg, x="Date", y="Score",color='Companion App')
st.plotly_chart(fig)