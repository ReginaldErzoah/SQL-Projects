--EXPLORING CLIENTS DEMOGRAPHICS & DATA SUMMARY
-- Average Balance per Marital Status of Clients

SELECT marital,AVG(CAST(balance AS float)) AS average_balance
FROM BankTargeting.dbo.Target
GROUP BY marital

-- Clients per Deposit Status

SELECT deposit, COUNT(*) AS count
FROM BankTargeting.dbo.Target
GROUP BY deposit

-- SEGMENTATION
--Segmenting Clients per Age Groups

SELECT
CASE 
	WHEN age < 30 THEN 'Young'
	WHEN age BETWEEN 30 AND 50 THEN 'Middle-aged'
	ELSE 'Elderly'
END AS Age_Group,COUNT(*) as Count
FROM BankTargeting.dbo.Target
GROUP BY
CASE
	WHEN age < 30 THEN 'Young'
	WHEN age BETWEEN 30 AND 50 THEN 'Middle-aged'
	ELSE 'Elderly'
END;

-- Segementing Clients by Job 

SELECT job, COUNT(*) AS Count
FROM BankTargeting.dbo.Target
GROUP BY job


--Binary Target Test Based on Whether Client Made Deposit or Not.

SELECT *,
CASE
	WHEN deposit='yes' THEN 1
	ELSE 0
END AS target
INTO BankTargeting.dbo.Target_with_target
FROM BankTargeting.dbo.Target

--View the Newly-Created Table (Target_with_target)

SELECT * 
FROM BankTargeting.dbo.Target_with_target



