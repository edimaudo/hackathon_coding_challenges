
from utils import * 

st.title(APP_NAME)
st.header(APP_DATA_INSIGHTS)

app_list = df_analysis['app'].unique()
app_list.sort()
app_choice = st.multiselect("Companion App",app_list,app_list)
analysis = df_analysis[df_analysis['app'].isin(app_choice)]
    
# Average Printer Score
st.subheader("App Score")
printer_score = analysis[['app','score']]
printer_score_agg = printer_score.groupby('app').agg(Total = ('score', 'mean')).reset_index()
printer_score_agg.columns = ['Companion App', 'Score']
printer_score_agg = printer_score_agg.sort_values("Score", ascending=True).reset_index()
fig = px.bar(printer_score_agg, x="Score", y="Companion App", orientation='h')
st.plotly_chart(fig)

# Printer review count
st.subheader("App review Count")
printer_count = analysis[['app', 'reviewId']]
printer_count_agg = printer_count.groupby(['app'])['reviewId'].agg('count').reset_index()
printer_count_agg.columns = ['Companion App', '# of Reviews']
printer_count_agg = printer_count_agg.sort_values("# of Reviews", ascending=True).reset_index()
fig = px.bar(printer_count_agg, x="# of Reviews", y="Companion App", orientation='h')
st.plotly_chart(fig)

# Printer Score over time
st.subheader("App Score trend")
printer_score_time = analysis[['app','score','Date']]
printer_score_time_agg = printer_score_time.groupby(['app','Date']).agg(Total = ('score', 'mean')).reset_index()
printer_score_time_agg.columns = ['Companion App', 'Date','Score']
printer_score_time_agg = printer_score_time_agg.sort_values("Date")
fig = px.line(printer_score_time_agg, x="Date", y="Score",color='Companion App')
st.plotly_chart(fig)
    
# Average thumbs up by selected printer
st.subheader("AppThumbs Up Count")
printer_thumbsup = analysis[['app','thumbsUpCount']]
printer_thumbsup_agg = printer_thumbsup.groupby('app').agg(Total = ('thumbsUpCount', 'mean')).reset_index()
printer_thumbsup_agg.columns = ['Companion App', 'Thumbs Up']
printer_thumbsup_agg = printer_thumbsup_agg.sort_values("Thumbs Up", ascending=True).reset_index()
fig = px.bar(printer_thumbsup_agg, x="Thumbs Up", y="Companion App", orientation='h')
st.plotly_chart(fig)