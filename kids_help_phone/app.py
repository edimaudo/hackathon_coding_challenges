import dash
import dash_core_components as dcc
import dash_html_components as html
import pandas as pd
import plotly.graph_objs as go


app = dash.Dash()

df = pd.read_excel('Kids_help_phone.xlsx',sheet_name="Donor2", index_col=None)
yearInfo = ['2010','2011','2012','2013','2014','2015','2016','2017','2018','2019']

app.layout = html.Div([
    dcc.Graph(
        id='GiftAmount-vs-Year',
        figure={
            'data': [
                go.Scatter(
                    x=df[df['Year'] == i]['Year'],
                    y=df[df['Year'] == i]['Gift Amount'],
                    text=df[df['Year'] == i]['Year'],
                    mode='markers',
                    opacity=0.8,
                    marker={
                        'size': 15,
                        'line': {'width': 0.5, 'color': 'white'}
                    },
                    name=i
                ) for i in yearInfo
            ],
            'layout': go.Layout(
                xaxis={'type': 'log', 'title': 'Donation Year'},
                yaxis={'title': 'Donations'},
                margin={'l': 40, 'b': 40, 't': 10, 'r': 10},
                legend={'x': 0, 'y': 1},
                hovermode='closest'
            )
        }
    )
])



if __name__ == '__main__':
	app.run_server()