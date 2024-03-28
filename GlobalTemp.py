import pyodbc 
import pandas as pd
import numpy as np
import seaborn as sns
import plotly as p
import plotly.express as px
import matplotlib.pyplot as plt

conn = pyodbc.connect('Driver={SQL Server};'
                      'Server=LAP-9LYKMG3\SQLEXPRESS;'
                      'Database=GlobalTemp;'
                      'Trusted_Connection=yes;')

query = 'SELECT * FROM DictCountryCityGeo'
query1 = 'SELECT * FROM AvgTempByCountry AS a ORDER BY a.AvgTemp DESC'
query2 = 'SELECT * FROM AvgTempByDate AS a ORDER BY a.Year'
query3 = 'SELECT * FROM AvgTempByCity'
query4 = 'SELECT * FROM AvgTempNY'


dfDictCountryCityGeo = pd.read_sql_query(query, conn)
dfAvgTempByCountry = pd.read_sql_query(query1, conn)
dfAvgTempByDate = pd.read_sql_query(query2, conn)
dfAvgTempByCity = pd.read_sql_query(query3, conn)
dfAvgTempNY = pd.read_sql_query(query4, conn)

#srednia temperatura w danym kraju na wykresie kolumnowym
plt.figure(figsize=(10,15))
sns.barplot(data=dfAvgTempByCountry, y=dfAvgTempByCountry['Country'], x=dfAvgTempByCountry['AvgTemp'])
plt.title('Average Temperature by Country')
plt.show()

#histogram sredniej temperatury w danym kraju
sns.histplot(dfAvgTempByCountry['AvgTemp'], bins=20, kde=True)
plt.title('Distribution of Average Temperature')
plt.xlabel('Average Temperature')
plt.show()


#wykres krajow wraz z ich szerokoscia oraz dlugoscia 
fig = px.scatter_mapbox(dfDictCountryCityGeo, lat='newLatitude', lon='newLongitude', hover_name='Country', hover_data=['City'], zoom=3)
fig.update_layout(mapbox_style='carto-positron', margin={'r':10,'t':10,'l':10,'b':10})
fig.write_html("CountryCity.html")


#wykres krajow wraz z ich szerokoscia oraz dlugoscia oraz srednia temperatura i liczba pomiarow
fig = px.scatter_mapbox(dfAvgTempByCity, lat='newLatitude', lon='newLongitude', hover_name='Country', hover_data=['AvgTemp'], zoom=3)
fig.update_layout(mapbox_style='carto-positron', margin={'r':10,'t':10,'l':10,'b':10})
fig.write_html("CountryCityAvgTemp.html")


#Średnia temperatura w zależnosci od roku
x = dfAvgTempByDate ['Year']
y = dfAvgTempByDate ['AvgTemp']

fig, ax = plt.subplots(figsize = (8,6)) #definicja wielkosci wykresu
ax.plot(x,y,"o", label = "data")
ax.legend(loc = "best")

#Wykres temperatur w zależnosci od daty w NY
dfAvgTempNY2013 = dfAvgTempNY.query('Year > 2003').sort_values(by = 'Dt')

x1 = dfAvgTempNY2013['Dt']
y1 = dfAvgTempNY2013['AverageTemperature']
plt.figure(1)
plt.plot(x1, y1)
plt.xlabel('Data')
plt.ylabel('AverageTemperature')
plt.title('Wykres sredniej temperatury na przestrzeni 2003-2013 w NY')
plt.show()


#How have temperature trends changed over the last 170 years?
#Are there significant differences in temperature trends between cities in different geographical locations?
#How do temperature fluctuations correlate with major global events?
