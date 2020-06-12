# Fund Tracker

A flutter application for budgets and keeping track of transactions.

Built because I couldn't find any applications that allowed a custom or a 4-week period.

Allows authentication with Firebase and uses Firestore as a cloud database on top of using the devices' local database. 

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
- XCode if you wish to run iOS

Follow the instructions here to set up: https://flutter.dev/docs/get-started/install.

## Demo

The first screen is the login page.

![Empty Login](https://github.com/ys27/FundTracker/blob/master/login_empty.png?raw=true)

Click on `Register` to create a user.

![Register](https://github.com/ys27/FundTracker/blob/master/register.png?raw=true)

Alternatively, you can log in with your existing credentials.

![Login](https://github.com/ys27/FundTracker/blob/master/login.png?raw=true)

The home page is a list of transactions.

![Empty Home](https://github.com/ys27/FundTracker/blob/master/home_empty.png?raw=true)

Let's add a transaction. I bought an app from the Play Store for $1.99.

![Adding Google Play Store Purchase](https://github.com/ys27/FundTracker/blob/master/add_tx_gpstore.png?raw=true)

I can also choose from a preset of categories. Let's choose `Games & Apps`.

![Adding Google Play Store Purchase Category](https://github.com/ys27/FundTracker/blob/master/add_tx_gpstore_category.png?raw=true)

I also want to add an income. I sold my car for $5000. I chose `Transportation` as the category.

![Added Sold Car](https://github.com/ys27/FundTracker/blob/master/home_sold_car.png?raw=true)

Say I wish to create a custom category for things I've sold.
Let's open the menu and go to `Categories`.
This page displays a list of all the categories. 
You can choose to show these in the transactions page by selecting/unselecting individual categories and change the order it is displayed in the dropdown.

![Menu From Home](https://github.com/ys27/FundTracker/blob/master/menu_open_from_home.png?raw=true)
![Default Categories](https://github.com/ys27/FundTracker/blob/master/categories_default.png?raw=true)

But we are here to create a new category, so click on the floating + button.
In the category creation/edit page, you can specify the name, the icon (from MaterialIcons), and the colour.

![Adding Category Name](https://github.com/ys27/FundTracker/blob/master/add_category_sold_name.png?raw=true)
![Adding Category Icon](https://github.com/ys27/FundTracker/blob/master/icon_selection.png?raw=true)
![Adding Category Colour](https://github.com/ys27/FundTracker/blob/master/colour_selection.png?raw=true)
![Adding Category Filled](https://github.com/ys27/FundTracker/blob/master/add_category_sold_finished.png?raw=true)

Click `Add` and at the bottom of the list, voila!

![Added Category](https://github.com/ys27/FundTracker/blob/master/categories_sold_added.png?raw=true)

You can click on each category to edit them, if you wish.
For now, let's go back to the car transaction and change the category.
In the category dropdown, you can see that `Items Sold` is now available to use.
Select the category, save, and the transaction is now updated.

![New Category In Dropdown](https://github.com/ys27/FundTracker/blob/master/car_tx_sold_category.png?raw=true)
![Updated Transaction New Category](https://github.com/ys27/FundTracker/blob/master/home_tx_sold_category.png?raw=true)

I just bought another app from the Play Store and wish to add a transaction.
As soon as I start typing, transactions from the past that starts with the same name are suggested.
Choose the suggestion. The name and the category are changed for you. Enter the rest of the details and save.

![Show Suggestions](https://github.com/ys27/FundTracker/blob/master/add_tx_gpstore2_suggestions.png?raw=true)
![Add Suggestion Details](https://github.com/ys27/FundTracker/blob/master/add_tx_gpstore2_details.png?raw=true)

Now that you have a few transactions, let's check out our statistics.
You can swipe to the left or click on `Statistics`.

![Statistics](https://github.com/ys27/FundTracker/blob/master/statistics.png?raw=true)

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

![Statistics](https://github.com/ys27/FundTracker/blob/master/statistics.png?raw=true)
![Statistics Categories](https://github.com/ys27/FundTracker/blob/master/stats_categories.png?raw=true)
![Statistics Top Expenses](https://github.com/ys27/FundTracker/blob/master/stats_top_expenses.png?raw=true)

The transactions can be filtered from the home page (Transactions or Statistics). This filter is shared and affects the statistics.
You can filter by income/expenses or by categories.

![Filters](https://github.com/ys27/FundTracker/blob/master/filters.png?raw=true)

There is also a search function at the top of the transactions list.

Another useful feature is custom periods. By default, periods are set by month.
In the `Periods` menu, let's add a custom period.
I want a 4 week custom period that starts this Friday. 
Don't worry about past transactions, this will set the past periods properly from any set start date.
Let's also set this as the default (active) period.

![Empty Periods](https://github.com/ys27/FundTracker/blob/master/periods_empty.png?raw=true)
![Add 4 Weeks Period](https://github.com/ys27/FundTracker/blob/master/add_period_4_weeks.png?raw=true)

I've also added a 2 week period to show that the active period is highlighted in blue.

![Periods With 4 Weeks Active](https://github.com/ys27/FundTracker/blob/master/periods_active_4_weeks.png?raw=true)

Back to the home page and the transactions list, and we can see that the transactions are split in different periods.
The first two transactions were added on June 11 (before the current period started), and the last one was added on the 12th.

![Custom Period in Home](https://github.com/ys27/FundTracker/blob/master/home_custom_period.png?raw=true)

The statistics page > Period tab also shows the updated period and any other periods that have transactions.

![Custom Period in Stats](https://github.com/ys27/FundTracker/blob/master/statistics_custom_period.png?raw=true)

Another feature that is essential are `Recurring Transactions`.
We can add this from the menu > `Recurring Transactions`.

![Empty Recurring Transactions](https://github.com/ys27/FundTracker/blob/master/recurring_transactions_empty.png?raw=true)

Let's say I want to give my little brother $5 for the next 5 days.
I can set the next date (or the start date), transaction details, the frequency, and if applicable, the end condition using *either* the number of times I would like, or the end date.

![Add Recurring Transaction](https://github.com/ys27/FundTracker/blob/master/add_recurring_transactions_allowance.png?raw=true)
![Added Recurring Transaction](https://github.com/ys27/FundTracker/blob/master/recurring_transactions_allowance.png?raw=true)

Now that the recurring transaction is added, let's go to the home page. 
Since we set the next date for today, the transaction is already added.
(Note: the allowance transaction shows up before the google play app purchase because recurring transactions are added with the time set as 00:00)

![Recurring Transaction Added](https://github.com/ys27/FundTracker/blob/master/home_recurring_transaction.png?raw=true)

The last item in the menu are the `Preferences`.
You can currently change these items in Preferences:
- Custom Range for the `Custom` tab in Statistics
- Default tab in Statistics when opened
- Reset Preferences

![Preferences](https://github.com/ys27/FundTracker/blob/master/preferences.png?raw=true)
