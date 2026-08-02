CREATE TABLE customer (
    customer_id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    address VARCHAR(255),
    state VARCHAR(100),
    city VARCHAR(100),
    is_active BOOLEAN DEFAULT TRUE,
    acc_created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    phone VARCHAR(20) UNIQUE
);

CREATE TABLE product (
    product_id BIGSERIAL PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    category VARCHAR(100),
    description TEXT
);

CREATE TABLE product_variant (
    product_variant_id BIGSERIAL PRIMARY KEY,
    product_id BIGINT NOT NULL REFERENCES product(product_id),
    sku VARCHAR(60) UNIQUE NOT NULL,
    net_quantity VARCHAR(30) NOT NULL
);

CREATE TABLE store (
    store_id BIGSERIAL PRIMARY KEY,
    store_name VARCHAR(150) NOT NULL,
    latitude DECIMAL(9,6),
    city VARCHAR(100),
    longitude DECIMAL(9,6),
    state VARCHAR(100),
    is_active BOOLEAN DEFAULT TRUE
);

CREATE TABLE shopper (
    shopper_id BIGSERIAL PRIMARY KEY,
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_available BOOLEAN DEFAULT TRUE,
    is_active BOOLEAN DEFAULT TRUE,
    phone VARCHAR(20) UNIQUE,
    email VARCHAR(255) UNIQUE,
    name VARCHAR(100) NOT NULL
);

CREATE TABLE shopper_location (
    shopper_location_id BIGSERIAL PRIMARY KEY,
    shopper_id BIGINT NOT NULL REFERENCES shopper(shopper_id),
    latitude DECIMAL(9,6),
    longitude DECIMAL(9,6),
    location_updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE shopping_list (
    shopping_list_id BIGSERIAL PRIMARY KEY,
    customer_id BIGINT NOT NULL REFERENCES customer(customer_id),
    shopping_list_name VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE store_catalog (
    store_catalog_id BIGSERIAL PRIMARY KEY,
    product_variant_id BIGINT NOT NULL REFERENCES product_variant(product_variant_id),
    store_id BIGINT NOT NULL REFERENCES store(store_id),
    price NUMERIC(10,2) NOT NULL,
    is_available BOOLEAN DEFAULT TRUE,
    UNIQUE(store_id, product_variant_id)
);

CREATE TABLE inventory (
    inventory_id BIGSERIAL PRIMARY KEY,
    product_variant_id BIGINT NOT NULL REFERENCES product_variant(product_variant_id),
    store_id BIGINT NOT NULL REFERENCES store(store_id),
    reserved_quantity INTEGER DEFAULT 0,
    available_quantity INTEGER NOT NULL,
    threshold_quantity INTEGER DEFAULT 0,
    last_updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(store_id, product_variant_id)
);

CREATE TABLE orders (
    order_id BIGSERIAL PRIMARY KEY,
    customer_id BIGINT NOT NULL REFERENCES customer(customer_id),
    shopper_id BIGINT REFERENCES shopper(shopper_id),
    store_id BIGINT NOT NULL REFERENCES store(store_id),
    order_status VARCHAR(30) NOT NULL,
    ordered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    order_total NUMERIC(12,2)
);

CREATE TABLE shopping_list_item (
    shopping_list_item_id BIGSERIAL PRIMARY KEY,
    shopping_list_id BIGINT NOT NULL REFERENCES shopping_list(shopping_list_id),
    product_variant_id BIGINT NOT NULL REFERENCES product_variant(product_variant_id),
    quantity INTEGER NOT NULL
);

CREATE TABLE order_item (
    order_item_id BIGSERIAL PRIMARY KEY,
    order_id BIGINT NOT NULL REFERENCES orders(order_id),
    product_variant_id BIGINT NOT NULL REFERENCES product_variant(product_variant_id),
    quantity INTEGER NOT NULL,
    price NUMERIC(10,2) NOT NULL
);

CREATE TABLE payment (
    payment_id BIGSERIAL PRIMARY KEY,
    order_id BIGINT UNIQUE NOT NULL REFERENCES orders(order_id),
    payment_mode VARCHAR(30),
    gateway_transaction_id VARCHAR(120) UNIQUE,
    payment_status VARCHAR(30),
    payment_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE delivery (
    delivery_id BIGSERIAL PRIMARY KEY,
    order_id BIGINT UNIQUE NOT NULL REFERENCES orders(order_id),
    tracking_number VARCHAR(100) UNIQUE,
    delivered_at TIMESTAMP,
    review TEXT,
    rating SMALLINT CHECK (rating BETWEEN 1 AND 5)
);

CREATE TABLE substitution (
    substitution_id BIGSERIAL PRIMARY KEY,
    customer_id BIGINT NOT NULL REFERENCES customer(customer_id),
    order_item_id BIGINT NOT NULL REFERENCES order_item(order_item_id),
    original_product_variant_id BIGINT NOT NULL REFERENCES product_variant(product_variant_id),
    substituted_status VARCHAR(30),
    approved_at TIMESTAMP,
    substituted_product_variant_id BIGINT REFERENCES product_variant(product_variant_id)
);