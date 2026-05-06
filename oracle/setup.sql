-- Active: 1775368893332@@127.0.0.1@1521@FREEPDB1@SYSTEM
-- =======================================================================================
-- PHẦN 1: KHỞI TẠO DATABASE VÀ DỌN DẸP (Oracle SQL)
-- =======================================================================================

-- Xóa các đối tượng cũ theo thứ tự đúng (Oracle không có DROP IF EXISTS)
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE RATING CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE FREESHIP_VOUCHER CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE SHOP_VOUCHER CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE PRODUCT_VOUCHER CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE VOUCHER CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE CONFIRM_DELIVERY CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE DELIVERY CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE CONFIRM_PAYMENT CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE PAYMENT CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE BELONG CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE ORDER_DETAIL CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE ORDERS CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE CATEGORIZE CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE CART_DETAIL CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE CART CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE MEDIA CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE USER_COMMENTS CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE REVIEW CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE FOLLOW CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE SELLER CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE BUYER CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE PRODUCT CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE CATEGORY CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE USERS CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

-- Xóa sequences
BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE SEQ_USERS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE SEQ_PRODUCT';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE SEQ_ORDERS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE SEQ_VOUCHER';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE SEQ_CART';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE SEQ_CATEGORY';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE SEQ_REVIEW';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE SEQ_PAYMENT';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE SEQ_DELIVERY';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE SEQ_CART_DETAIL';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE SEQ_ORDER_DETAIL';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE SEQ_RATING';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE SEQ_MEDIA';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

-- Xóa stored functions và procedures
BEGIN
    EXECUTE IMMEDIATE 'DROP FUNCTION FN_CalculateBuyerLoyaltyPoints';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP FUNCTION FN_CalculateTotalSellerSalesValue';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP PROCEDURE insert_user';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP PROCEDURE update_user';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP PROCEDURE delete_user';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP PROCEDURE insert_product';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP PROCEDURE update_product';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP PROCEDURE delete_product';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP PROCEDURE SP_GetCustomerOrders';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP PROCEDURE SP_AnalyzeShopSalesQuantity';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

-- Xóa triggers
BEGIN
    EXECUTE IMMEDIATE 'DROP TRIGGER TG_RATING_CheckDelivered';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TRIGGER update_rating_avg_after_insert';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TRIGGER update_rating_avg_after_update';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TRIGGER update_rating_avg_after_delete';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TRIGGER TG_USERS_AutoID';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TRIGGER TG_PRODUCT_AutoID';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TRIGGER TG_ORDERS_AutoID';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TRIGGER TG_VOUCHER_AutoID';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TRIGGER TG_CART_AutoID';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TRIGGER TG_REVIEW_AutoID';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TRIGGER TG_PAYMENT_AutoID';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TRIGGER TG_DELIVERY_AutoID';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TRIGGER TG_CATEGORY_AutoID';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TRIGGER TG_RATING_AutoID';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TRIGGER TG_CART_DETAIL_AutoID';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TRIGGER TG_ORDER_DETAIL_AutoID';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

-- =======================================================================================
-- PHẦN 2: TẠO SEQUENCES
-- =======================================================================================
CREATE SEQUENCE SEQ_USERS START WITH 1 INCREMENT BY 1 NOMAXVALUE NOCYCLE;
CREATE SEQUENCE SEQ_PRODUCT START WITH 1 INCREMENT BY 1 NOMAXVALUE NOCYCLE;
CREATE SEQUENCE SEQ_ORDERS START WITH 1 INCREMENT BY 1 NOMAXVALUE NOCYCLE;
CREATE SEQUENCE SEQ_VOUCHER START WITH 1 INCREMENT BY 1 NOMAXVALUE NOCYCLE;
CREATE SEQUENCE SEQ_CART START WITH 1 INCREMENT BY 1 NOMAXVALUE NOCYCLE;
CREATE SEQUENCE SEQ_CATEGORY START WITH 1 INCREMENT BY 1 NOMAXVALUE NOCYCLE;
CREATE SEQUENCE SEQ_REVIEW START WITH 1 INCREMENT BY 1 NOMAXVALUE NOCYCLE;
CREATE SEQUENCE SEQ_PAYMENT START WITH 1 INCREMENT BY 1 NOMAXVALUE NOCYCLE;
CREATE SEQUENCE SEQ_DELIVERY START WITH 1 INCREMENT BY 1 NOMAXVALUE NOCYCLE;
CREATE SEQUENCE SEQ_CART_DETAIL START WITH 1 INCREMENT BY 1 NOMAXVALUE NOCYCLE;
CREATE SEQUENCE SEQ_ORDER_DETAIL START WITH 1 INCREMENT BY 1 NOMAXVALUE NOCYCLE;
CREATE SEQUENCE SEQ_RATING START WITH 1 INCREMENT BY 1 NOMAXVALUE NOCYCLE;
CREATE SEQUENCE SEQ_MEDIA START WITH 1 INCREMENT BY 1 NOMAXVALUE NOCYCLE;

-- =======================================================================================
-- PHẦN 3: TẠO CẤU TRÚC BẢNG (TABLES)
-- =======================================================================================

-- Bảng USERS
CREATE TABLE USERS (
    user_id VARCHAR2(20) PRIMARY KEY,
    first_name VARCHAR2(255) NOT NULL,
    last_name VARCHAR2(255) NOT NULL,
    username VARCHAR2(255) NOT NULL UNIQUE,
    password VARCHAR2(255) NOT NULL,
    birthday DATE,
    sex VARCHAR2(20) CHECK (sex IN ('Nam', 'Nữ', 'Không trả lời')),
    address VARCHAR2(255) NOT NULL,
    phone_number VARCHAR2(15) NOT NULL,
    email VARCHAR2(50) NOT NULL UNIQUE,
    role VARCHAR2(10) CHECK (role IN ('buyer', 'seller')) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_phone_number CHECK (REGEXP_LIKE(phone_number, '^[0-9+]+$')),
    CONSTRAINT chk_email CHECK (REGEXP_LIKE(email, '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'))
);

-- Bảng BUYER
CREATE TABLE BUYER (
    user_id VARCHAR2(20) NOT NULL PRIMARY KEY,
    CONSTRAINT fk_buyer_user FOREIGN KEY (user_id) REFERENCES USERS (user_id) ON DELETE CASCADE
);

-- Bảng SELLER
CREATE TABLE SELLER (
    user_id VARCHAR2(20) NOT NULL PRIMARY KEY,
    shop_name VARCHAR2(255) NOT NULL,
    CONSTRAINT fk_seller_user FOREIGN KEY (user_id) REFERENCES USERS (user_id) ON DELETE CASCADE
);

-- Bảng CATEGORY
CREATE TABLE CATEGORY (
    category_id VARCHAR2(20) PRIMARY KEY,
    name VARCHAR2(255) NOT NULL,
    description CLOB
);

-- Bảng PRODUCT
CREATE TABLE PRODUCT (
    product_id VARCHAR2(20) PRIMARY KEY,
    user_id VARCHAR2(20) NOT NULL,
    name VARCHAR2(255) NOT NULL,
    weight NUMBER,
    product_size VARCHAR2(255),
    origin VARCHAR2(255) NOT NULL,
    brand VARCHAR2(255),
    description CLOB,
    price NUMBER(18, 2) NOT NULL,
    stock_quantity NUMBER DEFAULT 0 NOT NULL,
    rating_avg NUMBER(3, 2) DEFAULT 0.0,
    image_url VARCHAR2(2000),
    status VARCHAR2(20) DEFAULT 'active' NOT NULL CHECK (status IN ('active', 'inactive', 'out_of_stock')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_product_seller FOREIGN KEY (user_id) REFERENCES SELLER (user_id)
);

-- Bảng VOUCHER
CREATE TABLE VOUCHER (
    voucher_id VARCHAR2(20) PRIMARY KEY,
    code VARCHAR2(50) NOT NULL UNIQUE,
    description CLOB,
    discount_type VARCHAR2(20) CHECK (discount_type IN ('fixed_amount', 'percentage')) NOT NULL,
    discount_value NUMBER(18, 2) NOT NULL,
    min_purchase NUMBER(18, 2) DEFAULT 0,
    start_date TIMESTAMP NOT NULL,
    end_date TIMESTAMP NOT NULL
);

-- Bảng CART
CREATE TABLE CART (
    cart_id VARCHAR2(20) PRIMARY KEY,
    user_id VARCHAR2(20) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_cart_buyer FOREIGN KEY (user_id) REFERENCES BUYER (user_id) ON DELETE CASCADE
);

-- Bảng ORDERS
CREATE TABLE ORDERS (
    order_id VARCHAR2(20) PRIMARY KEY,
    user_id VARCHAR2(20) NOT NULL,
    status VARCHAR2(20) DEFAULT 'pending' NOT NULL CHECK (status IN ('pending', 'processing', 'shipped', 'delivered', 'cancelled')),
    delivery_address VARCHAR2(255) NOT NULL,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_orders_buyer FOREIGN KEY (user_id) REFERENCES BUYER (user_id)
);

-- Bảng REVIEW
CREATE TABLE REVIEW (
    review_id VARCHAR2(20) PRIMARY KEY,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    content CLOB NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    title VARCHAR2(255) NOT NULL
);

-- Bảng CART_DETAIL
CREATE TABLE CART_DETAIL (
    cart_item_id VARCHAR2(20) PRIMARY KEY,
    cart_id VARCHAR2(20) NOT NULL,
    product_id VARCHAR2(20) NOT NULL,
    quantity NUMBER NOT NULL CHECK (quantity > 0),
    price_at_add NUMBER(18, 2) NOT NULL,
    CONSTRAINT uk_cart_product UNIQUE (cart_id, product_id),
    CONSTRAINT fk_cartdetail_cart FOREIGN KEY (cart_id) REFERENCES CART (cart_id) ON DELETE CASCADE,
    CONSTRAINT fk_cartdetail_product FOREIGN KEY (product_id) REFERENCES PRODUCT (product_id)
);

-- Bảng ORDER_DETAIL
CREATE TABLE ORDER_DETAIL (
    order_item_id VARCHAR2(20) PRIMARY KEY,
    order_id VARCHAR2(20) NOT NULL,
    product_id VARCHAR2(20) NOT NULL,
    quantity NUMBER NOT NULL CHECK (quantity > 0),
    price NUMBER(18, 2) NOT NULL,
    payment_method VARCHAR2(255) NOT NULL,
    CONSTRAINT uk_order_product UNIQUE (order_id, product_id),
    CONSTRAINT fk_orderdetail_order FOREIGN KEY (order_id) REFERENCES ORDERS (order_id),
    CONSTRAINT fk_orderdetail_product FOREIGN KEY (product_id) REFERENCES PRODUCT (product_id)
);

-- Bảng BELONG
CREATE TABLE BELONG (
    product_id VARCHAR2(20) NOT NULL,
    category_id VARCHAR2(20) NOT NULL,
    PRIMARY KEY (product_id, category_id),
    CONSTRAINT fk_belong_product FOREIGN KEY (product_id) REFERENCES PRODUCT (product_id),
    CONSTRAINT fk_belong_category FOREIGN KEY (category_id) REFERENCES CATEGORY (category_id)
);

-- Bảng COMMENT
CREATE TABLE USER_COMMENTS (
    user_id VARCHAR2(20) NOT NULL,
    product_id VARCHAR2(20) NOT NULL,
    review_id VARCHAR2(20) NOT NULL,
    PRIMARY KEY (user_id, product_id, review_id),
    CONSTRAINT fk_comment_product FOREIGN KEY (product_id) REFERENCES PRODUCT (product_id),
    CONSTRAINT fk_comment_user FOREIGN KEY (user_id) REFERENCES USERS (user_id),
    CONSTRAINT fk_comment_review FOREIGN KEY (review_id) REFERENCES REVIEW (review_id)
);

-- Bảng FOLLOW
CREATE TABLE FOLLOW (
    buyer_id VARCHAR2(20) NOT NULL,
    seller_id VARCHAR2(20) NOT NULL,
    PRIMARY KEY (buyer_id, seller_id),
    CONSTRAINT fk_follow_buyer FOREIGN KEY (buyer_id) REFERENCES BUYER (user_id) ON DELETE CASCADE,
    CONSTRAINT fk_follow_seller FOREIGN KEY (seller_id) REFERENCES SELLER (user_id) ON DELETE CASCADE
);

-- Bảng MEDIA
CREATE TABLE MEDIA (
    media_id NUMBER PRIMARY KEY,
    review_id VARCHAR2(20) NOT NULL,
    media_url VARCHAR2(2000) NOT NULL,
    media_type VARCHAR2(10) CHECK (media_type IN ('image', 'video')) NOT NULL,
    CONSTRAINT fk_media_review FOREIGN KEY (review_id) REFERENCES REVIEW (review_id)
);

-- Bảng CATEGORIZE
CREATE TABLE CATEGORIZE (
    child_id VARCHAR2(20) NOT NULL,
    parent_id VARCHAR2(20) NOT NULL,
    PRIMARY KEY (child_id, parent_id),
    CONSTRAINT fk_categorize_child FOREIGN KEY (child_id) REFERENCES CATEGORY (category_id),
    CONSTRAINT fk_categorize_parent FOREIGN KEY (parent_id) REFERENCES CATEGORY (category_id)
);

-- Bảng PAYMENT
CREATE TABLE PAYMENT (
    payment_id VARCHAR2(20) PRIMARY KEY,
    status VARCHAR2(50) NOT NULL,
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    method VARCHAR2(255) NOT NULL,
    amount NUMBER(10, 2) NOT NULL
);

-- Bảng CONFIRM_PAYMENT
CREATE TABLE CONFIRM_PAYMENT (
    payment_id VARCHAR2(20) NOT NULL,
    order_id VARCHAR2(20) NOT NULL,
    PRIMARY KEY (payment_id, order_id),
    CONSTRAINT fk_confirmpayment_payment FOREIGN KEY (payment_id) REFERENCES PAYMENT (payment_id),
    CONSTRAINT fk_confirmpayment_order FOREIGN KEY (order_id) REFERENCES ORDERS (order_id)
);

-- Bảng DELIVERY
CREATE TABLE DELIVERY (
    delivery_id VARCHAR2(20) PRIMARY KEY,
    delivery_status VARCHAR2(20) DEFAULT 'pending' NOT NULL CHECK (delivery_status IN ('pending', 'in_transit', 'delivered', 'failed', 'shipped', 'cancelled')),
    courier_name VARCHAR2(50) NOT NULL,
    delivering_fee NUMBER(18, 2) NOT NULL
);

-- Bảng CONFIRM_DELIVERY
CREATE TABLE CONFIRM_DELIVERY (
    delivery_id VARCHAR2(20) NOT NULL,
    order_id VARCHAR2(20) NOT NULL,
    expected_delivery_date TIMESTAMP NOT NULL,
    PRIMARY KEY (delivery_id, order_id),
    CONSTRAINT fk_confirmdelivery_delivery FOREIGN KEY (delivery_id) REFERENCES DELIVERY (delivery_id),
    CONSTRAINT fk_confirmdelivery_order FOREIGN KEY (order_id) REFERENCES ORDERS (order_id)
);

-- Bảng PRODUCT_VOUCHER
CREATE TABLE PRODUCT_VOUCHER (
    voucher_id VARCHAR2(20) NOT NULL,
    product_id VARCHAR2(20) NOT NULL,
    PRIMARY KEY (voucher_id, product_id),
    CONSTRAINT fk_productvoucher_voucher FOREIGN KEY (voucher_id) REFERENCES VOUCHER (voucher_id),
    CONSTRAINT fk_productvoucher_product FOREIGN KEY (product_id) REFERENCES PRODUCT (product_id)
);

-- Bảng SHOP_VOUCHER
CREATE TABLE SHOP_VOUCHER (
    voucher_id VARCHAR2(20) NOT NULL,
    seller_id VARCHAR2(20) NOT NULL,
    PRIMARY KEY (voucher_id, seller_id),
    CONSTRAINT fk_shopvoucher_voucher FOREIGN KEY (voucher_id) REFERENCES VOUCHER (voucher_id),
    CONSTRAINT fk_shopvoucher_seller FOREIGN KEY (seller_id) REFERENCES SELLER (user_id)
);

-- Bảng FREESHIP_VOUCHER
CREATE TABLE FREESHIP_VOUCHER (
    voucher_id VARCHAR2(20) NOT NULL PRIMARY KEY,
    CONSTRAINT fk_freshshipvoucher_voucher FOREIGN KEY (voucher_id) REFERENCES VOUCHER (voucher_id)
);

-- Bảng RATING
CREATE TABLE RATING (
    rating_id VARCHAR2(20) PRIMARY KEY,
    review_id VARCHAR2(20) NOT NULL UNIQUE,
    score NUMBER NOT NULL CHECK (score BETWEEN 1 AND 5),
    packaging NUMBER NOT NULL CHECK (packaging BETWEEN 1 AND 5),
    delivery NUMBER NOT NULL CHECK (delivery BETWEEN 1 AND 5),
    quality NUMBER NOT NULL CHECK (quality BETWEEN 1 AND 5),
    CONSTRAINT fk_rating_review FOREIGN KEY (review_id) REFERENCES REVIEW (review_id)
);

-- =======================================================================================
-- PHẦN 4: TẠO INDEX
-- =======================================================================================
-- CREATE INDEX idx_users_email ON USERS(email);
-- CREATE INDEX idx_users_username ON USERS(username);
CREATE INDEX idx_product_user_id ON PRODUCT(user_id);
CREATE INDEX idx_product_name ON PRODUCT(name);
CREATE INDEX idx_product_status ON PRODUCT(status);
CREATE INDEX idx_orders_user_id ON ORDERS(user_id);
CREATE INDEX idx_orders_status ON ORDERS(status);
CREATE INDEX idx_orders_order_date ON ORDERS(order_date);
-- CREATE INDEX idx_cart_user_id ON CART(user_id);
CREATE INDEX idx_orderdetail_order_id ON ORDER_DETAIL(order_id);
CREATE INDEX idx_orderdetail_product_id ON ORDER_DETAIL(product_id);
CREATE INDEX idx_cartdetail_cart_id ON CART_DETAIL(cart_id);
CREATE INDEX idx_cartdetail_product_id ON CART_DETAIL(product_id);
CREATE INDEX idx_payment_status ON PAYMENT(status);
CREATE INDEX idx_delivery_status ON DELIVERY(delivery_status);
-- CREATE INDEX idx_voucher_code ON VOUCHER(code);
CREATE INDEX idx_voucher_date ON VOUCHER(start_date, end_date);
CREATE INDEX idx_comment_product_id ON USER_COMMENTS(product_id);
CREATE INDEX idx_comment_user_id ON USER_COMMENTS(user_id);

-- =======================================================================================
-- PHẦN 5: TẠO FUNCTIONS (Oracle)
-- =======================================================================================

-- Function: FN_CalculateBuyerLoyaltyPoints
CREATE OR REPLACE FUNCTION FN_CalculateBuyerLoyaltyPoints(p_buyer_id VARCHAR2)
RETURN INT
IS
    v_total_points INT := 0;
    v_order_value NUMBER(18, 2);
    v_count INT := 0;
BEGIN
    SELECT COUNT(*) INTO v_count FROM BUYER WHERE user_id = p_buyer_id;
    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Mã người dùng không tồn tại hoặc không phải là người mua.');
    END IF;

    FOR delivered_order IN (SELECT order_id FROM ORDERS WHERE user_id = p_buyer_id AND status = 'delivered') LOOP
        SELECT COALESCE(SUM(price * quantity), 0) INTO v_order_value 
        FROM ORDER_DETAIL WHERE order_id = delivered_order.order_id;
        
        IF v_order_value >= 100000 THEN 
            v_total_points := v_total_points + FLOOR(v_order_value / 100000); 
        END IF;
    END LOOP;
    
    RETURN v_total_points;
EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
END FN_CalculateBuyerLoyaltyPoints;
/

-- Function: FN_CalculateTotalSellerSalesValue
CREATE OR REPLACE FUNCTION FN_CalculateTotalSellerSalesValue(p_seller_id VARCHAR2, p_start_date DATE, p_end_date DATE)
RETURN NUMBER
IS
    v_total_sales NUMBER(18, 2) := 0;
    v_count INT := 0;
BEGIN
    SELECT COUNT(*) INTO v_count FROM SELLER WHERE user_id = p_seller_id;
    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Mã người bán không tồn tại.');
    END IF;
    
    IF p_start_date IS NULL OR p_end_date IS NULL OR p_start_date > p_end_date THEN
        RAISE_APPLICATION_ERROR(-20001, 'Ngày không hợp lệ.');
    END IF;

    SELECT COALESCE(SUM(OD.price * OD.quantity), 0) INTO v_total_sales
    FROM ORDER_DETAIL OD
    JOIN PRODUCT P ON OD.product_id = P.product_id
    JOIN ORDERS O ON OD.order_id = O.order_id
    WHERE P.user_id = p_seller_id 
      AND O.status = 'delivered' 
      AND TRUNC(O.order_date) BETWEEN p_start_date AND p_end_date;
    
    RETURN v_total_sales;
EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
END FN_CalculateTotalSellerSalesValue;
/

-- =======================================================================================
-- PHẦN 6: TẠO PROCEDURES (Oracle)
-- =======================================================================================

-- 1.1 Insert User
CREATE OR REPLACE PROCEDURE insert_user(
    p_first_name IN VARCHAR2,
    p_last_name IN VARCHAR2,
    p_username IN VARCHAR2,
    p_password IN VARCHAR2,
    p_birthday IN DATE,
    p_sex IN VARCHAR2,
    p_address IN VARCHAR2,
    p_phone_number IN VARCHAR2,
    p_email IN VARCHAR2,
    p_role IN VARCHAR2,
    p_shop_name IN VARCHAR2,
    p_new_user_id OUT VARCHAR2
)
IS
    v_count INT;
    v_final_shop_name VARCHAR2(255);
BEGIN
    SELECT COUNT(*) INTO v_count FROM USERS WHERE username = p_username;
    IF v_count > 0 THEN 
        RAISE_APPLICATION_ERROR(-20001, 'Tên đăng nhập đã tồn tại.'); 
    END IF;

    SELECT COUNT(*) INTO v_count FROM USERS WHERE email = p_email;
    IF v_count > 0 THEN 
        RAISE_APPLICATION_ERROR(-20001, 'Email đã được sử dụng.'); 
    END IF;

    IF p_role = 'seller' THEN
        IF p_shop_name IS NULL OR TRIM(p_shop_name) = '' THEN 
            v_final_shop_name := p_first_name || ' ' || p_last_name || ' Shop';
        ELSE 
            v_final_shop_name := p_shop_name; 
        END IF;
    END IF;

    SELECT 'U' || TO_CHAR(SYSDATE, 'YY') || LPAD(SEQ_USERS.NEXTVAL, 5, '0') INTO p_new_user_id FROM DUAL;

    INSERT INTO USERS (user_id, first_name, last_name, username, password, birthday, sex, address, phone_number, email, role, created_at) 
    VALUES (p_new_user_id, p_first_name, p_last_name, p_username, p_password, p_birthday, p_sex, p_address, p_phone_number, p_email, p_role, SYSTIMESTAMP);

    IF p_role = 'buyer' THEN 
        INSERT INTO BUYER(user_id) VALUES (p_new_user_id);
    ELSIF p_role = 'seller' THEN 
        INSERT INTO SELLER(user_id, shop_name) VALUES (p_new_user_id, v_final_shop_name);
    END IF;
    
    COMMIT;
END insert_user;
/

-- 1.2 Update User
CREATE OR REPLACE PROCEDURE update_user(
    p_user_id IN VARCHAR2,
    p_first_name IN VARCHAR2,
    p_last_name IN VARCHAR2,
    p_username IN VARCHAR2,
    p_password IN VARCHAR2,
    p_birthday IN DATE,
    p_sex IN VARCHAR2,
    p_address IN VARCHAR2,
    p_phone_number IN VARCHAR2,
    p_email IN VARCHAR2
)
IS
    v_count INT;
BEGIN
    SELECT COUNT(*) INTO v_count FROM USERS WHERE user_id = p_user_id;
    IF v_count = 0 THEN 
        RAISE_APPLICATION_ERROR(-20001, 'Người dùng không tồn tại.'); 
    END IF;

    UPDATE USERS
    SET first_name = p_first_name, 
        last_name = p_last_name, 
        username = p_username,
        password = NVL(p_password, password),
        birthday = p_birthday, 
        sex = p_sex, 
        address = p_address, 
        phone_number = p_phone_number,
        email = p_email, 
        updated_at = SYSTIMESTAMP
    WHERE user_id = p_user_id;
    
    COMMIT;
END update_user;
/

-- 1.3 Delete User
CREATE OR REPLACE PROCEDURE delete_user(p_user_id IN VARCHAR2)
IS
    v_count INT;
BEGIN
    SELECT COUNT(*) INTO v_count FROM USERS WHERE user_id = p_user_id;
    IF v_count = 0 THEN 
        RAISE_APPLICATION_ERROR(-20001, 'Người dùng không tồn tại.'); 
    END IF;

    SELECT COUNT(*) INTO v_count FROM ORDERS WHERE user_id = p_user_id;
    IF v_count > 0 THEN 
        RAISE_APPLICATION_ERROR(-20001, 'Không thể xóa người dùng đã có đơn hàng.'); 
    END IF;

    DELETE FROM FOLLOW WHERE buyer_id = p_user_id OR seller_id = p_user_id;
    DELETE FROM CART WHERE user_id = p_user_id;
    DELETE FROM SELLER WHERE user_id = p_user_id;
    DELETE FROM BUYER WHERE user_id = p_user_id;
    DELETE FROM USERS WHERE user_id = p_user_id;
    
    COMMIT;
END delete_user;
/

-- 2.1 Insert Product
CREATE OR REPLACE PROCEDURE insert_product(
    p_user_id IN VARCHAR2,
    p_name IN VARCHAR2,
    p_weight IN FLOAT,
    p_size IN VARCHAR2,
    p_origin IN VARCHAR2,
    p_brand IN VARCHAR2,
    p_description IN CLOB,
    p_price IN NUMBER,
    p_stock_quantity IN INT,
    p_image_url IN VARCHAR2,
    p_new_product_id OUT VARCHAR2
)
IS
    v_count INT;
BEGIN
    SELECT COUNT(*) INTO v_count FROM SELLER WHERE user_id = p_user_id;
    IF v_count = 0 THEN 
        RAISE_APPLICATION_ERROR(-20001, 'Người bán không tồn tại.'); 
    END IF;

    SELECT 'P' || TO_CHAR(SYSDATE, 'YY') || LPAD(SEQ_PRODUCT.NEXTVAL, 5, '0') INTO p_new_product_id FROM DUAL;

    INSERT INTO PRODUCT (product_id, user_id, name, weight, product_size, origin, brand, description, price, stock_quantity, image_url, status, created_at) 
    VALUES (p_new_product_id, p_user_id, p_name, p_weight, p_size, p_origin, p_brand, p_description, p_price, p_stock_quantity, p_image_url, 'active', SYSTIMESTAMP);
    
    COMMIT;
END insert_product;
/

-- 2.2 Update Product
CREATE OR REPLACE PROCEDURE update_product(
    p_product_id IN VARCHAR2,
    p_user_id IN VARCHAR2,
    p_name IN VARCHAR2,
    p_weight IN FLOAT,
    p_size IN VARCHAR2,
    p_origin IN VARCHAR2,
    p_brand IN VARCHAR2,
    p_description IN CLOB,
    p_price IN NUMBER,
    p_stock_quantity IN INT,
    p_image_url IN VARCHAR2,
    p_status IN VARCHAR2
)
IS
    v_count INT;
BEGIN
    SELECT COUNT(*) INTO v_count FROM PRODUCT WHERE product_id = p_product_id AND user_id = p_user_id;
    IF v_count = 0 THEN 
        RAISE_APPLICATION_ERROR(-20001, 'Sản phẩm không tồn tại hoặc không thuộc sở hữu.'); 
    END IF;

    UPDATE PRODUCT
    SET name = p_name, 
        weight = p_weight, 
        product_size = p_size, 
        origin = p_origin, 
        brand = p_brand,
        description = p_description, 
        price = p_price, 
        stock_quantity = p_stock_quantity,
        image_url = p_image_url, 
        status = p_status, 
        updated_at = SYSTIMESTAMP
    WHERE product_id = p_product_id;
    
    COMMIT;
END update_product;
/

-- 2.3 Delete Product
CREATE OR REPLACE PROCEDURE delete_product(
    p_product_id IN VARCHAR2,
    p_user_id IN VARCHAR2
)
IS
    v_count INT;
BEGIN
    SELECT COUNT(*) INTO v_count FROM PRODUCT WHERE product_id = p_product_id AND user_id = p_user_id;
    IF v_count = 0 THEN 
        RAISE_APPLICATION_ERROR(-20001, 'Sản phẩm không tồn tại hoặc không thuộc sở hữu.'); 
    END IF;

    SELECT COUNT(*) INTO v_count FROM ORDER_DETAIL WHERE product_id = p_product_id;
    IF v_count > 0 THEN 
        RAISE_APPLICATION_ERROR(-20001, 'Không thể xóa sản phẩm đã có đơn hàng.'); 
    END IF;

    DELETE FROM BELONG WHERE product_id = p_product_id;
    DELETE FROM CART_DETAIL WHERE product_id = p_product_id;
    DELETE FROM PRODUCT_VOUCHER WHERE product_id = p_product_id;
    DELETE FROM PRODUCT WHERE product_id = p_product_id;
    
    COMMIT;
END delete_product;
/

-- 3.1 SP_GetCustomerOrders
CREATE OR REPLACE PROCEDURE SP_GetCustomerOrders (
    p_user_id IN VARCHAR2,
    p_status IN VARCHAR2
)
IS
    v_count INT := 0;
BEGIN
    SELECT COUNT(*) INTO v_count FROM BUYER WHERE user_id = p_user_id;
    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'User ID không tồn tại hoặc không phải là người mua.');
    END IF;

    FOR rec IN (
        SELECT U.first_name, U.last_name, O.order_id, O.order_date, O.status, O.delivery_address
        FROM USERS U 
        JOIN ORDERS O ON U.user_id = O.user_id
        WHERE U.user_id = p_user_id AND (p_status IS NULL OR O.status = p_status)
        ORDER BY O.order_date DESC
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(rec.order_id || ' - ' || rec.status);
    END LOOP;
END SP_GetCustomerOrders;
/

-- 3.2 SP_AnalyzeShopSalesQuantity
CREATE OR REPLACE PROCEDURE SP_AnalyzeShopSalesQuantity (p_min_quantity INT)
IS
BEGIN
    IF p_min_quantity <= 0 THEN 
        RAISE_APPLICATION_ERROR(-20001, 'Số lượng tối thiểu > 0.'); 
    END IF;

    FOR rec IN (
        SELECT S.shop_name, SUM(OD.quantity) AS TotalQuantitySold, COUNT(DISTINCT OD.order_id) AS TotalOrders
        FROM SELLER S 
        JOIN PRODUCT P ON S.user_id = P.user_id 
        JOIN ORDER_DETAIL OD ON P.product_id = OD.product_id
        WHERE P.status = 'active' 
        GROUP BY S.shop_name 
        HAVING SUM(OD.quantity) >= p_min_quantity 
        ORDER BY TotalQuantitySold DESC
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(rec.shop_name || ' - ' || rec.TotalQuantitySold);
    END LOOP;
END SP_AnalyzeShopSalesQuantity;
/

-- =======================================================================================
-- PHẦN 7: TẠO TRIGGERS (Oracle)
-- =======================================================================================

-- Trigger kiểm tra đơn hàng delivered trước khi insert RATING
CREATE OR REPLACE TRIGGER TG_RATING_CheckDelivered
BEFORE INSERT ON RATING
FOR EACH ROW
DECLARE
    v_user_id VARCHAR2(20);
    v_product_id VARCHAR2(20);
    v_delivered_count INT;
    v_count INT;
BEGIN
    SELECT COUNT(*) INTO v_count FROM USER_COMMENTS WHERE review_id = :NEW.review_id;
    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Review không tồn tại trong bảng USER_COMMENTS.');
    END IF;
    
    SELECT c.user_id, c.product_id INTO v_user_id, v_product_id 
    FROM USER_COMMENTS c WHERE c.review_id = :NEW.review_id;
    
    SELECT COUNT(o.order_id) INTO v_delivered_count 
    FROM ORDERS o 
    JOIN ORDER_DETAIL od ON o.order_id = od.order_id
    WHERE o.user_id = v_user_id 
      AND od.product_id = v_product_id 
      AND o.status = 'delivered';
    
    IF v_delivered_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Chỉ được đánh giá sản phẩm đã giao thành công.');
    END IF;
END TG_RATING_CheckDelivered;
/

-- Trigger cập nhật rating_avg sau khi insert RATING
CREATE OR REPLACE TRIGGER update_rating_avg_after_insert
AFTER INSERT ON RATING FOR EACH ROW
DECLARE
    avg_rating NUMBER(3,2);
    v_product_id VARCHAR2(20);
    v_count INT;
BEGIN
    SELECT COUNT(*) INTO v_count FROM USER_COMMENTS WHERE review_id = :NEW.review_id;
    IF v_count > 0 THEN
        SELECT product_id INTO v_product_id FROM USER_COMMENTS WHERE review_id = :NEW.review_id;
        
        SELECT AVG(r.score) INTO avg_rating 
        FROM RATING r 
        JOIN USER_COMMENTS c ON r.review_id = c.review_id 
        WHERE c.product_id = v_product_id;
        
        UPDATE PRODUCT SET rating_avg = NVL(avg_rating,0) WHERE product_id = v_product_id;
    END IF;
END update_rating_avg_after_insert;
/

-- Trigger cập nhật rating_avg sau khi update RATING
CREATE OR REPLACE TRIGGER update_rating_avg_after_update
AFTER UPDATE ON RATING FOR EACH ROW
DECLARE
    avg_rating NUMBER(3,2);
    v_product_id VARCHAR2(20);
    v_count INT;
BEGIN
    IF :OLD.score <> :NEW.score THEN
        SELECT COUNT(*) INTO v_count FROM USER_COMMENTS WHERE review_id = :NEW.review_id;
        IF v_count > 0 THEN
            SELECT product_id INTO v_product_id FROM USER_COMMENTS WHERE review_id = :NEW.review_id;
            
            SELECT AVG(r.score) INTO avg_rating 
            FROM RATING r 
            JOIN USER_COMMENTS c ON r.review_id = c.review_id 
            WHERE c.product_id = v_product_id;
            
            UPDATE PRODUCT SET rating_avg = NVL(avg_rating,0) WHERE product_id = v_product_id;
        END IF;
    END IF;
END update_rating_avg_after_update;
/

-- Trigger cập nhật rating_avg sau khi delete RATING
CREATE OR REPLACE TRIGGER update_rating_avg_after_delete
AFTER DELETE ON RATING FOR EACH ROW
DECLARE
    avg_rating NUMBER(3,2);
    v_product_id VARCHAR2(20);
    v_count INT;
BEGIN
    SELECT COUNT(*) INTO v_count FROM USER_COMMENTS WHERE review_id = :OLD.review_id;
    IF v_count > 0 THEN
        SELECT product_id INTO v_product_id FROM USER_COMMENTS WHERE review_id = :OLD.review_id;
        
        SELECT AVG(r.score) INTO avg_rating 
        FROM RATING r 
        JOIN USER_COMMENTS c ON r.review_id = c.review_id 
        WHERE c.product_id = v_product_id;
        
        UPDATE PRODUCT SET rating_avg = NVL(avg_rating,0) WHERE product_id = v_product_id;
    END IF;
END update_rating_avg_after_delete;
/

-- Trigger sinh ID cho USERS
CREATE OR REPLACE TRIGGER TG_USERS_AutoID
BEFORE INSERT ON USERS FOR EACH ROW
BEGIN
    IF :NEW.user_id IS NULL OR :NEW.user_id = '' THEN
        SELECT 'U' || TO_CHAR(SYSDATE, 'YY') || LPAD(SEQ_USERS.NEXTVAL, 5, '0') INTO :NEW.user_id FROM DUAL;
    END IF;
END TG_USERS_AutoID;
/

-- Trigger sinh ID cho PRODUCT
CREATE OR REPLACE TRIGGER TG_PRODUCT_AutoID
BEFORE INSERT ON PRODUCT FOR EACH ROW
BEGIN
    IF :NEW.product_id IS NULL OR :NEW.product_id = '' THEN
        SELECT 'P' || TO_CHAR(SYSDATE, 'YY') || LPAD(SEQ_PRODUCT.NEXTVAL, 5, '0') INTO :NEW.product_id FROM DUAL;
    END IF;
END TG_PRODUCT_AutoID;
/

-- Trigger sinh ID cho ORDERS
CREATE OR REPLACE TRIGGER TG_ORDERS_AutoID
BEFORE INSERT ON ORDERS FOR EACH ROW
BEGIN
    IF :NEW.order_id IS NULL OR :NEW.order_id = '' THEN
        SELECT 'O' || TO_CHAR(SYSDATE, 'YY') || LPAD(SEQ_ORDERS.NEXTVAL, 5, '0') INTO :NEW.order_id FROM DUAL;
    END IF;
END TG_ORDERS_AutoID;
/

-- Trigger sinh ID cho VOUCHER
CREATE OR REPLACE TRIGGER TG_VOUCHER_AutoID
BEFORE INSERT ON VOUCHER FOR EACH ROW
BEGIN
    IF :NEW.voucher_id IS NULL OR :NEW.voucher_id = '' THEN
        SELECT 'V' || TO_CHAR(SYSDATE, 'YY') || LPAD(SEQ_VOUCHER.NEXTVAL, 5, '0') INTO :NEW.voucher_id FROM DUAL;
    END IF;
END TG_VOUCHER_AutoID;
/

-- Trigger sinh ID cho REVIEW
CREATE OR REPLACE TRIGGER TG_REVIEW_AutoID
BEFORE INSERT ON REVIEW FOR EACH ROW
BEGIN
    IF :NEW.review_id IS NULL OR :NEW.review_id = '' THEN
        SELECT 'R' || TO_CHAR(SYSDATE, 'YY') || LPAD(SEQ_REVIEW.NEXTVAL, 5, '0') INTO :NEW.review_id FROM DUAL;
    END IF;
END TG_REVIEW_AutoID;
/

-- Trigger sinh ID cho CART
CREATE OR REPLACE TRIGGER TG_CART_AutoID
BEFORE INSERT ON CART FOR EACH ROW
BEGIN
    IF :NEW.cart_id IS NULL OR :NEW.cart_id = '' THEN
        SELECT 'C' || TO_CHAR(SYSDATE, 'YY') || LPAD(SEQ_CART.NEXTVAL, 5, '0') INTO :NEW.cart_id FROM DUAL;
    END IF;
END TG_CART_AutoID;
/

-- Trigger sinh ID cho PAYMENT
CREATE OR REPLACE TRIGGER TG_PAYMENT_AutoID
BEFORE INSERT ON PAYMENT FOR EACH ROW
BEGIN
    IF :NEW.payment_id IS NULL OR :NEW.payment_id = '' THEN
        SELECT 'M' || TO_CHAR(SYSDATE, 'YY') || LPAD(SEQ_PAYMENT.NEXTVAL, 5, '0') INTO :NEW.payment_id FROM DUAL;
    END IF;
END TG_PAYMENT_AutoID;
/

-- Trigger sinh ID cho DELIVERY
CREATE OR REPLACE TRIGGER TG_DELIVERY_AutoID
BEFORE INSERT ON DELIVERY FOR EACH ROW
BEGIN
    IF :NEW.delivery_id IS NULL OR :NEW.delivery_id = '' THEN
        SELECT 'Y' || TO_CHAR(SYSDATE, 'YY') || LPAD(SEQ_DELIVERY.NEXTVAL, 5, '0') INTO :NEW.delivery_id FROM DUAL;
    END IF;
END TG_DELIVERY_AutoID;
/

-- Trigger sinh ID cho CATEGORY
CREATE OR REPLACE TRIGGER TG_CATEGORY_AutoID
BEFORE INSERT ON CATEGORY FOR EACH ROW
BEGIN
    IF :NEW.category_id IS NULL OR :NEW.category_id = '' THEN
        SELECT 'G' || TO_CHAR(SYSDATE, 'YY') || LPAD(SEQ_CATEGORY.NEXTVAL, 5, '0') INTO :NEW.category_id FROM DUAL;
    END IF;
END TG_CATEGORY_AutoID;
/

-- Trigger sinh ID cho RATING
CREATE OR REPLACE TRIGGER TG_RATING_AutoID
BEFORE INSERT ON RATING FOR EACH ROW
BEGIN
    IF :NEW.rating_id IS NULL OR :NEW.rating_id = '' THEN
        SELECT 'T' || TO_CHAR(SYSDATE, 'YY') || LPAD(SEQ_RATING.NEXTVAL, 5, '0') INTO :NEW.rating_id FROM DUAL;
    END IF;
END TG_RATING_AutoID;
/

-- Trigger sinh ID cho CART_DETAIL
CREATE OR REPLACE TRIGGER TG_CART_DETAIL_AutoID
BEFORE INSERT ON CART_DETAIL FOR EACH ROW
BEGIN
    IF :NEW.cart_item_id IS NULL OR :NEW.cart_item_id = '' THEN
        SELECT 'D' || TO_CHAR(SYSDATE, 'YY') || LPAD(SEQ_CART_DETAIL.NEXTVAL, 5, '0') INTO :NEW.cart_item_id FROM DUAL;
    END IF;
END TG_CART_DETAIL_AutoID;
/

-- Trigger sinh ID cho ORDER_DETAIL
CREATE OR REPLACE TRIGGER TG_ORDER_DETAIL_AutoID
BEFORE INSERT ON ORDER_DETAIL FOR EACH ROW
BEGIN
    IF :NEW.order_item_id IS NULL OR :NEW.order_item_id = '' THEN
        SELECT 'I' || TO_CHAR(SYSDATE, 'YY') || LPAD(SEQ_ORDER_DETAIL.NEXTVAL, 5, '0') INTO :NEW.order_item_id FROM DUAL;
    END IF;
END TG_ORDER_DETAIL_AutoID;
/

-- Trigger tự động tăng MEDIA_ID
CREATE OR REPLACE TRIGGER TG_MEDIA_AutoID
BEFORE INSERT ON MEDIA FOR EACH ROW
BEGIN
    IF :NEW.media_id IS NULL THEN
        SELECT SEQ_MEDIA.NEXTVAL INTO :NEW.media_id FROM DUAL;
    END IF;
END TG_MEDIA_AutoID;
/

COMMIT;

-- =======================================================================================
-- PHẦN 8: INSERT DATA MẪU
-- =======================================================================================

-- 1. INSERT USERS
INSERT INTO USERS (user_id, first_name, last_name, username, password, birthday, sex, address, phone_number, email, role)
VALUES ('U2310110', 'Anh', 'Nguyễn Ngọc Hoàng', 'hoanganh1812', '$2b$10$hashedpass1', TO_DATE('2005-12-18', 'YYYY-MM-DD'), 'Nữ', '48/44 đường Tân Quý, phường Bình Tân, TP.HCM', '0799610456', 'anh.nguyen@hcmut.edu.vn', 'buyer');

INSERT INTO USERS (user_id, first_name, last_name, username, password, birthday, sex, address, phone_number, email, role)
VALUES ('U2313522', 'Trang', 'Võ Ngọc Thùy', 'trangvongocthuy1008', '$2b$10$hashedpass2', TO_DATE('2005-08-10', 'YYYY-MM-DD'), 'Nữ', '269 đường Ông Ích Khiêm, phường Tân Phú, TP.HCM', '0562650565', 'trangvongocthuy1008@hcmut.edu.vn', 'buyer');

INSERT INTO USERS (user_id, first_name, last_name, username, password, birthday, sex, address, phone_number, email, role)
VALUES ('U2433225', 'Trang', 'Dương Thị Tuyết', 'trangduong', '$2b$10$hashedpass3', TO_DATE('2007-07-24', 'YYYY-MM-DD'), 'Nữ', '349 đường Điện Biên Phủ, phường Thảo Điền, TP.HCM', '0165144651', 'trangduongthituyet@hcmut.edu.vn', 'buyer');

INSERT INTO USERS (user_id, first_name, last_name, username, password, birthday, sex, address, phone_number, email, role)
VALUES ('U2213838', 'Tú', 'Dương Tú', 'duongtutu', '$2b$10$hashedpass4', TO_DATE('2003-03-24', 'YYYY-MM-DD'), 'Nam', '284 đường Quảng trường Sáng tạo, phường Thủ Đức, TP.HCM', '0516516514', 'tuduongtu@hcmut.edu.vn', 'seller');

INSERT INTO USERS (user_id, first_name, last_name, username, password, birthday, sex, address, phone_number, email, role)
VALUES ('U2313178', 'Thắng', 'Huỳnh Quốc', 'thanghuynh', '$2b$10$hashedpass5', TO_DATE('2005-05-18', 'YYYY-MM-DD'), 'Nam', '126/2 đường Gò Dầu, phường Phú Thọ Hòa, TP.HCM', '0154894589', 'thanghuynh@hcmut.edu.vn', 'seller');

INSERT INTO USERS (user_id, first_name, last_name, username, password, birthday, sex, address, phone_number, email, role)
VALUES ('U2314111', 'Minh', 'Lê Thị', 'minhle123', '$2b$10$hashedpass6', TO_DATE('2004-03-05', 'YYYY-MM-DD'), 'Nữ', '12 Lê Lợi, Phường Nhà Bè, TP.HCM', '0987654321', 'minhle123@gmail.com', 'seller');

INSERT INTO USERS (user_id, first_name, last_name, username, password, birthday, sex, address, phone_number, email, role)
VALUES ('U2314222', 'Huy', 'Nguyễn Văn', 'huynguyen', '$2b$10$hashedpass7', TO_DATE('2004-07-20', 'YYYY-MM-DD'), 'Nam', '99 Nguyễn Trãi, phường Tân Thới Hiệp, TP.HCM', '0912345678', 'huynguyen@gmail.com', 'seller');

INSERT INTO USERS (user_id, first_name, last_name, username, password, birthday, sex, address, phone_number, email, role)
VALUES ('U2314333', 'Lan', 'Phạm Thị', 'lanpham', '$2b$10$hashedpass8', TO_DATE('2005-11-11', 'YYYY-MM-DD'), 'Nữ', '55 Trần Hưng Đạo, Phường Diên Hồng, TP.HCM', '0923456789', 'lanpham@gmail.com', 'seller');

-- 2. INSERT BUYER & SELLER (User có thể vừa là buyer vừa là seller)
INSERT INTO BUYER (user_id) VALUES ('U2310110');
INSERT INTO BUYER (user_id) VALUES ('U2313522');
INSERT INTO BUYER (user_id) VALUES ('U2433225');
INSERT INTO BUYER (user_id) VALUES ('U2314111');
INSERT INTO BUYER (user_id) VALUES ('U2314222');
INSERT INTO BUYER (user_id) VALUES ('U2314333');

INSERT INTO SELLER (user_id, shop_name) VALUES ('U2213838', 'TuTechShop');
INSERT INTO SELLER (user_id, shop_name) VALUES ('U2313178', 'ThangGadget');
INSERT INTO SELLER (user_id, shop_name) VALUES ('U2314111', 'MinhStore');
INSERT INTO SELLER (user_id, shop_name) VALUES ('U2314222', 'HuyTech');
INSERT INTO SELLER (user_id, shop_name) VALUES ('U2314333', 'LanFashion');

-- 3. INSERT CATEGORY
INSERT INTO CATEGORY (category_id, name, description) VALUES ('G2100001', 'Điện thoại', 'Các loại điện thoại thông minh');
INSERT INTO CATEGORY (category_id, name, description) VALUES ('G2100002', 'Phụ kiện', 'Tai nghe, sạc, dây cáp');
INSERT INTO CATEGORY (category_id, name, description) VALUES ('G2100003', 'Laptop', 'Máy tính xách tay các thương hiệu');
INSERT INTO CATEGORY (category_id, name, description) VALUES ('G2100004', 'Thời trang', 'Quần áo và phụ kiện thời trang');
INSERT INTO CATEGORY (category_id, name, description) VALUES ('G2100005', 'Đồng hồ', 'Đồng hồ thông minh và cơ');

-- 4. INSERT PRODUCT
INSERT INTO PRODUCT (product_id, user_id, name, weight, product_size, origin, brand, description, price, stock_quantity, rating_avg, image_url, status, created_at)
VALUES ('P2200001', 'U2213838', 'iPhone 14', 0.4, '6.1 inch', 'Mỹ', 'Apple', 'Điện thoại Apple mới nhất', 12500000, 20, 4.9, 'iphone14.jpg', 'active', TO_TIMESTAMP('2025-10-01', 'YYYY-MM-DD'));

INSERT INTO PRODUCT (product_id, user_id, name, weight, product_size, origin, brand, description, price, stock_quantity, rating_avg, image_url, status, created_at)
VALUES ('P2200002', 'U2313178', 'Tai nghe Bluetooth', 0.2, 'Nhỏ', 'Trung Quốc', 'SoundMax', 'Tai nghe không dây âm thanh chuẩn', 500000, 50, 4.5, 'tainghe.jpg', 'active', TO_TIMESTAMP('2025-09-28', 'YYYY-MM-DD'));

INSERT INTO PRODUCT (product_id, user_id, name, weight, product_size, origin, brand, description, price, stock_quantity, rating_avg, image_url, status, created_at)
VALUES ('P2200003', 'U2213838', 'MacBook Air M2', 1.3, '13 inch', 'Mỹ', 'Apple', 'Laptop mỏng nhẹ pin trâu', 19000000, 10, 4.8, 'macbook.jpg', 'active', TO_TIMESTAMP('2025-08-30', 'YYYY-MM-DD'));

INSERT INTO PRODUCT (product_id, user_id, name, weight, product_size, origin, brand, description, price, stock_quantity, rating_avg, image_url, status, created_at)
VALUES ('P2200004', 'U2314333', 'Áo thun Local', 0.2, 'L', 'Vietnam', 'Local', 'Áo thun chất lượng', 450000, 100, 4.5, 'aothun.jpg', 'active', TO_TIMESTAMP('2025-10-01', 'YYYY-MM-DD'));

INSERT INTO PRODUCT (product_id, user_id, name, weight, product_size, origin, brand, description, price, stock_quantity, rating_avg, image_url, status, created_at)
VALUES ('P2200005', 'U2314222', 'Đồng hồ Casio', 0.1, 'Free', 'Japan', 'Casio', 'Đồng hồ nam', 2500000, 50, 4.8, 'dongho.jpg', 'active', TO_TIMESTAMP('2025-10-02', 'YYYY-MM-DD'));

INSERT INTO PRODUCT (product_id, user_id, name, weight, product_size, origin, brand, description, price, stock_quantity, rating_avg, image_url, status, created_at)
VALUES ('P2200006', 'U2314111', 'Chuột không dây', 0.15, 'Tiêu chuẩn', 'Trung Quốc', 'Logitech', 'Chuột gaming chuẩn', 1200000, 40, 4.7, 'chuot.jpg', 'active', TO_TIMESTAMP('2025-10-20', 'YYYY-MM-DD'));

INSERT INTO PRODUCT (product_id, user_id, name, weight, product_size, origin, brand, description, price, stock_quantity, rating_avg, image_url, status, created_at)
VALUES ('P2200007', 'U2314222', 'Tai nghe In-ear', 0.05, 'Nhỏ', 'Trung Quốc', 'Sony', 'Tai nghe nhỏ gọn', 350000, 60, 4.4, 'tainghe2.jpg', 'active', TO_TIMESTAMP('2025-10-21', 'YYYY-MM-DD'));

INSERT INTO PRODUCT (product_id, user_id, name, weight, product_size, origin, brand, description, price, stock_quantity, rating_avg, image_url, status, created_at)
VALUES ('P2200008', 'U2314333', 'Bàn phím cơ', 0.8, 'Fullsize', 'Trung Quốc', 'Corsair', 'Bàn phím cơ RGB', 1500000, 25, 4.6, 'banphim.jpg', 'active', TO_TIMESTAMP('2025-10-22', 'YYYY-MM-DD'));

-- 5. INSERT BELONG (Product - Category)
INSERT INTO BELONG (product_id, category_id) VALUES ('P2200001', 'G2100001');
INSERT INTO BELONG (product_id, category_id) VALUES ('P2200002', 'G2100002');
INSERT INTO BELONG (product_id, category_id) VALUES ('P2200003', 'G2100003');
INSERT INTO BELONG (product_id, category_id) VALUES ('P2200004', 'G2100004');
INSERT INTO BELONG (product_id, category_id) VALUES ('P2200005', 'G2100005');
INSERT INTO BELONG (product_id, category_id) VALUES ('P2200006', 'G2100002');
INSERT INTO BELONG (product_id, category_id) VALUES ('P2200007', 'G2100002');
INSERT INTO BELONG (product_id, category_id) VALUES ('P2200008', 'G2100002');

-- 6. INSERT CATEGORIZE (Hierarchy)
INSERT INTO CATEGORIZE (child_id, parent_id) VALUES ('G2100002', 'G2100001');
INSERT INTO CATEGORIZE (child_id, parent_id) VALUES ('G2100003', 'G2100001');
INSERT INTO CATEGORIZE (child_id, parent_id) VALUES ('G2100005', 'G2100002');
INSERT INTO CATEGORIZE (child_id, parent_id) VALUES ('G2100004', 'G2100002');
INSERT INTO CATEGORIZE (child_id, parent_id) VALUES ('G2100001', 'G2100004');

-- 7. INSERT FOLLOW
INSERT INTO FOLLOW (buyer_id, seller_id) VALUES ('U2310110', 'U2213838');
INSERT INTO FOLLOW (buyer_id, seller_id) VALUES ('U2310110', 'U2313178');
INSERT INTO FOLLOW (buyer_id, seller_id) VALUES ('U2313522', 'U2313178');
INSERT INTO FOLLOW (buyer_id, seller_id) VALUES ('U2433225', 'U2213838');
INSERT INTO FOLLOW (buyer_id, seller_id) VALUES ('U2314222', 'U2213838');
INSERT INTO FOLLOW (buyer_id, seller_id) VALUES ('U2314333', 'U2313178');

-- 8. INSERT CART (Chỉ buyer mới có giỏ hàng)
INSERT INTO CART (cart_id, user_id, created_at) VALUES ('C2300001', 'U2310110', TO_TIMESTAMP('2025-10-20', 'YYYY-MM-DD'));
INSERT INTO CART (cart_id, user_id, created_at) VALUES ('C2300002', 'U2313522', TO_TIMESTAMP('2025-10-21', 'YYYY-MM-DD'));
INSERT INTO CART (cart_id, user_id, created_at) VALUES ('C2300003', 'U2433225', TO_TIMESTAMP('2025-10-22', 'YYYY-MM-DD'));

-- 9. INSERT CART_DETAIL
INSERT INTO CART_DETAIL (cart_item_id, cart_id, product_id, quantity, price_at_add) VALUES ('D2400001', 'C2300001', 'P2200001', 1, 12500000);
INSERT INTO CART_DETAIL (cart_item_id, cart_id, product_id, quantity, price_at_add) VALUES ('D2400002', 'C2300001', 'P2200002', 1, 500000);
INSERT INTO CART_DETAIL (cart_item_id, cart_id, product_id, quantity, price_at_add) VALUES ('D2400003', 'C2300002', 'P2200003', 1, 19000000);
INSERT INTO CART_DETAIL (cart_item_id, cart_id, product_id, quantity, price_at_add) VALUES ('D2400004', 'C2300003', 'P2200002', 2, 500000);

-- 10. INSERT ORDERS
INSERT INTO ORDERS (order_id, user_id, status, delivery_address, order_date) VALUES ('O2500001', 'U2310110', 'delivered', '48/44 Tân Quý, phường Bình Tân, TP.HCM', TO_TIMESTAMP('2025-10-15', 'YYYY-MM-DD'));
INSERT INTO ORDERS (order_id, user_id, status, delivery_address, order_date) VALUES ('O2500002', 'U2313522', 'delivered', '269 Ông Ích Khiêm, phường Tân Phú, TP.HCM', TO_TIMESTAMP('2025-09-20', 'YYYY-MM-DD'));
INSERT INTO ORDERS (order_id, user_id, status, delivery_address, order_date) VALUES ('O2500003', 'U2433225', 'delivered', '349 Điện Biên Phủ, phường Thảo Điền, TP.HCM', TO_TIMESTAMP('2025-10-05', 'YYYY-MM-DD'));
INSERT INTO ORDERS (order_id, user_id, status, delivery_address, order_date) VALUES ('O2500004', 'U2314111', 'delivered', '12 Lê Lợi, phường An Lạc, TP.HCM', TO_TIMESTAMP('2025-10-22', 'YYYY-MM-DD'));
INSERT INTO ORDERS (order_id, user_id, status, delivery_address, order_date) VALUES ('O2500005', 'U2314222', 'delivered', '99 Nguyễn Trãi, phường Diên Hồng, TP.HCM', TO_TIMESTAMP('2025-10-23', 'YYYY-MM-DD'));
INSERT INTO ORDERS (order_id, user_id, status, delivery_address, order_date) VALUES ('O2500006', 'U2314333', 'pending', '55 Trần Hưng Đạo, phường Tân Sơn Nhì, TP.HCM', TO_TIMESTAMP('2025-10-24', 'YYYY-MM-DD'));

-- 11. INSERT ORDER_DETAIL
INSERT INTO ORDER_DETAIL (order_item_id, order_id, product_id, quantity, price, payment_method) VALUES ('I2600001', 'O2500001', 'P2200001', 1, 12500000, 'COD');
INSERT INTO ORDER_DETAIL (order_item_id, order_id, product_id, quantity, price, payment_method) VALUES ('I2600002', 'O2500002', 'P2200003', 1, 19000000, 'Online');
INSERT INTO ORDER_DETAIL (order_item_id, order_id, product_id, quantity, price, payment_method) VALUES ('I2600003', 'O2500003', 'P2200004', 2, 900000, 'COD');
INSERT INTO ORDER_DETAIL (order_item_id, order_id, product_id, quantity, price, payment_method) VALUES ('I2600004', 'O2500004', 'P2200006', 1, 1200000, 'Online');
INSERT INTO ORDER_DETAIL (order_item_id, order_id, product_id, quantity, price, payment_method) VALUES ('I2600005', 'O2500005', 'P2200007', 1, 350000, 'COD');
INSERT INTO ORDER_DETAIL (order_item_id, order_id, product_id, quantity, price, payment_method) VALUES ('I2600006', 'O2500006', 'P2200008', 2, 1500000, 'Online');

-- 12. INSERT PAYMENT & CONFIRM_PAYMENT
INSERT INTO PAYMENT (payment_id, status, payment_date, method, amount) VALUES ('M2700001', 'completed', TO_TIMESTAMP('2025-10-22', 'YYYY-MM-DD'), 'COD', 12500000);
INSERT INTO PAYMENT (payment_id, status, payment_date, method, amount) VALUES ('M2700002', 'pending', TO_TIMESTAMP('2025-10-25', 'YYYY-MM-DD'), 'Online', 19000000);
INSERT INTO PAYMENT (payment_id, status, payment_date, method, amount) VALUES ('M2700003', 'completed', TO_TIMESTAMP('2025-10-23', 'YYYY-MM-DD'), 'COD', 1000000);
INSERT INTO PAYMENT (payment_id, status, payment_date, method, amount) VALUES ('M2700004', 'completed', TO_TIMESTAMP('2025-10-26', 'YYYY-MM-DD'), 'Online', 1200000);
INSERT INTO PAYMENT (payment_id, status, payment_date, method, amount) VALUES ('M2700005', 'pending', TO_TIMESTAMP('2025-10-24', 'YYYY-MM-DD'), 'Online', 350000);
INSERT INTO PAYMENT (payment_id, status, payment_date, method, amount) VALUES ('M2700006', 'completed', TO_TIMESTAMP('2025-10-27', 'YYYY-MM-DD'), 'COD', 3000000);

INSERT INTO CONFIRM_PAYMENT (payment_id, order_id) VALUES ('M2700001', 'O2500001');
INSERT INTO CONFIRM_PAYMENT (payment_id, order_id) VALUES ('M2700002', 'O2500002');
INSERT INTO CONFIRM_PAYMENT (payment_id, order_id) VALUES ('M2700003', 'O2500003');
INSERT INTO CONFIRM_PAYMENT (payment_id, order_id) VALUES ('M2700004', 'O2500004');
INSERT INTO CONFIRM_PAYMENT (payment_id, order_id) VALUES ('M2700005', 'O2500005');
INSERT INTO CONFIRM_PAYMENT (payment_id, order_id) VALUES ('M2700006', 'O2500006');

-- 13. INSERT DELIVERY & CONFIRM_DELIVERY
INSERT INTO DELIVERY (delivery_id, delivery_status, courier_name, delivering_fee) VALUES ('Y2800001', 'delivered', 'GHTK', 25000);
INSERT INTO DELIVERY (delivery_id, delivery_status, courier_name, delivering_fee) VALUES ('Y2800002', 'in_transit', 'VNPost', 30000);
INSERT INTO DELIVERY (delivery_id, delivery_status, courier_name, delivering_fee) VALUES ('Y2800003', 'pending', 'J&T', 20000);
INSERT INTO DELIVERY (delivery_id, delivery_status, courier_name, delivering_fee) VALUES ('Y2800004', 'delivered', 'GHN', 25000);
INSERT INTO DELIVERY (delivery_id, delivery_status, courier_name, delivering_fee) VALUES ('Y2800005', 'in_transit', 'ViettelPost', 30000);
INSERT INTO DELIVERY (delivery_id, delivery_status, courier_name, delivering_fee) VALUES ('Y2800006', 'delivered', 'GHTK', 25000);

INSERT INTO CONFIRM_DELIVERY (delivery_id, order_id, expected_delivery_date) VALUES ('Y2800001', 'O2500001', TO_TIMESTAMP('2025-10-22', 'YYYY-MM-DD'));
INSERT INTO CONFIRM_DELIVERY (delivery_id, order_id, expected_delivery_date) VALUES ('Y2800002', 'O2500002', TO_TIMESTAMP('2025-10-28', 'YYYY-MM-DD'));
INSERT INTO CONFIRM_DELIVERY (delivery_id, order_id, expected_delivery_date) VALUES ('Y2800003', 'O2500003', TO_TIMESTAMP('2025-10-24', 'YYYY-MM-DD'));
INSERT INTO CONFIRM_DELIVERY (delivery_id, order_id, expected_delivery_date) VALUES ('Y2800004', 'O2500004', TO_TIMESTAMP('2025-10-27', 'YYYY-MM-DD'));
INSERT INTO CONFIRM_DELIVERY (delivery_id, order_id, expected_delivery_date) VALUES ('Y2800005', 'O2500005', TO_TIMESTAMP('2025-10-29', 'YYYY-MM-DD'));
INSERT INTO CONFIRM_DELIVERY (delivery_id, order_id, expected_delivery_date) VALUES ('Y2800006', 'O2500006', TO_TIMESTAMP('2025-10-30', 'YYYY-MM-DD'));

-- 14. INSERT VOUCHER
INSERT INTO VOUCHER (voucher_id, code, description, discount_type, discount_value, min_purchase, start_date, end_date)
VALUES ('V2920001', 'SHOP10', 'Giảm 10% cho đơn hàng trên 1 triệu', 'percentage', 10, 1000000, TO_TIMESTAMP('2025-10-01', 'YYYY-MM-DD'), TO_TIMESTAMP('2025-12-31', 'YYYY-MM-DD'));

INSERT INTO VOUCHER (voucher_id, code, description, discount_type, discount_value, min_purchase, start_date, end_date)
VALUES ('V2920002', 'GLOBAL50', 'Giảm 50k cho đơn hàng bất kỳ', 'fixed_amount', 50000, 0, TO_TIMESTAMP('2025-10-01', 'YYYY-MM-DD'), TO_TIMESTAMP('2025-12-31', 'YYYY-MM-DD'));

INSERT INTO VOUCHER (voucher_id, code, description, discount_type, discount_value, min_purchase, start_date, end_date)
VALUES ('V2920003', 'SHOP15', 'Giảm 15% cho đơn hàng trên 2 triệu', 'percentage', 15, 2000000, TO_TIMESTAMP('2025-10-05', 'YYYY-MM-DD'), TO_TIMESTAMP('2025-12-31', 'YYYY-MM-DD'));

INSERT INTO VOUCHER (voucher_id, code, description, discount_type, discount_value, min_purchase, start_date, end_date)
VALUES ('V2920004', 'GLOBAL100', 'Giảm 100k cho đơn hàng trên 1.5 triệu', 'fixed_amount', 100000, 1500000, TO_TIMESTAMP('2025-10-07', 'YYYY-MM-DD'), TO_TIMESTAMP('2025-12-31', 'YYYY-MM-DD'));

INSERT INTO VOUCHER (voucher_id, code, description, discount_type, discount_value, min_purchase, start_date, end_date)
VALUES ('V2920005', 'SHOP20', 'Giảm 20% cho đơn hàng trên 1 triệu', 'percentage', 20, 1000000, TO_TIMESTAMP('2025-10-10', 'YYYY-MM-DD'), TO_TIMESTAMP('2025-12-31', 'YYYY-MM-DD'));

INSERT INTO VOUCHER (voucher_id, code, description, discount_type, discount_value, min_purchase, start_date, end_date)
VALUES ('V2920006', 'FREESHIP50', 'Giảm 50k cho đơn hàng bất kỳ', 'fixed_amount', 50000, 0, TO_TIMESTAMP('2025-10-12', 'YYYY-MM-DD'), TO_TIMESTAMP('2025-12-31', 'YYYY-MM-DD'));

-- 15. INSERT VOUCHER SUB-TABLES
INSERT INTO PRODUCT_VOUCHER (voucher_id, product_id) VALUES ('V2920002', 'P2200001');
INSERT INTO PRODUCT_VOUCHER (voucher_id, product_id) VALUES ('V2920004', 'P2200003');

INSERT INTO SHOP_VOUCHER (voucher_id, seller_id) VALUES ('V2920001', 'U2213838');
INSERT INTO SHOP_VOUCHER (voucher_id, seller_id) VALUES ('V2920003', 'U2313178');
INSERT INTO SHOP_VOUCHER (voucher_id, seller_id) VALUES ('V2920005', 'U2314222');

INSERT INTO FREESHIP_VOUCHER (voucher_id) VALUES ('V2920006');

-- 16. INSERT REVIEW
INSERT INTO REVIEW (review_id, created_at, content, title) VALUES ('R2900001', TO_TIMESTAMP('2025-10-25', 'YYYY-MM-DD'), 'Sản phẩm chất lượng tuyệt vời!', 'Rất hài lòng');
INSERT INTO REVIEW (review_id, created_at, content, title) VALUES ('R2900002', TO_TIMESTAMP('2025-10-26', 'YYYY-MM-DD'), 'Giao hàng nhanh, đóng gói kỹ.', 'Tốt');
INSERT INTO REVIEW (review_id, created_at, content, title) VALUES ('R2900003', TO_TIMESTAMP('2025-10-27', 'YYYY-MM-DD'), 'Pin dùng bền, hình ảnh rõ nét.', 'Ổn định');
INSERT INTO REVIEW (review_id, created_at, content, title) VALUES ('R2900004', TO_TIMESTAMP('2025-10-28', 'YYYY-MM-DD'), 'Sản phẩm hơi khác hình minh họa.', 'Chấp nhận được');
INSERT INTO REVIEW (review_id, created_at, content, title) VALUES ('R2900005', TO_TIMESTAMP('2025-10-29', 'YYYY-MM-DD'), 'Dịch vụ hỗ trợ khách hàng rất tốt.', 'Tuyệt vời');

-- 17. INSERT COMMENT (Link User - Product - Review)
INSERT INTO USER_COMMENTS (user_id, product_id, review_id) VALUES ('U2310110', 'P2200001', 'R2900001');
INSERT INTO USER_COMMENTS (user_id, product_id, review_id) VALUES ('U2313522', 'P2200003', 'R2900002');
INSERT INTO USER_COMMENTS (user_id, product_id, review_id) VALUES ('U2433225', 'P2200004', 'R2900003');
INSERT INTO USER_COMMENTS (user_id, product_id, review_id) VALUES ('U2314111', 'P2200006', 'R2900004');
INSERT INTO USER_COMMENTS (user_id, product_id, review_id) VALUES ('U2314222', 'P2200007', 'R2900005');

-- 18. INSERT RATING
INSERT INTO RATING (rating_id, review_id, score, packaging, delivery, quality) VALUES ('T2910001', 'R2900001', 5, 5, 5, 5);
INSERT INTO RATING (rating_id, review_id, score, packaging, delivery, quality) VALUES ('T2910002', 'R2900002', 4, 4, 4, 4);
INSERT INTO RATING (rating_id, review_id, score, packaging, delivery, quality) VALUES ('T2910003', 'R2900003', 5, 4, 5, 5);
INSERT INTO RATING (rating_id, review_id, score, packaging, delivery, quality) VALUES ('T2910004', 'R2900004', 3, 3, 4, 3);
INSERT INTO RATING (rating_id, review_id, score, packaging, delivery, quality) VALUES ('T2910005', 'R2900005', 5, 5, 5, 5);

-- 19. INSERT MEDIA
INSERT INTO MEDIA (media_id, review_id, media_url, media_type) VALUES (SEQ_MEDIA.NEXTVAL, 'R2900001', 'img_review1.jpg', 'image');
INSERT INTO MEDIA (media_id, review_id, media_url, media_type) VALUES (SEQ_MEDIA.NEXTVAL, 'R2900001', 'review1.mp4', 'video');
INSERT INTO MEDIA (media_id, review_id, media_url, media_type) VALUES (SEQ_MEDIA.NEXTVAL, 'R2900002', 'img_review2.png', 'image');
INSERT INTO MEDIA (media_id, review_id, media_url, media_type) VALUES (SEQ_MEDIA.NEXTVAL, 'R2900003', 'img_review3.jpg', 'image');
INSERT INTO MEDIA (media_id, review_id, media_url, media_type) VALUES (SEQ_MEDIA.NEXTVAL, 'R2900003', 'review3.mp4', 'video');
INSERT INTO MEDIA (media_id, review_id, media_url, media_type) VALUES (SEQ_MEDIA.NEXTVAL, 'R2900004', 'img_review4.jpg', 'image');
INSERT INTO MEDIA (media_id, review_id, media_url, media_type) VALUES (SEQ_MEDIA.NEXTVAL, 'R2900005', 'img_review5.jpg', 'image');
INSERT INTO MEDIA (media_id, review_id, media_url, media_type) VALUES (SEQ_MEDIA.NEXTVAL, 'R2900005', 'review5.mp4', 'video');

COMMIT;

SELECT 'DATABASE SETUP COMPLETED SUCCESSFULLY!' AS Message FROM DUAL;