create database case_study;

use case_study;

select * from salaries;

-- 1 find countries  who gave fully remotely work for the title "managers" and salary excedding 90000 in USD
select distinct(company_location) 
from salaries 
where job_title like '%manager%' and remote_ratio=100 and salary_in_usd>90000;

-- 2 You have to hire freshers.Identify top 5 countries having greatest count of large (company size) number of companies.
select company_location,count(*) as total_company 
from salaries 
where company_size='L' and experience_level='EN'
group by company_location
order by total_company desc limit 5;


-- 3 Calculate percentage of employee who enjoy works from home with salaries excedding 100000$
set @count=(select count(*)  from salaries where remote_ratio=100 and salary_in_usd>100000);
set @total=(select count(*)  from salaries where salary_in_usd>100000);
set @percentage=round(((select @count)/(select @total))*100,2);
select @percentage as 'Percentage';

-- 4 Identify the locations where entry level average salaries exceed the average-salary for that job title in market for entry level.
select company_location,t.job_title,Avg_Salary,Avrg_per_country from
(select job_title,avg(salary_in_usd) as Avg_Salary from salaries where experience_level='EN' group by job_title) t
inner join
(select company_location,job_title,avg(salary_in_usd) as 'Avrg_per_country' from salaries where experience_level='EN' group by job_title,company_location)m
on t.job_title=m.job_title
where Avrg_per_country>Avg_Salary;

-- 5 For each job title find out which country pay maximum average salary
select job_title,company_location,avg_salary from
(select *, dense_rank() over (partition by job_title order by avg_salary desc) as rnk from
(select job_title,company_location,avg(salary_in_usd) as avg_salary from salaries group by job_title,company_location) t) p
where rnk=1;


-- 6 Find location where average salary is consistently increase over past year (countries only where data is available for past 3 years(present year and 2 past years))

with commontable as(
	select * from salaries where company_location in (
		select company_location from (
		select company_location,avg(salary_in_usd) as average,count(distinct work_year) as cnt
		from salaries
		where work_year>=year(current_date())-2
		group by company_location 
		having cnt =3) t
	)
)
select company_location,
max(case when work_year=2022 then average END) as average_salary_2022,
max(case when work_year=2023 then average END) as average_salary_2023,
max(case when work_year=2024 then average END) as average_salary_2024
from 
(select company_location,work_year ,avg(salary_in_usd) as 'average' from commontable group by company_location ,work_year)q 
group by company_location
having average_salary_2024>average_salary_2023 and average_salary_2023>average_salary_2022; 


-- 7 Determine the percentage of fully remote work for each experience level in 2021 and compare it with the corresponding figure to 2024


select m.experience_level,remote_2021,remote_2024 from (
select * ,((cnt)/(total))*100 as remote_2021 from(
	select a.experience_level,cnt,total from (
		(select experience_level,count(*) as total from salaries where work_year=2021 group by experience_level)a
		inner join
		(select experience_level,count(*) as cnt from salaries where work_year=2021 and remote_ratio=100 group by experience_level)b
		on a.experience_level=b.experience_level)
)t
)m inner join


(select * ,((cnt)/(total))*100 as remote_2024 from(
	select a.experience_level,cnt,total from (
		(select experience_level,count(*) as total from salaries where work_year=2024 group by experience_level)a
		inner join
		(select experience_level,count(*) as cnt from salaries where work_year=2024 and remote_ratio=100 group by experience_level)b
		on a.experience_level=b.experience_level)
)q
)n
on m.experience_level=n.experience_level;


-- 8  Calculate the increase salary level percentage for each experience_level and job_title between the year 2023 and 2024
select *,ROUND(((salary2024 - salary2023) / salary2023) * 100, 2) as increment from (
select p.experience_level,p.job_title,salary2023,salary2024 from (
select experience_level,job_title,round(avg(salary_in_usd),2) as 'salary2023' from salaries where work_year=2023 group by experience_level,job_title) p
inner join
(select experience_level,job_title,round(avg(salary_in_usd),2) as 'salary2024' from salaries where work_year=2024 group by experience_level,job_title) q
on p.experience_level=q.experience_level and p.job_title=q.job_title) r
order by increment desc ;

-- 9 Implement a security measure where employee in different experience level can only access details relevant to their experience level
-- ensuring data confidentiality and minimizing the risk of unautorized access
create user 'Entry_level'@'%' identified by 'EN';

create view entry_level as
(
select * from salaries where experience_level='EN'
);

grant select on case_study.entry_level to 'Entry_level'@'%';

--  provide Entry_level in username during new connection

show privileges;-- show commands 

-- how many people were employed IN different types of companies AS per their size IN 2021.
select company_location,count(*) as total from salaries where work_year=2021 group by company_location;

--  identify the top 3 job titles that command the highest average salary Among part-time Positions IN the year 2023. However, you are Only Interested IN Countries 
-- WHERE there are more than 50 employees, Ensuring a robust sample size for your analysis.
SELECT job_title, company_location,AVG(salary_in_usd) AS avg_salary
FROM 
	(select * from salaries where company_size='M') t
WHERE work_year = 2023 AND employment_type = 'PT'
GROUP BY job_title, company_location;

-- Select Countries where average mid-level salary is higher than overall mid-level salary for the year 2023.
select * from
	(select t.company_location,salary_2023,overall_salary from 
		(select company_location,avg(salary_in_usd) as salary_2023 from salaries where experience_level='MI' and work_year=2023 group by company_location) t
		join
		(select company_location,avg(salary_in_usd) as overall_salary from salaries where experience_level='MI'  group by company_location) q
		on t.company_location=q.company_location) s
where salary_2023>overall_salary;

--  Identify the company locations with the highest and lowest average salary for senior-level (SE) employees in 2023.
select * from 
	(select company_location,avg(salary_in_usd)as 'salary' from
		(select * from salaries where experience_level='SE' and work_year='2023') t
	group by company_location
	order by salary desc )q;
    
-- Assess the annual salary growth rate for various job titles. By Calculating the percentage Increase IN salary FROM previous year to this year
WITH AvgSalaries AS (
    SELECT
        job_title,
        AVG(CASE WHEN work_year = 2024 THEN salary ELSE NULL END) AS salary_2024,
        AVG(CASE WHEN work_year = 2023 THEN salary ELSE NULL END) AS salary_2023,
        AVG(CASE WHEN work_year = 2022 THEN salary ELSE NULL END) AS salary_2022,
        AVG(CASE WHEN work_year = 2021 THEN salary ELSE NULL END) AS salary_2021,
        AVG(CASE WHEN work_year = 2020 THEN salary ELSE NULL END) AS salary_2020
    FROM
        (SELECT work_year, job_title, ROUND(AVG(salary_in_usd), 2) AS salary
         FROM salaries
         GROUP BY work_year, job_title
         ORDER BY job_title) q
    GROUP BY job_title
)
SELECT
    job_title,
    CASE 
        WHEN salary_2024 IS NOT NULL AND salary_2023 IS NOT NULL THEN 
            ROUND(((salary_2024 - salary_2023) / salary_2023) * 100, 2)
        WHEN salary_2023 IS NOT NULL AND salary_2022 IS NOT NULL THEN 
            ROUND(((salary_2023 - salary_2022) / salary_2022) * 100, 2)
        WHEN salary_2022 IS NOT NULL AND salary_2021 IS NOT NULL THEN 
            ROUND(((salary_2022 - salary_2021) / salary_2021) * 100, 2)
        WHEN salary_2021 IS NOT NULL AND salary_2020 IS NOT NULL THEN 
            ROUND(((salary_2021 - salary_2020) / salary_2020) * 100, 2)
        ELSE NULL
    END AS percentage_increase
FROM
    AvgSalaries
ORDER BY
    job_title;
    

-- 6.	You've been hired by a global HR Consultancy to identify Countries experiencing significant salary growth for entry-level roles. 
-- Your task is to list the top three Countries with the highest salary growth rate FROM 2020 to 2023, 
-- Considering Only companies with more than 50 employees, helping multinational Corporations identify Emerging talent markets.
select * from salaries;

with avgsalaries as (
select company_location,
AVG(CASE WHEN work_year = 2023 THEN salary ELSE NULL END) AS salary_2023,
AVG(CASE WHEN work_year = 2022 THEN salary ELSE NULL END) AS salary_2022,
AVG(CASE WHEN work_year = 2021 THEN salary ELSE NULL END) AS salary_2021,
AVG(CASE WHEN work_year = 2020 THEN salary ELSE NULL END) AS salary_2020
from(
select work_year,company_location,avg(salary_in_usd) as salary from salaries where company_size='M' group by work_year,company_location) t
group by company_location)

select company_location,
	case 
		WHEN salary_2020 IS NOT NULL AND salary_2023 IS NOT NULL THEN 
				ROUND(((salary_2023 - salary_2020) / salary_2020) * 100, 2)
		else null
	end as percentage_increase
from avgsalaries
order by percentage_increase desc limit 3;

-- 7.	Picture yourself as a data architect responsible for database management. Companies in US and AU(Australia) decided to create a hybrid model for employees they decided 
-- that  employees earning salaries exceeding $90000 USD, will be given work from home. You now need to update the remote work ratio for eligible employees, 
-- ensuring efficient remote work management while implementing appropriate error handling mechanisms for invalid input parameters.
select * from 
(select * from salaries where company_location='US' or company_location='AU') t
where salary_in_usd>=90000;

update salaries
set remote_ratio=100
where remote_ratio=0
and salary_in_usd>=90000
and company_location in ('US','AU');

-- 8.	In the year 2024, due to increased demand in the data industry, there was an increase in salaries of data field employees.
-- a.	Entry Level-35% of the salary.
-- b.	Mid junior – 30% of the salary.
-- c.	Immediate senior level- 22% of the salary.
-- d.	Expert level- 20% of the salary.
-- e.	Director – 15% of the salary.
-- You must update the salaries accordingly and update them back in the original database.
SELECT *,
    CASE
        WHEN experience_level = 'EN' THEN salary_in_usd * 1.35
        WHEN experience_level = 'MI' THEN salary_in_usd * 1.30
        WHEN experience_level = 'SE' THEN salary_in_usd * 1.22
        WHEN experience_level = 'EX' THEN salary_in_usd * 1.20
        WHEN experience_level = 'DI' THEN salary_in_usd * 1.15
        ELSE salary_in_usd
    END AS updated_salary
FROM salaries;

select  * from salaries;

UPDATE salaries
SET salary_in_usd = CASE
    WHEN experience_level = 'EN' THEN salary_in_usd * 1.35
    WHEN experience_level = 'MI' THEN salary_in_usd * 1.30
    WHEN experience_level = 'SE' THEN salary_in_usd * 1.22
    WHEN experience_level = 'EX' THEN salary_in_usd * 1.20
    WHEN experience_level = 'DI' THEN salary_in_usd * 1.15
    ELSE salary_in_usd
END;


-- 9.	You are a researcher and you have been assigned the task to Find the year with the highest average salary for each job title.
select work_year,job_title,salary from (
	select *,rank() over(partition by job_title order by salary desc ) as rnk from 
		(select work_year,job_title,avg(salary_in_usd) as salary from salaries group by job_title,work_year
		order by job_title) t
	)q
where  rnk=1;

-- 10.	You have been hired by a market research agency where you been assigned the task to show the percentage of different employment type 
-- (full time, part time) in Different job roles, in the format where each row will be job title,
-- each column will be type of employment type and cell value for that row and column will show the % value.
select employment_type,t.job_title,round((cnt/total)*100,2) as per from (
(select employment_type,job_title,count(*) as cnt from salaries group by employment_type,job_title
order by job_title)t 
left join
(select job_title,count(*) as total from salaries group by job_title) q
on t.job_title=q.job_title)