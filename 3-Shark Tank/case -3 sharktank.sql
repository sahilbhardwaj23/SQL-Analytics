use task;

select * from sharktank;

truncate table sharktank;

select * from sharktank;

load data infile "E:/DSMP 1.0/Data Analyst/6-SQL/5 case study/3-Shark Tank/sharktank.csv"
into table sharktank
fields terminated by ','
optionally enclosed by '"'
lines terminated by '\r\n'
ignore 1 rows;

select * from sharktank;

-- 1.	You Team must promote shark Tank India season 4, The senior come up with the idea to show highest funding 
-- domain wise so that new startups can be attracted, and you were assigned the task to show the same.

select Industry,`Total_Deal_Amount(in_lakhs)` from(
	select Industry,`Total_Deal_Amount(in_lakhs)`,
    row_number() over(partition by industry  order by `Total_Deal_Amount(in_lakhs)` desc) as 'rnk' 
    from sharktank
	group by  `Industry`,`Total_Deal_Amount(in_lakhs)`)t
where rnk=1;


-- 2.	You have been assigned the role of finding the domain where female as pitchers have female to male pitcher ratio >70%
select * from(
select *,((Total_female/Total_male))*100 as 'Ratio' from (
select Industry,sum(Female_Presenters) as 'Total_female',sum(Male_Presenters) as 'Total_male' from sharktank group by industry having Total_female>0 and Total_male>0) t
)q
where Ratio>70;



-- 3.	You are working at marketing firm of Shark Tank India, you have got the task to determine volume of per season sale pitch made, 
-- pitches who received offer and pitches that were converted. 
-- Also show the percentage of pitches converted and percentage of pitches entertained.

select a.season_number,total,(received_offer/total)*100 as 'Received%',(accepted_offer/total)*100 as 'Accepted%' from (
(select season_number,count(startup_name)as total from sharktank group by season_number)a
inner join 
(select season_number,count(startup_name)as received_offer from sharktank where received_offer='Yes'group by season_number)b
on a.season_number=b.season_number
inner join 
(select season_number,count(startup_name)as accepted_offer from sharktank where accepted_offer='Yes'group by season_number) c
on b.season_number=c.season_number);


-- 4.	As a venture capital firm specializing in investing in startups featured on a renowned entrepreneurship TV show, you are determining the season 
-- with the highest average monthly sales and identify the top 5 industries  with the highest average monthly sales during that season to optimize investment decisions?

select season_number,industry,sales from (
	select season_number,industry,round(avg(`Monthly_Sales(in_lakhs)`),2) as 'sales',dense_rank() over(partition by season_number order by sales desc) as 'rnk'
	from sharktank group by season_number,industry order by season_number,rnk )t 
 where rnk<6 ;
 
 -- 5.	As a data scientist at our firm, your role involves solving real-world challenges like identifying industries with consistent increases in funds raised over 
 -- multiple seasons. This requires focusing on industries where data is available across all three seasons. Once these industries are pinpointed, your task is to delve into 
 -- the specifics, analyzing the number of pitches made, offers received, and offers converted per season within each industry.

with Industry_name as(
select * from (
SELECT 
    industry,
    AVG(CASE WHEN season_number = 1 THEN `Total_Deal_Amount(in_lakhs)` END) AS Season_1,
    AVG(CASE WHEN season_number = 2 THEN `Total_Deal_Amount(in_lakhs)` END) AS Season_2,
    AVG(CASE WHEN season_number = 3 THEN `Total_Deal_Amount(in_lakhs)` END) AS Season_3
FROM 
    sharktank 
GROUP BY 
    industry) t
where Season_1<Season_2 and Season_2<Season_3 and Season_1!=0)

select b.season_number,a.industry,
count(b.startup_name) as 'total',
count(case when b.accepted_offer='Yes' then b.startup_name end) as 'accepted',
count(case when b.received_offer='Yes' then b.startup_name end) as 'received'
from Industry_name as  a  inner join sharktank as b
on a.industry=b.industry
group by b.season_number,a.industry;

-- 6.	Every shark wants to know in how much year their investment will be returned, so you must create a system for them, where shark will enter the name of the startup’s
-- and the based on the total deal and equity given in how many years their principal  amount will be returned and make their investment decisions.
      
delimiter //
create procedure TOT( in startup varchar(100))
begin
   case 
      when (select Accepted_offer ='No' from sharktank where startup_name = startup)
	        then  select 'Turn Over time cannot be calculated';
	 when (select Accepted_offer ='yes' and `Yearly_Revenue(in_lakhs)` = 'Not Mentioned' from sharktank where startup_name= startup)
           then select 'Previous data is not available';
	 else
         select `startup_name`,`Yearly_Revenue(in_lakhs)`,`Total_Deal_Amount(in_lakhs)`,`Total_Deal_Equity(%)`, 
         (`Total_Deal_Amount(in_lakhs)`/((`Total_Deal_Equity(%)`)*`Yearly_Revenue(in_lakhs)`))*100 as 'years'
		 from sharktank where Startup_Name= startup;
	
    end case;
end
//
DELIMITER ;


call tot('BluePineFoods');


-- 7.	In the world of startup investing, we're curious to know which big-name investor, often referred to as "sharks," tends to put the most money into each deal on average. 
-- This comparison helps us see who's the most generous with their investments and how they measure up against their fellow investors.

select sharkname,round(avg(investment),2) as investment  from(
select 'Namita' as Sharkname, `Namita_Investment_Amount(in lakhs)` as 'Investment'  from sharktank where  `Namita_Investment_Amount(in lakhs)`>0
union all
select 'Vineeta' as Sharkname, `Vineeta_Investment_Amount(in_lakhs)` as 'Investment'  from sharktank where  `Vineeta_Investment_Amount(in_lakhs)`>0
union all
select 'Anupam' as Sharkname, `Anupam_Investment_Amount(in_lakhs)` as 'Investment'  from sharktank where  `Anupam_Investment_Amount(in_lakhs)`>0
union all
select 'Aman' as Sharkname, `Aman_Investment_Amount(in_lakhs)` as 'Investment'  from sharktank where  `Aman_Investment_Amount(in_lakhs)`>0
union all
select 'Peyush' as Sharkname, `Peyush_Investment_Amount((in_lakhs)` as 'Investment'  from sharktank where  `Peyush_Investment_Amount((in_lakhs)`>0
union all
select 'Amit' as Sharkname, `Amit_Investment_Amount(in_lakhs)` as 'Investment'  from sharktank where  `Amit_Investment_Amount(in_lakhs)`>0
union all
select 'Ashneer' as Sharkname, `Ashneer_Investment_Amount` as 'Investment'  from sharktank where  `Ashneer_Investment_Amount`>0
)t
group by sharkname
order by investment desc;

-- 8.	Develop a stored procedure that accepts inputs for the season number and the name of a shark. The procedure will then provide detailed insights into the total 
-- investment made by that specific shark across different industries during the specified season. Additionally, it will calculate the percentage 
-- of their investment in each sector relative to the total investment in that year, giving a comprehensive understanding of the shark's investment distribution and impact.

delimiter //
create procedure getseason(in season int,in sharkname varchar(100))
begin 
	 case
		when sharkname='Namita' then 
        set @total=(select sum(`Namita_Investment_Amount(in lakhs)`) from sharktank where season_number=season);
        select `industry`,sum(`Namita_Investment_Amount(in lakhs)`),(sum(`Namita_Investment_Amount(in lakhs)`)/@total)*100 as '%' from sharktank where season_number=season and `Namita_Investment_Amount(in lakhs)`>0 group by industry ;
        
        when sharkname='Vineeta' then 
        set @total=(select sum(`Vineeta_Investment_Amount(in_lakhs)`) from sharktank where season_number=season);
        select `industry`,sum(`Vineeta_Investment_Amount(in_lakhs)`),(sum(`Vineeta_Investment_Amount(in_lakhs)`)/@total)*100 as '%' from sharktank where season_number=season and `Vineeta_Investment_Amount(in_lakhs)`>0 group by industry;
        
        when sharkname='Anupam' then 
        set @total=(select sum(`Anupam_Investment_Amount(in_lakhs)`) from sharktank where season_number=season);
        select `industry`,sum(`Anupam_Investment_Amount(in_lakhs)`) ,(sum(`Anupam_Investment_Amount(in_lakhs)`)/@total)*100 as '%' from sharktank where season_number=season and `Anupam_Investment_Amount(in_lakhs)`>0 group by industry;
        
        when sharkname='Aman' then 
        set @total=(select sum(`Aman_Investment_Amount(in_lakhs)`) from sharktank where season_number=season);
        select `industry`,sum(`Aman_Investment_Amount(in_lakhs)`) ,(sum(`Aman_Investment_Amount(in_lakhs)`)/@total)*100 as '%' from sharktank where season_number=season and `Aman_Investment_Amount(in_lakhs)`>0 group by industry;
        
        when sharkname='Peyush' then 
        set @total=(select sum(`Peyush_Investment_Amount((in_lakhs)`) from sharktank where season_number=season);
        select `industry`,sum(`Peyush_Investment_Amount((in_lakhs)`) ,(sum(`Peyush_Investment_Amount((in_lakhs)`)/@total)*100 as '%' from sharktank where season_number=season and `Peyush_Investment_Amount((in_lakhs)`>0 group by industry;
        
        when sharkname='Amit' then 
        set @total=(select sum(`Amit_Investment_Amount(in_lakhs)`) from sharktank where season_number=season);
        select `industry`,sum(`Amit_Investment_Amount(in_lakhs)`) ,(sum(`Amit_Investment_Amount(in_lakhs)`)/@total)*100 as '%'  from sharktank where season_number=season and `Amit_Investment_Amount(in_lakhs)`>0 group by industry;
       
       when sharkname='Ashneer' then set @total=(select sum(`Ashneer_Investment_Amount`) from sharktank where season_number=season);
        select `industry`,sum(`Ashneer_Investment_Amount`),(sum(`Ashneer_Investment_Amount`)/@total)*100 as '%' from sharktank where season_number=season and `Ashneer_Investment_Amount`>0 group by industry;
        else
			Select "Incorrect Input";
	end case;
end
//
DELIMITER ;

call getseason(1,'Ashneer');

-- 9.	In the realm of venture capital, we're exploring which shark possesses the most diversified investment portfolio across various industries.
-- By examining their investment patterns and preferences, 
-- we aim to uncover any discernible trends or strategies that may shed light on their decision-making processes and investment philosophies.


select Sharkname,count(industry) from (
select  distinct(industry),'Namita' as Sharkname  from sharktank where  `Namita_Investment_Amount(in lakhs)`>0
union all
select distinct(industry),'Vineeta' as Sharkname  from sharktank where  `Vineeta_Investment_Amount(in_lakhs)`>0
union all
select distinct(industry) ,'Anupam' as Sharkname  from sharktank where  `Anupam_Investment_Amount(in_lakhs)`>0
union all
select distinct(industry) ,'Aman' as Sharkname  from sharktank where  `Aman_Investment_Amount(in_lakhs)`>0
union all
select distinct(industry),'Peyush' as Sharkname   from sharktank where  `Peyush_Investment_Amount((in_lakhs)`>0
union all
select distinct(industry),'Amit' as Sharkname  from sharktank where  `Amit_Investment_Amount(in_lakhs)`>0
union all
select  distinct(industry),'Ashneer' as Sharkname  from sharktank where  `Ashneer_Investment_Amount`>0
)t
group by Sharkname;


-- 10.	Explain the concept of indexes in MySQL. How do indexes improve query performance, 
-- and what factors should be considered when deciding which columns to index in a database table

-- arranging in data
-- optimize the query

