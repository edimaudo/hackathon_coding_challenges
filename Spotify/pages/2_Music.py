from utils import * 

st.title(APP_NAME)
st.header(APP_MUSIC)

with st.sidebar:
    age_option = st.multiselect("Age",age,age)
    gender_option = st.multiselect("Gender",gender,gender)
    usage_option = st.multiselect("Usage",usage,usage)
    subscription_option = st.multiselect("Subscription",subscription,subscription)


tab1, tab2, tab3, tab4, tab5, tab6, tab7, tab8, = st.tabs(["Cat", "Dog", "Owl","Cat", "Dog", "Owl","Cat", "Dog"])