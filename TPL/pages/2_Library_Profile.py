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
        st.write("Present Site Year",int(branch_df['PresentSiteYear'][0]))    
#branch location
#Add geojson data + #Lat	Long

with middle_container:
    st.subheader("Branch Features")
    col3, col4 = st.columns(2)
    with col3:
        st.write("Square Footage")
        st.write("No of workstations")
        st.write("Public Parking Available")
        st.write("Service Tier")
    with col4:
        st.write("Adult literacy Program Avilable")
        st.write("Computer learning centre Avilable")
        st.write("Digital Innovation Hub Avilable")
        st.write("Youth Hub Avilable")


    





st.subheader("Branch Trends")
# annual visits
# registrations
# Annual Circulation
# Annual Workstation Usage

# Wellheing index




