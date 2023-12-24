from utils import * 

st.title(APP_NAME)
st.header(APP_MUSIC)

with st.sidebar:
    age_option = st.multiselect("Age",age,age)
    gender_option = st.multiselect("Gender",gender,gender)
    usage_option = st.multiselect("Usage",usage,usage)
    subscription_option = st.multiselect("Subscription",subscription,subscription)

with st.container():
    music_df = df[(df['Age'].isin(age_option)) & (df['Gender'].isin(gender_option)) & (df['spotify_usage_period'].isin(usage_option)) & (df['spotify_subscription_plan'].isin(subscription_option))]
    
    st.subheader("Listening Style")
    output_df = music_df[['spotify_listening_device']]
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

    st.subheader('Music Time Slot')
    output_df = music_df[['music_time_slot']]
    output_df = output_df.groupby(['music_time_slot']).agg(Count = ('music_time_slot', 'count')).reset_index()
    output_df.columns = ['Music Time slot', 'Count']
    output_df.sort_values("Count", ascending=False, inplace=True)
    fig = px.pie(output_df, values='Count', names='Music Time slot')
    st.plotly_chart(fig)

