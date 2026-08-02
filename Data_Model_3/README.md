# Grocery Delivery Platform Database Architecture & Data Model

## Problem Overview
Designing a relational database schema for an on-demand grocery delivery platform where customers browse store-specific product catalogs, build and save shopping lists, place orders restricted to a single store, and receive fulfillment via personal shoppers. The system handles real-time store-level inventory, geolocation-based shopper assignment, real-time item substitution approval, order status tracking, and post-delivery customer ratings.

## Business Context & Key Questions
The data model is structured to manage multi-store operations and answer core operational questions:
1. **Real-time Inventory Visibility:** What is the current available stock for a specific product variant at a designated store location?
2. **Store-Specific Catalog & Pricing:** How does product pricing vary across different store locations for the same product variant?
3. **Shopper Assignment:** Which available shopper is nearest to the target store location to fulfill an order?
4. **Item Substitution Tracking:** What is the real-time approval status of shopper-proposed item substitutions for out-of-stock items?
5. **Shopper Efficiency Metrics:** How many orders has each shopper completed, and what is their average number of items picked per order?

## Key Requirements & System Constraints
* **Store-Specific Catalogs & Pricing:** Support independent product availability and store-specific price overrides per location.
* **Single-Store Order Locking:** Restrict each customer order strictly to items selected from a single store location.
* **Shopping List Reuse:** Enable customers to save shopping lists and reload them with live pricing for fast re-ordering.
* **Real-time Inventory Management:** Track stock levels (`available_quantity`, `reserved_quantity`, `threshold_quantity`) per store location.
* **Shopper Proximity & Availability:** Log shopper coordinates to assign orders based on distance to store and active availability.
* **Real-Time Substitution Workflow:** Support shopper-proposed substitutions for out-of-stock items requiring explicit customer approval.
* **Order Lifecycle Progression:** Track order state changes through defined phases: `created` -> `assigned` -> `shopping` -> `on_route` -> `delivered`.
* **Delivery Ratings & Feedback:** Capture delivery timestamps, customer ratings, and written reviews post-delivery.


## 1. Business Process Flow Diagram

![Business Process Flow](Business_Process_Flow.png)

### Workflow Overview:
The Business Process Flow illustrates the complete lifecycle of customer shopping, order creation, fulfillment, and delivery:
1. **Store Browsing & Selection:** Customer opens the application, browses available grocery stores, and views location-specific catalogs and prices.
2. **List Building & Order Placement:** Customer builds or loads a saved shopping list, selects a single store, verifies item availability, and places an order.
3. **Inventory Check & Substitutions:** Real-time stock is checked. If an item is out of stock, the shopper suggests a substitute, which the customer approves or rejects in real-time.
4. **Order Total & Payment:** Final order total is calculated using active store pricing, and payment is processed.
5. **Shopper Assignment & Fulfillment:** System assigns the nearest available shopper based on distance. The shopper picks items at the store.
6. **Delivery & Review:** Order goes out for delivery with real-time location updates. Upon delivery, the customer submits a rating and review.


## 2. Logical Data Model

![Logical Data Model](Logical_Data_Model.png)

### Logical Design Overview:
The Logical Data Model defines core domain entities and attributes required for the grocery platform:
* **Customer & Accounts:** `customer`
* **Store & Product Catalog:** `store`, `product`, `product_variant`, `store_catalog`
* **Inventory Control:** `inventory`
* **Shopping List Management:** `shopping_list`, `shopping_list_item`
* **Orders & Line Items:** `orders`, `order_item`
* **Shoppers & Tracking:** `shopper`, `shopper_location`
* **Item Substitutions:** `substitution`
* **Payment & Delivery:** `payment`, `delivery`


## 3. Entity Relationship Diagram (Physical Data Model)

![Entity Relationship Diagram](Entity_Relationship_Diagram.png)

### Relational Architecture & Foreign Keys:
The Entity Relationship Diagram (ERD) defines the physical database structure, table primary keys (`PK`), and foreign key constraints (`FK`):
* **Catalog & Variant Hierarchy:** `product_variant` references `product` (`product_id`). `store_catalog` connects `store` (`store_id`) and `product_variant` (`product_variant_id`) to enforce store-specific pricing.
* **Store Inventory:** `inventory` bridges `store` (`store_id`) and `product_variant` (`product_variant_id`) to track stock quantities.
* **Shopping List Persistence:** `shopping_list` links to `customer` (`customer_id`), while `shopping_list_item` links `shopping_list` (`shopping_list_id`) to `product_variant` (`product_variant_id`).
* **Order & Single-Store Locking:** `orders` links `customer` (`customer_id`), `store` (`store_id`), and optional `shopper` (`shopper_id`). `order_item` bridges `orders` (`order_id`) and `product_variant` (`product_variant_id`).
* **Shopper Tracking:** `shopper_location` logs GPS coordinates referencing `shopper` (`shopper_id`).
* **Substitution Flow:** `substitution` references `customer` (`customer_id`), `order_item` (`order_item_id`), `original_product_variant_id`, and `substituted_product_variant_id`.
* **Payment & Delivery Tracking:** `payment` and `delivery` maintain one-to-one foreign key constraints referencing `orders` (`order_id`).


## Schema Architecture

The physical database schema consists of 15 core tables:

| Table Name | Description | Key Attributes |
| :--- | :--- | :--- |
| **`customer`** | Master profile data for platform customers | `customer_id`, `name`, `email`, `phone`, `address`, `state`, `city`, `is_active`, `acc_created_at` |
| **`product`** | Master catalog for generic product descriptions | `product_id`, `name`, `category`, `description` |
| **`product_variant`** | SKU-level product variants and net quantity packages | `product_variant_id`, `product_id`, `sku`, `net_quantity` |
| **`store`** | Grocery store locations and geographical coordinates | `store_id`, `store_name`, `latitude`, `longitude`, `city`, `state`, `is_active` |
| **`store_catalog`** | Store-specific product pricing and item availability | `store_catalog_id`, `product_variant_id`, `store_id`, `price`, `is_available` |
| **`inventory`** | Real-time stock levels per variant per store location | `inventory_id`, `product_variant_id`, `store_id`, `available_quantity`, `reserved_quantity`, `threshold_quantity`, `last_updated_at` |
| **`shopping_list`** | Header records for customer saved shopping lists | `shopping_list_id`, `customer_id`, `shopping_list_name`, `created_at` |
| **`shopping_list_item`** | Product variants and quantities stored within a shopping list | `shopping_list_item_id`, `shopping_list_id`, `product_variant_id`, `quantity` |
| **`orders`** | Core header records for placed customer orders | `order_id`, `customer_id`, `shopper_id`, `store_id`, `order_status`, `ordered_at`, `order_total` |
| **`order_item`** | Line-item quantities and store prices for an order | `order_item_id`, `order_id`, `product_variant_id`, `quantity`, `price` |
| **`shopper`** | Personal shopper profile details and active status | `shopper_id`, `name`, `email`, `phone`, `is_available`, `is_active`, `joined_at` |
| **`shopper_location`** | Live GPS location updates recorded for active shoppers | `shopper_location_id`, `shopper_id`, `latitude`, `longitude`, `location_updated_at` |
| **`substitution`** | Item substitution requests and customer approval logs | `substitution_id`, `customer_id`, `order_item_id`, `original_product_variant_id`, `substituted_product_variant_id`, `substituted_status`, `approved_at` |
| **`payment`** | Payment transaction details and gateway records | `payment_id`, `order_id`, `payment_mode`, `gateway_transaction_id`, `payment_status`, `payment_time` |
| **`delivery`** | Delivery tracking metrics, ratings, and customer reviews | `delivery_id`, `order_id`, `tracking_number`, `delivered_at`, `review`, `rating` |


## Key Business Queries

All operational and analytical SQL queries answering key business questions are provided in [`Business_Solution.sql`](Business_Solution.sql).

### Key Queries Included in `Business_Solution.sql`:
1. **Real-Time Store Inventory:** Queries available stock and inventory threshold alerts for products at a store location.
2. **Store-Specific Catalog & Pricing:** Compares store prices across different locations for product variants.
3. **Saved Shopping List Retrieval:** Loads saved lists with live prices to calculate order totals for a chosen store.
4. **Shopper Proximity Assignment:** Uses coordinate calculations to identify available shoppers closest to a store location.
5. **Substitution Tracking:** Displays active substitution proposals awaiting customer approval.
6. **Order Lifecycle & Delivery Tracking:** Tracks order status, assigned shoppers, payment, and delivery completion details.
7. **Shopper Efficiency Metrics:** Aggregates completed order count and average items picked per order per shopper.
