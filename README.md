# restaurant_app_new

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Cybersecurity Risks

- The timestamp of the order must be taken from the server to prevent the user from changing the time of the order.
- If table ordering is implemented, the current idea is to use a randomly generated code to identify the table. This code must be generated by the server to prevent the user from changing the table. This should work like the authenticator apps.
- It seems like some random person could just log into the localhost and change the order status. The localhost should also be password protected.
- No internet no app. The app should be able to work offline within the wifi network.

## Features

- Make app have english and portuguese languages at least on the table side.
- Consider adding a BAR function where it displays the drinks, desert and entree orders separately.


## SQL tables

### User
- id
- name
- type (customer, waiter, chef)

### Order
- id
- table_id  (0 if takeout)
- takeaway_name - name of the person that ordered the takeout
- order_type (table, takeout)
- order_status (pending, preparing, ready, delivered, payed) - this is displayed on a button that can be changed by the chef
- order_time (timestamp)
- delivery_time (timestamp) - this is only filled when the order is delivered
- user_id (waiter id)


### Menu (Usually there are 2 menus daily and a fixed menu)
- id
- name (daily, fixed)
- list of items


### Item
- id
- name
- menu_id
- type (entree, main, dessert, drink, cafeteria, spirits)
- user_id (waiter id, chef id)
- availability (available, unavailable)
- additional_info (no salad, no onions, etc) - This should spawn a list of checkboxes on the app. But first implemented in text form.

# TODO

Bellow is a list of features ***to be implemented***:
- [x] Add "Add table" button that pops an Add table dialog
- [ ] Add some sort of "Cookie" to keep record of:
    - [ ] On the Initial/Kitchen Screen record :
        - [x] Type of Menu ( Daily, Fixed, Sunday)
        - [ ] Order grouping ( Order by time/ Group orders)
    - [x] Add Order Dialog (Remember Menu Type)
    - [ ] Table Filtering by prefix in Waiter Screen

- [ ] Fill the database with the menus and drinks
- [ ] Add order grouping ( Order by time/ Group orders by MenuItem)
    - Group by menuItem should look like this
        Sum(Portions) - DishName
        - Portions x DishName table.id/takeaway_name - user.name - OrderTime/DeliveryTime - OrderId...
- [x] Make it possible for the Waiter to see a version of the Kitchen Screen
- [x] Add Color to Orders depending on delay and state
- [ ] Make it possible in Order Dialog to add 0.5 portions i.e. ( DishName + 1 portion(s) -  + 0.5 portion(s) -)
- [x] Waiter Screen should display tables with a  preview of  the items on the table
- [ ] In Kitchen Screen, the user should be able to toggle the **availability** of an item
- [ ] In the Order Dialog only available items can be added
- [ ] Waiter Screen should have different colours:
    - [ ] Table State (Free, Waiting, Served)
    - [ ] Table Dialog should display the State of each item/order (Ordered, Cooked, Served)

- [ ] Waiter Screem should open ***Table dialogs*** or ***table screens*** (_discuss_)
    - [ ] Add order should be available in **Waiter Screen** and **Table Dialog**.

- [ ] Some items should not be available to add half portions (e.g. soups, coffees, etc)

- [ ] Waiter Screen should allow the waiter to "Finish" the table. Using a ***Bill button***.

- [ ] Show user names on the:
    - [ ] Waiter and Kitchen Screen
    - [ ] Orders (so that you know who asked for it)

- [ ] List users and allow Kitchen Screen to Remove and Add/Register from Kitchen Screen (**Dialog**)

- [ ] Allow changing the character size on Kitchen Screen

- [ ] The Kitchen Screen should only display orders for each day, also have a date scroll.

- [ ] Hash user passwords

- [ ] Add a "Remember sign in data" checkbox on the login screen

- [ ] Create an undo button

Bellow is a list of features ***to be considered***:
- [ ] Make app have english and portuguese languages at least on the table side.
- [ ] Make it possible to "schedule" order with assigning table and do that later (If some costumer )
- [ ] Make it possible to change the table of an order/ Change from table to takeaway and reverse
- [ ] Make it possible to Reserve a table and see Reserved tables
- [ ] Solve the half portions problem
