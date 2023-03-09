# CovidPorfolioProject

This Github Repository contain my Covid 19 Project in which I have used SQL for Data Exploration and Tableau for Data Visualisation

***1. Data Exploration using _SQL_***

*Tools: Microsoft SQL Server, Microsoft Excel* 

> - I made use of the covid dataset from [Data Source](https://ourworldindata.org/covid-deaths).
> - As it was one big dataset, I used Excel to manipulate the Data and convert it into two individual tables making it easier to demonstrate the concept of joins
> - Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

***2. Creating Visualisation and Dashboard using _Tableau_***

*Tools: Tableau Public, Microsoft Excel*

**Data Prepartion:**
> - Importing Data: I will be using the data from the queries we ran in our Data Exploration using SQL project,
I have copied each output individually onto an excel sheet and saved it to later import into tableau as SQL server doesn't directly connect with Tableau                  Public.
> - Changes in Data: While copying and pasting the data into Excel we needed to make sure we replaced all the records containing NULL values with 0 as if we don't do so,
Tableau will consider them as text data and we don't want that happening. Secondly, while copy pasting dates in Excel, it will assign the general datatype to the column, changing that to shortdate will fix that problem.

**Visualisation:**

> - Visualisations used: Text Box, Bar plot, Maps, Time series graph
> - Link to dashboard: [Covid 19 Dashboard](https://public.tableau.com/app/profile/sayyed.asif/viz/Covid19Dashboard_16783477991420/Dashboard1?publish=yes).
