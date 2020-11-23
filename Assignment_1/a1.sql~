-- COMP9311 17s2 Assignment 1
-- Schema for OzCars
--
-- Date: 16/08/2017 
-- Student Name:Yuchen Yan 
-- Student ID:Z5146418 
--

-- Some useful domains; you can define more if needed.

create domain URLType as
	varchar(100) check (value like 'http://%');

create domain EmailType as
	varchar(100) check (value like '%@%.%');

create domain PhoneType as
	char(10) check (value ~ '[0-9]{10}');


-- EMPLOYEE

create table Employee(
	EID  serial NOT NULL, 
    	firstname varchar(50) NOT NULL,
	lastname varchar(50) NOT NULL,
	TFN char(9) NOT NULL check(TFN ~'[0-9]{9}'),
        salary integer not null check (salary > 0),
	primary key (EID)
);

create table "Admin"(
       EID integer not null references Employee(EID),
       primary key(EID)

);

create table Mechanic(
       EID integer NOT NULL references Employee(EID),
       license char(8) NOT NULL check(license ~'[0-9a-zA-Z]{8}'),
       primary key(EID)
);


create table Salesman(
       EID integer NOT NULL references Employee(EID),
       commRate integer NOT NULL CHECK(5 <= commRate and commRate <= 20),
       primary key (EID)
);



--Client

create table Client(
       CID serial NOT NULL,
       "name" varchar(100) NOT NULL,
       address varchar(200) NOT NULL,
       phone char(10) not null check (phone ~ '[0-9]{10}'),
       email EmailType,
       primary key(CID)
);

create table Company(
       CID integer not null references Client(CID),
       ABN char(11) not null check (ABN ~ '[0-9]{11}'),
       url URLType not null,
       primary key(CID)
);




-- CAR

create domain CarLicenseType as
        varchar(6) check (value ~ '[0-9A-Za-z]{1,6}');

create domain OptionType as varchar(12)
	check (value in ('sunroof','moonroof','GPS','alloy wheels','leather'));

create domain VINType as char(17) check(value ~ '[0-9a-hj-np-pr-zA-HJ-NP-PR-Z]{17}'); 







create table Car(
       VIN VINType not null,
       "year" integer not null check(1970 <= year and year <= 2099),
       model varchar(40) not null,
       manufacturer varchar(40) not null,
       primary key(VIN)
);

create table CarOptions(
       car VINType not null references Car(VIN),
       "options" OptionType,
       primary key(car)
);

create table NewCar(
       VIN VINType not null references Car(VIN),
       cost numeric(8,2) not null,
       charges numeric(8,2) not null,
       primary key(VIN)       
);


create table UsedCar(
       VIN VINType not null references Car(VIN),
       plateNumber CarLicenseType not null,
       primary key (VIN)
);















--Buy
create table Buys(
       Salesman integer not null,
       Client integer not null,
       UsedCar VINType not null,  
       
       price numeric(8,2) not null,
       "date" date not null,
       commission numeric(8,2) not null,
       foreign key(Salesman) references Employee(EID),
       foreign key(Client) references Client(CID), 
       foreign key(UsedCar)references UsedCar(VIN),
       primary key("date", UsedCar)
);



--Sell
create table Sells(
       Salesman integer not null,
       Client integer not null,
       UsedCar VINType not null,
    
       "date" date not null,
       price numeric(8,2) not null,
       commission numeric(8,2) not null,
       primary key("date", UsedCar),
       foreign key(Salesman) references Employee(EID),
       foreign key(Client) references Client(CID),
       foreign key(UsedCar) references UsedCar(VIN)

);

create table SellsNew(
       Salesman integer not null,
       Client integer not null,
       NewCar VINType not null,

       "date" date not null,
       price numeric(8,2) not null,
       commission numeric(8,2) not null,
       plateNumber CarLicenseType not null,
       foreign key(Salesman) references Employee(EID), 
       foreign key(Client) references Client(CID), 
       foreign key(NewCar) references NewCar(VIN),
       primary key("date", NewCar)
);




--Repairs


create table RepairJob(
       Client integer not null,
       UsedCar VINType not null,

       "number" integer not null check(1 <= number and number <= 999),
       description varchar(250) not null,
       "work" numeric(8,2) not null,
       parts numeric(8,2) not null,
       "date" date not null,
       primary key("number"),
       foreign key(Client) references Client(CID),
       foreign key(UsedCar) references UsedCar(VIN)
);




create table Does(
       Mechanic integer not null,
       RepairJob integer not null,
       primary key(Mechanic, RepairJob),
       foreign key(Mechanic) references Mechanic(EID),
       foreign key(RepairJob) references RepairJob("number")

);











