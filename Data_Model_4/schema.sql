CREATE TABLE guest (
    guest_id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    phone_number VARCHAR(20),
    is_active BOOLEAN DEFAULT TRUE,
    email_id VARCHAR(255) UNIQUE NOT NULL
);

CREATE TABLE property (
    property_id BIGSERIAL PRIMARY KEY,
    location VARCHAR(255) NOT NULL,
    property_name VARCHAR(150) NOT NULL
);

CREATE TABLE room_type (
    room_type_id BIGSERIAL PRIMARY KEY,
    property_id BIGINT NOT NULL REFERENCES property(property_id),
    type VARCHAR(100) NOT NULL
);

CREATE TABLE room_type_availability (
    room_type_availability_id BIGSERIAL PRIMARY KEY,
    room_type_id BIGINT NOT NULL REFERENCES room_type(room_type_id),
    date DATE NOT NULL,
    available_rooms INTEGER NOT NULL CHECK (available_rooms >= 0),
    UNIQUE (room_type_id, date)
);

CREATE TABLE pricing (
    pricing_id BIGSERIAL PRIMARY KEY,
    room_type_id BIGINT NOT NULL REFERENCES room_type(room_type_id),
    date DATE NOT NULL,
    cost NUMERIC(12,2) NOT NULL CHECK (cost >= 0),
    currency_type VARCHAR(10) NOT NULL,
    UNIQUE (room_type_id, date, currency_type)
);

CREATE TABLE pricing_rule (
    pricing_rule_id BIGSERIAL PRIMARY KEY,
    room_type_id BIGINT NOT NULL REFERENCES room_type(room_type_id),
    rule_type VARCHAR(50) NOT NULL,
    increment_price NUMERIC(12,2) NOT NULL CHECK (increment_price >= 0)
);

CREATE TABLE booking (
    booking_id BIGSERIAL PRIMARY KEY,
    room_type_id BIGINT NOT NULL REFERENCES room_type(room_type_id),
    property_id BIGINT NOT NULL REFERENCES property(property_id),
    status VARCHAR(30) NOT NULL,
    check_in DATE NOT NULL,
    guest_id BIGINT NOT NULL REFERENCES guest(guest_id),
    check_out DATE NOT NULL,
    CHECK (check_out > check_in)
);

CREATE TABLE review (
    review_id BIGSERIAL PRIMARY KEY,
    property_id BIGINT NOT NULL REFERENCES property(property_id),
    guest_id BIGINT NOT NULL REFERENCES guest(guest_id),
    booking_id BIGINT NOT NULL REFERENCES booking(booking_id),
    rating SMALLINT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    rater VARCHAR(20) NOT NULL CHECK (rater IN ('GUEST', 'HOST')),
    given_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);