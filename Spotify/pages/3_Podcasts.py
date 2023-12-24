from utils import * 

st.title(APP_NAME)
st.header(APP_PODCAST)

with st.sidebar:
    age_option = st.multiselect("Age",age,age)
    gender_option = st.multiselect("Gender",gender,gender)
    usage_option = st.multiselect("Usage",usage,usage)
    subscription_option = st.multiselect("Subscription",subscription,subscription)

with st.container():
    podcast_df = df[(df['Age'].isin(age_option)) & (df['Gender'].isin(gender_option)) & (df['spotify_usage_period'].isin(usage_option)) & (df['spotify_subscription_plan'].isin(subscription_option))]

    st.subheader("Listening Style")
    output_df = podcast_df[['spotify_listening_device']]
    output_df = output_df.groupby(['spotify_listening_device']).agg(Count = ('spotify_listening_device', 'count')).reset_index()
    output_df.columns = ['Listening Device', 'Count']
    output_df.sort_values("Count", ascending=True, inplace=True)
    fig = px.bar(output_df, x="Count", y="Listening Device",orientation='h')
    st.plotly_chart(fig)
           
    st.subheader("Genres")
    output_df = music_df[['fav_music_genre']]
    output_df = output_df.groupby(['fav_music_genre']).agg(Count = ('fav_music_genre', 'count')).reset_index()
    output_df.columns = ['Music Genre', 'Count']
    output_df.sort_values("Count", ascending=True,inplace=True)
    fig = px.bar(output_df, x="Count", y="Music Genre",orientation='h')
    st.plotly_chart(fig)
#     spotify_listening_device
# pod_lis_frequency
# fav_pod_genre
# preffered_pod_format
# pod_host_preference
# preffered_pod_duration
# pod_variety_satisfaction