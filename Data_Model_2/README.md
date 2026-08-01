# E-Commerce Platform Database Architecture & Data Model

## Problem Overview
Designing the core relational database schema for a large-scale E-Commerce platform (such as Amazon or Shopify) to handle complex product catalogs, multi-warehouse inventory, customer orders, payment processing, and multi-step fulfillment.

## Business Context & Key Questions
The data model is designed to support high-throughput transactions and answer critical operational metrics:
1. **Inventory Visibility:** What is the total available stock for each product variant across all warehouses?
2. **Fulfillment Tracking:** What is the real-time fulfillment status of an order for a customer?
3. **Stock Alerting:** Which product variants are out of stock or below safety threshold levels in each warehouse?
4. **Revenue Analytics:** How much revenue has been generated, categorized by product hierarchies and categories?
5. **Warehouse Routing:** Can local warehouses fulfill incoming customer orders based on matching customer city and stock availability?

## Key Requirements & System Constraints
* **Hierarchical Categories:** Support multi-level parent-child product categories (e.g., Electronics > Phones > Smartphones).
* **Product Variants:** Flexibly manage SKU-level variants (e.g., color, size, pricing).
* **Multi-Warehouse Inventory Management:** Track stock levels (`available_quantity`, `reserved_quantity`, `threshold_level`) per variant across multiple warehouses.
* **Customer Profile & Address Book:** Support multiple delivery addresses per customer for seamless checkout.
* **Multi-Item & Split Orders:** Allow orders to contain multiple items with independent shipment tracking from different warehouses.
* **Payment Processing & Gateway Audit:** Record payment transactions and track individual gateway attempt logs with status codes and failure reasons.
* **Shipment & Carrier Integration:** Monitor dispatch dates, estimated delivery times, carrier details, and unique tracking numbers.
* **Scale:** System built to support 100M+ products, 1B+ annual orders across 500+ global warehouses.


## 1. Business Process Flow Diagram

![Business Process Flow](Business_Process_Flow.png)

### Workflow Overview:
The Business Process Flow illustrates the complete end-to-end journey of a customer transaction and order fulfillment lifecycle:
1. **Discovery & Selection:** Customer visits website → Searches for product → Views product details → Selects specific variant (Color, Size) → Adds item to cart.
2. **Checkout & Order Creation:** Customer places order → Provides customer shipping details (Name, Address) → Completes Payment.
3. **Fulfillment & Reservation:** System reserves inventory stock → Optimal Warehouse is selected based on availability and proximity.
4. **Shipping & Delivery:** Shipment record is created with carrier details → Order goes Out for Delivery → Delivered to customer.


## 2. Logical Data Model

![Logical Data Model](Logical_Data_Model.png)

### Logical Design Overview:
The Logical Data Model establishes the structural blueprint of the system, defining core entities, primary key identifiers (`PK`), and key business attributes without implementation-specific foreign key constraints:
* **Product Catalog:** `Product_Category`, `Product`, `Product_Variant`
* **Inventory & Warehouse:** `Warehouse`, `Inventory`
* **Customer Management:** `Customer`, `Customer_Address`
* **Sales & Ordering:** `Order`, `Order_Item`
* **Payment Processing:** `Payment`, `Payment_Attempt`
* **Logistics & Delivery:** `Carrier`, `Shipment`

## 3. Entity Relationship Diagram (Physical Data Model)

![Entity Relationship Diagram](Entity_Relationship_Diagram.png)

### Relational Architecture & Foreign Keys:
The Entity Relationship Diagram (ERD) defines the physical database structure, showing table relationships, cardinality, primary keys (`PK`), and foreign key constraints (`FK`):
* **Category Hierarchy:** `Product_Category` references itself (`parent_category_id` → `category_id`) to form parent-child category trees.
* **Product Hierarchy:** `Product` links to `Product_Category` (`category_id`), while `Product_Variant` links to `Product` (`product_id`).
* **Multi-Location Stock:** `Inventory` bridges `Warehouse` (`warehouse_id`) and `Product_Variant` (`product_variant_id`).
* **Customer & Order Placement:** `Customer` connects to `Customer_Address` (`customer_id`) and `orders` (`customer_id`), with `orders` referencing `Customer_Address` (`ca_id`).
* **Line Items & Shipments:** `order_item` bridges `orders` (`order_id`), `Product_Variant` (`product_variant_id`), and optional `shipment` (`shipment_id`).
* **Payment Pipeline:** `payment` references `orders` (`order_id`), while `payment_attempt` logs attempts for `payment` (`payment_id`).
* **Shipment & Carrier:** `shipment` links `orders` (`order_id`), `warehouse` (`warehouse_id`), and `carrier` (`carrier_id`).


## Schema Architecture

The physical database model consists of 13 core tables:

| Table Name | Description | Key Attributes |
| :--- | :--- | :--- |
| **`customer`** | Master store for customer profiles | `customer_id`, `customer_name`, `email`, `phone`, `is_active` |
| **`customer_address`** | Delivery addresses linked to customer accounts | `ca_id`, `customer_id`, `address`, `customer_city`, `customer_state`, `country`, `postal_code` |
| **`product_category`** | Hierarchical categories with parent-child relationships | `category_id`, `category_name`, `product_description`, `parent_category_id` |
| **`product`** | Master catalog for products | `product_id`, `category_id`, `product_name`, `brand`, `product_description` |
| **`product_variant`** | SKU-level variants (color, size, price) | `product_variant_id`, `product_id`, `sku`, `colour`, `product_size`, `price`, `is_active` |
| **`warehouse`** | Storage centers and fulfillment hubs | `warehouse_id`, `warehouse_name`, `city`, `state_name`, `country`, `storage_capacity`, `is_active` |
| **`inventory`** | Real-time stock levels per variant per warehouse | `inventory_id`, `warehouse_id`, `product_variant_id`, `available_quantity`, `reserved_quantity`, `threshold_level` |
| **`orders`** | Header details for placed orders | `order_id`, `customer_id`, `ca_id`, `ordered_at`, `status` |
| **`order_item`** | Line items associated with orders and shipments | `order_item_id`, `order_id`, `product_variant_id`, `shipment_id`, `quantity`, `price` |
| **`payment`** | Master payment transaction records | `payment_id`, `order_id`, `payment_type`, `payment_at`, `total_payment` |
| **`payment_attempt`** | Transaction logs for payment gateway responses | `payment_attempt_id`, `payment_id`, `gateway_ref_id`, `status`, `reason`, `created_at` |
| **`carrier`** | Logistics partners and shipping providers | `carrier_id`, `carrier_name`, `email`, `phone` |
| **`shipment`** | Shipment packages dispatched from warehouses | `shipment_id`, `carrier_id`, `warehouse_id`, `order_id`, `shipment_status`, `shipment_at`, `estimated_at`, `tracking_number` |

## Key Business Queries

All operational and analytical SQL queries answering the key business questions are provided in [`Business_Solution.sql`](Business_Solution.sql).

### Key Queries Included in `Business_Solution.sql`:
1. **Total Inventory Visibility:** Aggregates available stock quantities across all warehouses per product.
2. **Customer Order Fulfillment Tracking:** Joins customer, orders, and shipment tables to track live delivery status for specific customer orders.
3. **Stock Alerting (Low/Out of Stock):** CTE identifying items with zero stock or quantity below safety threshold levels along with warehouse locations.
4. **Category Revenue Analytics:** Calculates revenue generated across product categories by joining sales items with product hierarchies.
5. **Local Warehouse Fulfillment Check:** Evaluates whether local city warehouses have sufficient inventory stock to fulfill customer orders.

