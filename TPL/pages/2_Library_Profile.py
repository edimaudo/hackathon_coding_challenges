from utils import *

st.image(img)
st.title(APP_NAME)
st.header(LIBRARY_PROFILE_HEADER)

#side bar library name dropdown
branch_option = st.sidebar.selectbox('Branches',branch_list)


branch_df = general_info_branch[(general_info_branch['BranchName'] == branch_option)].reset_index()
top_container = st.container()
middle_container = st.container()
bottom_container = st.container()
wellbeing_container = st.container()


with top_container:
    st.subheader("Branch Profile")
    col1, col2 = st.columns(2)
    with col1:
        st.write("Branch Name" + " : " + str(branch_df['BranchName'][0]))
        st.write("Branch Code"+ " : " +branch_df['BranchCode'][0])
        st.write("Address" + " : " + branch_df['Address'][0])
        st.write("Postal Code"+ " : " +branch_df['PostalCode'][0])
    with col2:
        st.write("Telephone"+ " : " +branch_df['Telephone'][0])
        st.write("Website"+ " : " +branch_df['Website'][0])
        st.write("Ward Name" + " : " + branch_df['WardName'][0])
        st.write("Site Year" + " : " + str(int(branch_df['PresentSiteYear'][0])))  
#branch location
#Add geojson data + #Lat	Long

with middle_container:
    st.subheader("Branch Features")
    col1, col2 = st.columns(2)
    with col1:
        st.write("Square Footage")
        st.write("No of workstations")
        st.write("Public Parking Available")
        st.write("Service Tier")
    with col2:
        st.write("Adult literacy Program Avilable")
        st.write("Computer learning centre Avilable")
        st.write("Digital Innovation Hub Avilable")
        st.write("Youth Hub Avilable")



with bottom_container:
    st.subheader("Branch Trends")
    st.markdown("**Annual Vists**")
    df = visits_branch[['Year','BranchCode','Visits']]
    df = df[(df['BranchCode'] == branch_df['BranchCode'][0])]
    df = df[['Year','Visits']]
    df= df.groupby(['Year']).agg(Total_visits = ('Visits', 'sum')).reset_index()
    df.columns = ['Year','Total Visits']
    df = df.sort_values("Year", ascending=True).reset_index()
    fig = px.bar(df, x="Year", y="Total Visits")
    st.plotly_chart(fig)

    st.markdown("**Annual Registrations**")
    df = card_registration_branch[['Year','BranchCode','Registrations']]
    df = df[(df['BranchCode'] == branch_df['BranchCode'][0])]
    df = df[['Year','Registrations']]
    df= df.groupby(['Year']).agg(Total_registrations = ('Registrations', 'sum')).reset_index()
    df.columns = ['Year','Total Registrations']
    df = df.sort_values("Year", ascending=True).reset_index()
    fig = px.bar(df, x="Year", y="Total Registrations")
    st.plotly_chart(fig)

    st.markdown("**Annual Circulations**")
    df = circulation_branch[['Year','BranchCode','Circulation']]
    df = df[(df['BranchCode'] == branch_df['BranchCode'][0])]
    df = df[['Year','Circulation']]
    df= df.groupby(['Year']).agg(Total_circulations = ('Circulation', 'sum')).reset_index()
    df.columns = ['Year','Total Circulations']
    df = df.sort_values("Year", ascending=True).reset_index()
    fig = px.bar(df, x="Year", y="Total Circulations")
    st.plotly_chart(fig)

    st.markdown("**Annual Workstation Usage**")
    df = workstation_usage_branch[['Year','BranchCode','Sessions']]
    df = df[(df['BranchCode'] == branch_df['BranchCode'][0])]
    df = df[['Year','Sessions']]
    df= df.groupby(['Year']).agg(Total_sessions = ('Sessions', 'sum')).reset_index()
    df.columns = ['Year','Total Sessions']
    df = df.sort_values("Year", ascending=True).reset_index()
    fig = px.bar(df, x="Year", y="Total Sessions")
    st.plotly_chart(fig)





