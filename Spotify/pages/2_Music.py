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
    output_df.sort_values("Count", ascending=True, inplace=True)
    fig = px.pie(output_df, values='Count', names='Music Time slot')
    st.plotly_chart(fig)

    st.subheader('Music Mood')
    output_df = music_df[['music_Influencial_mood']]
    output_df = output_df.groupby(['music_Influencial_mood']).agg(Count = ('music_Influencial_mood', 'count')).reset_index()
    output_df.columns = ['Music Mood', 'Count']
    output_df.sort_values("Count", ascending=True,inplace=True)
    fig = px.bar(output_df, x="Count", y="Music Mood",orientation='h')
    st.plotly_chart(fig)

    st.subheader('Music Listening Frequency')
    output_df = music_df[['music_lis_frequency']]
    output_df = output_df.groupby(['music_lis_frequency']).agg(Count = ('music_lis_frequency', 'count')).reset_index()
    output_df.columns = ['Listening Frequency', 'Count']
    output_df.sort_values("Count", ascending=True,inplace=True)
    fig = px.bar(output_df, x="Count", y="Listening Frequency",orientation='h')
    st.plotly_chart(fig)

    st.subheader('Music Exploration Method')
    output_df = music_df[['music_expl_method']]
    output_df = output_df.groupby(['music_expl_method']).agg(Count = ('music_expl_method', 'count')).reset_index()
    output_df.columns = ['Music Exploration', 'Count']
    output_df.sort_values("Count", ascending=True,inplace=True)
    fig = px.bar(output_df, x="Count", y="Music Exploration",orientation='h')
    st.plotly_chart(fig)

    st.subheader('Music Recommendation Rating')
    output_df = music_df[['music_recc_rating']]
    output_df = output_df.groupby(['music_recc_rating']).agg(Count = ('music_recc_rating', 'count')).reset_index()
    output_df.columns = ['Recommendation Rating', 'Count']
    output_df.sort_values("Recommendation Rating", ascending=True,inplace=True)
    fig = px.bar(output_df, x="Count", y="Recommendation Rating",orientation='h')
    st.plotly_chart(fig)