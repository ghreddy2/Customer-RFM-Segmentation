# Customer-Segmentation
RFM(Recency, Frequency and Monetary) based segmentation and scoring the customers.


# What is "Customer-Segmentation" about?
 Customer segmentation is the process of dividing customers into groups based on common characteristics
 so companies can market to each group effectively and appropriately.
 
 
# Why Segment Customers?

Segmentation allows marketers to better tailor their marketing efforts to various audience subsets.
Those efforts can relate to both communications and product development.

Specifically, segmentation helps a company:

* Create and communicate targeted marketing messages that will resonate with specific groups of customers.

* Select the best communication channel for the segment, which might be email, social media posts, radio advertising, or another approach, depending on the segment. 

* Identify ways to improve products or new product or service opportunities.

* Establish better customer relationships.

* Test pricing options.

* Focus on the most profitable customers.

* Improve customer service.

* Upsell and cross-sell other products and services.


# What is RFM analysis?

RFM (recency, frequency, monetary) analysis is a behavior based technique used to segment customers by examining their transaction history such as

- how recently a customer has purchased (recency)

- how often they purchase (frequency)

- how much the customer spends (monetary)

It is based on the marketing axiom that *80% of your business comes from 20% of your customers*.
RFM helps to identify customers who are more likely to respond to promotions by segmenting them into various categories.

# Data
To calculate the RFM score for each customer we need transaction data which should include the following:

* a unique customer id
* date of transaction/order
* transaction/order amount

# What can you find in this R file?

* I took two excel files where AMorderList gives us information about the details of orders with unique OrderID.
* The another file AMbreakdown gives us the information about a customer purchase.

We will set the data as required by finding the values of Recency, Frequency and Monetary value by setting a particular limit date.


We have created a new table with the columns as Recency, Frequency and TotAmount(Monetary) and Amount(particular customer average).

# Segmentation
In the initial segmentation part we have segmented the customers based on their activity and we have considered them as 'inactive' if 
no activtity is observed in three years, and so on.

And then in the further segmentation we have resegmented the customers based on their average purchase and their initial segmentation.

The next is followed by segmenting the customers similarly if the analysis is done a year before i.e.,2013.

Then, we can build our probability models to find the customers whom we have to concentrate by giving them offers, promocodes, etc.,
and try to stop them who is likely tp churn.

We can also try to find our top customers and to concentrate on them too.
