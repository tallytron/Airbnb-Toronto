![airbnb](https://github.com/user-attachments/assets/fec70754-be01-4b2f-88b2-d34f07ff8287)

# Airbnb Toronto - Analysis using SQL and Tableau 

I stumbled upon a website called Inside Airbnb. Naturally, I thought it was a good idea to take a look at the data on my home city of Toronto and see what I can find.

The data contained more than one table and looked a bit messy, I decided to do some light cleaning and EDA in SQL before moving on to visualizing my findings with Tableau.

## Data Exploration and Storytelling

I approached the study with a single question in mind: if I were an Airbnb employee, how would I convert the data I have into actionable things to improve the company's revenue?

As I did not have access to Airbnb's real revenue information, I had to establish the KPI(s) to be used to measure revenue.

I choose to estimate the revenue potential based on the total profits of all active listings for the next month in order to determine the revenue potential (30 days).

Specifically, Revenue Potential is Price x (30 - availability 30).

Then, I had to specify what "active listings" imply for the purposes of this research, which meant that the latest review of the listing was conducted no earlier than January 2022.

In light of this, I delved into the study in search of Airbnb's primary income contributors (as determined by several criteria) and if the company has reached its maximum revenue potential.

Check out the SQL code [here.](https://github.com/tallytron/Airbnb-Toronto/blob/01e1eaca09dd0990bad2132263107bee3a9baace/Airbnb.sql)

[Tableau](https://public.tableau.com/app/profile/talal.azhar/viz/Airbnb_16643976358400/Dashboard1) visualization.
