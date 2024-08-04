use case_study;

SELECT * FROM `googleplaystore(impure)`;
-- when we are importing impure database sql can't import all rows we have to clean this data first through python and then import the cleaned data.

drop table `googleplaystore(impure)`;

select * from playstore;
-- whole data is not imported due to encoding,variables
-- we have to truncate this table and then load the external file to this table

truncate table playstore;

select * from playstore;

load data infile "E:/DSMP 1.0/Data Analyst/6-SQL/5 case study/Case Study 2/playstore.csv" -- path of file
into table playstore -- table name 
fields terminated by ',' -- mysql server load csv files only 
optionally enclosed by '"' -- data contains some space 
lines terminated by '\r\n' -- for new line 
ignore 1 rows;

--  by default we can't load data through this we have to modify the file
-- go to file "C:\ProgramData\MySQL\MySQL Server 8.0\my.ini" by enabling hidden items and open it in notepad then modify this file.
-- turn off the mysql services
-- local_infile=ON
-- paste the above code in that file at client section under default characterset, and then in server section under sever type=3,then search sequre using ctrl+f 
-- this will show a path clean that path save this file if (provide the write permission to user) switch on the services and restart and run the infile code in sql

select * from playstore;


-- 1.	You're working as a market analyst for a mobile app development company. 
-- Your task is to identify the most promising categories (TOP 5) for launching new free apps based on their average ratings.
select Category,round(avg(rating),2) as rating 
from playstore 
where type='Free' 
group by category 
order by rating desc limit 5;

-- 2.	As a business strategist for a mobile app company, your objective is to pinpoint the three categories that generate the most revenue from paid apps. 
-- This calculation is based on the product of the app price and its number of installations.
select category,round(avg(rev),2) as revenue from
	(select *,(`Price`*`Installs`) as rev from playstore where type = 'paid')t
group by category 
order by revenue desc limit 3;

-- 3.	As a data analyst for a gaming company, you're tasked with calculating the percentage of app within each category. 
-- This information will help the company understand the distribution of gaming apps across different categories.

select category,(cnt/(select count(*) from playstore))*100 as percentage from
	(select category,count(*) as cnt from playstore group by category)t
order by percentage desc;


-- 4.	As a data analyst at a mobile app-focused market research firm you’ll recommend whether the company 
-- should develop paid or free apps for each category based on the ratings of that category.
with t1 as
(select category,round(avg(rating),2) as 'paid' from playstore where `type`='paid' group by category),
t2 as
(select category,round(avg(rating),2) as 'free' from playstore where `type`='free' group by category)
select *,if(paid>free,'Devlop paid apps','develop free app') as 'decision'
from (
	select a.category,paid,free from t1 as  a inner join t2 as b on a.category=b.category
    )k;
    
-- 5.	Suppose you're a database administrator your databases have been hacked and hackers are changing price of certain apps on the database,
-- it is taking long for IT team to neutralize the hack, however you as a responsible manager don’t want your data to be changed, 
-- do some measure where the changes in price can be recorded as you can’t stop hackers from making changes.

-- we will create a different table and store all the updates in that table

create table pricechangelog(
	app varchar(255),
    old_price decimal(10,2),
    new_price decimal(10,2),
    operation_type varchar(255),
    operation_date timestamp
    );

select * from pricechangelog;

-- creating a copy of data
create table play as select * from playstore;

select * from play;


DELIMITER // -- in btw  after delimiter two symbol will treat all statements as a single statement  

CREATE TRIGGER price_change_log
AFTER UPDATE
ON play
FOR EACH ROW
BEGIN
    INSERT INTO pricechangelog(app, old_price, new_price, operation_type, operation_date)
    VALUES (NEW.app, OLD.price, NEW.price, 'update', CURRENT_TIMESTAMP); --  statements end here
END;   --  statements ends here
//

DELIMITER ;



set sql_safe_update=0;

update play
set price =10
where app='Photo Editor & Candy Camera & Grid & ScrapBook';

update play 
set price =5
where app = 'Coloring book moana';

select * from pricechangelog;

select * from play;

-- 6.	Your IT team have neutralized the threat; however, hackers have made some changes in the prices, 
-- but because of your measure you have noted the changes, now you want correct data to be inserted into the database again.

-- update + join
-- pricechangelog

select * from play as a inner join pricechangelog as b on a.app=b.app;   -- step 1
 
 drop trigger price_change_log;
 
update play as a
inner join pricechangelog as b on a.app=b.app
set a.price=b.old_price;

select * from play;


-- 7.	As a data person you are assigned the task of investigating the correlation between two numeric factors: app ratings and the quantity of reviews.
-- (x-x')  (y-y')  (x-x')^2  (y-y')^2

set @x=(select round(avg(rating),2) from playstore);
set @y=(select round(avg(reviews),2) from playstore);
select @x,@y ;


with k as (
select *,round((rat*rat),2) as 'sqrt_x',round((rev*rev),2) as 'sqrt_y' from 
	(select rating ,@X,round((rating-@x),2) as 'rat',reviews,@y,round((reviews-@y),2) as 'rev' from playstore)t
)
    
select @num:=sum((rat*rev)) ,@deno_1:=sum(sqrt_x),@deno_2:=sum(sqrt_y) from k;
select round(((@num)/(sqrt((@deno_1)*(@deno_2)))),2) as 'corr';



--  8.	Your boss noticed  that some rows in genres columns have multiple genres in them, which was creating issue when developing the  recommender system from the data he/she 
-- assigned you the task to clean thegenres column and make two genres out of it, rows that have only one genre will have  other column as blank.


-- the two genre can differentiate by ;
select * from playstore;

DELIMITER //

CREATE FUNCTION f_name(a VARCHAR(200))
RETURNS VARCHAR(100)
DETERMINISTIC
BEGIN
    DECLARE l INT;
    DECLARE s VARCHAR(100);

    SET l = LOCATE(';', a);  -- position of ;
    SET s = IF(l > 0, LEFT(a, l - 1), a);  -- if ; is present return the string before ; else return original

    RETURN s;
END;
//

DELIMITER ;


-- second function
DELIMITER //

CREATE FUNCTION l_name(a VARCHAR(200))
RETURNS VARCHAR(100)
DETERMINISTIC
BEGIN
    DECLARE l INT;
    DECLARE s VARCHAR(100);
    
    SET l = LOCATE(';', a);  -- position of ;
    SET s = IF(l = 0, ' ', SUBSTRING(a, l + 1, LENGTH(a)));  -- if ; is not present return the string 
    
    RETURN s;
END;
//

DELIMITER ;


select f_name('Sahil;Bhardwaj');

select l_name('Sahil;Bhardwaj');


select genres,f_name(genres) as 'first_name',l_name(genres) as 'last_name' from playstore;


-- 10.What is the difference between “Duration Time” and “Fetch Time.”
-- duration time-time taken by sql to understand a query
-- fetch time- time taken to display the result after understanding/calculation