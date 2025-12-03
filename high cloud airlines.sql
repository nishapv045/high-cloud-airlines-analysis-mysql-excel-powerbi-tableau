/*1) "1.calcuate the following fields from the Year	Month (#)	Day  fields ( First Create a Date Field from Year , Month , Day fields)"
   A.Year
   B.Monthno
   C.Monthfullname
   D.Quarter(Q1,Q2,Q3,Q4)
   E. YearMonth ( YYYY-MMM)
   F. Weekdayno
   G.Weekdayname
   H.FinancialMOnth
   I. Financial Quarter */

select  date, year(date)Year,
month(date)Monthno,
monthname(date)Monthname,
concat("Q",quarter(date))Quarter, 
DATE_FORMAT(Date, '%Y-%b') AS YYYY_MMM,
dayofweek(date)Weekno,dayname(date)Weekname,
  CASE 
    WHEN MONTH(Date) > 3
      THEN month(date)-3
    ELSE 
      month(date)+9
  END AS Financial_Month,
  CASE 
    WHEN MONTH(Date) BETWEEN 4 AND 6 THEN 'Q1'
    WHEN MONTH(Date) BETWEEN 7 AND 9 THEN 'Q2'
    WHEN MONTH(Date) BETWEEN 10 AND 12 THEN 'Q3'
    WHEN MONTH(Date) BETWEEN 1 AND 3 THEN 'Q4'
  END AS Financial_Quarter
from
(SELECT MAKEDATE(Year, 1) 
       + INTERVAL (Month - 1) MONTH 
       + INTERVAL (Day - 1) DAY AS Date
FROM maindata)a; 

# 2)  Find the load Factor percentage on a yearly , Quarterly , Monthly basis ( Transported passengers / Available seats)
# Yearly Load factor %
select Year,concat(round(load_factor/total*100,2),"%") as 'Load factor %' from
(select *,sum(Load_factor) over() as Total from
(select year, sum(transported_passengers/available_seats) Load_factor from maindata group by 1)a)b;

# Monthly Load Factor
select Monthname,concat(round(T_load_factor/total*100,2),"%") as'load Factor %' from
(select *,sum(T_load_factor) over() as total from
(select month(date)monthno,monthname(date)Monthname,sum(load_factor)T_Load_Factor from
(SELECT  MAKEDATE(Year, 1) 
       + INTERVAL (Month - 1) MONTH 
       + INTERVAL (Day - 1) DAY AS Date,transported_passengers/available_seats as load_factor from maindata)a group by 1,2 order by 1)b)c;

# Quaterly Load Factor
select concat("Q",quarter)Quarter,concat(round(T_load_factor/total*100,2),"%") as'load Factor %' from
(select *,sum(T_load_factor) over() as total from
(select quarter(date)quarter,sum(load_factor)T_Load_Factor from
(SELECT  MAKEDATE(Year, 1) 
       + INTERVAL (Month - 1) MONTH 
       + INTERVAL (Day - 1) DAY AS Date,transported_passengers/available_seats as load_factor from maindata)a group by 1)b)c order by 1;

# 3) Find the load Factor percentage on a Carrier Name basis ( Transported passengers / Available seats)
select Carrier_Name,concat(round(load_factor/total*100,2),"%") as 'Load factor %' from
(select *,sum(Load_factor) over() as Total from
(select Carrier_Name, sum(transported_passengers/available_seats) Load_factor from maindata group by 1 order by load_factor desc)a)b limit 10;


# 4) Identify Top 10 Carrier Names based passengers preference 
select Carrier_Name,CONCAT(ROUND(sum(transported_passengers)/ 1000000, 2), 'M') AS No_of_passengers
from maindata group by 1 order by sum(Transported_Passengers)desc limit 10;

# 5) Display top Routes ( from-to City) based on Number of Flights 
select from_to_city as Routes, count(datasource_ID)No_of_Flight from 
maindata group by 1 order by No_of_flight desc limit 10;


# 6) Identify the how much load factor is occupied on Weekend vs Weekdays.
select Type_of_week,concat(round(Lf/total*100,2),"%") as 'Load Factor %' from
(select *, sum(LF) over() as total from
(select
case
when weekday(date)>4
then "Weekends"
else "weekdays" end as type_of_week,sum(load_factor)LF
 from
(select makedate(year,1)
+ interval(month -1)Month
+ interval(day -1)day as date,transported_passengers/available_seats as load_factor from maindata)a group by 1)b)c;

# 7) Identify number of flights based on Distance group
select b.Distance_Interval,count(a.datasource_id)no_of_Flights from
maindata as a inner join distance_groups as b 
on a.Distance_Group_ID = b.Distance_Group_ID group by 1 order by no_of_Flights desc;


# Total Airlines
select count(distinct(airline_id))as Total_Airlines from maindata;

# Total Aircraft
select count(distinct(aircraft_type))as Total_Aircraft from maindata as a 
inner join aircraft_types as b
on a.Aircraft_Type_ID=b.Aircraft_Type_ID;

# Total aircraft group
select count(distinct(aircraft_group))as Total_Aircraft_group from maindata as a 
inner join aircraft_Groups as b
on a.Aircraft_Group_ID=b.Aircraft_group_id;

# total flight_type
select Flight_Type,count(Flight_Type)NO_of_trips from maindata as a 
inner join flight_types as b
on a.datasource_id=b.datasource_ID group by 1 order by No_of_trips desc;

# total passengers
select concat(round(sum(transported_passengers)/1000000,2),"M") as Total_passengers from maindata;




	


