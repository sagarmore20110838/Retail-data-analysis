
/* Creating the database and table in it : */

CREATE DATABASE RETAIL  ;
USE RETAIL ; 

SELECT * FROM CUSTOMER ; 

SELECT * FROM Transactions ; 

SELECT * FROM PROD_CAT_INFO ; 

-- IMPORTED THE DATA FROM TASK-IMPORT


--DATA PREPARATION AND UNDERSTANDING
--1.What is the total number of rows in each of the 3 tables in the database?

SELECT COUNT(*) as row_count
 FROM Customer  
 UNION
SELECT COUNT(*) as TRANS_row_count
 FROM Transactions  
 UNION
SELECT COUNT(*) as PRODUCT_CAT_row_count
 FROM PROD_CAT_INFO ; 


---2.	What is the total number of transactions that have a return?
SELECT COUNT(total_amt) NOS_TRANSATIONS 
FROM Transactions 
WHERE total_amt<0 ; 



---3.	As you would have noticed, the dates provided across the datasets are not in a correct format.
-- As first steps, pls convert the date variables into valid date formats before proceeding ahead.

 
SELECT *, CONVERT(VARCHAR,tran_date,101 ) NEW_DATE 
FROM Transactions




---4.	What is the time range of the transaction data available for analysis? Show the output in number of days, months and years
--      simultaneously in different columns.

SELECT MAX(tran_date) MAX_DATE
FROM Transactions;

SELECT MIN(tran_date) MIN_DATE 
FROM Transactions;

SELECT DISTINCT DATEDIFF("DAY", '2011-01-25' ,'2014-02-28' ) TIME_RANGE_DAYS,
DATEDIFF("MONTH", '2011-01-25' ,'2014-02-28' ) TIME_RANGE_MONTH,
DATEDIFF("YEAR", '2011-01-25' ,'2014-02-28' ) TIME_RANGE_YEAR ; 



--5.	Which product category does the sub-category “DIY” belong to?


SELECT * 
FROM PROD_CAT_INFO 
WHERE prod_subcat ='DIY'

-- Books 


--DATA ANALYSIS : 

--1.Which channel is most frequently used for transactions?

SELECT TOP 1  STORE_TYPE , COUNT(Store_type) NO_TRANSACTIONS
 FROM Transactions
 GROUP BY Store_type
 ORDER BY  COUNT(Store_type) DESC; 


--2.What is the count of Male and Female customers in the database?

SELECT Gender , COUNT(Gender) T_COUNT
FROM CUSTOMER
GROUP BY Gender ;

--3.From which city do we have the maximum number of customers and how many? 

SELECT  TOP 1 city_code , COUNT(city_code) TOTAL_CUST
FROM CUSTOMER
GROUP BY city_code
ORDER BY  COUNT(city_code)DESC ;


--4.How many sub-categories are there under the Books category?

SELECT prod_cat, prod_subcat
FROM PROD_CAT_INFO
WHERE prod_cat = 'Books'

-- TOTAL 6 SUB_CATEGORY 


--5.What is the maximum quantity of products ever ordered?

SELECT T2.prod_cat, T2.prod_subcat, T1.Qty FROM 
Transactions T1 INNER JOIN PROD_CAT_INFO T2 
ON T1.prod_cat_code = T2.prod_cat_code AND T1.prod_subcat_code=T2.prod_sub_cat_code
ORDER BY QTY DESC ; 

--6.What is the net total revenue generated in categories Electronics and Books?

SELECT T2.prod_cat , SUM(total_amt) TOTAL_SALES   FROM 
Transactions T1 INNER JOIN PROD_CAT_INFO T2 
ON T1.prod_cat_code = T2.prod_cat_code AND T1.prod_subcat_code=T2.prod_sub_cat_code
GROUP BY T2.prod_cat
HAVING T2.prod_cat IN ('Books', 'Electronics'); 


--7.How many customers have >10 transactions with us, excluding returns?


SELECT T1.customer_Id , COUNT(T1.customer_Id) TRANS_NUMB FROM 
Customer T1 INNER JOIN Transactions T2 
ON T1.customer_Id = T2.cust_id
WHERE total_amt>0
GROUP BY T1.customer_Id  
HAVING COUNT(T1.customer_Id) > 10 ;

--8.What is the combined revenue earned from the “Electronics” & “Clothing” categories, from “Flagship stores”?

SELECT SUM(T1.total_amt) TOTAL_REV FROM 
Transactions T1 INNER JOIN PROD_CAT_INFO T2 
ON T1.prod_cat_code = T2.prod_cat_code AND T1.prod_subcat_code=T2.prod_sub_cat_code
WHERE T1.Store_type = 'Flagship store' AND T2.prod_cat IN ('Electronics', 'Clothing'); 



--9.What is the total revenue generated from “Male” customers in “Electronics” category? Output should display total revenue by prod sub-cat.
 
SELECT T3.prod_subcat , SUM(T2.total_amt) TOTAT_REV FROM 
Customer T1 INNER JOIN Transactions T2 
ON T1.customer_Id = T2.cust_id
INNER JOIN PROD_CAT_INFO T3 
ON T2.prod_cat_code=T3.prod_cat_code AND T2.prod_subcat_code = T3.prod_sub_cat_code
WHERE  T1.Gender = 'M' AND  T3.prod_cat IN ('Electronics')
GROUP BY T3.prod_subcat ; 


--10.What is percentage of sales and returns by product sub category; display only top 5 sub categories in terms of sales?


SELECT TOP 5  T2.prod_subcat , SUM(T1.total_amt) SALES ,(SUM(T1.total_amt)/54443652)*100 PECENT_SALES  FROM 
Transactions T1 INNER JOIN PROD_CAT_INFO T2 
ON T1.prod_cat_code = T2.prod_cat_code AND T1.prod_subcat_code=T2.prod_sub_cat_code
WHERE T1.total_amt > 0
GROUP BY T2.prod_subcat
ORDER BY SUM(T1.total_amt) DESC;

SELECT TOP 5 T2.prod_subcat , SUM(T1.total_amt) RETURS , (SUM(T1.total_amt)/-5873034)*100 PECENT_RETURN  FROM 
Transactions T1 INNER JOIN PROD_CAT_INFO T2 
ON T1.prod_cat_code = T2.prod_cat_code AND T1.prod_subcat_code=T2.prod_sub_cat_code
WHERE T1.total_amt < 0 
GROUP BY T2.prod_subcat
ORDER BY SUM(T1.total_amt) DESC;


--11.For all customers aged between 25 to 35 years find what is the net total revenue generated by these consumers in last 
--   30 days of transactions from max transaction date available in the data?

CREATE VIEW CUST_WITH_AGE AS
SELECT *, DATEDIFF("YEAR", DOB, '2014-02-28') Age
FROM CUSTOMER_NEW_DATA  
 

SELECT SUM(T2.total_amt) TOTAL_REV FROM 
CUST_WITH_AGE T1 INNER JOIN Transactions T2 
ON T1.customer_Id = T2.cust_id
WHERE Age BETWEEN 25 AND 35 AND tran_date >'2014-01-28' ;


--12.Which product category has seen the max value of returns in the last 3 months of transactions?

SELECT TOP 1 T3.prod_cat, SUM(T2.total_amt) RETURN_VALUE  FROM 
CUST_WITH_AGE T1 INNER JOIN Transactions T2 
ON T1.customer_Id = T2.cust_id  INNER JOIN 
PROD_CAT_INFO T3 
ON T2.prod_cat_code = T3.prod_cat_code AND T2.prod_subcat_code = T3.prod_sub_cat_code
WHERE  tran_date >'2013-11-30' AND total_amt <0
GROUP BY T3.prod_cat 
ORDER BY SUM(T2.total_amt) ; 

-- ITS BOOKS CATEGORY 


--13.Which store-type sells the maximum products; by value of sales amount and by quantity sold?

 
SELECT TOP 1  Store_type , SUM(RATE) TOTAL_SALES , SUM(Qty) TOTAL_QTY
FROM Transactions
GROUP BY Store_type
ORDER BY SUM(RATE) DESC , SUM(Qty) DESC; 

-- E-SHOP SOLD THE MAXIMUM PRODUCS 


--14.What are the categories for which average revenue is above the overall average.

SELECT  AVG(AVEG_CATEGORY)  FROM 
(SELECT  T2.prod_cat , AVG(T1.total_amt) AS AVEG_CATEGORY   FROM 
Transactions T1 INNER JOIN PROD_CAT_INFO T2 
ON T1.prod_cat_code = T2.prod_cat_code AND T1.prod_subcat_code=T2.prod_sub_cat_code
GROUP BY T2.prod_cat ) T3 
-- CALCULATING PRODUCT AVG -- 2099.34  

--- FINAL OUT : 

SELECT  T2.prod_cat , AVG(T1.total_amt) AS AVEG_CATEGORY   FROM 
Transactions T1 INNER JOIN PROD_CAT_INFO T2 
ON T1.prod_cat_code = T2.prod_cat_code AND T1.prod_subcat_code=T2.prod_sub_cat_code
GROUP BY T2.prod_cat
HAVING  AVG(T1.total_amt) > 2099.34; 



--15.Find the average and total revenue by each subcategory for the categories which are among top 5 categories in terms of quantity sold.

SELECT TOP 5  T2.prod_cat, T2.prod_subcat , AVG(T1.total_amt) AVG_REVENUE ,SUM(T1.total_amt)TOTAL_REVENUE, SUM(T1.Qty) TOTAL_QTY FROM 
Transactions T1 INNER JOIN PROD_CAT_INFO T2 
ON T1.prod_cat_code = T2.prod_cat_code AND T1.prod_subcat_code=T2.prod_sub_cat_code
GROUP BY T2.prod_cat , T2.prod_subcat
ORDER BY SUM(T1.Qty) DESC ; 





















 






















  ; 












 



















































































































 











 

