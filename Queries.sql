SET SEARCH_PATH TO factory_db;

-----------------------------------------------------SQL Queries--------------------------------------------------------

SET SEARCH_PATH TO factory_db;

--1
Select * from factory_db."Employee" where "Qualification"='MSc';

--2
Select * from factory_db."Department" where "Salary">=25000;

--3
Select "Buyer_id" from factory_db."Orders&Delivery" where "Payment_status"='Unpaid';

--4
Select "Date" from factory_db."Ad_impact" where "Curr_Month_Sale" > "Prev_Month_Sale";

--5
SELECT "Employee_id" FROM factory_db."Insurance" WHERE "Reason"='Sick';

--6
Select * From factory_db."Employee" Where since<2012;

--7
Select "Product_name" From factory_db."Products";

--8
Select "Date" From factory_db."Profit/Loss" WHERE "Loss"> "Profit";

--9
Select "Vehicle_id" From factory_db."Vehicle" WHERE "Status"='available' ;

--10
Select "Employee_id" From factory_db."Employee" WHERE "Country_name" <> 'INDIA' ;

--11
Select "Employee"."Employee_id","Department"."Salary"
From factory_db."Employee" NATURAL JOIN factory_db."Department" ;

--12
Select "Mobile_Number"."Employee_id",COUNT("Mobile_no") From factory_db."Mobile_Number" 
GROUP BY "Mobile_Number"."Employee_id";

--13
Select "Employee"."Employee_id",SUM("Attendence"."Leaves") 
From factory_db."Employee" NATURAL JOIN factory_db."Attendence" 
GROUP BY "Employee"."Employee_id";

--14
Select "Products"."Product_name","produced_by"."machine_id" 
From factory_db."Products" NATURAL JOIN factory_db."produced_by"; 

--15
Select "Employee"."Employee_Name"
From factory_db."Employee" NATURAL JOIN factory_db."Insurance"
WHERE "Insurance"."Amount">20000; 

--16
SELECT * 
FROM factory_db."Shift" as t2 NATURAL JOIN 
(Select "Employee"."Shift_id" as Shift_id,COUNT("Employee_id") as Employee_count
From factory_db."Employee"
GROUP BY "Employee"."Shift_id"
ORDER BY "Employee"."Shift_id" ASC) as t1 
WHERE t1.Shift_id=t2."Shift_id";

--17
SELECT t2."Department_id",t1.Employee_count 
FROM factory_db."Department" as t2 NATURAL JOIN 
(Select "Employee"."Department_id" as Department_id,COUNT("Employee_id") as Employee_count
From factory_db."Employee"
GROUP BY "Employee"."Department_id"
ORDER BY "Employee"."Department_id" ASC) as t1 
WHERE t1.Department_id=t2."Department_id" AND t2."Salary">=30000


--18
Select DISTINCT(t1."Store_name", t1."Store_address") 
from factory_db."Buyers" as t1 natural join factory_db."Orders&Delivery" as t2
where t2."Payment_status"='Unpaid';

--19
Select DISTINCT(t1."Employee_Name") as driver
from factory_db."Employee" as t1 natural join factory_db."Vehicle" as t2
where t2."Status"='maintainence';

--20
SELECT t1."Buyer_name","Orders&Delivery"."Product_id", "Orders&Delivery"."Quantity"
FROM (factory_db."Orders&Delivery" NATURAL JOIN factory_db."Buyers" as t1);




---------------------------------------------function 1-------------------------------------
CREATE OR REPLACE FUNCTION Total_revenue()
RETURNS TABLE(d date, total_revenue int)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
RETURN QUERY EXECUTE format 
('SELECT "Factory_outlet"."Date","Profit/Loss"."Total_amount"+"Factory_outlet"."Revenue" 
 FROM factory_db."Factory_outlet" NATURAL JOIN factory_db."Profit/Loss";');
END;
$BODY$;

SELECT factory_db.total_revenue();


-------------------------------------------------function-2---------------------------------
CREATE OR REPLACE FUNCTION net_salary()
RETURNS TABLE (Employee_id int, Salary int)
LANGUAGE 'plpgsql'
AS $BODY$
DECLARE R RECORD;
BEGIN
CREATE TEMP TABLE t1(Employee_id int, salary int) ON COMMIT DROP;
FOR R IN (SELECT "Attendence"."Employee_id","Attendence"."Leaves", "Attendence"."Allowed_leaves", "Attendence"."Total_amount" FROM factory_db."Attendence")
loop
if(R."Leaves">R."Allowed_leaves") then
INSERT INTO t1(Employee_id, salary) VALUES (R."Employee_id", R."Total_amount"-((R."Leaves"-R."Allowed_leaves")*(R."Total_amount")/30));
else INSERT INTO t1(Employee_id, salary) VALUES (R."Employee_id", R."Total_amount");
end if;
end loop;
RETURN QUERY TABLE t1;
END;
$BODY$;

SELECT factory_db.net_salary();


------------------------------------------trigger func--------------------------------------
BEGIN
UPDATE factory_db."Buyers"
SET "Buyers"."Points"="Buyers"."Points"+(new."Quantity"/1000)*5
WHERE "Buyers"."Buyers_id"=New."Buyer_id";
return new;
END

SELECT "Buyers"."Buyers_id", "Buyers"."Points" From factory_db."Buyers"
WHERE "Buyers"."Buyers_id"=1;
insert into factory_db."Orders&Delivery" values(1,1,50,'2022-03-05',2000,'Paid');
