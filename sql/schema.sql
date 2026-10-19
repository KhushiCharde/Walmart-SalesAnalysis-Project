-- Run with MySQL 8.0 or later before scripts/load_mysql.py.
CREATE DATABASE IF NOT EXISTS walmart_analysis;
USE walmart_analysis;
CREATE TABLE IF NOT EXISTS walmart (
  invoice_id BIGINT PRIMARY KEY,
  branch VARCHAR(30) NOT NULL,
  city VARCHAR(100) NOT NULL,
  category VARCHAR(100) NOT NULL,
  unit_price DECIMAL(12,2) NOT NULL,
  quantity INT NOT NULL,
  date DATE NOT NULL,
  time TIME NOT NULL,
  payment_method VARCHAR(40) NOT NULL,
  rating DECIMAL(5,2) NOT NULL,
  profit_margin DECIMAL(6,4) NOT NULL,
  total DECIMAL(14,2) NOT NULL,
  INDEX idx_date (date),
  INDEX idx_branch (branch)
);
