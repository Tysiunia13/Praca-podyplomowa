--CREATE DATABASE GLOBALTEMP;
--GO

--u¿ywamy bazy  GlobalTemp
USE GlobalTemp
GO;


IF OBJECT_ID('AvgTempWithGeo') IS NOT NULL 
DROP TABLE AvgTempWithGeo;


--Tworzenie struktury tabeli, do której zostan¹ zaczytane dane
CREATE TABLE AvgTempWithGeo
(
	Dt DATE NOT NULL,
	AverageTemperature FLOAT,
	AverageTemperatureUncertainty FLOAT,
	City NVARCHAR(100),
	Country NVARCHAR(100),
	Latitude NVARCHAR(100),
	Longitude NVARCHAR(100)
);

--Importujemy dane z pliku - jeden plik
BULK INSERT AvgTempWithGeo
	FROM   'C:\D\0001_Studia_AI_ML\Praca_podyplomowa\GlobalLandTemperatures_GlobalLandTemperaturesByMajorCity.csv'
	WITH
	(
		FIELDTERMINATOR = ',',
		ROWTERMINATOR = '\n', 
		FIRSTROW = 2
	);

SELECT a.*
FROM [GLOBALTEMP].[dbo].[AvgTempWithGeo] a;


--Zmiana danych geograficznych z DD na DMS
--Wspó³rzêdne mo¿na podawaæ w formacie DMS (Stopnie° Minuty' Sekundy") jak i DD (Stopnie Dziesiêtne)
--S to ujemne, N dodatnie, 
--W to ujemne, E dodatnie
CREATE VIEW AvgTempWithGeo2
AS
	SELECT a.*, 
		CASE 
		  WHEN SUBSTRING(a.Latitude,LEN(a.Latitude),1) = 'N' THEN CONVERT(FLOAT, SUBSTRING(a.Latitude,1,LEN(a.Latitude)-1))
		  ELSE CONVERT(FLOAT, SUBSTRING(a.Latitude,1,LEN(a.Latitude)-1)) *(-1)
		END AS newLatitude,
		CASE 
		  WHEN SUBSTRING(a.Longitude,LEN(a.Longitude),1) = 'E' THEN CONVERT(FLOAT, SUBSTRING(a.Longitude,1,LEN(a.Longitude)-1))
		  ELSE CONVERT(FLOAT, SUBSTRING(a.Longitude,1,LEN(a.Longitude)-1)) *(-1)
		END AS newLongitude
	FROM AvgTempWithGeo a;

--PROFILOWANIE DANYCH
--liczba obserwacji--239177
SELECT COUNT(*) NumberOfObservations
FROM AvgTempWithGeo a;

--liczba krajów--49
SELECT COUNT(DISTINCT(a.Country)) NumberOfCountries
FROM AvgTempWithGeo a;

--liczba miast--100
SELECT COUNT(DISTINCT(a.City)) NumberOfCities
FROM AvgTempWithGeo a;

--liczba ró¿nych dat--3239, minimalna data --1743-11-01, maksymalna data --2013-09-01, liczba lat miedzy min i max ---270
SELECT COUNT(DISTINCT(a.Dt)) NumberOfDates, MIN(a.Dt) MinDt, MAX(a.Dt) MaxDt, DATEDIFF(YEAR, MIN(a.Dt), MAX(a.Dt)) YearBetweenMinMax
FROM AvgTempWithGeo a;

--liczba miast bez szerokoœci i d³ugoœci geograficznej--0
SELECT COUNT(*) NumberOfNullLonLAt
FROM AvgTempWithGeo a
WHERE a.Latitude IS NULL OR a.Longitude IS NULL;

--liczba miast bez temepatury --11002
SELECT COUNT(*) NumberOfNullAvgTemp
FROM AvgTempWithGeo a
WHERE a.AverageTemperature IS NULL;


--Tworzenie s³ownika miast i pañstw wraz z lokalizacj¹
CREATE VIEW DictCountryCityGeo
AS
	SELECT DISTINCT t.Country, t.City , t.Latitude, t.Longitude, t.newLatitude, t.newLongitude
	FROM AvgTempWithGeo2 t;

SELECT *
FROM DictCountryCityGeo;

--tworzenie widoku œrednia temperatura w danym mieœcie w przeci¹gu 270 lat
CREATE VIEW AvgTempByCity
AS
	SELECT t.Country,t.City, t.newLatitude, t.newLongitude, ROUND(AVG(t.AverageTemperature),2) AvgTemp, count(*) Quantity
	FROM AvgTempWithGeo2 t
	WHERE  t.AverageTemperature is NOT NULL
	GROUP BY t.Country, t.City, t.newLatitude, t.newLongitude;

SELECT *
FROM AvgTempByCity;


--tworzenie widoku
CREATE VIEW AvgTempByMonth 
AS
	SELECT t.Country, t.City , t.newLatitude, t.newLongitude, MONTH(t.Dt) MonthOfYear, ROUND(AVG(t.AverageTemperature),2) AvgTempByMonth, count(*) Quantity
	FROM AvgTempWithGeo2 t
	WHERE  t.AverageTemperature is NOT NULL AND  t.AverageTemperatureUncertainty is NOT NULL
	GROUP BY t.Country, t.City, t.newLatitude, t.newLongitude,  MONTH(t.Dt);

SELECT *
FROM AvgTempByMonth;


--tworzenie widoku
CREATE VIEW AvgTempByCountry
AS
	SELECT t.Country, ROUND(AVG(t.AverageTemperature),2) AvgTemp, count(*) Quantity
	FROM AvgTempWithGeo2 t
	WHERE  t.AverageTemperature is NOT NULL
	GROUP BY t.Country;

SELECT *
FROM AvgTempByCountry;




CREATE VIEW AvgTempByDate
AS
	SELECT t.Dt, YEAR(t.Dt) Year, ROUND(AVG(t.AverageTemperature),2) AvgTemp, count(*) Quantity
	FROM AvgTempWithGeo2 t
	WHERE  t.AverageTemperature is NOT NULL
	GROUP BY t.Dt;


SELECT *
FROM AvgTempByDate d
ORDER By d.Year;


CREATE VIEW AvgTempNY
AS
	SELECT a.*, CONVERT(INT, YEAR(a.Dt)) Year , CONVERT(INT, MONTH(a.Dt)) Month, CONVERT(INT, DAY(a.Dt)) Day
	FROM AvgTempWithGeo2 a
	WHERE UPPER(a.City) like 'NEW YORK'
	AND a.AverageTemperature IS NOT NULL;