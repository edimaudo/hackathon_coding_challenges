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
           
    st.subheader("Listening Frequency")
    output_df = podcast_df[['pod_lis_frequency']]
    output_df = output_df.groupby(['pod_lis_frequency']).agg(Count = ('pod_lis_frequency', 'count')).reset_index()
    output_df.columns = ['Listening Frequency, 'Count']
    output_df.sort_values("Count", ascending=True,inplace=True)
    fig = px.bar(output_df, x="Count", y="Listening Frequency",orientation='h')
    st.plotly_chart(fig)

    st.subheader("Genre")
    output_df = podcast_df[['fav_pod_genre']]
    output_df = output_df.groupby(['fav_pod_genre']).agg(Count = ('fav_pod_genre', 'count')).reset_index()
    output_df.columns = ['Genre, 'Count']
    output_df.sort_values("Count", ascending=True,inplace=True)
    fig = px.bar(output_df, x="Count", y="Genre",orientation='h')
    st.plotly_chart(fig)

    st.subheader("Format")
    output_df = podcast_df[['preffered_pod_format']]
    output_df = output_df.groupby(['preffered_pod_format']).agg(Count = ('preffered_pod_format', 'count')).reset_index()
    output_df.columns = ['Format, 'Count']
    output_df.sort_values("Count", ascending=True,inplace=True)
    fig = px.bar(output_df, x="Count", y="Format",orientation='h')
    st.plotly_chart(fig)

    st.subheader("Host Preference")
    output_df = podcast_df[['pod_host_preference']]
    output_df = output_df.groupby(['pod_host_preference']).agg(Count = ('pod_host_preference', 'count')).reset_index()
    output_df.columns = ['Host Preference, 'Count']
    output_df.sort_values("Count", ascending=True,inplace=True)
    fig = px.bar(output_df, x="Count", y="Host Preference",orientation='h')
    st.plotly_chart(fig)

    st.subheader("Podcast Duration")
    output_df = podcast_df[['preffered_pod_duration']]
    output_df = output_df.groupby(['preffered_pod_duration']).agg(Count = ('preffered_pod_duration', 'count')).reset_index()
    output_df.columns = ['Podcast Duration, 'Count']
    output_df.sort_values("Count", ascending=True,inplace=True)
    fig = px.bar(output_df, x="Count", y="Podcast Duration",orientation='h')
    st.plotly_chart(fig)

