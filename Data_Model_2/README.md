# Data Model 2: E-Commerce Platform Database Architecture

## Problem Overview
Designing the core relational database schema for a large-scale E-Commerce platform (such as Amazon or Shopify) to handle complex product catalogs, multi-warehouse inventory, customer orders, payment processing, and multi-step fulfillment.

## Business Context & Questions
The data model is designed to answer critical business operational metrics:
* **Inventory Visibility:** Total available units of each product across all warehouses.
* **Fulfillment Tracking:** Real-time order fulfillment status for customers.
* **Stock Alerting:** Identification of products with inventory issues (out-of-stock / backorder).
* **Revenue Analytics:** Revenue breakdown categorized by product hierarchies.
* **Warehouse Routing:** Optimal fulfillment location selection based on warehouse proximity.

## Key Requirements
* **Hierarchical Categories:** Support parent-child category structures (e.g., Electronics > Phones > Smartphones).
* **Product Variants:** Products support multiple SKU-level variants (e.g., color, size).
* **Warehouse Inventory:** Stock tracking per variant per warehouse with available_quantity and reserved_quantity.
* **Customer Profiles:** Support multiple delivery addresses per customer.
* **Multi-Source Orders:** Orders can contain multiple line items and fulfillments from separate warehouses.
* **Payment Processing:** Track payment attempts with gateway reference IDs.
* **Shipment Management:** Full tracking with carriers, tracking numbers, and shipment statuses.

## System Constraints
* **Scale:** 100M+ products, 1B+ annual orders across 500+ global warehouses.
* **Real-Time Accuracy:** Strict inventory consistency for available vs. reserved stock.
* **Compliance & History:** PCI compliance for payment data and 7-year order history retention.

## Repository Artifacts
* [Business_Process_Flow.png](Business_Process_Flow.png): High-level customer journey & order fulfillment flow.
* [Logical_Data_Model.png](Logical_Data_Model.png): Entities, attributes, and primary keys representation.
* [Entity_Relationship_Diagram.png](Entity_Relationship_Diagram.png): Complete ERD illustrating table relationships & foreign keys.
* [Physical_Data_Model.sql](Physical_Data_Model.sql): Production-ready PostgreSQL DDL script creating all core tables and constraints.
