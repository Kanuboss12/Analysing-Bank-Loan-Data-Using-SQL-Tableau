CREATE DATABASE BANKLOAN_DB;
USE BANKLOAN_DB;
SHOW TABLES;
DESC LOAN_DATA;

alter table loan_data
modify column id int not null primary key;

-- QUESTIONS TO ANSWER 


-- Retrieve Total Loan Applications --
SELECT 
  COUNT(ID) AS Total_Loan_Applications 
FROM 
  LOAN_DATA;


-- Retrieve Month-to-Date (MTD) Total Loan Applications --
SELECT 
  COUNT(ID) AS MTD_Total_Loan_Applications 
FROM 
  LOAN_DATA 
WHERE 
  MONTH(ISSUE_DATE)= '12' 
  AND YEAR(ISSUE_DATE)= 2021;


-- Track Changes Month-over-Month (MoM) In Loan Applications --
select month(issue_date) Month, 
count(id) as Monthwise_Total_Loan_Applications, 
LAG(COUNT(ID)) OVER (ORDER BY MONTH(ISSUE_DATE)) AS Previous_Month_Total_Loan_Applications,
COUNT(ID) - LAG(COUNT(ID)) OVER (ORDER BY MONTH(ISSUE_DATE)) AS MoM_Change
from loan_data
group by month(issue_date)
order by 1;


-- Total Amount of Funds Disbursed as Loans --
SELECT 
  SUM(LOAN_AMOUNT) AS Total_Funded_Amount 
FROM 
  LOAN_DATA;


-- Retrieve Month-to-Date (MTD) Total Funded Amount --
SELECT 
  sum(loan_amount) AS MTD_Total_Funded_Amount
FROM 
  LOAN_DATA 
WHERE 
  MONTH(ISSUE_DATE)= '12' 
  AND YEAR(ISSUE_DATE)= 2021;


-- Track Changes Month-over-Month (MoM) In Total Funded Amount--
select month(issue_date) Month, 
sum(loan_amount) as Monthwise_Total_Funded_Amount, 
LAG(SUM(loan_amount)) OVER (ORDER BY MONTH(ISSUE_DATE)) AS PreviousMonth_TotalLoanFunded,
SUM(loan_amount) - LAG(sum(loan_amount)) OVER (ORDER BY MONTH(ISSUE_DATE)) AS MoM_Change
from loan_data
group by month(issue_date)
order by 1;


-- Total Amount Received From Borrowers --
SELECT 
  SUM(TOTAL_PAYMENT) AS Total_Amount_Recieved 
FROM 
  LOAN_DATA;


-- Month-to-Date (MTD) Total Amount Received --
SELECT 
  sum(TOTAL_PAYMENT) AS MTD_Total_Amount_Recieved
FROM 
  LOAN_DATA 
WHERE 
  MONTH(ISSUE_DATE)= '12' 
  AND YEAR(ISSUE_DATE)= 2021;


-- Track Changes Month-over-Month (MoM) In Total Amount Recieved --
select month(issue_date) Month, 
sum(total_payment) as Monthwise_Total_Amount_Recieved, 
LAG(SUM(total_payment)) OVER (ORDER BY MONTH(ISSUE_DATE)) AS PreviousMonth_TotalAmountRecieved,
SUM(total_payment) - LAG(sum(total_payment)) OVER (ORDER BY MONTH(ISSUE_DATE)) AS MoM_Change
from loan_data
group by month(issue_date)
order by 1;


-- Average Interest Rate --
SELECT 
  AVG(INT_RATE)*100 AS Avg_Int_Rate
FROM 
  LOAN_DATA;


-- MTD Average Interest Rate--
SELECT 
   AVG(INT_RATE) * 100 AS MTD_Avg_Int_Rate
FROM 
   LOAN_DATA 
WHERE  
   MONTH(ISSUE_DATE)='12';


-- Month over Month Average Interest Rate Change--
SELECT MONTH(ISSUE_DATE) AS Month,
AVG(INT_RATE)*100 AS Monthly_Avg_Int_Rate,
LAG(AVG(int_rate)*100) OVER (ORDER BY MONTH(ISSUE_DATE)) AS PreviousMonth_Avg_Int_Rate,
AVG(INT_RATE)*100 - LAG(AVG(int_rate)*100) OVER (ORDER BY MONTH(ISSUE_DATE)) AS MoM_Change
from loan_data
group by Month(issue_date)
ORDER BY 1 ASC;


-- average DTI for borrowers --
SELECT AVG(DTI)* 100 AS Avg_DTI
FROM 
  LOAN_DATA;

-- MTD Average Debt To Income Ratio--
SELECT AVG(DTI)* 100 AS MTD_Avg_DTI
FROM LOAN_DATA
where
month(issue_date)='12' and year(issue_date)='2021';

-- Month over Month Average DTI Change--
SELECT MONTH(ISSUE_DATE) AS Months,
AVG(DTI)*100 AS Monthly_Avg_DTI,
lag(AVG(DTI)*100) OVER (ORDER BY MONTH(ISSUE_DATE)) AS PreviousMonth_Avg_DTI,
AVG(DTI)*100 - lag(AVG(DTI)*100) OVER (ORDER BY MONTH(ISSUE_DATE)) AS PreviousMonth_Avg_DTI
from LOAN_DATA
GROUP BY MONTH(ISSUE_DATE)
ORDER BY 1 ASC;


/*Identifying the total number of loan applications falling under the 'Good Loan' category.
Good Loans are loans with a loan status of 'Fully Paid' and 'Current.*/

SELECT distinct(LOAN_STATUS)
FROM loan_data;

SELECT COUNT(ID) AS Good_Loan_Applications
FROM loan_data 
WHERE loan_status= 'FULLY PAID' 
OR loan_status='CURRENT';

-- calculate the percentage of loan applications classified as Good Loans.

SELECT ROUND((COUNT(ID)*100)/(SELECT COUNT(ID) FROM LOAN_DATA),2) 
AS Good_LoanApplication_Percentage
FROM loan_data 
WHERE loan_status= 'FULLY PAID' 
OR loan_status='CURRENT';

SELECT
    Round((COUNT(CASE WHEN loan_status = 'Fully Paid' OR loan_status = 'Current' THEN id END) * 100.0) / 
	COUNT(id),2) AS Good_Loan_Percentage
FROM loan_data;

-- Total amount of funds disbursed as Good Loans by Bank -- 
 
SELECT SUM(LOAN_AMOUNT) as Good_Loan_Funded_Amount
FROM loan_data
WHERE loan_status= 'FULLY PAID' 
OR loan_status='CURRENT';

-- Total Amount Received from Borrowers for Good Loans -- 

SELECT SUM(TOTAL_PAYMENT) AS Good_Loan_Recieved_Amount
FROM loan_data
WHERE loan_status= 'FULLY PAID' 
OR loan_status='CURRENT';


-/*Identifying the total number of loan applications falling under the 'Bad Loan' category --
Bad Loans are loans with a loan status of Charged Off.*/

SELECT COUNT(ID) Bad_Loan_Applications
FROM loan_data
WHERE loan_status='Charged Off';

-- calculate the percentage of loan applications classified as Bad Loans --

SELECT ROUND(COUNT(ID)*100/ (SELECT COUNT(ID) FROM LOAN_DATA),2)
AS Bad_Loan_Percentage
FROM loan_data
WHERE loan_status='Charged Off';

-- Total amount of funds disbursed as Bad Loans by Bank -- 

SELECT SUM(LOAN_AMOUNT)
AS Bad_Loan_Funded_Amount
FROM LOAN_DATA
WHERE loan_status='Charged Off';

-- Total Amount Received from Borrowers for Bad Loans --

SELECT SUM(TOTAL_PAYMENT) AS Bad_Loan_Recieved_Amount
FROM loan_data
WHERE loan_status='Charged Off';


-- Loan Status Grid View  --

SELECT LOAN_STATUS,
COUNT(ID) AS LoanCount,
SUM(LOAN_AMOUNT) Total_Funded_Amount,
SUM(TOTAL_PAYMENT) AS Total_Amount_Received,
AVG(int_rate)*100 AS Interest_Rate,
AVG(DTI)*100 AS DTI
FROM loan_data
GROUP BY loan_status
ORDER BY LOANCOUNT DESC;


-- Month-to-Date (MTD) Total Amount Received and Total Amount Funded Loan Status wise--

SELECT 
	loan_status, 
	SUM(total_payment) AS MTD_Total_Amount_Received, 
	SUM(loan_amount) AS MTD_Total_Funded_Amount 
FROM loan_data
WHERE MONTH(issue_date) = '12'      
AND YEAR(issue_date)='2021'
GROUP BY loan_status
ORDER BY 2 DESC;

/*using where to filter data for month 12th as if we use having MONTH(issue_date) = 12 after group by 
it will cause error because having find value based on aggrregated group formed but we have 3 rows for 12th month*/ 


-- BANK LOAN REPORT OVERVIEW --

-- CALCULATE MONTH WISE TOTAL APPLICATION RECIEVED, TOTAL FUNDED AMOUNT AND TOTAL RECIEVED AMOUNT BY BANK --

SELECT MONTH(ISSUE_DATE) AS MONTH,
MONTHNAME(ISSUE_DATE) AS Month_name,
COUNT(ID) AS TOTAL_LOAN_APPLICATIONS,
SUM(LOAN_AMOUNT) AS TOTAL_FUNDED_AMOUNT,
SUM(TOTAL_PAYMENT) AS TOTAL_AMOUNT_RECIEVED
FROM loan_data
GROUP BY MONTH(ISSUE_DATE),MONTHNAME(ISSUE_DATE)
ORDER BY MONTH(ISSUE_DATE) ASC;


-- CALCULATE STATEWISE TOTAL APPLICATION RECIEVED, TOTAL FUNDED AMOUNT AND TOTAL RECIEVED AMOUNT BY BANK --

SELECT address_state AS State,
COUNT(ID) AS TOTAL_LOAN_APPLICATIONS,
SUM(LOAN_AMOUNT) AS TOTAL_FUNDED_AMOUNT,
SUM(TOTAL_PAYMENT) AS TOTAL_AMOUNT_RECIEVED
FROM loan_data
GROUP BY address_state
ORDER BY STATE ASC;


-- CALCULATE TERM WISE TOTAL APPLICATION RECIEVED, TOTAL FUNDED AMOUNT AND TOTAL RECIEVED AMOUNT BY BANK --

SELECT TERM,
COUNT(ID) AS TOTAL_LOAN_APPLICATIONS,
SUM(LOAN_AMOUNT) AS TOTAL_FUNDED_AMOUNT,
SUM(TOTAL_PAYMENT) AS TOTAL_AMOUNT_RECIEVED
FROM loan_data
GROUP BY TERM
ORDER BY 1 ASC;


-- CALCULATE  EMPLOYEE LENGTH WISE TOTAL APPLICATION RECIEVED, TOTAL FUNDED AMOUNT AND TOTAL RECIEVED AMOUNT BY BANK --

SELECT emp_length,
COUNT(ID) AS TOTAL_LOAN_APPLICATIONS,
SUM(LOAN_AMOUNT) AS TOTAL_FUNDED_AMOUNT,
SUM(TOTAL_PAYMENT) AS TOTAL_AMOUNT_RECIEVED
FROM loan_data
GROUP BY emp_length
ORDER BY emp_length ASC;


-- CALCULATE  PURPOSE WISE TOTAL APPLICATION RECIEVED, TOTAL FUNDED AMOUNT AND TOTAL RECIEVED AMOUNT BY BANK --

SELECT PURPOSE,
COUNT(ID) AS TOTAL_LOAN_APPLICATIONS,
SUM(LOAN_AMOUNT) AS TOTAL_FUNDED_AMOUNT,
SUM(TOTAL_PAYMENT) AS TOTAL_AMOUNT_RECIEVED
FROM loan_data
GROUP BY purpose
ORDER BY 2;


-- CALCULATE HOME OWNERSHIP  WISE TOTAL APPLICATION RECIEVED, TOTAL FUNDED AMOUNT AND TOTAL RECIEVED AMOUNT BY BANK --

SELECT home_ownership,
COUNT(ID) AS TOTAL_LOAN_APPLICATIONS,
SUM(LOAN_AMOUNT) AS TOTAL_FUNDED_AMOUNT,
SUM(TOTAL_PAYMENT) AS TOTAL_AMOUNT_RECIEVED
FROM loan_data
GROUP BY home_ownership
ORDER BY home_ownership ASC;


-- 

SELECT 
	purpose AS PURPOSE, GRADE,
	COUNT(id) AS Total_Loan_Applications,
	SUM(loan_amount) AS Total_Funded_Amount,
	SUM(total_payment) AS Total_Amount_Received
FROM loan_data
GROUP BY purpose,GRADE
HAVING GRADE='A' 
ORDER BY GRADE,purpose;

