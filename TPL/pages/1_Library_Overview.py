# Library Overview

from utils import *

st.image(img)
st.title(APP_NAME)
st.header(LIBRARY_OVERVIEW_HEADER)

with st.container():
    top_metric_container = st.container()
    bottom_metric_container = st.container()
    col1, col2,col3,col4 = st.columns(4)
    with top_metric_container:
        with col1:
            st.metric("No of libraries",general_info_branch.shape[0])
        with col2:
            st.metric("No of computer learning centres",computer_learning_centre.shape[0])
        with col3:
            st.metric("No of digital innovation hubs",digital_innovation_hub.shape[0])
        with col4:
            st.metric("No of kidstop literacy centres",kid_stop.shape[0])
    with bottom_metric_container:
        with col1:
            st.metric("No of neighorhood improvement areas",neighorhood_improvement.shape[0])
        with col2:
            st.metric("No of youth advisory group locations",youth_advisory.shape[0])
        with col3:
            st.metric("No of youth hub locations",youth_hubs.shape[0])        

with st.container():
    st.subheader("Annual Visits")
    df = visits_branch[['Year','Visits']]
    df= df.groupby(['Year']).agg(Total_visits = ('Visits', 'sum')).reset_index()
    df.columns = ['Year','Total Visits']
    df = df.sort_values("Year", ascending=True).reset_index()
    fig = px.bar(df, x="Year", y="Total Visits")
    st.plotly_chart(fig)
    st.subheader("Annual Registrations")
    df = card_registration_branch[['Year','Registrations']]
    df= df.groupby(['Year']).agg(Total_registrations = ('Registrations', 'sum')).reset_index()
    df.columns = ['Year','Total Registrations']
    df = df.sort_values("Year", ascending=True).reset_index()
    fig = px.bar(df, x="Year", y="Total Registrations")
    st.plotly_chart(fig)
    st.subheader("Annual Circulation")
    df = circulation_branch[['Year','Circulation']]
    df= df.groupby(['Year']).agg(Total_circulations = ('Circulation', 'sum')).reset_index()
    df.columns = ['Year','Total Circulations']
    df = df.sort_values("Year", ascending=True).reset_index()
    fig = px.bar(df, x="Year", y="Total Circulations")
    st.plotly_chart(fig)
    st.subheader("Annual Workstation Usage")
    df = workstation_usage_branch[['Year','Sessions']]
    df= df.groupby(['Year']).agg(Total_sessions = ('Sessions', 'sum')).reset_index()
    df.columns = ['Year','Total Sessions']
    df = df.sort_values("Year", ascending=True).reset_index()
    fig = px.bar(df, x="Year", y="Total Sessions")
    st.plotly_chart(fig)


