SET search_path to public;

--------------------------------DDL Scripts in public Schemas---------------------------------

CREATE TABLE IF NOT EXISTS "Raw_materials"
(
    "Raw_id" integer NOT NULL,
    "Name" character varying COLLATE pg_catalog."default" NOT NULL,
    "Price" smallint NOT NULL,
    CONSTRAINT "Raw_materials_pkey" PRIMARY KEY ("Raw_id"),
    CONSTRAINT price_check CHECK ("Price" > 0)
)

CREATE TABLE IF NOT EXISTS "Products"
(
    "Product_id" integer NOT NULL,
    "Product_name" character varying COLLATE pg_catalog."default" NOT NULL,
    "Product_price" integer NOT NULL,
    CONSTRAINT "Products_pkey" PRIMARY KEY ("Product_id"),
    CONSTRAINT product_price_check CHECK ("Product_price" > 0)
)

CREATE TABLE IF NOT EXISTS is_used
(
    "Raw_id" integer NOT NULL,
    product_id integer NOT NULL,
    "Quantity" integer NOT NULL,
    CONSTRAINT is_used_pkey PRIMARY KEY ("Raw_id", product_id),
    CONSTRAINT "Raw_id" FOREIGN KEY ("Raw_id")
        REFERENCES "Raw_materials" ("Raw_id") MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT product_id FOREIGN KEY (product_id)
        REFERENCES "Products" ("Product_id") MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE CASCADE
)

CREATE TABLE IF NOT EXISTS "Shift"
(
    "Shift_id" smallint NOT NULL,
    "Start_time" time with time zone NOT NULL,
    "End_time" time with time zone NOT NULL,
    CONSTRAINT "Shift_pkey" PRIMARY KEY ("Shift_id"),
    CONSTRAINT shifts CHECK ("Shift_id" = ANY (ARRAY[1, 2, 3, 4, 5]))
)

CREATE TABLE IF NOT EXISTS "Department"
(
    "Department_id" integer NOT NULL,
    "Department_Name" character varying COLLATE pg_catalog."default" NOT NULL,
    "Salary" integer NOT NULL,
    "Bonus" integer DEFAULT 0,
    CONSTRAINT "Department_pkey" PRIMARY KEY ("Department_id"),
    CONSTRAINT salary CHECK ("Salary" > 0)
)

CREATE TABLE IF NOT EXISTS "Factory_outlet"
(
    "Date" date NOT NULL,
    "Revenue" integer DEFAULT 0,
    CONSTRAINT "Factory_outlet_pkey" PRIMARY KEY ("Date")
)

CREATE TABLE IF NOT EXISTS "Profit/Loss"
(
    "Date" date NOT NULL,
    "Profit" integer DEFAULT 0,
    "Loss" integer DEFAULT 0,
    "Total_amount" integer DEFAULT 0,
    CONSTRAINT "Profit/Loss_pkey" PRIMARY KEY ("Date")
)

CREATE TABLE IF NOT EXISTS "Country"
(
    "Country_Name" character varying COLLATE pg_catalog."default" NOT NULL,
    "Currency" character varying COLLATE pg_catalog."default",
    CONSTRAINT "Country_pkey" PRIMARY KEY ("Country_Name")
)

CREATE TABLE IF NOT EXISTS "Employee"
(
    "Employee_id" integer NOT NULL,
    "Employee_Name" character varying COLLATE pg_catalog."default",
    "Shift_id" integer NOT NULL,
    "Department_id" integer NOT NULL,
    "Address" character varying COLLATE pg_catalog."default",
    "Country_name" character varying COLLATE pg_catalog."default",
    "Qualification" character varying COLLATE pg_catalog."default",
    "DOB" date NOT NULL,
    "Since" character varying NOT NULL,
    CONSTRAINT "Employee_pkey" PRIMARY KEY ("Employee_id"),
    CONSTRAINT "Country" FOREIGN KEY ("Country_name")
        REFERENCES "Country" ("Country_Name") MATCH SIMPLE
        ON UPDATE SET NULL
        ON DELETE SET NULL,
    CONSTRAINT depart FOREIGN KEY ("Department_id")
        REFERENCES "Department" ("Department_id") MATCH SIMPLE
        ON UPDATE SET NULL
        ON DELETE SET NULL,
    CONSTRAINT shifts FOREIGN KEY ("Shift_id")
        REFERENCES "Shift" ("Shift_id") MATCH SIMPLE
        ON UPDATE SET NULL
        ON DELETE SET NULL
)

CREATE TABLE IF NOT EXISTS "Attendance"
(
    "Employee_id" integer NOT NULL,
    "Month" character varying NOT NULL,
    "Leaves" smallint DEFAULT 0,
    "Present" smallint DEFAULT 0,
    "Allowed_leaves" smallint DEFAULT 3,
    "Total_amount" integer DEFAULT 0,
    CONSTRAINT "Attendence_pkey" PRIMARY KEY ("Employee_id", "Month"),
    CONSTRAINT employees FOREIGN KEY ("Employee_id")
        REFERENCES "Employee" ("Employee_id") MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE CASCADE
)

CREATE TABLE IF NOT EXISTS "Vehicle"
(
    "Vehicle_id" integer NOT NULL,
    "Employee_id" integer NOT NULL,
    "Model" character varying COLLATE pg_catalog."default",
    "Capacity" integer NOT NULL,
    "Status" character varying COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT "Vehicle_pkey" PRIMARY KEY ("Vehicle_id"),
    CONSTRAINT driver FOREIGN KEY ("Employee_id")
        REFERENCES "Employee" ("Employee_id") MATCH SIMPLE
        ON UPDATE SET NULL
        ON DELETE SET NULL,
    CONSTRAINT status_check CHECK ("Status"::text = ANY (ARRAY['available'::character varying, 'busy'::character varying, 'maintainence'::character varying]::text[]))
)

CREATE TABLE IF NOT EXISTS "Buyers"
(
    "Buyers_id" integer NOT NULL,
    "Buyer_name" character varying COLLATE pg_catalog."default",
    "Store_name" character varying COLLATE pg_catalog."default" NOT NULL,
    "Store_address" character varying COLLATE pg_catalog."default" NOT NULL,
    "Country_name" character varying COLLATE pg_catalog."default" NOT NULL,
    "Points" integer DEFAULT 0,
    CONSTRAINT "Buyers_pkey" PRIMARY KEY ("Buyers_id"),
    CONSTRAINT lives_in FOREIGN KEY ("Country_name")
        REFERENCES "Country" ("Country_Name") MATCH SIMPLE
        ON UPDATE SET NULL
        ON DELETE SET NULL,
    CONSTRAINT non_negative CHECK ("Points" > 0)
)

CREATE TABLE IF NOT EXISTS "Insurance"
(
    "Month" character varying NOT NULL,
    "Employee_id" integer NOT NULL,
    "Amount" bigint NOT NULL DEFAULT 0,
    "Reason" character varying COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT "Insurance_pkey" PRIMARY KEY ("Month", "Employee_id"),
    CONSTRAINT employee FOREIGN KEY ("Employee_id")
        REFERENCES "Employee" ("Employee_id") MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE CASCADE
)

CREATE TABLE IF NOT EXISTS "Cold_warehouse"
(
    date date NOT NULL,
    "Product_id" integer NOT NULL,
    shift_id integer NOT NULL,
    buyer_id integer NOT NULL,
    vehicle_number integer NOT NULL,
    CONSTRAINT "Cold_warehouse_pkey" PRIMARY KEY (date, "Product_id", shift_id, buyer_id, vehicle_number),
    CONSTRAINT "Buyer" FOREIGN KEY (buyer_id)
        REFERENCES "Buyers" ("Buyers_id") MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT product FOREIGN KEY ("Product_id")
        REFERENCES "Products" ("Product_id") MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT shift FOREIGN KEY (shift_id)
        REFERENCES "Shift" ("Shift_id") MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT vehicle FOREIGN KEY (vehicle_number)
        REFERENCES "Vehicle" ("Vehicle_id") MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE CASCADE
)

CREATE TABLE IF NOT EXISTS "Machine"
(
    "Machine_id" integer NOT NULL,
    "Machine_name" character varying COLLATE pg_catalog."default",
    department_id integer NOT NULL,
    rpm integer NOT NULL,
    total_workig_hours integer NOT NULL,
    "Last_serviced" date NOT NULL,
    CONSTRAINT "Machine_pkey" PRIMARY KEY ("Machine_id"),
    CONSTRAINT dep FOREIGN KEY (department_id)
        REFERENCES "Department" ("Department_id") MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE CASCADE
)

CREATE TABLE IF NOT EXISTS produced_by
(
    product_id integer NOT NULL,
    machine_id integer NOT NULL,
    working_time smallint NOT NULL,
    CONSTRAINT produced_by_pkey PRIMARY KEY (product_id, machine_id),
    CONSTRAINT mac FOREIGN KEY (machine_id)
        REFERENCES "Machine" ("Machine_id") MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT prod FOREIGN KEY (product_id)
        REFERENCES "Products" ("Product_id") MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE CASCADE
)

CREATE TABLE IF NOT EXISTS produces
(
    product_id integer NOT NULL,
    date date NOT NULL,
    shift_id smallint NOT NULL,
    accepted_quanity integer NOT NULL,
    rejected_quantity smallint DEFAULT 0,
    CONSTRAINT produces_pkey PRIMARY KEY (product_id, date, shift_id),
    CONSTRAINT pro FOREIGN KEY (product_id)
        REFERENCES "Products" ("Product_id") MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT shift FOREIGN KEY (shift_id)
        REFERENCES "Shift" ("Shift_id") MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE CASCADE
)

CREATE TABLE IF NOT EXISTS "Ad_impact"
(
    "Date" date NOT NULL,
    "Product_id" integer NOT NULL,
    "Prev_Month_Sale" integer DEFAULT 0,
    "Curr_Month_Sale" integer DEFAULT 0,
    CONSTRAINT "Ad_impact_pkey" PRIMARY KEY ("Date", "Product_id"),
    CONSTRAINT pr FOREIGN KEY ("Product_id")
        REFERENCES "Products" ("Product_id") MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE CASCADE
)

CREATE TABLE IF NOT EXISTS "Orders&Delivery"
(
    "Vechile_number" integer NOT NULL,
    "Buyer_id" integer NOT NULL,
    "Product_id" integer NOT NULL,
    "Date" date NOT NULL,
    "Quantity" integer NOT NULL,
    "Payment_status" character varying COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT "Orders&Delivery_pkey" PRIMARY KEY ("Vechile_number", "Buyer_id", "Product_id", "Date"),
    CONSTRAINT buy FOREIGN KEY ("Buyer_id")
        REFERENCES "Buyers" ("Buyers_id") MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT prods FOREIGN KEY ("Product_id")
        REFERENCES "Products" ("Product_id") MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT vech FOREIGN KEY ("Vechile_number")
        REFERENCES "Vehicle" ("Vehicle_id") MATCH SIMPLE
        ON UPDATE SET NULL
        ON DELETE SET NULL,
    CONSTRAINT pay_check CHECK ("Payment_status"::text = ANY (ARRAY['Paid'::character varying, 'Unpaid'::character varying]::text[]))
)

CREATE TABLE IF NOT EXISTS "Mobile_Number"
(
    "Mobile_no" bigint NOT NULL,
    "Employee_id" integer NOT NULL,
    CONSTRAINT "Mobile_Number_pkey" PRIMARY KEY ("Employee_id", "Mobile_no"),
    CONSTRAINT "Employee" FOREIGN KEY ("Employee_id")
        REFERENCES "Employee" ("Employee_id") MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT "check" CHECK ("Mobile_no" >= 1000000000 AND "Mobile_no" <= '9999999999'::bigint)
)

----------------------------------------Loading Data----------------------------------------

COPY "Raw_materials"("Raw_id","Name","Price") 
FROM 'D:\SEMESTER V\DBMS\Project_Table\Raw_materials.csv' 
DELIMITER ',' CSV HEADER;

Select * from "Raw_materials";


COPY "Products"("Product_id","Product_name","Product_price") 
FROM 'D:\SEMESTER V\DBMS\Project_Table\Product.csv' 
DELIMITER ',' CSV HEADER;

Select * from "Products";


COPY is_used("product_id","Raw_id","Quantity") 
FROM 'D:\SEMESTER V\DBMS\Project_Table\is_used.csv' 
DELIMITER ',' CSV HEADER;

Select * from is_used;

COPY "Department"("Department_id","Department_Name","Salary","Bonus") 
FROM 'D:\SEMESTER V\DBMS\Project_Table\Department.csv' 
DELIMITER ',' CSV HEADER;

Select * from "Department";

COPY "Factory_outlet"("Date","Revenue") 
FROM 'D:\SEMESTER V\DBMS\Project_Table\Factory_outlet.csv' 
DELIMITER ',' CSV HEADER;

Select * from "Factory_outlet";

COPY "Profit/Loss"("Date","Profit","Loss","Total_amount") 
FROM 'D:\SEMESTER V\DBMS\Project_Table\Profit_Loss.csv' 
DELIMITER ',' CSV HEADER;

Select * from "Profit/Loss";


COPY "Country"("Country_Name","Currency") 
FROM 'D:\SEMESTER V\DBMS\Project_Table\Country.csv' 
DELIMITER ',' CSV HEADER;

Select * from "Country";

COPY "Shift"("Shift_id","Start_time","End_time") 
FROM 'D:\SEMESTER V\DBMS\Project_Table\Shift.csv' 
DELIMITER ',' CSV HEADER;

Select * from "Shift";

COPY "Employee"("Employee_id","Employee_Name","Shift_id","Department_id","Address","Country_name","Qualification","DOB","Since") 
FROM 'D:\SEMESTER V\DBMS\Project_Table\Employee.csv' 
DELIMITER ',' CSV HEADER;

Select * from "Employee";

COPY "Attendance"("Employee_id","Month","Leaves","Present","Allowed_leaves","Total_amount") 
FROM 'D:\SEMESTER V\DBMS\Project_Table\Attendance.csv' 
DELIMITER ',' CSV HEADER;

Select * from "Attendance";

COPY "Vehicle"("Vehicle_id","Employee_id","Model","Capacity","Status") 
FROM 'D:\SEMESTER V\DBMS\Project_Table\Vehicle.csv' 
DELIMITER ',' CSV HEADER;

Select * from "Vehicle";

COPY "Insurance"("Month","Employee_id","Amount","Reason")
FROM 'D:\SEMESTER V\DBMS\Project_Table\Insurance.csv' 
DELIMITER ',' CSV HEADER;

Select * from "Insurance";

COPY "Buyers"("Buyers_id","Buyer_name","Store_name","Store_address","Country_name","Points")
FROM 'D:\SEMESTER V\DBMS\Project_Table\Buyers.csv' 
DELIMITER ',' CSV HEADER;

Select * from "Buyers";

COPY "Cold_warehouse"(date,"Product_id",shift_id,buyer_id,vehicle_number)
FROM 'D:\SEMESTER V\DBMS\Project_Table\Cold_warehouse.csv' 
DELIMITER ',' CSV HEADER;

Select * from "Cold_warehouse";

COPY "Machine"("Machine_id","Machine_name",department_id,rpm,total_workig_hours,"Last_serviced")
FROM 'D:\SEMESTER V\DBMS\Project_Table\Machine.csv' 
DELIMITER ',' CSV HEADER;

Select * from "Machine";

COPY produced_by(product_id,machine_id,working_time)
FROM 'D:\SEMESTER V\DBMS\Project_Table\Produced_by.csv' 
DELIMITER ',' CSV HEADER;

Select * from produced_by;


COPY produces(product_id,date,shift_id,accepted_quanity,rejected_quantity)
FROM 'D:\SEMESTER V\DBMS\Project_Table\Produces.csv' 
DELIMITER ',' CSV HEADER;

Select * from produces;

COPY "Ad_impact"("Date","Product_id","Prev_Month_Sale","Curr_Month_Sale")
FROM 'D:\SEMESTER V\DBMS\Project_Table\Ad_impact.csv' 
DELIMITER ',' CSV HEADER;

Select * from "Ad_impact";

COPY "Orders&Delivery"("Vechile_number","Buyer_id","Product_id","Date","Quantity","Payment_status")
FROM 'D:\SEMESTER V\DBMS\Project_Table\Orders&Delivery.csv' 
DELIMITER ',' CSV HEADER;

Select * from "Orders&Delivery";

COPY "Mobile_Number"("Mobile_no","Employee_id")
FROM 'D:\SEMESTER V\DBMS\Project_Table\Mobile_no.csv' 
DELIMITER ',' CSV HEADER;

Select * from "Mobile_Number";
