from utils import * 

st.title(APP_NAME)
#st.header(APP_LOAN)

# country_choice = st.multiselect("Countries",country,['Costa Rica','Chile'])
# funding_status = ['funded','fundRaising']
# sector_df = df[(df['COUNTRY_NAME'].isin(country_choice)) & df['STATUS'].isin(funding_status)]

# with st.expander("Country Insights"):
#     top_tab1, top_tab2,top_tab3, top_tab4 = st.tabs(["Avg. Loan Amount", "Avg. Loan Amount by Year","Avg. Lender Term", "Avg. # of Lenders"])
#     with top_tab1:
#         sector_count_df = sector_df[['COUNTRY_NAME','LOAN_AMOUNT']]
#         sector_df_agg = sector_count_df.groupby('COUNTRY_NAME').agg(Lenders = ('LOAN_AMOUNT', 'mean')).reset_index()
#         sector_df_agg.columns = ['Country', 'Loan Amount ($)']
#         sector_df_agg = sector_df_agg.sort_values("Loan Amount ($)", ascending=True).reset_index()
#         fig = px.bar(sector_df_agg, x="Loan Amount ($)", y="Country", orientation='h')
#         st.plotly_chart(fig)
#     with top_tab2:
#         sector_count_df = sector_df[['COUNTRY_NAME','Year','LOAN_AMOUNT']]
#         sector_count_df_agg = sector_count_df.groupby(['COUNTRY_NAME','Year']).agg(Lenders = ('LOAN_AMOUNT', 'mean')).reset_index()
#         sector_count_df_agg.columns = ['Country', 'Year','Loan Amount ($)']
#         sector_count_df_agg = sector_count_df_agg.sort_values("Year", ascending=True).reset_index()
#         fig = px.line(sector_count_df_agg, x="Year", y="Loan Amount ($)", color_discrete_sequence=px.colors.qualitative.Alphabet,color="Country")
#         st.plotly_chart(fig)
#     with top_tab3:
#         sector_count_df = sector_df[['COUNTRY_NAME','LENDER_TERM']]
#         sector_count_df_agg = sector_count_df.groupby('COUNTRY_NAME').agg(Lenders = ('LENDER_TERM', 'mean')).reset_index()
#         sector_count_df_agg.columns = ['Country', 'Avg Lender Term (in Months)']
#         sector_count_df_agg = sector_count_df_agg.sort_values("Avg Lender Term (in Months)", ascending=True).reset_index()
#         fig = px.bar(sector_count_df_agg, x="Avg Lender Term (in Months)", y="Country", orientation='h')
#         st.plotly_chart(fig)
#     with top_tab4:
#         sector_count_df = sector_df[['COUNTRY_NAME','NUM_LENDERS_TOTAL']]
#         sector_count_df_agg = sector_count_df.groupby('COUNTRY_NAME').agg(Lenders = ('NUM_LENDERS_TOTAL', 'mean')).reset_index()
#         sector_count_df_agg.columns = ['Country', 'Avg # of Lenders']
#         sector_count_df_agg = sector_count_df_agg.sort_values("Avg # of Lenders", ascending=True).reset_index()
#         fig = px.bar(sector_count_df_agg, x="Avg # of Lenders", y="Country", orientation='h')
#         st.plotly_chart(fig)


# with st.expander("Sector Insights"):
#     top_tab1, top_tab2,top_tab3, top_tab4 = st.tabs(["Avg. Loan Amount", "Avg. Loan Amount by Year","Avg. Lender Term", "Avg. # of Lenders"])
#     with top_tab1:
#         sector_count_df = sector_df[['SECTOR_NAME','LOAN_AMOUNT']]
#         sector_df_agg = sector_count_df.groupby('SECTOR_NAME').agg(Lenders = ('LOAN_AMOUNT', 'mean')).reset_index()
#         sector_df_agg.columns = ['Sector', 'Loan Amount ($)']
#         sector_df_agg = sector_df_agg.sort_values("Loan Amount ($)", ascending=True).reset_index()
#         fig = px.bar(sector_df_agg, x="Loan Amount ($)", y="Sector", orientation='h')
#         st.plotly_chart(fig)
#     with top_tab2:
#         sector_count_df = sector_df[['SECTOR_NAME','Year','LOAN_AMOUNT']]
#         sector_count_df_agg = sector_count_df.groupby(['SECTOR_NAME','Year']).agg(Lenders = ('LOAN_AMOUNT', 'mean')).reset_index()
#         sector_count_df_agg.columns = ['Sector', 'Year','Loan Amount ($)']
#         sector_count_df_agg = sector_count_df_agg.sort_values("Year", ascending=True).reset_index()
#         fig = px.line(sector_count_df_agg, x="Year", y="Loan Amount ($)", color_discrete_sequence=px.colors.qualitative.Alphabet,color="Sector")
#         st.plotly_chart(fig)
#     with top_tab3:
#         sector_count_df = sector_df[['SECTOR_NAME','LENDER_TERM']]
#         sector_count_df_agg = sector_count_df.groupby('SECTOR_NAME').agg(Lenders = ('LENDER_TERM', 'mean')).reset_index()
#         sector_count_df_agg.columns = ['Sector', 'Avg Lender Term (in months)']
#         sector_count_df_agg = sector_count_df_agg.sort_values("Avg Lender Term (in months)", ascending=True).reset_index()
#         fig = px.bar(sector_count_df_agg, x="Avg Lender Term (in months)", y="Sector", orientation='h')
#         st.plotly_chart(fig)
#     with top_tab4:
#         sector_count_df = sector_df[['SECTOR_NAME','NUM_LENDERS_TOTAL']]
#         sector_count_df_agg = sector_count_df.groupby('SECTOR_NAME').agg(Lenders = ('NUM_LENDERS_TOTAL', 'mean')).reset_index()
#         sector_count_df_agg.columns = ['Sector', 'Avg # of Lenders']
#         sector_count_df_agg = sector_count_df_agg.sort_values("Avg # of Lenders", ascending=True).reset_index()
#         fig = px.bar(sector_count_df_agg, x="Avg # of Lenders", y="Sector", orientation='h')
#         st.plotly_chart(fig)

# with st.expander("Activites Insights"):
#     top_tab1, top_tab2,top_tab3, top_tab4 = st.tabs(["Avg. Loan Amount", "Avg. Loan Amount by Year","Avg. Lender Term", "Avg. # of Lenders"])
#     with top_tab1:
#         sector_count_df = sector_df[['ACTIVITY_NAME','LOAN_AMOUNT']]
#         sector_df_agg = sector_count_df.groupby('ACTIVITY_NAME').agg(Lenders = ('LOAN_AMOUNT', 'mean')).reset_index()
#         sector_df_agg.columns = ['Activity', 'Loan Amount ($)']
#         sector_df_agg = sector_df_agg.sort_values("Loan Amount ($)", ascending=True).reset_index()
#         fig = px.bar(sector_df_agg, x="Loan Amount ($)", y="Activity", orientation='h')
#         st.plotly_chart(fig)
#     with top_tab2:
#         sector_count_df = sector_df[['ACTIVITY_NAME','Year','LOAN_AMOUNT']]
#         sector_count_df_agg = sector_count_df.groupby(['ACTIVITY_NAME','Year']).agg(Lenders = ('LOAN_AMOUNT', 'mean')).reset_index()
#         sector_count_df_agg.columns = ['Activity', 'Year','Loan Amount ($)']
#         sector_count_df_agg = sector_count_df_agg.sort_values("Year", ascending=True).reset_index()
#         fig = px.line(sector_count_df_agg, x="Year", y="Loan Amount ($)", color_discrete_sequence=px.colors.qualitative.Alphabet,color="Activity")
#         st.plotly_chart(fig)
#     with top_tab3:
#         sector_count_df = sector_df[['ACTIVITY_NAME','LENDER_TERM']]
#         sector_count_df_agg = sector_count_df.groupby('ACTIVITY_NAME').agg(Lenders = ('LENDER_TERM', 'mean')).reset_index()
#         sector_count_df_agg.columns = ['Activity', 'Avg Lender Term (in months)']
#         sector_count_df_agg = sector_count_df_agg.sort_values("Avg Lender Term (in months)", ascending=True).reset_index()
#         fig = px.bar(sector_count_df_agg, x="Avg Lender Term (in months)", y="Activity", orientation='h')
#         st.plotly_chart(fig)
#     with top_tab4:
#         sector_count_df = sector_df[['ACTIVITY_NAME','NUM_LENDERS_TOTAL']]
#         sector_count_df_agg = sector_count_df.groupby('ACTIVITY_NAME').agg(Lenders = ('NUM_LENDERS_TOTAL', 'mean')).reset_index()
#         sector_count_df_agg.columns = ['Activity', 'Avg # of Lenders']
#         sector_count_df_agg = sector_count_df_agg.sort_values("Avg # of Lenders", ascending=True).reset_index()
#         fig = px.bar(sector_count_df_agg, x="Avg # of Lenders", y="Activity", orientation='h')
#         st.plotly_chart(fig)



