# Fund Tracker

A flutter application for budgets and keeping track of transactions.

I built this because I couldn't find any application that allowed a custom or a 4-week period.

Allows authentication with Firebase and uses Firestore as a cloud database on top of using the devices' local database as backup. 

Features include: 
- statistics
- custom periods
- recurring transactions
- custom categories
- filters

and more...


## To run

To build this application and run it on your device or an emulator, you need:
- Flutter
- Android SDK
- XCode if you wish to run on iOS

Follow the instructions here to set up: https://flutter.dev/docs/get-started/install.

### Note to users

The default cloud database (Firebase) is on a free tier, and set up to remove all accounts periodically.   
Please do not store important information using the default database.

## Demo

The first screen is the login page.

<img alt="Empty Login" src="https://github.com/ys27/FundTracker/blob/master/README_images/login_empty.png?raw=true" width="40%">
Click on `Register` to create a user.

<img alt="Register" src="https://github.com/ys27/FundTracker/blob/master/README_images/register.png?raw=true" width="40%">

Alternatively, you can log in with your existing credentials.

<img alt="Login" src="https://github.com/ys27/FundTracker/blob/master/README_images/login.png?raw=true" width="40%">

The home page is a list of transactions.

<img alt="Empty Home" src="https://github.com/ys27/FundTracker/blob/master/README_images/home_empty.png?raw=true" width="40%">

Let's add a transaction. I bought an app from the Play Store for $1.99.

<img alt="Adding Google Play Store Purchase" src="https://github.com/ys27/FundTracker/blob/master/README_images/add_tx_gpstore.png?raw=true" width="40%">

I can also choose from a preset of categories. Let's choose `Games & Apps`.

<img alt="Adding Google Play Store Purchase Category" src="https://github.com/ys27/FundTracker/blob/master/README_images/add_tx_gpstore_category.png?raw=true" width="40%">

I also want to add an income. I sold my car for $5000. I chose `Transportation` as the category.

<img alt="Added Sold Car" src="https://github.com/ys27/FundTracker/blob/master/README_images/home_sold_car.png?raw=true" width="40%">

Say I wish to create a custom category for things I've sold.
Let's open the menu and go to `Categories`.
This page displays a list of all the categories. 
You can choose to show these in the transactions page by selecting/unselecting individual categories and change the order it is displayed in the dropdown.

<div>
  <img alt="Menu From Home" src="https://github.com/ys27/FundTracker/blob/master/README_images/menu_open_from_home.png?raw=true" width="40%">
  <img alt="Default Categories" src="https://github.com/ys27/FundTracker/blob/master/README_images/categories_default.png?raw=true" width="40%">
</div>

But we are here to create a new category, so click on the floating + button.
In the category creation/edit page, you can specify the name, the icon (from MaterialIcons), and the colour.

<div>
  <img alt="Adding Category Name" src="https://github.com/ys27/FundTracker/blob/master/README_images/add_category_sold_name.png?raw=true" width="40%">
  <img alt="Adding Category Icon" src="https://github.com/ys27/FundTracker/blob/master/README_images/icon_selection.png?raw=true" width="40%">
</div>
<div>
  <img alt="Adding Category Colour" src="https://github.com/ys27/FundTracker/blob/master/README_images/colour_selection.png?raw=true" width="40%">
  <img alt="Adding Category Filled" src="https://github.com/ys27/FundTracker/blob/master/README_images/add_category_sold_finished.png?raw=true" width="40%">
</div>

Click `Add` and at the bottom of the list, voila!

<img alt="Added Category" src="https://github.com/ys27/FundTracker/blob/master/README_images/categories_sold_added.png?raw=true" width="40%">

You can click on each category to edit them, if you wish.
For now, let's go back to the car transaction and change the category.
In the category dropdown, you can see that `Items Sold` is now available to use.
Select the category, save, and the transaction is now updated.

<div>
  <img alt="New Category In Dropdown" src="https://github.com/ys27/FundTracker/blob/master/README_images/car_tx_sold_category.png?raw=true" width="40%">
  <img alt="Updated Transaction New Category" src="https://github.com/ys27/FundTracker/blob/master/README_images/home_tx_sold_category.png?raw=true" width="40%">
</div>

I just bought another app from the Play Store and wish to add a transaction.
As soon as I start typing, transactions from the past that starts with the same name are suggested.
Choose the suggestion. The name and the category are changed for you. Enter the rest of the details and save.

<div>
  <img alt="Show Suggestions" src="https://github.com/ys27/FundTracker/blob/master/README_images/add_tx_gpstore2_suggestions.png?raw=true" width="40%">
  <img alt="Add Suggestion Details" src="https://github.com/ys27/FundTracker/blob/master/README_images/add_tx_gpstore2_details.png?raw=true" width="40%">
</div>

Now that you have a few transactions, let's check out our statistics.
You can swipe to the left or click on `Statistics`.

<img alt="Statistics" src="https://github.com/ys27/FundTracker/blob/master/README_images/statistics.png?raw=true" width="40%">

There are three main views:
- All-Time
- Period
- Custom

The All-Time tab shows you stats from your first-ever transaction.
The Period tab shows you periodic stats, which you can select from the dropdown.
The Custom tab shows you stats from the range of transactions that can be set in `Preferences`, or you can use the date selector to select the start date in which to show the stats from. (TODO: Allow end date selection)

The statistics page currently has the following information:
- Balance
- Remaining days in current period / Remaining balance per day
- Actual Income / Expenses
- Expenditure per category (TODO: Consider income? preferences)
- Top Expenses

<div>
  <img alt="Statistics" src="https://github.com/ys27/FundTracker/blob/master/README_images/statistics.png?raw=true" width="40%">
  <img alt="Statistics Categories" src="https://github.com/ys27/FundTracker/blob/master/README_images/stats_categories.png?raw=true" width="40%">
</div>
<img alt="Statistics Top Expenses" src="https://github.com/ys27/FundTracker/blob/master/README_images/stats_top_expenses.png?raw=true" width="40%">

The transactions can be filtered from the home page (Transactions or Statistics). This filter is shared and affects the statistics.
You can filter by income/expenses or by categories.

<img alt="Filters" src="https://github.com/ys27/FundTracker/blob/master/README_images/filters.png?raw=true" width="40%">

There is also a search function at the top of the transactions list.

Another useful feature is custom periods. By default, periods are set by month.
In the `Periods` menu, let's add a custom period.
I want a 4 week custom period that starts this Friday. 
Don't worry about past transactions, this will set the past periods properly from any set start date.
Let's also set this as the default (active) period.

<div>
  <img alt="Empty Periods" src="https://github.com/ys27/FundTracker/blob/master/README_images/periods_empty.png?raw=true" width="40%">
  <img alt="Add 4 Weeks Period" src="https://github.com/ys27/FundTracker/blob/master/README_images/add_period_4_weeks.png?raw=true" width="40%">
</div>

I've also added a 2 week period to show that the active period is highlighted in blue.

<img alt="Periods With 4 Weeks Active" src="https://github.com/ys27/FundTracker/blob/master/README_images/periods_active_4_weeks.png?raw=true" width="40%">

Back to the home page and the transactions list, and we can see that the transactions are split in different periods.
The first two transactions were added on June 11 (before the current period started), and the last one was added on the 12th.

<img alt="Custom Period in Home" src="https://github.com/ys27/FundTracker/blob/master/README_images/home_custom_period.png?raw=true" width="40%">

The statistics page > Period tab also shows the updated period and any other periods that have transactions.

<img alt="Custom Period in Stats" src="https://github.com/ys27/FundTracker/blob/master/README_images/statistics_custom_period.png?raw=true" width="40%">

Another feature that is essential are `Recurring Transactions`.
We can add this from the menu > `Recurring Transactions`.

<img alt="Empty Recurring Transactions" src="https://github.com/ys27/FundTracker/blob/master/README_images/recurring_transactions_empty.png?raw=true" width="40%">

Let's say I want to give my little brother $5 for the next 5 days.
I can set the next date (or the start date), transaction details, the frequency, and if applicable, the end condition using *either* the number of times I would like, or the end date.

<div>
  <img alt="Add Recurring Transaction" src="https://github.com/ys27/FundTracker/blob/master/README_images/add_recurring_transactions_allowance.png?raw=true" width="40%">
  <img alt="Added Recurring Transaction" src="https://github.com/ys27/FundTracker/blob/master/README_images/recurring_transactions_allowance.png?raw=true" width="40%">
</div>

Now that the recurring transaction is added, let's go to the home page. 
Since we set the next date for today, the transaction is already added.
(Note: the allowance transaction shows up before the google play app purchase because recurring transactions are added with the time set as 00:00)

<img alt="Recurring Transaction Added" src="https://github.com/ys27/FundTracker/blob/master/README_images/home_recurring_transaction.png?raw=true" width="40%">

The last item in the menu are the `Preferences`.
You can currently change these items in Preferences:
- Custom Range for the `Custom` tab in Statistics
- Default tab in Statistics when opened
- Reset Preferences

<img alt="Preferences" src="https://github.com/ys27/FundTracker/blob/master/README_images/preferences.png?raw=true" width="40%">
