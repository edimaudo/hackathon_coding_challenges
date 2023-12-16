from utils import * 

st.title(APP_NAME)
# st.header(APP_RISK)

# with st.expander("Filters"):
#     country_choice = st.multiselect("Countries",country,['Costa Rica'])
#     sector_choice = st.multiselect('Sectors', sector,sector)

# funding_status = ['funded','fundRaising']
# def calculate_portfolio_returns(country_choice,sector_choice,funding_status):
#     fund_df = df[(df['COUNTRY_NAME'].isin(country_choice)) & (df['STATUS'].isin(funding_status)) & (df['SECTOR_NAME'].isin(sector_choice))]
#     fund_df['DISBURSE_TIME'] = pd.to_datetime(fund_df['DISBURSE_TIME']).dt.date
#     fund_df_agg = fund_df.groupby(['SECTOR_NAME', 'DISBURSE_TIME']).agg(TOTAL_FUNDED_AMOUNT = ('FUNDED_AMOUNT', 'sum')).reset_index()
#     fund_df_agg.columns = ['SECTOR NAME', 'DISBURSE TIME', 'TOTAL FUNDED AMOUNT']

#     # sector
#     sector_count =  len(fund_df_agg['SECTOR NAME'].unique())

#     # CREATE Pivot data
#     fund_df_agg_pivot = pd.pivot_table(data=fund_df_agg,values ='TOTAL FUNDED AMOUNT',columns=['SECTOR NAME'] ,index=['DISBURSE TIME'])
#     fund_df_agg_pivot = fund_df_agg_pivot.fillna(0)

#     # mean daily loans
#     mean_ret = fund_df_agg_pivot.mean(axis=0)
#     # covariance matrix with annualization
#     cov_mat = pd.DataFrame.cov(fund_df_agg_pivot) * 252
#     #simulation of 10000 portfolios
#     num_port = 10000
#     # Creating a matrix to store the weights
#     all_wts  = []
#     # Portfolio returns
#     port_returns = []
#     # Portfolio Standard deviation
#     port_risk = []
#     # Portfolio Sharpe Ratio
#     sharpe_ratio = []

#     random.seed(10)
#     # Simulation
#     sim_data = list(range(1,num_port+1))
#     for value in sim_data:
#         #for value in sim_data:
#         wts = np.random.uniform(0,1,sector_count)
#         wts = wts/sum(wts)
#         # Storing weight
#         all_wts.append(wts)

#         # Portfolio returns
#         port_ret = sum(wts * mean_ret)

#         # Storing Portfolio Returns values
#         port_returns.append(port_ret)

#         # Creating and storing portfolio risk
#         port_sd = math.sqrt(np.matmul(wts.transpose(),(np.matmul(cov_mat,wts))))
#         port_risk.append(port_sd)

#         # Creating and storing Portfolio Sharpe Ratios
#         # Assuming 0% Risk free rate
#         sr = port_ret/port_sd
#         sharpe_ratio.append(sr)

#     # Storing the values in the table
#     portfolio_values = pd.DataFrame()
#     portfolio_values['Return']  = port_returns
#     portfolio_values['Risk']  = port_risk
#     portfolio_values['SharpeRatio']  = sharpe_ratio

#     column_info = fund_df_agg['SECTOR NAME'].unique()
#     all_weights = pd.DataFrame (all_wts, columns = column_info)

#     # Combing all the values together
#     portfolio_values = pd.concat([all_weights, portfolio_values], axis = 1)

#     # Next lets look at the portfolios that matter the most.
#     # - The minimum variance portfolio
#     min_var_index = portfolio_values[['Risk']].idxmin()
#     max_sr_index = portfolio_values[['SharpeRatio']].idxmax()
#     max_col = len(column_info)
#     col_range = list(range(max_col))
#     min_var = portfolio_values.iloc[min_var_index,col_range]
#     max_sr = portfolio_values.iloc[max_sr_index,col_range]

#     st.write("""
#     The sectors & weights shown would yield the least risk.
#     """)
#     min_var2 = pd.melt(min_var, value_vars=column_info)
#     min_var2.columns = ["Sector","Weights"]
#     min_var2 = min_var2.sort_values("Weights", ascending=True).reset_index()
#     fig = px.bar(min_var2, x="Weights", y="Sector", orientation='h')
#     st.plotly_chart(fig)
    

# calculate_return_btn = st.button("Generate Least Risky Sectors")

# if calculate_return_btn:
#     calculate_portfolio_returns(country_choice, sector_choice,funding_status)
    


