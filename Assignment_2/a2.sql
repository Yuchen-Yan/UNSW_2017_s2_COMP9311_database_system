--Comp9311 Assignment 2
--Name:Yuchen Yan
--zID:z5146418

--Q1-List all the company names and countries that are incorporated outside Australia.
create or replace view Q1(Name, Country) 
as
select Name, Country
From Company
--country is not Australia
where Country<>'Australia'
;





--Q2-List all the company codes that have more than five executive members on record 
create or replace view Q2(Code)
as
select Code
from Executive 
group by Code
--number of person bigger than 5
having count(Person)>5
;





--Q3-List all the company names that are in the sector of "Technology"
create or replace view Q3(Name)
as 
select c.Name 
from Category g join Company c on (g.Code = c.Code)
--Sector is technology
where g.Sector = 'Technology'
;





--Q4-Find the number of Industries in each Sector
create or replace view Q4(Sector, "Number")
as
--Group the sector, find the number of industry
select Sector, count(Industry)
from Category
group by Sector
;





--Q5-Find all the executives that are affiliated with companies in the sector of "Technology". If an executive is affiliated with more than one company, he/she is counted if one of these companies is in the sector of "Technology".
create or replace view Q5(Name)
as
select distinct e.Person
from Executive e join Category c on (e.Code = c.Code)
--sector is technology
where c.Sector = 'Technology'
;





--Q6-List all the company names in the sector of "Services" that are located in Australia with the first digit of their zip code being 2.
create or replace view Q6(Name)
as
select c.Name
from Company c join Category g on (c.Code = g.Code)
--Sector is servises country is Australia and zip bagin with 2
where g.Sector = 'Services' AND c.Country = 'Australia' AND c.Zip ~ '^2'
;





--Very important one, will be used several times
--Q7-Create a database view of the ASX table that contains previous Price, Price change (in amount, can be negative) and Price gain
create or replace view Q7("Date", Code, Volume, PrePrice, Price, Change, Gain)
as
--Create two temporary views, one comtain the price, and another comtain the previous price
with currentPrice as (select "Date", Code, Volume, Price from ASX),
	prePrice  as (select "Date", Code, lag(Price) over (partition by Code order by "Date") as prePrice 
		      from ASX)
--Select the preprice and other information from the virtual views
select currentPrice."Date", currentPrice.Code, currentPrice.Volume, prePrice.prePrice, currentPrice.Price, currentPrice.Price-prePrice.prePrice, (currentPrice.Price-prePrice.prePrice)/prePrice.prePrice*100
from currentPrice, prePrice
where currentPrice.Code = prePrice.Code and currentPrice."Date" = prePrice."Date" and prePrice."Date" <> (select min("Date") from ASX)
; 





--Q8-Find the most active trading stock on every trading day.
create or replace view Q8("Date", Code, Volume)
as
--Open a temporary view find the maximum volume
with maxV as (select "Date",max(Volume) as Volume from ASX group by "Date" order by "Date")
--Select the volume and date and code from the virtual view 
select m."Date", a.Code, m.Volume
from ASX a, maxV m 
where a."Date" = m."Date" and a.Volume = m.volume
order by "Date" , Code
;





--Q9-Find the number of companies per Industry. Order your result by Sector and then by Industry.
create or replace view Q9(Sector, Industry, Number)
as
--Create a temporate view 
with industryCompany as (select Industry, count(Code) as Number from Category group by Industry)
--Select the number of companies per industry
select distinct c.Sector, i.Industry, i.Number
from industryCompany i, Category c 
where i.Industry = c.Industry 
order by c.Sector, i.Industry
;





--Q10-List all the companies (by their Code) that are the only one in their Industry (i.e., no competitors).
create or replace view Q10(Code, Industry)
as
select Code, Industry
from Category
--Find the industry have only one company
where Industry in (select Industry 
      	       	   from Category 
		   group by Industry 
		   having count(Code) = 1)
;





--Q11-List all sectors ranked by their average ratings in descending order. AvgRating is calculated by finding the average AvgCompanyRating for each sector
create or replace view Q11(Sector, AvgRating)
as
--Select the avg rating
select c.Sector, avg(Star)
from Category c, Rating r
where c.Code = r.Code
group by c.Sector 
--Rank by average rating
order by avg(Star) desc
;





--Q12-Output the person names of the executives that are affiliated with more than one company.
create or replace view Q12(Name)
as
--Group by person to find the person attach to more than one company
select Person
from Executive 
group by Person
having count(Code)>1
;





--Q13-Find all the companies with a registered address in Australia, in a Sector where there are no overseas companies in the same Sector.
create or replace view Q13(Code, Name, Address, Zip, Sector)
as
--Select the proper information of proper companys 
select c.Code, c.Name, c.Address, c.Zip, g.Sector
from Company c join Category g on (c.Code = g.Code)
--No country can contain the company outside australia
where g.Sector not in (select g1.Sector 
      	  	       from Company c1 join Category g1 on (c1.Code = g1.Code)
		       where c1.Country <> 'Australia')
;





--Q14-Calculate stock gains based on their prices of the first trading day and last trading day 
create or replace view Q14(Code, BeginPrice, EndPrice,Change,Gain)
as
--Create four temporate views.
--B find the earlest date of all company,BP find the price of the earlest date
--E find the lastest date of all company,EP find the price of the lastest date
with B as (select Code, min("Date") as BeginDate from ASX group by Code),
     BP as (select b.Code, a.Price from B b, ASX a where b.Code = a.Code and b.BeginDate = a."Date"),
     E as (select Code, max("Date") as EndDate from ASX group by Code),
     EP as (select e.Code, a.Price from E e, ASX a where e.Code = a.Code and e.EndDate = a."Date")
--Combine the Bp and EP views, to find the stock gains
select b.Code, b.Price, e.Price, e.Price-b.Price,(e.Price-b.Price)/b.Price*100 
from BP b, EP e
where b.Code = e.Code
order by (e.Price-b.Price)/b.Price*100 DESC, Code ASC
;





--Q15-For all the trading records in the ASX table, produce the following statistics as a database view (where Gain is measured in percentage). AvgDayGain is defined as the summation of all the daily gains (in percentage) then divided by the number of trading days
create or replace view Q15(Code, MinPrice, AvgPrice, MaxPrice, MinDayGain, AvgDayGain, MaxDayGain)
as
--Create two temporate view. 
--One contains the max, min, avg gain. Another contains max, min, avg price
with DG as (select Code, Min(Gain) as MinDayGain, Avg(Gain) as AvgDayGain, Max(Gain) as MaxDayGain  from Q7 group by Code),
     P  as (select Code, Min(Price) as MinPrice, Avg(Price) as AvgPrice, Max(Price) as MaxPrice from ASX group by Code)
--Combine the two views
select d.Code, p.MinPrice, p.AvgPrice, p.MaxPrice, d.MinDayGain, d.AvgDayGain, d.MaxDayGain
from DG d, P p
where d.Code = p.Code
;




 
--16-Create a trigger on the Executive table, to check and disallow any insert or update of a Person in the Executive table to be an executive of more than one company. 
create function q16() returns trigger as 
$$
begin
--Select the person if the person inserted already inside the table
select * from Executicve where Person = new.Person;
--If the person already execute some company return old
if (found) then
   return old;
end if;
   return new;
end;
$$ language plpgsql;
--Create trigger for above function
create trigger Q16 before insert or update
on Executive for each row execute procedure q16();





--17-Create a trigger to increase the stock's rating (as Star's) to 5 when the stock has made a maximum daily price gain.Otherwise, decrease the stock's rating to 1 when the stock has performed the worst in the sector in terms of daily percentage price gain. 
create function q17() returns trigger as
$$
--Declare for three useful variables.
declare
maxgain numeric;
mingain numeric;
newgain numeric;
begin
--Calculate the min gain base on the sector and date insert
mingain := (select min(gain)
	    from Q7 q join Category c on(q.Code = c.Code)
	    where q.Date = new.Date and c.Sector = (select Sector
	    	  	   	    		    from Category 
						    where Code = new.Code));
--Calculate the max gain base on the sector and date insert 
maxgain := (select max(gain)
            from Q7 q join Category c on(q.Code = c.Code)
            where q.Date = new.Date and c.Sector = (select Sector
                                                    from Category
                                                    where Code = new.Code));
--Calculate the gain insert by user
newgain := (select gain from Q7 where new.Date = Q7.Date and new.Code = Q7.Code);
--Update all the rating of the company, which reach the maximum gain
if (newgain >= maxgain) then
   update Rating
   set Star = 5
   where Code in (select Code from Q7 where gain = newgain);
--Update all the rating of the company, which reach the minimum gain 
elsif (newgain <= mingain) then 
   update Rating
   set Star = 1
   where Code in (select Code from Q7 where gain = newgain);
end if;
end;
$$ language plpgsql;
--Create the trigger base on above function
create trigger Q17 after insert
on ASX for each row execute procedure q17();



  

--18-Create a trigger to log any updates on Price and/or Voume in the ASX table and log these updates (only for update, not inserts) into the ASXLog table. 
create function q18() returns trigger
as
$$
begin
--Check if the insert date and code is equal to the old one
if (new.Code != old.Code or new."Date" != old."Date") then
--If the value is not equal to the old one, then do reject the update   
     return old;
else
--Insert into ASXLog table the value updated                                   
     insert into ASXLog("Date", Code, OldVolume, OldPrice)
     values(new."Date" ,new.Code ,new.Volume,new.Price);
     return new;
end if;
end;
$$ language plpgsql;
--Create the trigger base on above function
create trigger Q18 before update
on ASX for each row execute procedure q18();







