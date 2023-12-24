from utils import * 

st.title(APP_NAME)
st.header(APP_MUSIC)

with st.sidebar:
    age_option = st.multiselect("Age",age,age)
    gender_option = st.multiselect("Gender",gender,gender)
    usage_option = st.multiselect("Usage",usage,usage)
    subscription_option = st.multiselect("Subscription",subscription,subscription)

with st.container():
    container = st.container()
    #middle_container = st.container()
    #bottom_container = st.container()
    col1, col2 = st.columns(2)
    music_df = df[(df['Age'].isin(age_option)) & (df['Gender'].isin(gender_option)) & (df['spotify_usage_period'].isin(usage_option)) & (df['spotify_subscription_plan'].isin(subscription_option))]
    with container:
        with col1:
            pass
        with col2:
            pass
    with container:
        with col1:
            pass
        with col2:
            pass
    with container:
        with col1:
            pass
        with col2:
            pass
