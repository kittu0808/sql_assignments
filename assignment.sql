-- Q1 -Retrieve the total number of records in the dataset. 
SELECT COUNT(*) AS total_records FROM employee_database.mock_data ;
-- Q2 -Find the count of distinct genders present in the dataset. 
SELECT COUNT(DISTINCT gender) FROM employee_database.mock_data;
-- Q3-Calculate the average length of email addresses in the dataset.
SELECT AVG(LENGTH(email)) FROM employee_database.mock_data;
-- Q4 -List the top 5 countries with the highest number of individuals. 
SELECT country, COUNT(*) AS highest_count
FROM employee_database.mock_data
GROUP BY country
ORDER BY highest_count DESC
LIMIT 5;
-- Q5 -Find the percentage of males in the dataset. 
SELECT AVG(gender = 'male') * 100 AS percentage_male
FROM employee_database.mock_data;
-- Q6 -Identify the country with the highest number of females. 
SELECT country FROM employee_database.mock_data
WHERE gender = 'female'
GROUP BY country
ORDER BY COUNT(*) DESC
LIMIT 1;
-- Q7-Determine the number of individuals with gender labeled as "Genderqueer"
SELECT COUNT(*) AS genderqueer_count
FROM employee_database.mock_data
WHERE gender = 'Genderqueer';

-- Q8-List the first 10 records sorted by last name in ascending order. 
SELECT *
FROM employee_database.mock_data
ORDER BY last_name ASC
LIMIT 10;

-- Q9-Calculate the number of individuals from each country. 
SELECT country, COUNT(*) AS individuals_count
FROM employee_database.mock_data
GROUP BY country;

-- Q10 -Find the email addresses with a ".com" domain. 
SELECT email
FROM employee_database.mock_data
WHERE email LIKE '%.com';

-- Q 11-Identify individuals whose first names start with the letter 'A'. 
SELECT first_name
FROM employee_database.mock_data
WHERE first_name LIKE 'A%';

-- Q 12-Calculate the ratio of males to females in the dataset. 
select
    (SELECT COUNT(*) FROM employee_database.mock_data WHERE gender = 'male') / 
    (SELECT COUNT(*) FROM employee_database.mock_data WHERE gender = 'female') AS male_to_female_ratio;

    SELECT 
    SUM(case WHEN gender = 'male' THEN 1 ELSE 0 END) / SUM(case WHEN gender = 'female' THEN 1 ELSE 0 END) AS male_to_female_ratio
FROM 
    employee_database.mock_data;

-- Q 13-Find the last 5 records sorted by country code in descending order.
SELECT Country_code
FROM employee_database.mock_data
ORDER BY country_code DESC
LIMIT 5;

-- Q 14-Identify individuals with a single-word last name. 
SELECT last_name
FROM employee_database.mock_data
WHERE last_name NOT LIKE '% %';

-- Q 15-Calculate the average length of first names in the dataset.
SELECT AVG(LENGTH(first_name)) AS avg_first_name_length
FROM employee_database.mock_data;


 




