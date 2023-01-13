#Create PERSON table
CREATE TABLE PERSON ( 
person_id INT NOT NULL, 
first_name VARCHAR(100), 
preferred_first_name VARCHAR(100), 
last_name VARCHAR(100) NOT NULL, 
date_of_birth DATE, 
hire_date DATE, 
occupation VARCHAR(1), 
PRIMARY KEY (person_id) 
);

#Create ADDRESS table
CREATE TABLE ADDRESS ( 
address_id INT NOT NULL, 
person_id INT NOT NULL, 
address_type VARCHAR(4) NOT NULL, 
street_line_1 VARCHAR(100), 
city VARCHAR(100), 
state VARCHAR(100), 
zip_code VARCHAR(30), 
PRIMARY KEY (address_id), 
FOREIGN KEY (person_id) 
REFERENCES PERSON(person_id) 
);

/*
1) Write a query to select all rows from person. If the person row has a value in preferred_first_name, select the
preferred name instead of the value in first name. Alias the column as REPORTING_NAME.
*/
SELECT person_id, IFNULL(preferred_first_name, first_name) 
AS REPORTING_NAME, last_name, date_of_birth, hire_date, occupation 
FROM PERSON ORDER BY person_id;

/*
2) Write a query to select all rows from person that have a NULL occupation.
*/
SELECT person_id, first_name, preferred_first_name, last_name, date_of_birth, hire_date 
FROM PERSON 
WHERE occupation = NULL;

/*
3) Write a query to select all rows from person that have a date_of_birth before August 7th, 1990.
*/
SELECT person_id, first_name, preferred_first_name, last_name, date_of_birth, hire_date, occupation 
FROM PERSON 
WHERE date_of_birth < '1990-08-07';

/*
4) Write a query to select all rows from person that have a hire_date in the past 100 days.
*/
SELECT person_id, first_name, preferred_first_name, last_name, date_of_birth, hire_date, occupation 
FROM PERSON 
WHERE hire_date >= DATE_SUB(NOW(), INTERVAL 100 DAY);

/*
5) Write a query to select rows from person that also have a row in address with address_type = 'HOME'.
*/
SELECT p.person_id, p.first_name, p.preferred_first_name, p.last_name, p.date_of_birth, p.hire_date, p.occupation 
FROM PERSON p INNER JOIN ADDRESS a ON p.person_id = a.person_id 
WHERE a.address_type = 'HOME';

/*
6) Write a query to select all rows from person and only those rows from address that have a matching billing address
(address_type = 'BILL'). If a matching billing address does not exist, display 'NONE' in the address_type column.
*/
SELECT p.person_id, p.first_name, p.preferred_first_name, p.last_name, p.date_of_birth, p.hire_date, p.occupation, COALESCE(a.address_type, 'NONE') 
AS address_type, a.street_line_1, a.city, a.state, a.zip_code 
FROM PERSON p LEFT JOIN ADDRESS a ON p.person_id = a.person_id AND a.address_type = 'BILL';

/*
7) Write a query to count the number of addresses per address type.
	Output:
	address_type count
	------------- ------
	HOME 			  99
	BILL 			 150
*/
SELECT address_type, COUNT(*) AS count FROM ADDRESS GROUP BY address_type ORDER BY count DESC;

/*
8) Write a query to select data in the following format:
	last_name home_address billing_address
	------------------ 		------------------------------------ 		---------------------------------------
	Smith 					89 Lyon Circle, Clifton, VA 12345 			25 Science Park, New Haven, CT 06511
	Jones 					212 Maple Ave, Manassas, VA 22033 			275 Winchester Ave, New Haven, CT 06511
*/
SELECT p.last_name, MAX(CASE WHEN ha.address_type = 'HOME' THEN ha.street_line_1 ELSE 
NULL END) AS home_address, 
MAX(CASE WHEN ba.address_type = 'BILL' THEN ba.street_line_1 ELSE 
NULL END) AS billing_address 
FROM person p 
LEFT JOIN ADDRESS ha ON p.person_id = ha.person_id AND ha.address_type = 'HOME' 
LEFT JOIN ADDRESS ba ON p.person_id = ba.person_id AND ba.address_type = 'BILL' 
GROUP BY p.last_name;

/*
9) Write a query to update the person.occupation column to ‘X’ for all rows that have a ‘BILL’ address in the address table.
*/
UPDATE person p 
SET p.occupation = 'X' 
WHERE EXISTS 
    (SELECT 1 FROM address a 
    WHERE a.person_id = p.person_id AND a.address_type = 'BILL');

