# Libraries
import streamlit as st
import pandas as pd
import plotly.express as px
import os, os.path
import geopandas
import sklearn
from sklearn import preprocessing
from sklearn import model_selection
from sklearn.metrics import mean_absolute_error, mean_squared_error,r2_score
from sklearn.model_selection import cross_val_score,train_test_split, TimeSeriesSplit, GridSearchCV, RandomizedSearchCV
from sklearn.preprocessing import LabelEncoder, MinMaxScaler, StandardScaler, OneHotEncoder
from sklearn.linear_model import LinearRegression
from sklearn import ensemble
from sklearn.ensemble import RandomForestRegressor,GradientBoostingRegressor, VotingRegressor
from sklearn.neighbors import KNeighborsRegressor

@st.cache
def load_data():
    data = pd.read_excel(DATA_URL)
    return data

# Load data
DATA_URL = "otf.xlsx"
df = load_data()

st.title('OTF Charity Insights')
# About
st.header("About")
with st.expander("About"):
    st.image("trillium-logo.jpeg")
    st.write("The goal is to use open data from Ontario Trillium Foundation to analyze charity data")
    st.write("The Ontario Trillium Foundation (OTF) is an agency of the Government of Ontario and one of Canada’s " + 
    "leading granting foundations. Our investments in communities across the province help build healthy and vibrant communities." + 
    "Our key funder, the Ministry of Heritage, Sport, Tourism and Culture Industries enables us to provide grants that can make the greatest impact. " +
    "OTF also administers grants on behalf of the Ministry of Children, Community and Social Services. Last year, $115 million was invested into more than" + 
    "644 projects in communities across the province")
    st.write("https://otf.ca/who-we-are/about-us/our-story")

# Overview
st.header("Overview")
with st.expander("Overview"):
    top_container = st.container()
    metric_column1, metric_column2,metric_column3,metric_column4, metric_column5,metric_column6 = st.columns(6)
    with top_container:
        metric_column1.metric("Charities",str( len(df['Identifier'].unique()))) #len(pd.unique(df['height'])
        metric_column2.metric("No. of Years",str(len(df['Fiscal_year_update'].unique())))
        metric_column3.metric("Cities",str(len(df['Recipient_org_city_update'].unique())))
        metric_column4.metric("Grant Programs",str(len(df['Grant_program'].unique())))
        metric_column5.metric("Program Areas",str(len(df['Program_area_update'].unique())))
        metric_column6.metric("Age Groups",str(len(df['Age_group_update'].unique())))#
    # Funding Trend
    df_total_grants = df[['Amount_awarded','Fiscal_year_update']]
    df_total_grants_agg = df_total_grants.groupby('Fiscal_year_update').agg(Total_Amount_Awarded = 
                                                                        ('Amount_awarded', 'sum')).reset_index()
    df_total_grants_agg.columns = ['Year', 'Amount Awarded (CAD)']
    df_total_grants_agg.sort_values("Amount Awarded (CAD)", ascending=True)
    fig = px.bar(df_total_grants_agg, x="Year", y="Amount Awarded (CAD)")
    st.plotly_chart(fig)

# Charity Insights
st.header("Charity Insights")

with st.expander("Charity Insights"):
    charity_list = df['Organization_name'].unique()
    charity_list  = charity_list.astype('str')
    charity_list.sort()
    charity_choice = st.selectbox("Pick a Charity",charity_list)

    st.subheader("Charity Overview")
    charity_container = st.container()
    charity_metric_column1, charity_metric_column2,charity_metric_column3,charity_metric_column4 = st.columns(4)
    with charity_container:
        charity = df[(df.Organization_name == charity_choice)]
        # English description
        charity_name = charity['Organization_name'].unique()
        # Incorporation #
        charity_incorporation = charity['Recipient_org_incorporation_number'].unique()
        # registration #
        charity_registration = charity['Recipient_org_registration_number'].unique()
        # Number of cities
        charity_cities = len(charity['Organization_name'].unique())
        charity_metric_column1.subheader("Name")
        charity_metric_column1.write(str(charity_name[0]))
        charity_metric_column2.subheader("Registration #")
        charity_metric_column2.write(str(charity_registration[0]))
        charity_metric_column3.subheader("# of Cities")
        charity_metric_column3.write(str(charity_cities))
        
        charity_grants = charity[['Amount_awarded','Fiscal_year_update']]
        charity_grants = charity_grants.groupby('Fiscal_year_update').agg(Total_Amount_Awarded = 
                                                                        ('Amount_awarded', 'sum')).reset_index()
        charity_grants.columns = ['Year', 'Amount Awarded (CAD)']
        charity_grants.sort_values("Amount Awarded (CAD)", ascending=True)
        fig = px.bar(charity_grants, x="Year", y="Amount Awarded (CAD)")
        st.plotly_chart(fig)

    st.subheader("Yearly Insights")
    year_container =  st.container()
    with year_container:
        year_list = df['Fiscal_year_update'].unique()
        year_list  = year_list.astype('int')
        year_list.sort()
        year_choice = st.selectbox("year",year_list)
        charity_year = df[(df.Organization_name == charity_choice)& (df.Fiscal_year_update == year_choice)]
    
        # Age breakdown 
        age_group = charity_year[['Amount_awarded','Age_group_update']]
        age_group_agg = age_group.groupby('Age_group_update').agg(Total_Amount_Awarded = 
                                                                        ('Amount_awarded', 'sum')).reset_index()
        age_group_agg.columns = ['Age Group', 'Amount Awarded (CAD)']
        age_group_agg = age_group_agg.sort_values("Amount Awarded (CAD)", ascending=True).reset_index()
        fig = px.bar(age_group_agg, x="Amount Awarded (CAD)", y="Age Group", orientation='h')
        st.plotly_chart(fig)
        
        # program area
        program_area = charity_year[['Amount_awarded','Program_area_update']]
        program_area_agg = program_area.groupby('Program_area_update').agg(Total_Amount_Awarded = 
                                                                        ('Amount_awarded', 'sum')).reset_index()
        program_area_agg.columns = ['Program Area', 'Amount Awarded (CAD)']
        program_area_agg = program_area_agg.sort_values("Amount Awarded (CAD)", ascending=True).reset_index()
        fig = px.bar(program_area_agg, x="Amount Awarded (CAD)", y="Program Area", orientation='h')
        st.plotly_chart(fig)

        # population served
        population_served = charity_year[['Amount_awarded','Population_served']]
        population_served_agg = population_served.groupby('Population_served').agg(Total_Amount_Awarded = 
                                                                        ('Amount_awarded', 'sum')).reset_index()
        population_served_agg.columns = ['Population Served', 'Amount Awarded (CAD)']
        population_served_agg = population_served_agg.sort_values("Amount Awarded (CAD)", ascending=True).reset_index()
        fig = px.bar(population_served_agg, x="Amount Awarded (CAD)", y="Population Served", orientation='h')
        st.plotly_chart(fig)

        # grant programs
        grant_program = charity_year[['Amount_awarded','Grant_program']]
        grant_program_agg = grant_program.groupby('Grant_program').agg(Total_Amount_Awarded = 
                                                                        ('Amount_awarded', 'sum')).reset_index()
        grant_program_agg.columns = ['Grant Program', 'Amount Awarded (CAD)']
        grant_program_agg = grant_program_agg.sort_values("Amount Awarded (CAD)", ascending=True).reset_index()
        fig = px.bar(grant_program_agg, x="Amount Awarded (CAD)", y="Grant Program", orientation='h')
        st.plotly_chart(fig)

        # budget fund
        budget_fund = charity_year[['Amount_awarded','Budget_fund']]
        budget_fund_agg = budget_fund.groupby('Budget_fund').agg(Total_Amount_Awarded = 
                                                                        ('Amount_awarded', 'sum')).reset_index()
        budget_fund_agg.columns = ['Budget Fund', 'Amount Awarded (CAD)']
        budget_fund_agg = budget_fund_agg.sort_values("Amount Awarded (CAD)", ascending=True).reset_index()
        fig = px.bar(budget_fund_agg, x="Amount Awarded (CAD)", y="Budget Fund", orientation='h')
        st.plotly_chart(fig)
        
        # cities
        recipient_org_city_update = charity_year[['Amount_awarded','Recipient_org_city_update']]
        recipient_org_city_update_agg = recipient_org_city_update.groupby('Recipient_org_city_update').agg(Total_Amount_Awarded = 
                                                                        ('Amount_awarded', 'sum')).reset_index()
        recipient_org_city_update_agg.columns = ['City', 'Amount Awarded (CAD)']
        recipient_org_city_update_agg = recipient_org_city_update_agg.sort_values("Amount Awarded (CAD)", ascending=True).reset_index()
        fig = px.bar(recipient_org_city_update_agg, x="Amount Awarded (CAD)", y="City", orientation='h')
        st.plotly_chart(fig)  

# Charity Prediction
st.header("Charity Prediction")
with st.expander("Charity Prediction"):
    charity_metric_column1, charity_metric_column2,charity_metric_column3,charity_metric_column4,charity_metric_column5 = st.columns(5)
    charity_data = df[['Fiscal_year_update','Recipient_org_city_update','Grant_program',
                 'Program_area_update','Age_group_update','Budget_fund_update','Amount_awarded']]
    
    city = charity_data['Recipient_org_city_update'].unique()
    city  = city.astype('str')
    city.sort()

    grant = charity_data['Grant_program'].unique()
    grant  = grant.astype('str')
    grant.sort()

    program_area = charity_data['Program_area_update'].unique()
    program_area  = program_area.astype('str')
    program_area.sort()

    age = charity_data['Age_group_update'].unique()
    age  = age.astype('str')
    age.sort()

    budget_fund = charity_data['Budget_fund_update'].unique()
    budget_fund  = budget_fund.astype('str')
    budget_fund.sort()

    #with charity_metric_column1:
    city_choice = st.selectbox("Pick a City",city)
    #with charity_metric_column2:
    grant_choice = st.selectbox("Pick a Grant Option",grant)
    #with charity_metric_column3:
    program_area_choice = st.selectbox("Pick a Program Area",program_area)
    #with charity_metric_column4:
    age_choice = st.selectbox("Pick an Age group",age)
    #with charity_metric_column5:
    budget_fund_choice = st.selectbox("Pick a Budget Fund",budget_fund)
    

    # Regression Model
    import warnings
    warnings.simplefilter(action='ignore', category=FutureWarning)
    model=GradientBoostingRegressor()
    # Data 
    model_data = df[['Fiscal_year_update','Recipient_org_city_update','Grant_program',
                 'Program_area_update','Age_group_update','Budget_fund_update','Amount_awarded']]
    #Recode data
    model_data["Recipient_org_city_update"] = model_data["Recipient_org_city_update"].astype('category')
    model_data["Grant_program"] = model_data["Grant_program"].astype('category')
    model_data["Program_area_update"] = model_data["Program_area_update"].astype('category')
    model_data["Age_group_update"] = model_data["Age_group_update"].astype('category')
    model_data["Budget_fund_update"] = model_data["Budget_fund_update"].astype('category')

    model_data["Recipient_org_city_update_cat"] = model_data["Recipient_org_city_update"].cat.codes
    model_data["Grant_program_cat"] = model_data["Grant_program"].cat.codes
    model_data["Program_area_update_cat"] = model_data["Program_area_update"].cat.codes
    model_data["Age_group_update_cat"] = model_data["Age_group_update"].cat.codes
    model_data["Budget_fund_update_cat"] = model_data["Budget_fund_update"].cat.codes

    # Create train and test data
    X = model_data[['Fiscal_year_update','Recipient_org_city_update_cat','Grant_program_cat',
                    'Program_area_update_cat','Age_group_update_cat','Budget_fund_update_cat']]
    Y = model_data['Amount_awarded']
    X_train, X_test, y_train, y_test = train_test_split(X, Y, test_size=0.8, random_state=0)

    regressor = model.fit(X_train, y_train)
    y_pred = regressor.predict(X_test)

    clicked = st.button("Run Prediction")

    # Run Prediction
    if clicked:
        prediction_df = model_data[(model_data.Recipient_org_city_update == city_choice)]
        prediction_df.reset_index(drop=True, inplace=True)
        city = prediction_df['Recipient_org_city_update_cat'][0]
        prediction_df = model_data[(model_data.Grant_program == grant_choice)]
        prediction_df.reset_index(drop=True, inplace=True)
        grant = prediction_df['Grant_program_cat'][0]
        prediction_df = model_data[(model_data.Program_area_update == program_area_choice)]
        prediction_df.reset_index(drop=True, inplace=True)
        program_area = prediction_df['Program_area_update_cat'][0]
        prediction_df = model_data[(model_data.Age_group_update == age_choice)]
        prediction_df.reset_index(drop=True, inplace=True)
        age_group = prediction_df['Age_group_update_cat'][0]
        prediction_df = model_data[(model_data.Budget_fund_update == budget_fund_choice)]
        prediction_df.reset_index(drop=True, inplace=True)
        budget_fund = prediction_df['Budget_fund_update_cat'][0]
        year = 2022

        info_df = pd.DataFrame(columns = ['Fiscal_year_update','Recipient_org_city_update',
        'Grant_program','Program_area_update','Age_group_update','Budget_fund_update'],
        index = ['a'])
        info_df.loc['a'] = [year, city, grant,program_area,age_group,budget_fund]
        y_pred_test = regressor.predict(info_df)
        output = float("{:.2f}".format(y_pred_test[0]))
        output = str(output) + " CAD"
        st.write("Based on the metrics selected the amount below is what is predicted for next year")
        st.metric("Amount Awarded",output)



   
  
    



        
    

    

    
    
    
    
    
    			