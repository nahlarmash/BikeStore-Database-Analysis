Create Database BikeStore;

USE BikeStore;

--------- Explore Data -------------
Select * From [production].[brands];
Select * From [production].[categories];
Select * From [production].[products];
Select * From [production].[stocks];
Select * From [sales].[customers];
Select * From [sales].[order_items];
Select * From [sales].[orders];
Select * From [sales].[staffs];
Select * From [sales].[stores];

---------------------- Questions --------------------------
-- Q1: Which bike is most expensive?Select TOP 1        product_name,	   list_priceFrom [production].[products]Order By list_price DESC;-- What could be the motive behind pricing this bike at the high price?Select TOP 1        p.product_name,	   p.list_price,	   c.category_name,	   b.brand_nameFrom [production].[products] as pINNER JOIN [production].[categories] as cON p.category_id = c.category_idINNER JOIN [production].[brands] as bON p.brand_id = b.brand_idOrder By list_price Desc;-- Q2: How many total customers does BikeStore have?Select Count(Distinct customer_id) as Total_CustomersFrom [sales].[customers];-- Would you consider people with order status 3 as customers substantiate your answer?Select Count(Distinct c.customer_id) as Total_Customers,       Count(Distinct Case When o.order_status = 3 Then c.customer_id End) As Customers_Status,	   Count(Distinct c.customer_id) - Count(Distinct Case When o.order_status = 3 Then c.customer_id End) As Valid_CustomersFrom [sales].[customers] as cLeft Join [sales].[orders] as oOn c.customer_id = o.customer_id; -- Q3: How many stores does BikeStore have?Select count(store_id) as No_of_StoresFrom [sales].[stores];-- Q4: What is the total price spent per order?Select order_id, sum([list_price] * [quantity] * (1-[discount])) as Total_PriceFrom [sales].[order_items]Group By order_id;-- Q5: What’s the sales/revenue per store?Select s.store_id, sum([list_price] * [quantity] * (1-[discount])) as Sales_RevenueFrom [sales].[stores] as sINNER JOIN [sales].[orders] as oOn s.store_id = o.store_idINNER JOIN [sales].[order_items] as ordOn o.order_id = ord.order_idGroup By s.store_idOrder By s.store_id;-- Q6: Which category is most sold?Select Max(c.category_name) as Most_soldFrom [production].[categories] as cINNER JOIN [production].[products] as pOn c.category_id = p.category_idINNER JOIN [sales].[order_items] as ordOn ord.product_id = p.product_id
-- Q7: Which category rejected more orders?
Select Top 1
       c.category_name, Count(o.order_status) as More_Rejected
From [production].[categories] as c
INNER JOIN [production].[products] as p
On c.category_id = p.category_id
INNER JOIN [sales].[order_items] as ord
On p.product_id = ord.product_id
INNER JOIN [sales].[orders] as o
On o.order_id = ord.order_id
Where o.order_status = 3
Group By c.category_name
Order By More_Rejected Desc;

-- Q8: Which bike is the least sold?
Select Top 1
       c.category_name, Count(ord.order_id) as No_of_Sold
From [production].[categories] as cINNER JOIN [production].[products] as pOn c.category_id = p.category_idINNER JOIN [sales].[order_items] as ordOn ord.product_id = p.product_id
Group By c.category_name 
Order By No_of_Sold;


-- Q9: What’s the full name of a customer with ID 259?
Select concat(first_name, ' ', last_name) as Full_Name, customer_id 
From [sales].[customers]
Where customer_id = 259;

-- Q10: What did the customer on question 9 buy and when? What’s the status of this order?
Select concat(first_name, ' ', last_name) as Full_Name, s.customer_id, o.order_id, order_status, order_date, product_name, category_name
From [sales].[customers] as s
INNER JOIN [sales].[orders] as o
On s.customer_id = o.customer_id
INNER JOIN [sales].[order_items] as ord
On o.order_id = ord.order_id
INNER JOIN [production].[products] as p
On ord.product_id = p.product_id
INNER JOIN [production].[categories] as c
On c.category_id = p.category_id
Where s.customer_id = 259;

-- Q11: Which staff processed the order of customer 259? And from which store?
Select o.customer_id, s.staff_id, concat(first_name, ' ', last_name) as Full_Name, store_name
From [sales].[staffs] as s
INNER JOIN [sales].[orders] as o
On s.staff_id = o.staff_id
INNER JOIN [sales].[stores] as t
On o.store_id = t.store_id
Where o.customer_id = 259;

-- Q12: How many staff does BikeStore have? Who seems to be the lead Staff at BikeStore?
-- How many staff does BikeStore have?
Select Count(*) As No_of_Staff
From [sales].[staffs]

-- Who seems to be the lead Staff at BikeStore?
Select staff_id, concat(first_name, ' ', last_name) as Lead_Staff
From [sales].[staffs]
Where manager_id IS NULL;

-- Q13: Which brand is the most liked?
Select Top 1
       b.brand_name, sum([quantity]) as Total_Quantity
From [production].[brands] as b
INNER JOIN [production].[products] as p
On b.brand_id = p.brand_id
INNER JOIN [sales].[order_items] as ord
On p.product_id = ord.product_id
Group By b.brand_name
Order By Total_Quantity Desc;

-- Q14: How many categories does BikeStore have
Select Top 1
       Count(distinct category_name) as No_of_Categories
From [production].[categories]

-- which one is the least liked?
Select Top 1
       category_name, sum([quantity]) as Total_Quantity
From [production].[categories] as c
INNER JOIN [production].[products] as p
On c.category_id = p.category_id
INNER JOIN [sales].[order_items] as o
On p.product_id = o.product_id
Group By category_name
Order By Total_Quantity;

-- Q15: Which store still have more products of the most liked brand?
--  Most liked brand
Select Top 1
       brand_name, sum(quantity) as Total_Quantity
From [production].[brands] as b
INNER JOIN [production].[products] as p
on b.brand_id = p.brand_id
INNER JOIN [sales].[order_items] as o
on p.product_id = o.product_id 
Group By brand_name Order By Total_Quantity Desc;

-- Store that still have more products
Select Top 1
       store_name, sum(t.quantity) as No_of_Stocks
From [sales].[stores] as s
INNER JOIN [production].[stocks] as t
on s.store_id = t.store_id
Group By store_name 
Order By No_of_Stocks Desc;

-- Which store still have more products of the most liked brand?
With MostLikedBrand As(
Select Top 1
       brand_name, sum(quantity) as Total_Quantity
From [production].[brands] as b
INNER JOIN [production].[products] as p
on b.brand_id = p.brand_id
INNER JOIN [sales].[order_items] as o
on p.product_id = o.product_id 
Group By brand_name Order By Total_Quantity Desc)
Select Top 1
       store_name, sum(t.quantity) as No_of_Stocks
From [sales].[stores] as s
INNER JOIN [production].[stocks] as t
on s.store_id = t.store_id
INNER JOIN [production].[products] as p
    ON p.product_id = t.product_id
INNER JOIN [production].[brands] AS b
    ON p.brand_id = b.brand_id
Where b.brand_name = (Select brand_name From MostLikedBrand)
Group By store_name 
Order By No_of_Stocks Desc;

-- Q16: Which state is doing better in terms of sales?
Select Top 1
       state, sum([list_price] *[quantity]*(1-[discount])) as Total_Sales
From [sales].[stores] as s
INNER JOIN [sales].[orders] as o
on s.store_id = o.store_id
INNER JOIN [sales].[order_items] as ord
On o.order_id = ord.order_id
Group By state
Order By Total_Sales Desc;

-- Q17: What’s the discounted price of product id 259?
Select product_id, sum(discount) as Total_Discount
From [sales].[order_items]
Where product_id = 259
Group By product_id;

-- Q18: What’s the product name, quantity, price, category, model year and brand name of product number 44?
Select p.product_id, product_name, brand_name, category_name, model_year, p.list_price, sum(quantity) as Total_Quantity
From [production].[products] as p
INNER JOIN [production].[brands] as b
on b.brand_id = p.brand_id 
INNER JOIN [production].[categories] as c
on p.category_id = c.category_id
INNER JOIN [sales].[order_items] as o
on o.product_id = p.product_id
Where p.product_id = 44
Group By p.product_id, product_name, brand_name, category_name, model_year, p.list_price;

-- Q19: What’s the zip code of CA?
Select state, zip_code 
From [sales].[stores] 
Where state = 'CA';

-- Q20: How many states does BikeStore operate in?
Select count(distinct state) as StatesOperatedIn
From [sales].[stores];

-- Q21: How many bikes under the children category were sold in the last 8 months?
Select c.category_name, sum(quantity) as Total_Sales
From [production].[categories] as c
INNER JOIN [production].[products] as p
on c.category_id = p.category_id
INNER JOIN [sales].[order_items] as o
on p.product_id = o.product_id
INNER JOIN [sales].[orders] as ord
on o.order_id = ord.order_id 
where c.category_name Like 'Children%'
      AND ord.order_date Between (select Dateadd(month, -8, MAX(order_date)) FROM [sales].[orders])
	                             AND (SELECT MAX(order_date) FROM [sales].[orders])
Group By c.category_name;


-- Q22: What’s the shipped date for the order from customer 523
Select customer_id, order_id, shipped_date
From [sales].[orders]
Where customer_id = 523;

-- Q23: How many orders are still pending?
Select count(*) as Pending_Orders
From [sales].[orders]
Where shipped_date IS NULL;

-- Q24: What’s the names of category and brand does "Electra white water 3i - 2018" fall under?
Select product_name, category_name, brand_name
From [production].[categories] as c
INNER JOIN [production].[products] as p
on c.category_id = p.category_id
INNER JOIN [production].[brands] as b
on p.brand_id = b.brand_id
where product_name = 'Electra white water 3i - 2018';