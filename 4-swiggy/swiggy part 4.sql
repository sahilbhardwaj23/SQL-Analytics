use task ;

SELECT * FROM swiggy;

-- check if there is null values in dataset or not

select sum(case when hotel_name='' then 1 else 0 end )as hotel from swiggy;

select sum(case when rating ='' then 1 else 0 end ) as rating_count from swiggy;

select sum(case when time_minutes ='' then 1 else 0 end ) as time_min from swiggy;

select sum(case when food_type ='' then 1 else 0 end ) as food_type from swiggy;

select sum(case when location ='' then 1 else 0 end ) as location from swiggy;

select sum(case when offer_above ='' then 1 else 0 end ) as offer_above from swiggy;

select sum(case when offer_percentage ='' then 1 else 0 end ) as offer_percentage from swiggy;


-- get column name of a table
select * from information_schema.columns where table_name='swiggy'; -- meta data of table

select column_name from information_schema.columns where table_name='swiggy';

-- how to get null values count automatically
-- delimiter // 
-- create procedure count_blank_rows()
-- begin
-- 		select group_concat(
-- 			concat('sum(case when`',column_name,'`='''' then 1 else 0 end) as `',column_name,'`')
-- 			) into @sql
-- 			from information_schema.columns where table_name='swiggy';

-- 		set @sql=concat('select ',@sql,'from swiggy');
-- 		prepare smt from @sql; --  text to command
-- 		execute smt;
-- 	end
-- //
-- delimiter;



call count_blank_rows();-- 
 
 

DELIMITER //

CREATE FUNCTION f_name(a VARCHAR(200))
RETURNS VARCHAR(100)
DETERMINISTIC
BEGIN
    DECLARE l INT;
    DECLARE s VARCHAR(100);

    SET l = LOCATE(' ', a);  -- position of ;
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
    
    SET l = LOCATE(' ', a);  -- position of ;
    SET s = IF(l = 0, ' ', SUBSTRING(a, l + 1, LENGTH(a)));  -- if ; is not present return the string 
    
    RETURN s;
END;
//

DELIMITER ;
 
-- time_minutes entries are in rating column we have to move those but only  integer out of text

select * from swiggy where rating like '%mins%';
 
select f_name(rating) from swiggy where rating like '%mins%';
  
update swiggy
set time_minutes=f_name(rating)
where time_minutes=0;

-- time_minutes column same enteries in range of time reply them with their mean

select * from swiggy where time_minutes like'%-%';

-- update  f_name and l_name split them on the basis of -
select *,f_name(time_minutes) as f1,l_name(time_minutes) as f2 from swiggy where time_minutes like'%-%';

update swiggy
set time_minutes=((f_name(time_minutes))+(l_name(time_minutes)))/2
where time_minutes like'%-%';

select * from swiggy where hotel_name='Oven Story Pizza - Standout Toppings';

-- we have done with time_minutes now we deal with rating column

select * from swiggy where rating like '%mins%';

select location,round(avg(rating),2)
from swiggy
where rating not like '%mins%'
group by location;


-- Create a temporary table to store cleaned ratings
CREATE TEMPORARY TABLE temp_swiggy AS
SELECT location,
       CASE
           WHEN rating LIKE '%mins%' THEN rating
           ELSE TRIM(rating) -- Remove leading/trailing spaces
       END AS cleaned_rating
FROM swiggy;

-- Update the original table with cleaned ratings
UPDATE swiggy AS s
JOIN temp_swiggy AS t
ON s.location = t.location
SET s.rating = t.cleaned_rating;

UPDATE swiggy AS s
JOIN (
    SELECT location, ROUND(AVG(CAST(rating AS DECIMAL(10,2))), 2) AS avg_rating
    FROM swiggy
    WHERE rating NOT LIKE '%mins%'
    GROUP BY location
) AS t
ON s.location = t.location
SET s.rating = t.avg_rating
WHERE s.rating LIKE '%mins%';

select * from swiggy where rating like '%mins%';

-- we still left with some rows because these are unique value we will update this with the avg of rating



set @average=(select round(avg(rating),2) from swiggy where rating not like '%mins%');
select @average;

update swiggy
set rating=@average
where rating  like '%mins%';

select * from swiggy where hotel_name='Dominic Pizza';

select * from swiggy;

-- till now we have cleaned two columns rating and time_minutes

select distinct(location) from swiggy where location like '%kandivali%';

update swiggy
set location ='Kandivali East'
where location like '%East%';


update swiggy
set location ='Kandivali West'
where location like '%West%';

update swiggy
set location ='Kanivali East'
where location = 'Thakur Village, Kandivali (E)';

update swiggy
set location ='Kanivali East'
where location = 'Kandivali W';

 select distinct(location) from swiggy;
 
 -- location column is cleaned now we clean offer_percentage
 
 select * from swiggy;
 
 update swiggy
 set offer_percentage=0
 where offer_above='not_available';
 
 -- now we will count the total number of unique food_type among all hotel_name
 
select substring_index('American, Burgers, Italian, Continental, Pizzas, Pastas, Beverages, Snacks',',',2); -- first two element from string

select substring_index('American, Burgers, Italian, Continental, Pizzas, Pastas, Beverages, Snacks',',',-2);  -- last two element from string

 select substring_index(substring_index('American, Burgers, Italian, Continental, Pizzas, Pastas, Beverages, Snacks',',',2),',',-1); -- only one element of given index

-- count number of ,

select char_length('American, Burgers, Italian, Continental, Pizzas, Pastas, Beverages, Snacks'); -- total words
select char_length(replace('American, Burgers, Italian, Continental, Pizzas, Pastas, Beverages, Snacks',',','')); -- without space


select 0 as N 
union all select 1
union all select 2
union all select 3
union all select 4
union all select 5
union all select 6
union all select 7
union all select 8
union all select 9;

select a.N+(b.N)*10 as 'Num' from (
(select 0 as N union all select 1 union all select 2 union all select 3 union all select 4 union all select 5
union all select 6 union all select  7 union all select 8 union all select 9) a
cross join
(select 0 as N union all select 1 union all select 2 union all select 3 union all select 4 union all select 5
union all select 6 union all select  7 union all select 8 union all select 9) b
);


select * from swiggy
join 
(
	select 1*a.N+(b.N)*10 as 'Num' from (
		(select 1 as N  union all select 2 union all select 3 union all select 4 union all select 5
		union all select 6 union all select  7 union all select 8 union all select 9) a
		cross join
		(select 0 as N union all select 1 union all select 2 union all select 3 union all select 4 union all select 5
		union all select 6 union all select  7 union all select 8 union all select 9) b
	)
) as numbers on char_length(food_type)-char_length(replace(food_type,',',''))>=numbers.Num-1;


with swiggy_cleaned as(
select *,substring_index(substring_index(food_type,',',numbers.Num),',',-1) as food 
from swiggy
join 
(
	select 1*a.N+(b.N)*10 as 'Num' from (
		(select 1 as N  union all select 2 union all select 3 union all select 4 union all select 5
		union all select 6 union all select  7 union all select 8 union all select 9) a
		cross join
		(select 0 as N union all select 1 union all select 2 union all select 3 union all select 4 union all select 5
		union all select 6 union all select  7 union all select 8 union all select 9) b
	)
) as numbers on char_length(food_type)-char_length(replace(food_type,',',''))>=numbers.Num-1)
select * from swiggy_cleaned;


