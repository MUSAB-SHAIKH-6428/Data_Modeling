CREATE TABLE customer (
    customer_id      BIGSERIAL PRIMARY KEY,
    customer_name    VARCHAR(100) NOT NULL,
    email            VARCHAR(255) UNIQUE NOT NULL,
    phone            VARCHAR(20) UNIQUE,
    is_active        BOOLEAN DEFAULT TRUE,
    created_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE customer_address (
    ca_id            BIGSERIAL PRIMARY KEY,
    customer_id      BIGINT NOT NULL,
    address          VARCHAR(255) NOT NULL,
    apartment        VARCHAR(100),
    customer_city    VARCHAR(100) NOT NULL,
    customer_state   VARCHAR(100),
    country          VARCHAR(100),
    postal_code      VARCHAR(20),

    CONSTRAINT fk_customer
        FOREIGN KEY(customer_id)
        REFERENCES customer(customer_id)
);

CREATE TABLE product_category (
    category_id        BIGSERIAL PRIMARY KEY,
    category_name      VARCHAR(100) NOT NULL,
    product_description TEXT,
    parent_category_id BIGINT,

    CONSTRAINT fk_parent_category
        FOREIGN KEY(parent_category_id)
        REFERENCES product_category(category_id)
);

CREATE TABLE product (
    product_id          BIGSERIAL PRIMARY KEY,
    category_id         BIGINT NOT NULL,
    product_name        VARCHAR(200) NOT NULL,
    brand               VARCHAR(100),
    product_description TEXT,

    CONSTRAINT fk_category
        FOREIGN KEY(category_id)
        REFERENCES product_category(category_id)
);

CREATE TABLE product_variant (
    product_variant_id BIGSERIAL PRIMARY KEY,
    product_id         BIGINT NOT NULL,
    sku                VARCHAR(50) UNIQUE NOT NULL,
    colour             VARCHAR(50),
    product_size       VARCHAR(30),
    price              NUMERIC(12,2) NOT NULL,
    is_active          BOOLEAN DEFAULT TRUE,

    CONSTRAINT fk_product
        FOREIGN KEY(product_id)
        REFERENCES product(product_id)
);

CREATE TABLE warehouse (
    warehouse_id     BIGSERIAL PRIMARY KEY,
    warehouse_name   VARCHAR(100),
    city             VARCHAR(100),
    state_name       VARCHAR(100),
    country          VARCHAR(100),
    storage_capacity INTEGER,
    is_active        BOOLEAN DEFAULT TRUE
);

CREATE TABLE inventory (
    inventory_id       BIGSERIAL PRIMARY KEY,
    warehouse_id       BIGINT NOT NULL,
    product_variant_id BIGINT NOT NULL,
    available_quantity INTEGER NOT NULL,
    reserved_quantity  INTEGER DEFAULT 0,
    threshold_level    INTEGER,

    CONSTRAINT fk_inventory_warehouse
        FOREIGN KEY(warehouse_id)
        REFERENCES warehouse(warehouse_id),

    CONSTRAINT fk_inventory_variant
        FOREIGN KEY(product_variant_id)
        REFERENCES product_variant(product_variant_id)
);

CREATE TABLE orders (
    order_id    BIGSERIAL PRIMARY KEY,
    customer_id BIGINT NOT NULL,
    ca_id       BIGINT NOT NULL,
    ordered_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status      VARCHAR(30),

    CONSTRAINT fk_order_customer
        FOREIGN KEY(customer_id)
        REFERENCES customer(customer_id),

    CONSTRAINT fk_order_address
        FOREIGN KEY(ca_id)
        REFERENCES customer_address(ca_id)
);

CREATE TABLE order_item (
    order_item_id      BIGSERIAL PRIMARY KEY,
    order_id           BIGINT NOT NULL,
    product_variant_id BIGINT NOT NULL,
    shipment_id        BIGINT,
    quantity           INTEGER NOT NULL,
    price              NUMERIC(12,2) NOT NULL,

    CONSTRAINT fk_orderitem_order
        FOREIGN KEY(order_id)
        REFERENCES orders(order_id),

    CONSTRAINT fk_orderitem_variant
        FOREIGN KEY(product_variant_id)
        REFERENCES product_variant(product_variant_id)
);

CREATE TABLE payment (
    payment_id    BIGSERIAL PRIMARY KEY,
    order_id      BIGINT NOT NULL,
    payment_type  VARCHAR(30),
    payment_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total_payment NUMERIC(12,2),

    CONSTRAINT fk_payment_order
        FOREIGN KEY(order_id)
        REFERENCES orders(order_id)
);

CREATE TABLE payment_attempt (
    payment_attempt_id BIGSERIAL PRIMARY KEY,
    payment_id         BIGINT NOT NULL,
    gateway_ref_id     VARCHAR(100),
    status             VARCHAR(30),
    reason             TEXT,
    created_at         TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_attempt_payment
        FOREIGN KEY(payment_id)
        REFERENCES payment(payment_id)
);

CREATE TABLE carrier (
    carrier_id   BIGSERIAL PRIMARY KEY,
    carrier_name VARCHAR(100),
    email        VARCHAR(100),
    phone        VARCHAR(20)
);

CREATE TABLE shipment (
    shipment_id     BIGSERIAL PRIMARY KEY,
    carrier_id      BIGINT NOT NULL,
    warehouse_id    BIGINT NOT NULL,
    order_id        BIGINT NOT NULL,
    shipment_status VARCHAR(30),
    shipment_at     TIMESTAMP,
    estimated_at    TIMESTAMP,
    tracking_number VARCHAR(100) UNIQUE,

    CONSTRAINT fk_shipment_carrier
        FOREIGN KEY(carrier_id)
        REFERENCES carrier(carrier_id),

    CONSTRAINT fk_shipment_warehouse
        FOREIGN KEY(warehouse_id)
        REFERENCES warehouse(warehouse_id),

    CONSTRAINT fk_shipment_order
        FOREIGN KEY(order_id)
        REFERENCES orders(order_id)
);

CREATE INDEX idx_customer_address_customer ON customer_address(customer_id);
CREATE INDEX idx_product_category ON product(category_id);
CREATE INDEX idx_product_variant_product ON product_variant(product_id);
CREATE INDEX idx_inventory_warehouse ON inventory(warehouse_id);
CREATE INDEX idx_inventory_variant ON inventory(product_variant_id);
CREATE INDEX idx_orders_customer ON orders(customer_id);
CREATE INDEX idx_orders_address ON orders(ca_id);
CREATE INDEX idx_order_item_order ON order_item(order_id);
CREATE INDEX idx_order_item_variant ON order_item(product_variant_id);
CREATE INDEX idx_payment_order ON payment(order_id);
CREATE INDEX idx_payment_attempt_payment ON payment_attempt(payment_id);
CREATE INDEX idx_shipment_order ON shipment(order_id);
CREATE INDEX idx_shipment_carrier ON shipment(carrier_id);
CREATE INDEX idx_shipment_warehouse ON shipment(warehouse_id);