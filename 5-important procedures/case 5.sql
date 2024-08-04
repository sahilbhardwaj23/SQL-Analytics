use task;

CREATE TABLE employees (
    id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL,
    hire_date DATE NOT NULL
);

-- Insert 15 rows into the employees table
INSERT INTO employees (first_name, last_name, email, hire_date)
VALUES ('John', 'Doe', 'johndoe@example.com', '2022-01-15'),
       ('Jane', 'Smith', 'janesmith@example.com', '2021-11-30'),
       ('Alice', 'Johnson', 'alicejohnson@example.com', '2022-03-10'),
       ('David', 'Brown', 'davidbrown@example.com', '2022-02-20'),
       ('Emily', 'Davis', 'emilydavis@example.com', '2022-04-05'),
       ('Michael', 'Wilson', 'michaelwilson@example.com', '2022-01-05'),
       ('Sarah', 'Taylor', 'sarahtaylor@example.com', '2022-03-25'),
       ('Kevin', 'Clark', 'kevinclark@example.com', '2022-02-15'),
       ('Jessica', 'Anderson', 'jessicaanderson@example.com', '2022-04-01'),
       ('Matthew', 'Martinez', 'matthewmartinez@example.com', '2022-01-10'),
       ('Laura', 'Robinson', 'laurarobinson@example.com', '2022-03-15'),
       ('Daniel', 'White', 'danielwhite@example.com', '2022-02-05'),
       ('Amy', 'Harris', 'amyharris@example.com', '2022-04-20'),
       ('Jason', 'Lee', 'jasonlee@example.com', '2022-01-20'),
       ('Rachel', 'Moore', 'rachelmoore@example.com', '2022-03-05');


-- inserting duplicates
INSERT INTO employees (first_name, last_name, email, hire_date) values
('Emily', 'Davis', 'emilydavis@example.com', '2022-04-05'),
('Matthew', 'Martinez', 'matthewmartinez@example.com', '2022-01-10');


-- 1 You have got duplciate rows in table you have to delete them.

select * from employees where id in(
select id from 
(select id, row_number() over(partition by first_name,last_name) as 'rnk' from employees)t
where rnk=1);


delete from employees where id in(
select id from 
(select id, row_number() over(partition by first_name,last_name) as 'rnk' from employees)t
where rnk>1);

select * from employees;


create table sales
(  
    sales_person varchar(100),
    territory varchar(2),
    sales int 
);

INSERT INTO sales (sales_person, territory, sales)
VALUES ('John', 'A',40),
       ('Alice', 'A', 150),
       ('Michael', 'A', 200),
       ('Sarah', 'A', 120),
       ('Kevin', 'A', 180),
       ('Jessica', 'A', 90),
       ('David', 'A', 130),
       ('Emily', 'A', 140),
       ('Daniel', 'A', 270),
       ('Laura', 'A', 300),
       ('Jane', 'B', 180),
       ('Robert', 'B', 220),
       ('Mary', 'B', 190),
       ('Peter', 'B', 210),
       ('Emma', 'B', 130),
       ('Matthew', 'B', 140),
       ('Olivia', 'B', 170),
       ('William', 'B', 240),
       ('Sophia', 'B', 210),
       ('Andrew', 'B', 300),
       ('James', 'C', 300),
       ('Linda', 'C', 270),
       ('Richard', 'C', 320),
       ('Jennifer', 'C', 280),
       ('Charles', 'C', 250),
       ('Amanda', 'C', 290),
       ('Thomas', 'C', 260),
       ('Susan', 'C', 310),
       ('Paul', 'C', 280),
       ('Karen', 'C', 300);

-- 2  You are a sales manager and you have 3 territories under you,   the manager decided that for each territory the salesperson who have  sold more than 30%  of the average of that 
-- territory  will  get  hike  and person who have done 80% less than the average salary will be issued PIP , now for all you have to  tell your manager if he/she will 
-- get a hike or will be in a PIP

select * from sales;

select  territory ,avg(sales) from sales group by territory;

set @a=(select round(avg(sales),2) from sales where territory='A');
set @b=(select round(avg(sales),2)  from sales where territory='B');
set @c=(select round(avg(sales),2)  from sales where territory='C');
select @a,@b,@c;

select sales_person,territory,
case
	when sales>(1.3*territory_mean) then 'hike'
    when sales<(0.8*territory_mean) then 'pip'
    else 'same_parameter'
end as reward
from (select * ,
	case
		when territory='A' then @a
		when territory='B' then @b
		when territory='C' then @c
		else null
		end as
	territory_mean
	from sales)
k;


/* 3. You are database administrator for a university , University have declared result for a special exam , However children were not happy with the marks as marks were
not given appropriately
and many students marksheet was blank , so they striked. Due to strike univerisity again checked the sheets and updates were made. Handle these updates*/



Create table students
( 
roll int ,
s_name varchar(100),
Marks  float
);

INSERT INTO students (roll, s_name, Marks)
VALUES 
    (1, 'John', 75),
    (2, 'Alice', 55),
    (3, 'Bob', 40),
    (4, 'Sarah', 85),
    (5, 'Mike', 65),
    (6, 'Emily', 50),
    (7, 'David', 70),
    (8, 'Sophia', 45),
    (9, 'Tom', 55),
    (10, 'Emma', 80),
    (11, 'James', 58),
    (12, 'Lily', 72),
    (13, 'Andrew', 55),
    (14, 'Olivia', 62),
    (15, 'Daniel', 78);

    
Create table std_updates
(
  roll int,
  s_name varchar(100),
  marks float 
);

INSERT INTO std_updates (roll, s_name, Marks)
VALUES 
		(8, 'Sophia', 75),   -- existing
		(9, 'Tom', 85),
		(16, 'Grace', 55),     -- new
		(17, 'Henry', 72),
		(18, 'Sophie', 45),
		(19, 'Jack', 58),
		(20, 'Ella', 42);

select * from students;      
  
select * from std_updates;

-- first we will update the marks of students

update students as s
inner join
std_updates as t
set s.marks=t.marks
where s.roll=t.roll;


-- now we will add new students data

insert into students (
select roll,s_name,marks from(
	select s.roll as r1,t.* 
	from students as s
	right join 
	std_updates as t
	on s.roll=t.roll) k
where r1 is null);

select * from students;

truncate std_updates;

DELIMITER //
CREATE procedure updation_insertion()
BEGIN
	-- first we will update the marks of students

	update students as s
	inner join
	std_updates as t
	set s.marks=t.marks
	where s.roll=t.roll;
    
    -- now we will add new students data

	insert into students (
	select roll,s_name,marks from(
		select s.roll as r1,t.* 
		from students as s
		right join 
		std_updates as t
		on s.roll=t.roll) k
	where r1 is null);
		
	TRUNCATE TABLE std_updates;
END //
DELIMITER ;

call updation_insertion();

-- 4 You have  to make a procedure , where you will give 
 --3 inputs string, deliminator  and before and after  command , based on the   information provided you have to 
-- find that part of string.
 
        -- in industry we have space constraints , thats why we try to make things as simple as possbile, and resuable things.

DELIMITER //
create function string_split( s varchar(100), d varchar(5), c varchar (10))
returns Varchar(100)
DETERMINISTIC
begin
     set @l = length(d);  -- deliminator can be of any length.
     set @p = locate(d, s);
     set @o = 
        case  when c like '%before%'
            then left(s,@p-1)
        else 
            substring(s, @p+@l,length(s))
		end;
  return @o;
end //
DELIMITER ;

select string_split('sahil@gmail.com','@','before');

-- 5 You have a table that stores student information  roll number wise , now some of the students have left the school due to which the  roll numbers became discontinuous
-- Now your task is to make them continuous.
-- creating table

truncate table students;

CREATE TABLE students (
    roll_number INT PRIMARY KEY,
    name VARCHAR(50),
    marks DECIMAL(5, 2),
    favourite_subject VARCHAR(50)
);

-- inserting data
INSERT INTO students (roll_number, name, marks, favourite_subject) VALUES
    (1, 'Rahul Sharma', 75.5, 'Mathematics'),
    (2, 'Priya Patel', 82.0, 'Science'),
    (3, 'Amit Singh', 68.5, 'History'),
    (4, 'Sneha Reddy', 90.75, 'English'),
    (5, 'Vivek Gupta', 79.0, 'Physics'),
    (6, 'Ananya Desai', 85.25, 'Chemistry'),
    (7, 'Rajesh Verma', 72.0, 'Biology'),
    (8, 'Neha Mishra', 88.5, 'Computer Science'),
    (9, 'Arun Kumar', 76.75, 'Economics'),
    (10, 'Pooja Mehta', 94.0, 'Geography'),
	(11, 'Sanjay Gupta', 81.5, 'Mathematics'),
    (12, 'Divya Sharma', 77.0, 'Science'),
    (13, 'Rakesh Patel', 83.5, 'History'),
    (14, 'Kavita Reddy', 89.25, 'English'),
    (15, 'Ankit Verma', 72.0, 'Physics');


select * from students;

delete from students
where roll_number in (3,6,9,12);

select * from students;

-- roll no of students became discontiuous due to those students who left the college

update students as s
inner join 
(select * ,row_number() over(order by roll_number) as 'rl'from students) as t
on s.roll_number=t.roll_number
set s.roll_number =t.rl;


-- create a procedure for the above work
DELIMITER //
create procedure roll_update()
begin
	update students as s
	inner join 
	(select * ,row_number() over(order by roll_number) as 'rl'from students) as t
	on s.roll_number=t.roll_number
	set s.roll_number =t.rl;
end //
DELIMITER ;

-- Create the event to renumber students every hour
DELIMITER //
CREATE EVENT IF NOT EXISTS renumber_students_event
ON SCHEDULE EVERY 20 second
DO
BEGIN
    CALL roll_update();
END//
DELIMITER ;


-- 6  -- create a system where it will check the warehouse before making the sale and if sufficient quantity is avaibale make the sale and store the sales transaction 
 -- else show error for insufficient quantity.( like an ecommerce website, before making final transaction look for stock.)

create table products
   (
      product_code varchar(20),
      product_name varchar(20),
      price int,
      Quantity_remaining int,
      Quantity_sold int
	);
    
   
INSERT INTO products (product_code, product_name, price, Quantity_remaining, Quantity_sold)
VALUES
    ('RO001', 'Rolex Submariner', 7500, 20, 0),
    ('RO002', 'Rolex Datejust', 6000, 15, 0),
    ('RO003', 'Rolex Daytona', 8500, 25, 0),
    ('RO004', 'Rolex GMT-Master II', 7000, 18, 0),
    ('RO005', 'Rolex Explorer', 5500, 12, 0),
    ('RO006', 'Rolex Yacht-Master', 9000, 30, 0),
    ('RO007', 'Rolex Sky-Dweller', 9500, 22, 0);


  create table sales_database
  ( 
     order_id int auto_increment primary key,
     order_date date,
     product_code varchar(10),
     Quantity_sold int,
     per_quantity_price int,
     total_sale_price int
  );



select * from products;

DELIMITER //
CREATE PROCEDURE MakeSale(IN pname VARCHAR(100),IN quantity INT)
BEGIN
    set @co = (select product_code from products where product_name= pname);
    set @qu = (select Quantity_remaining from products  where product_code= @co);
    set @pr = (select price from products where product_code= @co);
    IF quantity <=  @qu THEN
        INSERT INTO sales_database (order_date, product_code, Quantity_sold, per_quantity_price , total_sale_price)
        VALUES (CURRENT_DATE(), @co, quantity,@pr, quantity* @pr);
        SELECT 'Sale successful' AS message; -- Output success message
        update products
        set quantity_remaining = quantity_remaining - quantity,
            Quantity_sold= Quantity_sold+quantity
		where  product_name = pname;
	ELSE
        SELECT 'Insufficient quantity available' AS message;
    END IF;

END //
DELIMITER ;

set sql_safe_update=0;

call makesale ('Rolex Submariner', 4);

select * from sales_database;

select * from products;

 -- 8 Given a Sales table containing SaleID, ProductID, SaleAmount, and SaleDate, write a SQL query to find the top  2 salespeople based on
  -- their total sales amount for the current month. If there's a tie in sales amount, prioritize the salesperson with the earlier registration date.
  
  CREATE TABLE Sales_man (
    Sale_man_registration_date date ,
    ProductID INT,
    SaleAmount DECIMAL(10, 2),
    SaleDate DATE,
    SalespersonID INT
);


-- Inserting Sample Data into the Sales Table
INSERT INTO Sales_man (Sale_man_registration_date, ProductID, SaleAmount, SaleDate, SalespersonID)
VALUES
    ('2023-07-15', 101, 150.00, '2023-07-05', 1),
    ('2023-07-15', 102, 200.00, '2023-07-10', 2),
    ('2023-07-15', 103, 180.00, '2023-07-15', 3),
    ('2023-07-15', 104, 220.00, '2023-07-20', 4),
    ('2023-06-15', 105, 190.00, '2023-07-25', 5),
    ('2023-07-15', 101, 210.00, '2023-08-05', 1),
    ('2023-07-15', 102, 180.00, '2023-08-10', 2),
    ('2023-07-15', 103, 200.00, '2023-08-15', 3),
    ('2023-07-15', 104, 190.00, '2023-08-20', 4),
    ('2023-07-15', 105, 220.00, '2023-08-25', 5),
    ('2024-01-10', 101, 230.00, '2024-01-05', 1),
    ('2024-01-10', 102, 190.00, '2024-01-10', 2),
    ('2024-01-10', 103, 220.00, '2024-01-15', 3),
    ('2024-01-10', 104, 190.00, '2024-01-20', 4),
    ('2024-01-10', 105, 230.00, '2024-01-25', 5),
    ('2024-01-10', 101, 240.00, '2024-02-05', 1),
    ('2024-01-10', 102, 180.00, '2024-02-10', 2),
    ('2024-01-10', 103, 220.00, '2024-02-15', 3),
    ('2024-01-10', 104, 200.00, '2024-02-20', 4),
    ('2023-01-10', 105, 210.00, '2024-02-25', 5),
    ('2024-04-15', 101, 250.00, '2024-04-05', 1),
    ('2024-04-15', 102, 200.00, '2024-04-10', 2),
    ('2024-04-15', 103, 180.00, '2024-04-15', 3),
    ('2024-04-15', 104, 220.00, '2024-04-20', 4),
    ('2024-04-15', 105, 220.00, '2024-04-25', 5),
    ('2024-04-15', 101, 210.00, '2024-05-05', 1),
    ('2024-04-15', 102, 180.00, '2024-05-10', 2),
    ('2024-04-15', 103, 200.00, '2024-05-15', 3),
    ('2024-04-15', 104, 190.00, '2024-05-20', 4),
    ('2024-03-15', 105, 220.00, '2024-05-25', 5);


select * from Sales_man;

select salespersonId, sum(saleamount)as summ, min(Sale_man_registration_date) as mindate  from Sales_man where year(saledate)=2024 and month(saledate) = 4 group by salespersonid
order by summ desc , mindate
  ;-- finding all three



-- 9 You have got transaction data in the format  transaction id , date , type , amount and description , howvevrr this format is not
 -- easily interpretable , now you have to make it in the good format ( month , year, revenue, expenditure, profit)
 
CREATE TABLE transactions (
    transaction_id INT PRIMARY KEY,
    transaction_date DATE,
    transaction_type VARCHAR(50),
    amount DECIMAL(10, 2),
    descriptions varchar(1000)
);

INSERT INTO transactions (transaction_id, transaction_date, transaction_type, amount, descriptions) VALUES
(1, '2024-01-05', 'Expense', 500.00, 'Office supplies'),
(2, '2024-01-15', 'Revenue', 1500.00, 'Consulting fees'),
(3, '2024-02-10', 'Expense', 300.00, 'Travel expenses'),
(4, '2024-02-22', 'Revenue', 2000.00, 'Product sales'),
(5, '2024-03-03', 'Expense', 700.00, 'Advertising costs'),
(6, '2024-03-18', 'Revenue', 1800.00, 'Service subscriptions'),
(7, '2024-04-12', 'Expense', 400.00, 'Software licenses'),
(8, '2024-04-29', 'Revenue', 2500.00, 'Event sponsorship'),
(9, '2024-01-09', 'Expense', 600.00, 'Equipment maintenance'),
(10, '2024-01-14', 'Revenue', 1200.00, 'Online course sales'),
(11, '2024-02-20', 'Expense', 450.00, 'Utility bills'),
(12, '2024-02-25', 'Revenue', 3000.00, 'Consulting services'),
(13, '2024-03-05', 'Expense', 550.00, 'Office rent'),
(14, '2024-03-08', 'Revenue', 1800.00, 'Web development project'),
(15, '2024-04-19', 'Expense', 400.00, 'Employee training'),
(16, '2024-04-21', 'Revenue', 2200.00, 'Product sales'),
(17, '2024-01-28', 'Expense', 750.00, 'Marketing campaign'),
(18, '2024-01-15', 'Revenue', 1600.00, 'Consulting fees'),
(19, '2024-02-21', 'Expense', 350.00, 'Office supplies'),
(20, '2024-02-28', 'Revenue', 2800.00, 'Event ticket sales');


select * from transactions;

select month(transaction_date)  as months , year(transaction_date) as years,
sum(case when transaction_type ='Revenue'  then amount else 0 end ) as total_revenue,
sum(case when transaction_type ='Expense'  then amount else 0 end ) as total_expenses,
sum(case when transaction_type ='Revenue'  then amount else 0 end )- sum(case when transaction_type ='Expense'  then amount else 0 end ) as net_profit
from 
transactions 
group by 
   year(transaction_date), month(transaction_date)
order by  months;

-- 7 you have a table where there is sales data for entire month you have to calculate cumultive sum for the entire  month data  show it month wise and week wise both	
  CREATE TABLE sales_month (
    sale_date DATE,
    day_of_week VARCHAR(20),
    sales_amount DECIMAL(10, 2)
);
  
  
  -- Insert sales data for each day of April 2024
INSERT INTO sales_month (sale_date, day_of_week, sales_amount) VALUES
    ('2024-04-01', 'Friday', 1500.00),
    ('2024-04-02', 'Saturday', 1800.50),
    ('2024-04-03', 'Sunday', 2500.75),
    ('2024-04-04', 'Monday', 3200.25),
    ('2024-04-05', 'Tuesday', 2800.60),
    ('2024-04-06', 'Wednesday', 2100.90),
    ('2024-04-07', 'Thursday', 3500.00),
    ('2024-04-08', 'Friday', 2200.00),
    ('2024-04-09', 'Saturday', 1900.25),
    ('2024-04-10', 'Sunday', 2600.75),
    ('2024-04-11', 'Monday', 3100.50),
    ('2024-04-12', 'Tuesday', 2900.80),
    ('2024-04-13', 'Wednesday', 2400.70),
    ('2024-04-14', 'Thursday', 3800.00),
    ('2024-04-15', 'Friday', 3200.50),
    ('2024-04-16', 'Saturday', 1800.75),
    ('2024-04-17', 'Sunday', 2700.25),
    ('2024-04-18', 'Monday', 3000.20),
    ('2024-04-19', 'Tuesday', 2600.90),
    ('2024-04-20', 'Wednesday', 2200.60),
    ('2024-04-21', 'Thursday', 3600.00),
    ('2024-04-22', 'Friday', 2900.50),
    ('2024-04-23', 'Saturday', 2100.75),
    ('2024-04-24', 'Sunday', 2800.25),
    ('2024-04-25', 'Monday', 3300.80),
    ('2024-04-26', 'Tuesday', 2700.70),
    ('2024-04-27', 'Wednesday', 2300.00),
    ('2024-04-28', 'Thursday', 3700.50),
    ('2024-04-29', 'Friday', 3100.75),
    ('2024-04-30', 'Saturday', 1900.25);

select * from sales_month;

select sale_date,sum(sales_amount)  over (order by sale_date) as running_sum from sales_month;

select s.sale_date, day_of_week, sales_amount, running_sum from  sales_month as s
inner join
(
select sale_date,sum(sales_amount)  over (order by sale_date) as running_sum from sales_month
)k on s.sale_date=k.sale_date;


-- for each week closing
select * from 
(
	select s.sale_date, day_of_week, sales_amount, running_sum from  sales_month as s
	inner join
	(
	select sale_date,sum(sales_amount)  over (order by sale_date) as running_sum from sales_month
	)k on s.sale_date=k.sale_date
)m where day_of_week= 'Friday'

-- 10 ACID Properties

/*Atomicity: Atomicity ensures that each transaction is treated as a single "unit", which means that either all of its operations are successfully 
completed and applied to the database, or none of them are. If any part of the transaction fails, the entire transaction is rolled back to its original 
state (i.e., before the transaction started), ensuring that the database remains in a consistent state.

Consistency: Consistency guarantees that the database remains in a valid state before and after the execution of a transaction. This means that any constraints,
 rules, or conditions defined for the database must be satisfied at all times, ensuring data integrity. Transactions should only transition the database from one valid
 state to another valid state.
 
Isolation: Isolation ensures that the execution of transactions concurrently (i.e., at the same time) does not result in any unexpected behavior or interference.
 Each transaction should operate independently of other transactions, and the result of executing multiple transactions concurrently should be equivalent to some 
 sequential execution of those transactions. Isolation levels (e.g., Read Committed, Repeatable Read, Serializable) determine the degree of isolation provided by a 
 database system.
 
Durability: Durability guarantees that once a transaction has been committed (i.e., its changes have been applied to the database), these changes will persist even in
 the event of system failures such as power outages or crashes. The database system must ensure that the committed changes are permanently stored and will not be lost.
*/
  

