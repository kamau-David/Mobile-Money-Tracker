CREATE DATABASE kes_tracker_db;
USE kes_tracker_db;


CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    phone_number VARCHAR(15) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    current_balance DECIMAL(15, 2) DEFAULT 0.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


CREATE TABLE transactions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    amount DECIMAL(15, 2) NOT NULL,
    type ENUM('INCOME', 'EXPENSE') NOT NULL,
    category VARCHAR(50) DEFAULT 'Uncategorized',
    description TEXT,
    mpesa_code VARCHAR(20) UNIQUE, 
    transaction_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);


CREATE TABLE recurring_patterns (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    expected_day INT, 
    average_amount DECIMAL(15, 2),
    paybill_number VARCHAR(20),
    description VARCHAR(100),
    FOREIGN KEY (user_id) REFERENCES users(id)
);