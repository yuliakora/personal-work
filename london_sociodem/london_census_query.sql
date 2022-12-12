-- Data Exploration: London City Socioeconomics

-- Objective:
-- To conduct data exploration
-- To detect any patterns in the distribution of traditionally vulnerable households (single parent households with children, households with the elderly)
-- To determine if any dramatic changes happened between 2011 and 2021

-- Key Takeaways:
-- Just under 10% of households are single parent households with children.
-- 13% of households have one or more members aged 65+.
-- 5% of households are deprived in 3+ dimensions.
-- Between 2011 and 2021, there was a slight decrease in the proportion of single parent households with children
--	as well as in the proportion of households deprived in 3 or more dimensions.
-- Households with the highest concentration of single parent households with children tend to live
--	on the outskirts of London in wards like New Addington North, Enfield Lock and Brimsdown.
-- At the ward level, there doesn't appear to be a correlation between the proportion of single parent households with children,
--	and the proportion of households deprived in 3+ dimensions. 
--	More tests (correlation test, regression analysis) need to be run to confirm this finding.

SELECT *
FROM LondonProject..household_comp_2021_clean


SELECT ward_code, ward_name, hh_single_parent_dep_kids, hh_1_66_plus, hh_all_66plus
FROM LondonProject..household_comp_2021_clean;


-- Exploratory Questions:
-- 1a. How may total households are there in London? What percentage of them are families with single parents?
-- 1b. What percentage of them are families where one or more members are aged 65+?
-- 2a. Which ward contains the highest concentration of single parent households? 
-- 2b. Which ward contains the highest concentration of households where one or more members are aged 65+?
-- 3. Has the proportion of single parent households increased from 2011 to 2021? (look at percentage difference)
-- 4. What proportion of households is deprived in 3+ dimensions?
-- 5. Which ward has the highest proportion of households that are deprived in 3+ dimensions?
-- 6. Did the proportion of households that are deprived in 3+ dimensions increase between 2011 and 2021?  
-- 7. Is there any correlation between wards that have a high proportion of single parent households and wards that have a high concentration of housheolds deprived in 3+ dimensions?



-- 1
SELECT SUM(hh_single_parent_dep_kids) / SUM(hh_total)*100 AS pct_single_parent_dep_kids,
SUM(hh_1_66_plus + hh_all_66plus) / SUM(hh_total)*100 AS pct_elderly,
SUM(hh_total) AS hh_london_total
FROM LondonProject..household_comp_2021_clean;

-- In 2021, there were 3,420,056 total households in London
-- In 2021, 8% of all households in London were single parent households
-- 13% of all households had one or more people aged 66+


-- 2
SELECT ward_name, (hh_single_parent_dep_kids/hh_total)*100 AS hh_pct_single_parent_dep_kids, (hh_1_66_plus + hh_all_66plus)/hh_total*100 AS hh_pct_elderly
FROM LondonProject..household_comp_2021_clean
ORDER BY hh_pct_single_parent_dep_kids DESC;

-- New Addington North, Enfield Lock and Brimsdown have the highest concentration of households with single parents with kids
-- All three neighborhoods are located on the outskirts of London


SELECT ward_name, (hh_single_parent_dep_kids/hh_total) AS hh_pct_single_parent_dep_kids, (hh_1_66_plus + hh_all_66plus)/hh_total AS hh_pct_elderly
FROM LondonProject..household_comp_2021_clean
ORDER BY hh_pct_elderly DESC;

-- Farnborough&Crofton, Cranham and Emerson Park have the highest concentration of households with people aged 66+


--3

SELECT AVG(c21.hh_single_parent_dep_kids/c21.hh_total*100) AS avg_2021,
AVG(c11.hh_single_parent_dep_kids/c11.hh_total*100) AS avg_2011
FROM LondonProject..household_comp_2021_clean c21
JOIN LondonProject..household_comp_2011_clean c11 
ON c21.ward_name=c11.ward_name;

-- The proportion of single parent households decreased slightly from 9% in 2011 to 8% in 2021


-- 4
SELECT (SUM(hh_deprived_3_dim + hh_deprived_4_dim)/SUM(hh_total) * 100) AS hh_deprived_3plus_dim
FROM LondonProject..household_deprivation_2021_clean;

-- 5% of households in London are deprived in 3 or more dimensions


--5
SELECT ward_name,
((hh_deprived_3_dim + hh_deprived_4_dim)/hh_total * 100) AS hh_deprived_3plus_dim
FROM LondonProject..household_deprivation_2021_clean
ORDER BY hh_deprived_3plus_dim DESC;

-- Church Street, Notting Dale and St Pancras & Somers Town have the highest proportion of households deprived in 3+ dimensions


--6
SELECT AVG((d21.hh_deprived_3_dim + d21.hh_deprived_4_dim)/d21.hh_total * 100) AS avg_2021,
AVG((d11.hh_deprived_3_dim + d11.hh_deprived_4_dim)/d11.hh_total * 100) AS avg_2011
FROM LondonProject..household_deprivation_2021_clean d21
JOIN LondonProject..household_deprivation_2011_clean d11 
ON d21.ward_name=d11.ward_name;

-- The proportion of households deprived in 3+ dimensions decreased from 7% in 2011 to 5% in 2021


--7

/* Deprived in 3+ Dimensions: Highest 10 Wards:
	1. Church Street                    
	2. Notting Dale                       
	3. St Pancras & Somers Town
	4. Westbourne
	5. Queen's Park
	6. Golborne
	7. Edmonton Green
	8. Northumberland Park
	9. Stonebridge
	10. Upper Edmonton
*/ 

/* Proportion of Single Parent Households with Kids: Highest 10 Wards:

	1. New Addington North
	2. Enfield Lock
	3. Brimsdown
	4. Carterhatch
	5. Ponders End
	6. Barking Riverside
	7. Gascoigne
	8. Lower Edmonton
	9. Thamesmead Moorings
	10. Bullsmoor

*/

-- There doesn't appear to be a correlation between the proportion of single parent households and the proportion of households deprived in 3+ dimensions at the ward level
-- However, to know more definitively we would need to run a correlation test or regression analysis, preferably at the individual level
-- If running a regression at the individual level, we could consider including ward fixed effects and creating dummy variables for demographic type (single parents with children, married with no children, etc)

-----------------------------------------------------------------

-- Creating View to store data for later visualizations

-- 1. Ward map - concentration of single parent households
-- 2. Ward map - concentration of households deprived in 3+ dimensions
-- 3. Ward map - Change from 2011 to 2021 in the % of households deprived in 3+ dimensions
-- 4. Top 10 Bar Chart - Total number of single parent households by ward, include London average
-- 5. Chart or map of wards that experienced the greatest increase in the total number of households
-- 6. Chart or map of wards that experienced the greatest increase in the % of non-deprived households
-- 7. Top down statistics: changes between 2011 and 2021 in
--      total # of HH, % of single parent households, % of households deprived in 3+ dimensions

-- 1 & 2
DROP VIEW IF EXISTS ConcentrationSingleParentHouseholds;

GO

CREATE VIEW ConcentrationSingleParentHouseholds AS
SELECT d21.ward_name,
((d21.hh_deprived_3_dim + d21.hh_deprived_4_dim)/d21.hh_total * 100) AS hh_deprived_3plus_dim,
c21.hh_single_parent_dep_kids/c21.hh_total*100 AS hh_pct_single_parent_dep_kids
FROM LondonProject..household_deprivation_2021_clean d21
JOIN LondonProject..household_comp_2021_clean c21
ON d21.ward_name = c21.ward_name;

GO

-- 3
DROP VIEW IF EXISTS Deprived3PlusHouseholdChange;

GO

CREATE VIEW Deprived3PlusHouseholdChange AS
SELECT d21.ward_name,
(d21.hh_deprived_3_dim + d21.hh_deprived_4_dim)/d21.hh_total * 100 AS depr3_2021,
(d11.hh_deprived_3_dim + d11.hh_deprived_4_dim)/d11.hh_total * 100 AS depr3_2011
FROM LondonProject..household_deprivation_2021_clean d21
JOIN LondonProject..household_deprivation_2011_clean d11 
ON d21.ward_name=d11.ward_name;

GO

--4
DROP VIEW IF EXISTS TotalSingleParentHouseholds2021;

GO

CREATE VIEW TotalSingleParentHouseholds2021 AS
SELECT ward_name,
hh_single_parent_dep_kids, 
(SELECT AVG(hh_single_parent_dep_kids) FROM LondonProject..household_comp_2021_clean) AS hh_single_parent_dep_kids_avg
FROM LondonProject..household_comp_2021_clean;

GO

--5
DROP VIEW IF EXISTS TotalHouseholdChange;

GO

CREATE VIEW TotalHouseholdChange AS
SELECT c21.ward_name, c21.hh_total AS hh_total_21,
c11.hh_total AS hh_total_11,
c21.hh_total - c11.hh_total AS hh_2011_2021_num_hh_change,
(c21.hh_total - c11.hh_total)/c11.hh_total * 100 AS hh_total_pct_change
FROM LondonProject..household_comp_2021_clean c21
JOIN LondonProject..household_comp_2011_clean c11
ON c21.ward_name=c11.ward_name;

GO

--6
DROP VIEW IF EXISTS NonDeprivedHouseholdsChange;

GO

CREATE VIEW NonDeprivedHouseholdsChange AS
SELECT c21.ward_name, 
c11.hh_deprived_0_dim AS hh_0dim_2011,
c21.hh_deprived_0_dim AS hh_0dim_2021,
c11.hh_total AS hh_total_2011,
c21.hh_total AS hh_total_2021,
(c21.hh_deprived_0_dim/c21.hh_total) - (c11.hh_deprived_0_dim/c11.hh_total) AS hh_deprived_0_dim_2021_2021_diff 
FROM LondonProject..household_deprivation_2021_clean AS c21
JOIN LondonProject..household_deprivation_2011_clean AS c11
ON c21.ward_name=c11.ward_name;

GO

--7
--High Level Statistics
-- Increase in # of Households, 2011 to 2021: 157,531
-- Difference in % of Total Households that are Single Parent, 2011 to 2021: -0.76%
-- Difference in % of Total Households Deprived in 3+ Dimensions, 2011 to 2021: -2.6%


SELECT SUM(c21.hh_total) AS hh_total_2021,
SUM(c11.hh_total) AS hh_total_2011
FROM LondonProject..household_comp_2021_clean AS c21
JOIN LondonProject..household_comp_2011_clean AS c11
ON c21.ward_name=c11.ward_name;