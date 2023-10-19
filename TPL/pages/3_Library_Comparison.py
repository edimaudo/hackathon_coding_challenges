#branch comparison
from utils import *

st.image(img)
st.title(APP_NAME)
st.header(LIBRARY_COMPARISON_HEADER)

top_container = st.container()
middle_container = st.container()
bottom_container = st.container()
branch_option1 = st.sidebar.selectbox('First Branch',branch_list)
branch_option2 = st.sidebar.selectbox('Second Branch',branch_list)
branch_df1 = general_info_branch[(general_info_branch['BranchName'] == branch_option1)].reset_index()
branch_df2 = general_info_branch[(general_info_branch['BranchName'] == branch_option2)].reset_index()

with top_container:
    st.subheader("Branch Profile")
    col1, col2 = st.columns(2)
    with col1:
        st.write("Branch Name" + " : " + str(branch_df1['BranchName'][0]))
        st.write("Branch Code"+ " : " +branch_df1['BranchCode'][0])
        st.write("Address" + " : " + branch_df1['Address'][0])
        st.write("Postal Code"+ " : " +branch_df1['PostalCode'][0])
        st.write("Telephone"+ " : " +branch_df1['Telephone'][0])
        st.write("Website"+ " : " +branch_df1['Website'][0])
        st.write("Ward Name" + " : " + branch_df1['WardName'][0])
        st.write("Site Year" + " : " + str(int(branch_df1['PresentSiteYear'][0])))  
    with col2:
        st.write("Branch Name" + " : " + str(branch_df2['BranchName'][0]))
        st.write("Branch Code"+ " : " +branch_df2['BranchCode'][0])
        st.write("Address" + " : " + branch_df2['Address'][0])
        st.write("Postal Code"+ " : " +branch_df2['PostalCode'][0])
        st.write("Telephone"+ " : " +branch_df2['Telephone'][0])
        st.write("Website"+ " : " +branch_df2['Website'][0])
        st.write("Ward Name" + " : " + branch_df2['WardName'][0])
        st.write("Site Year" + " : " + str(int(branch_df2['PresentSiteYear'][0])))  
    #Lat	Long
#branch location - #Add geojson data

with middle_container:
    st.subheader("Branch Features")
    col1, col2 = st.columns(2)
    with col1:
        st.write("Square Footage")
        st.write("No of workstations")
        st.write("Public Parking Available")
        st.write("Service Tier")
        st.write("Adult literacy Program Avilable")
        st.write("Computer learning centre Avilable")
        st.write("Digital Innovation Hub Avilable")
        st.write("Youth Hub Avilable")	
    with col2:
        st.write("Square Footage")
        st.write("No of workstations")
        st.write("Public Parking Available")
        st.write("Service Tier")
        st.write("Adult literacy Program Avilable")
        st.write("Computer learning centre Avilable")
        st.write("Digital Innovation Hub Avilable")
        st.write("Youth Hub Avilable")	

with bottom_container:
    st.subheader("Branch Trends")
    st.markdown("**Annual Vists**")
    df = visits_branch[['Year','BranchCode','Visits']]
    df = df[(df['BranchCode'].isin(branch_df1['BranchCode'][0],branch_df2['BranchCode'][0]))]
    df = df[['Year','BranchCode','Visits']]
    df= df.groupby(['Year','BranchCode']).agg(Total_visits = ('Visits', 'sum')).reset_index()
    df.columns = ['Year','Branch Code','Total Visits']
    df = df.sort_values("Year", ascending=True).reset_index()
    fig = px.bar(df, x="Year", y="Total Visits", color='Branch Code')
    st.plotly_chart(fig)

    st.markdown("**Annual Registrations**")
    df = card_registration_branch[['Year','BranchCode','Registrations']]
    df = df[(df['BranchCode'].isin(branch_df1['BranchCode'][0],branch_df2['BranchCode'][0]))]
    df = df[['Year','Registrations']]
    df= df.groupby(['Year','BranchCode']).agg(Total_registrations = ('Registrations', 'sum')).reset_index()
    df.columns = ['Year','Branch Code','Total Registrations']
    df = df.sort_values("Year", ascending=True).reset_index()
    fig = px.bar(df, x="Year", y="Total Registrations",color = 'Branch Code')
    st.plotly_chart(fig)

    st.markdown("**Annual Circulations**")
    df = circulation_branch[['Year','BranchCode','Circulation']]
    df = df[(df['BranchCode'].isin(branch_df1['BranchCode'][0],branch_df2['BranchCode'][0]))]
    df = df[['Year','Circulation']]
    df= df.groupby(['Year','BranchCode']).agg(Total_circulations = ('Circulation', 'sum')).reset_index()
    df.columns = ['Year','BranchCode','Total Circulations']
    df = df.sort_values("Year", ascending=True).reset_index()
    fig = px.bar(df, x="Year", y="Total Circulations",color='Branch Code')
    st.plotly_chart(fig)

    st.markdown("**Annual Workstation Usage**")
    df = workstation_usage_branch[['Year','BranchCode','Sessions']]
    df = df[(df['BranchCode'].isin(branch_df1['BranchCode'][0],branch_df2['BranchCode'][0]))]
    df = df[['Year','BranchCode','Sessions']]
    df= df.groupby(['Year','BranchCode']).agg(Total_sessions = ('Sessions', 'sum')).reset_index()
    df.columns = ['Year','Branch Code','Total Sessions']
    df = df.sort_values("Year", ascending=True).reset_index()
    fig = px.bar(df, x="Year", y="Total Sessions",color='Branch Code')
    st.plotly_chart(fig)

#wellbeing index#

# Data Q&A
#Add LLM using Langchain —> https://python.langchain.com/docs/modules/agents/toolkits/pandas.html