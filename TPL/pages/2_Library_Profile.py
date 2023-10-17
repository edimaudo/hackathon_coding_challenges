from utils import *

st.image(img)
st.title(APP_NAME)
st.header(LIBRARY_PROFILE_HEADER)

#side bar library name dropdown
branch_option = st.sidebar.selectbox('Branches',branches)


st.subheader("Branch Profile")
branch_df =  general_info_branch[(general_info_branch.BranchName == branch_option)]   #general_info_branch[(general_info_branch['BranchName']==(branch_option))]
top_metric_container = st.container()
middle_metric_container = st.container()
bottom_metric_container = st.container()
col1, col2,col3 = st.columns(3)
with st.container():
    with col1:
        st.metric("Branch Name",branch_df['BranchName'])
        st.metric("Address",branch_df['Address'])
        st.metric("Present Site Year",branch_df['PresentSiteYear'])
    with col2:
        st.metric("Branch Name",branch_df['BranchName'])
        st.metric("Address",branch_df['Address'])
        st.metric("Present Site Year",branch_df['PresentSiteYear'])
    with col3:
        st.metric("Branch Name",branch_df['BranchName'])
        st.metric("Address",branch_df['Address'])
        st.metric("Present Site Year",branch_df['PresentSiteYear'])

#branch profile
#BranchName BranchCode # PhysicalBranch
#Address	PostalCode	WardName
#PresentSiteYear #Website	Telephone		

#branch location
#Add geojson data + #Lat	Long

st.subheader("Branch Features")
##branch features
#SquareFootage	PublicParking
# Workstations
#ServiceTier
#AdultLiteracyProgram	
#computer learning centre available
#digital innovation hub 
#kid stop early learning centre
#Youth advisory
#youth hub

st.subheader("Branch Trends")
# annual visits
# registrations
# Annual Circulation
# Annual Workstation Usage

# Wellheing index




