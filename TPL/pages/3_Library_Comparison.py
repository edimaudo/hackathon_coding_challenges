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

##branch profile
#branch profile
#BranchName BranchCode # PhysicalBranch
#Address	PostalCode	PresentSiteYear
#WardNo	WardName
#Website	Telephone		
#Lat	Long
#branch location - #Add geojson data

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

#Trends
# annual visits
# registrations
# Annual Circulation
# Annual Workstation Usage

#wellbeing index#
#Add LLM using Langchain —> https://python.langchain.com/docs/modules/agents/toolkits/pandas.html