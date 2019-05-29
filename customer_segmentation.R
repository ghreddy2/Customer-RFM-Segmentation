 
#CUSTOMER SEGMENTATION
#Customer segmentation is the process of dividing customers into groups based on common 
#characteristics so companies can market to each group effectively and appropriately.

#The First Step import data

setwd("C:\\Users\\ghreddy\\Desktop\\rfm")
am2 <- read.csv("AMbreakdown.csv")
am1 <- read.csv("AMorderList.csv")


#Merge two data tables by common columns or row names.
am <- merge(am1, am2, all.x = T) #joining both the data tables as one.
l = ncol(am) #assigning the columns in the dataframe to a variable 
am <- am[,-c(l-2,l-1,l)] #dropping some unwanted columns in the data.
View(am) #checking for the data in the table 'am'.
dim(am) #checking for the dimensions.
names(am) #checking for the column names.

#PREPARING THE DATA FOR ANALYSIS  

# Time handling

time1 = "2017-05-01"
time2 = "2016-12-12"

#Function difftime calculates a difference of two date/time objects and returns an 
#object of class "difftime" with an attribute indicating the units. 
difftime(time1, time2, units="days") #checking for time difference.
class(difftime(time1, time2, units="days")) #checking for the class of time difference.
as.numeric(difftime(time1, time2, units="days")) #Creates or coerces objects of type "numeric". 


#CREATING AN ADDITIONAL COLUMN THAT WILL HOLD THE INFORMATION OF DAYS SINCE LAST PURCHASE.

am$daysSince <- round(as.numeric(difftime("2015-01-01",as.Date(am$OrderDate,format="%d/%m/%y"), units="days")))
View(am)

#sqldf() performs the SQL select or other statement and returns the result.
install.packages("sqldf")
#ACTIVATING SQLDF 
require(sqldf)
colnames(am)[colnames(am)=="ï..OrderID"] <- "OrderId" #changing the name of column where both the datasets are merged.

#dplyr is a grammar of data manipulation that helps to solve the data manipulation challenges.
library(dplyr)
#This is like a transposed version of print, this makes it possible to see every column in a data frame. 
glimpse(am)
class(am$Sales)="numeric"

#CALULATE RECENCY, FREQUENCY AND MONETARY (RFM) VALUES FOR EACH UNIQUE CUSTOMERS.


customer = sqldf("SELECT CustomerName,
				         MIN(DaysSince) AS Recency,  
                 COUNT(distinct(OrderID)) AS Frequency,
                 AVG(Sales) AS Amount,
                 SUM(Sales) AS TotAmount,
                 MAX(DaysSince) AS FirstPurchase
                 FROM am GROUP BY 1")
#Recency (R): How many days ago was their last purchase?
#Frequency (F): How many times has the customer purchased from our store.
#Monetary (M): How much has this customer spent.

View(customer)



#CUSTOMER SEGMENTATION BASED ON RFM VALUES

#INITIAL SEGMENTATION

customer$segment <- NA  #Adding a new column to the customer table with name 'segment'
#logic :
#classifying a customer as 'inactive' after three years of inactivity.
customer$segment[which(customer$Recency > 365*3)]= "inactive" 
#classifying a customer as 'cold' if an activity is observed between two to three years of inactivity.
customer$segment[which(customer$Recency <= 365*3 & customer$Recency > 365*2)] = "cold" 
#classifying a customer as 'warm' if an activity is observed between one to two years of inactivity.
customer$segment[which(customer$Recency <= 365*2 & customer$Recency > 365)] = "warm" 
#classifying a customer as 'active' if an activity is observed within one year.
customer$segment[which(customer$Recency <= 365)]= "active" 

View(customer)

#FURTHER SEGMENTATION
#logic :
#if the first purchase is less than a year they are classified as 'new active'.
customer$segment[which(customer$FirstPurchase < 365)] = "new active" 
#if an activity is observed less than a year and the amount spent is above $200 is considered as 'active high value'.
customer$segment[(customer$segment=="active") & (customer$Amount > 200)] = "active high value" 
#if an activity is observed less than a year and the amount spent is less than $200 is considered as 'active low value'.
customer$segment[(customer$segment=="active") & (customer$Amount < 200)] = "active low value"
#if an activity is observed between one to two years of inactivity and their first purchase is less than two years are considered as 'new warm'.
customer$segment[(customer$segment=="warm") & (customer$FirstPurchase < 365*2)] = "new warm"

#if an activity is observed between one to two years of inactivity and the amount spent is above $200 is considered as 'warm high value'.
customer$segment[(customer$segment=="warm") & (customer$Amount > 200)] = "warm high value"
#if an activity is observed between one to two years of inactivity and the amount spent is less than $200 is considered as 'warm low value'.
customer$segment[(customer$segment=="warm") & (customer$Amount < 200)] = "warm low value"

View(customer)


#STUDYING THE SEGMENTS

#NUMBER OF CUSTOMERS 
#Use length command
length(customer$CustomerName)

#FREQUENCY DISTRIBUTION OF SEGMENTS 
#USe table command
table(customer$segment)

#Re-Ordering the levels
customer$segment <- factor(x=customer$segment, levels = c("inactive", "cold", "warm high value", 
                                                          "warm low value", "new warm", "active high value",
                                                          "active low value","new active"))

table(customer$segment)


#Aggregating the data

#Splits the data into subsets, computes summary statistics for each and returns the result.
aggregate(customer[,2:5], by = list(customer$segment), FUN=mean) 


#  PART 2 : PREPARING THE DATA FOR CUSTOMER SCORING
#SEGMENTING THE DATA RETROSPECTIVELY


#Segmentation that would have happened an year ago (in 2013).
#in the above segmentation, if an activity is done in the year 2013 are considered as 'inactive'.
#now lets check how the customers are segmented if the segmentation is done an year ago.

customer_2013 <- sqldf("SELECT CustomerName, MIN(DaysSince)-365 AS Recency,
                       COUNT(distinct(OrderID)) AS Frequency, AVG(Sales) AS Amount, SUM(Sales) AS TotAmount,
                       MAX(DaysSince)-365 AS FirstPurchase
                       FROM am 
                       WHERE DaysSince > 365
                       GROUP BY 1")

View(customer_2013)


#INITIAL SEGMENTATION
##Note: you can change the parameters with business justification 

customer_2013$segment <- NA 
#logic :
customer_2013$segment[which(customer_2013$Recency > 365*3)] ="inactive"
customer_2013$segment[which(customer_2013$Recency <= 365*3 & customer_2013$Recency > 365*2)] = "cold"
customer_2013$segment[which(customer_2013$Recency <= 365*2 & customer_2013$Recency > 365)] = "warm"
customer_2013$segment[which(customer_2013$Recency <= 365)] = "active"
View(customer_2013)
#FURTHER SEGMENTATION 
#logic :
customer_2013$segment[which(customer_2013$FirstPurchase < 365)] = "new active"
customer_2013$segment[which(customer_2013$segment=="active" & customer_2013$Amount > 200)] = "active high value"
customer_2013$segment[which(customer_2013$segment=="active" & customer_2013$Amount < 200)] = "active low value"
customer_2013$segment[which(customer_2013$segment=="warm" & customer$FirstPurchase < 365*2)] = "new warm"
customer_2013$segment[which(customer_2013$segment=="warm" & customer_2013$Amount > 200)] = "warm high value"
customer_2013$segment[which(customer_2013$segment=="warm" & customer_2013$Amount < 200)] = "warm low value"


class(am$Sales)
View(am)

am$year_of_purchase = format(as.Date(am$OrderDate,format="%d/%m/%y"),"%y")

#REVENUE GENERATED IN 2014 (PER CUSTOMER)
##creating a new table as revenue_2014 by selecting the customername, their total purchase for their purchase in 2014.
revenue_2014 <- sqldf("SELECT CustomerName, SUM(Sales) AS TOTSales
                      FROM am
                      WHERE year_of_purchase = 14 
                      GROUP BY 1")
length(customer$CustomerName)
length(revenue_2014$CustomerName)
View(revenue_2014)


#MERGE 
#creating a new table 'actual' by merging two tables customer and revenue generated in 2014.
actual = merge(customer, revenue_2014, all.x = T)
View(actual)

#Note that some Customers have a missing values for revenue. This indicate that they
#did not purchase in the year 2015

#AVERAGE REVENUE PER SEGMENTS Actual Code already provided below
aggregate(actual$TOTSales, by=list(actual$segment), FUN = mean)


#MERGE THE 2013 CUSTOMERS WITH 2014 REVENUE 
forward = merge(customer_2013, revenue_2014, all.x = T)
#replacing the null values as 0.
forward$TOTSales[is.na(forward$TOTSales)] <- 0
View(forward)


#STUDYING THE SEGMENT
#creating a new table to show the total sales by each segment.
agg = aggregate(forward$TOTSales, by=list(customer_2013$segment), FUN = mean)
View(agg)
agg[order(agg$Group.1, decreasing = T),]
#barplot shows us the bar plots for total sales according to segments.
barplot(agg$x, names.arg = agg$Group.1)


#FLAGING THE CUSTOMERS WHO REMAINED ACTIVE IN 2014 
#creating a new column with name 'active_2014' as 1 for whose purchase 
forward$active_2014 <- as.numeric(forward$TOTSales>0)
View(forward)
table(forward$active_2014)



#BUILDING THE PROBABILITY MODEL
#using active_2014 as dependent variable and Recency + Frequency + Amount + FirstPurchase as ind variables

#probability gives us the importance of the the customer for us.
#glm is used to fit generalized linear models.
prob.model = glm( active_2014 ~ Recency+Frequency+Amount+FirstPurchase, data=forward,
                 family = "binomial")
#(type = "response") gives the predicted probabilities
forward$prob = predict(prob.model, type = "response")
View(forward)


#BUILDING THE AMOUNT MODEL (considering only 1s)
#creating a new dataframe considering the customers who are active in the year 2014. 
amt.data = forward[forward$active_2014==1, ]  
View(amt.data)

# use TOTSales as dependent variable and Recency + Frequency + Amount + FirstPurchase as ind variables
#creating a linear model considering the total sales as dependant and others as independant from amt.data
amt.model = lm(TOTSales ~ Recency+Frequency+Amount+FirstPurchase , amt.data)
plot(amt.model)
#Cook's distance or Cook's D is a commonly used estimate of the influence of a data point when performing a least-squares regression analysis.

View(amt.model)
summary(amt.model) #checking for summary of the model.



#APPLY THE MODEL TO TODAY'S DATA (01-01-2015)
View(customer)
#applying the same model on the first segmentation and check for the probability for 
##the expected amount that a customer can make a purchase based on the RFM segmentations.
customer$prob = predict(prob.model, newdata = customer, type = "response") #tells us whom to concentrate for providing offers.
customer$ExpAmt = round(predict(amt.model, newdata = customer),2) #the expected amount the customer can purchase in their next visit.
customer$score = round(customer$prob*customer$ExpAmt,2) #customer scoring is done by using the probability and expected amount
 
View(customer)

