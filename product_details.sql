-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Dec 25, 2025 at 03:52 PM
-- Server version: 8.0.30
-- PHP Version: 8.3.15

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `product_details`
--

-- --------------------------------------------------------

--
-- Table structure for table `brands`
--

CREATE TABLE `brands` (
  `brand_id` int NOT NULL,
  `name` varchar(100) NOT NULL,
  `description` text,
  `logo_url` varchar(255) DEFAULT NULL,
  `website_url` varchar(255) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `brands`
--

INSERT INTO `brands` (`brand_id`, `name`, `description`, `logo_url`, `website_url`, `is_active`, `created_at`) VALUES
(1, 'Apple', 'Technology company', NULL, NULL, 1, '2025-11-16 20:24:08'),
(2, 'Samsung', 'Electronics manufacturer', NULL, NULL, 1, '2025-11-16 20:24:08'),
(3, 'Dell', 'Computer technology company', NULL, NULL, 1, '2025-11-16 20:24:08'),
(4, 'Nike', 'Athletic apparel and footwear', NULL, NULL, 1, '2025-11-16 20:24:08');

-- --------------------------------------------------------

--
-- Table structure for table `categories`
--

CREATE TABLE `categories` (
  `category_id` int NOT NULL,
  `name` varchar(100) NOT NULL,
  `description` text,
  `parent_category_id` int DEFAULT NULL,
  `image_url` varchar(255) DEFAULT NULL,
  `sort_order` int DEFAULT '0',
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `categories`
--

INSERT INTO `categories` (`category_id`, `name`, `description`, `parent_category_id`, `image_url`, `sort_order`, `is_active`, `created_at`) VALUES
(1, 'Electronics', 'Electronic devices and accessories', NULL, NULL, 1, 1, '2025-11-16 20:24:08'),
(2, 'Smartphones', 'Mobile phones and smartphones', 1, NULL, 1, 1, '2025-11-16 20:24:08'),
(3, 'Laptops', 'Laptop computers and accessories', 1, NULL, 2, 1, '2025-11-16 20:24:08'),
(4, 'Fashion', 'Clothing and accessories', NULL, NULL, 2, 1, '2025-11-16 20:24:08'),
(5, 'Men\'s Fashion', 'Clothing for men', 4, NULL, 1, 1, '2025-11-16 20:24:08'),
(6, 'Women\'s Fashion', 'Clothing for women', 4, NULL, 2, 1, '2025-11-16 20:24:08');

-- --------------------------------------------------------

--
-- Table structure for table `inventory_transactions`
--

CREATE TABLE `inventory_transactions` (
  `transaction_id` int NOT NULL,
  `variant_id` int NOT NULL,
  `transaction_type` enum('purchase','sale','return','adjustment','damage') NOT NULL,
  `quantity_change` int NOT NULL,
  `previous_stock` int NOT NULL,
  `new_stock` int NOT NULL,
  `reference_type` enum('order','purchase_order','manual','system') DEFAULT 'manual',
  `reference_id` int DEFAULT NULL,
  `reason` text,
  `transaction_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `created_by` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `orders`
--

CREATE TABLE `orders` (
  `order_id` int NOT NULL,
  `order_number` varchar(50) NOT NULL,
  `user_id` int NOT NULL,
  `status` enum('pending','confirmed','processing','shipped','delivered','cancelled','refunded') DEFAULT 'pending',
  `payment_status` enum('pending','paid','failed','refunded','partially_refunded') DEFAULT 'pending',
  `shipping_status` enum('pending','packed','shipped','delivered','returned') DEFAULT 'pending',
  `subtotal` decimal(10,2) NOT NULL,
  `tax_amount` decimal(10,2) DEFAULT '0.00',
  `shipping_amount` decimal(10,2) DEFAULT '0.00',
  `discount_amount` decimal(10,2) DEFAULT '0.00',
  `total_amount` decimal(10,2) NOT NULL,
  `currency` varchar(3) DEFAULT 'USD',
  `shipping_address_id` int NOT NULL,
  `billing_address_id` int NOT NULL,
  `customer_note` text,
  `internal_notes` text,
  `estimated_delivery_date` date DEFAULT NULL,
  `actual_delivery_date` date DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `orders`
--

INSERT INTO `orders` (`order_id`, `order_number`, `user_id`, `status`, `payment_status`, `shipping_status`, `subtotal`, `tax_amount`, `shipping_amount`, `discount_amount`, `total_amount`, `currency`, `shipping_address_id`, `billing_address_id`, `customer_note`, `internal_notes`, `estimated_delivery_date`, `actual_delivery_date`, `created_at`, `updated_at`) VALUES
(1, 'ORD-001', 1, 'delivered', 'paid', 'pending', '999.00', '0.00', '0.00', '0.00', '1049.00', 'USD', 1, 1, NULL, NULL, NULL, NULL, '2025-11-16 20:24:08', '2025-11-16 20:24:08'),
(2, 'ORD-002', 2, 'processing', 'paid', 'pending', '1698.00', '0.00', '0.00', '0.00', '1748.00', 'USD', 3, 3, NULL, NULL, NULL, NULL, '2025-11-16 20:24:08', '2025-11-16 20:24:08'),
(3, 'ORD-003', 1, 'pending', 'pending', 'pending', '150.00', '0.00', '0.00', '0.00', '165.00', 'USD', 1, 1, NULL, NULL, NULL, NULL, '2025-11-16 20:24:08', '2025-11-16 20:24:08');

-- --------------------------------------------------------

--
-- Table structure for table `order_items`
--

CREATE TABLE `order_items` (
  `order_item_id` int NOT NULL,
  `order_id` int NOT NULL,
  `variant_id` int NOT NULL,
  `product_name` varchar(255) NOT NULL,
  `variant_attributes` json DEFAULT NULL,
  `unit_price` decimal(10,2) NOT NULL,
  `quantity` int NOT NULL,
  `line_total` decimal(10,2) NOT NULL,
  `tax_amount` decimal(10,2) DEFAULT '0.00',
  `discount_amount` decimal(10,2) DEFAULT '0.00',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `order_items`
--

INSERT INTO `order_items` (`order_item_id`, `order_id`, `variant_id`, `product_name`, `variant_attributes`, `unit_price`, `quantity`, `line_total`, `tax_amount`, `discount_amount`, `created_at`) VALUES
(1, 1, 1, 'iPhone 13 Pro', NULL, '999.00', 1, '999.00', '0.00', '0.00', '2025-11-16 20:24:08'),
(2, 2, 1, 'iPhone 13 Pro', NULL, '999.00', 1, '999.00', '0.00', '0.00', '2025-11-16 20:24:08'),
(3, 2, 3, 'iPhone 13 Pro', NULL, '999.00', 1, '999.00', '0.00', '0.00', '2025-11-16 20:24:08'),
(4, 3, 5, 'Nike Air Max 270', NULL, '150.00', 1, '150.00', '0.00', '0.00', '2025-11-16 20:24:08');

-- --------------------------------------------------------

--
-- Table structure for table `price_history`
--

CREATE TABLE `price_history` (
  `price_id` int NOT NULL,
  `product_id` int NOT NULL,
  `variant_id` int DEFAULT NULL,
  `old_price` decimal(10,2) DEFAULT NULL,
  `new_price` decimal(10,2) NOT NULL,
  `change_type` enum('sale','increase','decrease','promotion') NOT NULL,
  `reason` text,
  `effective_from` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `effective_to` timestamp NULL DEFAULT NULL,
  `created_by` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `products`
--

CREATE TABLE `products` (
  `product_id` int NOT NULL,
  `sku` varchar(50) NOT NULL,
  `name` varchar(255) NOT NULL,
  `description` text,
  `short_description` text,
  `brand_id` int NOT NULL,
  `category_id` int NOT NULL,
  `base_price` decimal(10,2) NOT NULL,
  `compare_at_price` decimal(10,2) DEFAULT NULL,
  `cost_price` decimal(10,2) DEFAULT NULL,
  `weight` decimal(8,2) DEFAULT NULL,
  `dimensions` json DEFAULT NULL,
  `featured` tinyint(1) DEFAULT '0',
  `status` enum('active','inactive','draft','archived') DEFAULT 'draft',
  `inventory_tracking` tinyint(1) DEFAULT '1',
  `min_stock_threshold` int DEFAULT '5',
  `meta_title` varchar(255) DEFAULT NULL,
  `meta_description` text,
  `slug` varchar(255) NOT NULL,
  `rating_average` decimal(3,2) DEFAULT '0.00',
  `review_count` int DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `products`
--

INSERT INTO `products` (`product_id`, `sku`, `name`, `description`, `short_description`, `brand_id`, `category_id`, `base_price`, `compare_at_price`, `cost_price`, `weight`, `dimensions`, `featured`, `status`, `inventory_tracking`, `min_stock_threshold`, `meta_title`, `meta_description`, `slug`, `rating_average`, `review_count`, `created_at`, `updated_at`) VALUES
(1, 'IPHONE13-001', 'iPhone 13 Pro', 'Latest iPhone with advanced camera system', NULL, 1, 2, '999.00', '1099.00', NULL, NULL, NULL, 0, 'active', 1, 5, NULL, NULL, 'iphone-13-pro', '0.00', 0, '2025-11-16 20:24:08', '2025-11-16 20:24:08'),
(2, 'IPHONE13-002', 'iPhone 13', 'Powerful smartphone with great features', NULL, 1, 2, '799.00', '899.00', NULL, NULL, NULL, 0, 'active', 1, 5, NULL, NULL, 'iphone-13', '0.00', 0, '2025-11-16 20:24:08', '2025-11-16 20:24:08'),
(3, 'SAMSUNG-S21', 'Samsung Galaxy S21', 'Android flagship smartphone', NULL, 2, 2, '849.00', '949.00', NULL, NULL, NULL, 0, 'active', 1, 5, NULL, NULL, 'samsung-galaxy-s21', '0.00', 0, '2025-11-16 20:24:08', '2025-11-16 20:24:08'),
(4, 'DELL-XPS13', 'Dell XPS 13 Laptop', 'Premium ultrabook', NULL, 3, 3, '1199.00', '1299.00', NULL, NULL, NULL, 0, 'active', 1, 5, NULL, NULL, 'dell-xps-13', '0.00', 0, '2025-11-16 20:24:08', '2025-11-16 20:24:08'),
(5, 'NIKE-AIRMAX', 'Nike Air Max 270', 'Comfortable running shoes', NULL, 4, 5, '150.00', '180.00', NULL, NULL, NULL, 0, 'active', 1, 5, NULL, NULL, 'nike-air-max-270', '0.00', 0, '2025-11-16 20:24:08', '2025-11-16 20:24:08');

-- --------------------------------------------------------

--
-- Table structure for table `product_attributes`
--

CREATE TABLE `product_attributes` (
  `attribute_id` int NOT NULL,
  `name` varchar(100) NOT NULL,
  `type` enum('text','color','image','number') DEFAULT 'text',
  `is_variant_attribute` tinyint(1) DEFAULT '0',
  `sort_order` int DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `product_attributes`
--

INSERT INTO `product_attributes` (`attribute_id`, `name`, `type`, `is_variant_attribute`, `sort_order`, `created_at`) VALUES
(1, 'Color', 'color', 1, 0, '2025-11-16 20:24:08'),
(2, 'Storage', 'text', 1, 0, '2025-11-16 20:24:08'),
(3, 'Size', 'text', 1, 0, '2025-11-16 20:24:08'),
(4, 'Material', 'text', 0, 0, '2025-11-16 20:24:08');

-- --------------------------------------------------------

--
-- Table structure for table `product_attribute_values`
--

CREATE TABLE `product_attribute_values` (
  `value_id` int NOT NULL,
  `attribute_id` int NOT NULL,
  `value` varchar(100) NOT NULL,
  `display_value` varchar(100) DEFAULT NULL,
  `color_hex` varchar(7) DEFAULT NULL,
  `image_url` varchar(255) DEFAULT NULL,
  `sort_order` int DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `product_attribute_values`
--

INSERT INTO `product_attribute_values` (`value_id`, `attribute_id`, `value`, `display_value`, `color_hex`, `image_url`, `sort_order`, `created_at`) VALUES
(1, 1, 'black', 'Jet Black', '#000000', NULL, 0, '2025-11-16 20:24:08'),
(2, 1, 'white', 'Pure White', '#FFFFFF', NULL, 0, '2025-11-16 20:24:08'),
(3, 1, 'blue', 'Sierra Blue', '#5C8AB9', NULL, 0, '2025-11-16 20:24:08'),
(4, 2, '128gb', '128GB', NULL, NULL, 0, '2025-11-16 20:24:08'),
(5, 2, '256gb', '256GB', NULL, NULL, 0, '2025-11-16 20:24:08'),
(6, 2, '512gb', '512GB', NULL, NULL, 0, '2025-11-16 20:24:08'),
(7, 3, 's', 'Small', NULL, NULL, 0, '2025-11-16 20:24:08'),
(8, 3, 'm', 'Medium', NULL, NULL, 0, '2025-11-16 20:24:08'),
(9, 3, 'l', 'Large', NULL, NULL, 0, '2025-11-16 20:24:08');

-- --------------------------------------------------------

--
-- Table structure for table `product_reviews`
--

CREATE TABLE `product_reviews` (
  `review_id` int NOT NULL,
  `product_id` int NOT NULL,
  `user_id` int NOT NULL,
  `order_item_id` int DEFAULT NULL,
  `rating` tinyint NOT NULL,
  `title` varchar(255) DEFAULT NULL,
  `review_text` text,
  `is_approved` tinyint(1) DEFAULT '0',
  `helpful_count` int DEFAULT '0',
  `not_helpful_count` int DEFAULT '0',
  `verified_purchase` tinyint(1) DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ;

--
-- Dumping data for table `product_reviews`
--

INSERT INTO `product_reviews` (`review_id`, `product_id`, `user_id`, `order_item_id`, `rating`, `title`, `review_text`, `is_approved`, `helpful_count`, `not_helpful_count`, `verified_purchase`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 1, 5, 'Amazing phone!', 'The camera quality is outstanding and battery life is great.', 1, 0, 0, 1, '2025-11-16 20:24:08', '2025-11-16 20:24:08'),
(2, 5, 1, 4, 4, 'Very comfortable', 'Great for running and daily wear.', 1, 0, 0, 1, '2025-11-16 20:24:08', '2025-11-16 20:24:08');

-- --------------------------------------------------------

--
-- Table structure for table `product_variants`
--

CREATE TABLE `product_variants` (
  `variant_id` int NOT NULL,
  `product_id` int NOT NULL,
  `sku` varchar(50) NOT NULL,
  `price_adjustment` decimal(10,2) DEFAULT '0.00',
  `weight_adjustment` decimal(8,2) DEFAULT '0.00',
  `image_url` varchar(255) DEFAULT NULL,
  `stock_quantity` int DEFAULT '0',
  `low_stock_threshold` int DEFAULT '5',
  `is_default` tinyint(1) DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `product_variants`
--

INSERT INTO `product_variants` (`variant_id`, `product_id`, `sku`, `price_adjustment`, `weight_adjustment`, `image_url`, `stock_quantity`, `low_stock_threshold`, `is_default`, `created_at`, `updated_at`) VALUES
(1, 1, 'IPHONE13-PRO-128-BLACK', '0.00', '0.00', NULL, 50, 5, 1, '2025-11-16 20:24:08', '2025-11-16 20:24:08'),
(2, 1, 'IPHONE13-PRO-256-BLACK', '100.00', '0.00', NULL, 30, 5, 0, '2025-11-16 20:24:08', '2025-11-16 20:24:08'),
(3, 1, 'IPHONE13-PRO-128-BLUE', '0.00', '0.00', NULL, 25, 5, 0, '2025-11-16 20:24:08', '2025-11-16 20:24:08'),
(4, 5, 'NIKE-AIRMAX-S', '0.00', '0.00', NULL, 100, 5, 0, '2025-11-16 20:24:08', '2025-11-16 20:24:08'),
(5, 5, 'NIKE-AIRMAX-M', '0.00', '0.00', NULL, 150, 5, 1, '2025-11-16 20:24:08', '2025-11-16 20:24:08'),
(6, 5, 'NIKE-AIRMAX-L', '0.00', '0.00', NULL, 80, 5, 0, '2025-11-16 20:24:08', '2025-11-16 20:24:08');

-- --------------------------------------------------------

--
-- Table structure for table `related_products`
--

CREATE TABLE `related_products` (
  `relation_id` int NOT NULL,
  `product_id` int NOT NULL,
  `related_product_id` int NOT NULL,
  `relation_type` enum('cross_sell','up_sell','complementary','similar') DEFAULT 'similar',
  `sort_order` int DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `related_products`
--

INSERT INTO `related_products` (`relation_id`, `product_id`, `related_product_id`, `relation_type`, `sort_order`, `created_at`) VALUES
(1, 1, 2, 'similar', 0, '2025-11-16 20:24:08'),
(2, 1, 3, 'similar', 0, '2025-11-16 20:24:08'),
(3, 5, 1, 'cross_sell', 0, '2025-11-16 20:24:08');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `user_id` int NOT NULL,
  `username` varchar(50) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `first_name` varchar(50) DEFAULT NULL,
  `last_name` varchar(50) DEFAULT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `date_of_birth` date DEFAULT NULL,
  `registration_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `last_login` timestamp NULL DEFAULT NULL,
  `account_status` enum('active','inactive','suspended','banned') DEFAULT 'active',
  `email_verified` tinyint(1) DEFAULT '0',
  `profile_picture_url` varchar(255) DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`user_id`, `username`, `email`, `password_hash`, `first_name`, `last_name`, `phone`, `date_of_birth`, `registration_date`, `last_login`, `account_status`, `email_verified`, `profile_picture_url`, `deleted_at`, `created_at`, `updated_at`) VALUES
(1, 'john_doe', 'john.doe@email.com', 'hashed_password_1', 'John', 'Doe', '+1234567890', '1990-05-15', '2025-11-16 20:24:08', NULL, 'active', 1, NULL, NULL, '2025-11-16 20:24:08', '2025-11-16 20:24:08'),
(2, 'sarah_smith', 'sarah.smith@email.com', 'hashed_password_2', 'Sarah', 'Smith', '+1234567891', '1985-08-22', '2025-11-16 20:24:08', NULL, 'active', 1, NULL, NULL, '2025-11-16 20:24:08', '2025-11-16 20:24:08'),
(3, 'mike_jones', 'mike.jones@email.com', 'hashed_password_3', 'Mike', 'Jones', '+1234567892', '1992-12-10', '2025-11-16 20:24:08', NULL, 'active', 1, NULL, NULL, '2025-11-16 20:24:08', '2025-11-16 20:24:08'),
(4, 'emma_wilson', 'emma.wilson@email.com', 'hashed_password_4', 'Emma', 'Wilson', '+1234567893', '1988-03-30', '2025-11-16 20:24:08', NULL, 'active', 1, NULL, NULL, '2025-11-16 20:24:08', '2025-11-16 20:24:08');

-- --------------------------------------------------------

--
-- Table structure for table `user_addresses`
--

CREATE TABLE `user_addresses` (
  `address_id` int NOT NULL,
  `user_id` int NOT NULL,
  `address_type` enum('home','work','billing','shipping') DEFAULT 'home',
  `street_address` text NOT NULL,
  `city` varchar(100) NOT NULL,
  `state` varchar(100) DEFAULT NULL,
  `country` varchar(100) NOT NULL,
  `postal_code` varchar(20) DEFAULT NULL,
  `is_default` tinyint(1) DEFAULT '0',
  `latitude` decimal(10,8) DEFAULT NULL,
  `longitude` decimal(11,8) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `user_addresses`
--

INSERT INTO `user_addresses` (`address_id`, `user_id`, `address_type`, `street_address`, `city`, `state`, `country`, `postal_code`, `is_default`, `latitude`, `longitude`, `created_at`, `updated_at`) VALUES
(1, 1, 'home', '123 Main St', 'New York', 'NY', 'USA', '10001', 1, NULL, NULL, '2025-11-16 20:24:08', '2025-11-16 20:24:08'),
(2, 1, 'work', '456 Office Blvd', 'New York', 'NY', 'USA', '10002', 0, NULL, NULL, '2025-11-16 20:24:08', '2025-11-16 20:24:08'),
(3, 2, 'home', '789 Park Ave', 'Los Angeles', 'CA', 'USA', '90210', 1, NULL, NULL, '2025-11-16 20:24:08', '2025-11-16 20:24:08'),
(4, 3, 'home', '321 Oak Street', 'Chicago', 'IL', 'USA', '60601', 1, NULL, NULL, '2025-11-16 20:24:08', '2025-11-16 20:24:08');

-- --------------------------------------------------------

--
-- Table structure for table `variant_attribute_combinations`
--

CREATE TABLE `variant_attribute_combinations` (
  `combination_id` int NOT NULL,
  `variant_id` int NOT NULL,
  `attribute_id` int NOT NULL,
  `value_id` int NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `variant_attribute_combinations`
--

INSERT INTO `variant_attribute_combinations` (`combination_id`, `variant_id`, `attribute_id`, `value_id`, `created_at`) VALUES
(1, 1, 1, 1, '2025-11-16 20:24:08'),
(2, 1, 2, 4, '2025-11-16 20:24:08'),
(3, 2, 1, 1, '2025-11-16 20:24:08'),
(4, 2, 2, 5, '2025-11-16 20:24:08'),
(5, 3, 1, 3, '2025-11-16 20:24:08'),
(6, 3, 2, 4, '2025-11-16 20:24:08'),
(7, 4, 3, 7, '2025-11-16 20:24:08'),
(8, 5, 3, 8, '2025-11-16 20:24:08'),
(9, 6, 3, 9, '2025-11-16 20:24:08');

-- --------------------------------------------------------

--
-- Table structure for table `wishlists`
--

CREATE TABLE `wishlists` (
  `wishlist_id` int NOT NULL,
  `user_id` int NOT NULL,
  `name` varchar(100) NOT NULL,
  `is_public` tinyint(1) DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `wishlist_items`
--

CREATE TABLE `wishlist_items` (
  `wishlist_item_id` int NOT NULL,
  `wishlist_id` int NOT NULL,
  `variant_id` int NOT NULL,
  `added_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `notes` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `brands`
--
ALTER TABLE `brands`
  ADD PRIMARY KEY (`brand_id`);

--
-- Indexes for table `categories`
--
ALTER TABLE `categories`
  ADD PRIMARY KEY (`category_id`),
  ADD KEY `idx_category_tree` (`parent_category_id`,`sort_order`);

--
-- Indexes for table `inventory_transactions`
--
ALTER TABLE `inventory_transactions`
  ADD PRIMARY KEY (`transaction_id`),
  ADD KEY `created_by` (`created_by`),
  ADD KEY `idx_inventory_variant` (`variant_id`,`transaction_date`);

--
-- Indexes for table `orders`
--
ALTER TABLE `orders`
  ADD PRIMARY KEY (`order_id`),
  ADD UNIQUE KEY `order_number` (`order_number`),
  ADD KEY `shipping_address_id` (`shipping_address_id`),
  ADD KEY `billing_address_id` (`billing_address_id`),
  ADD KEY `idx_order_status` (`status`,`payment_status`),
  ADD KEY `idx_order_user` (`user_id`,`created_at`);

--
-- Indexes for table `order_items`
--
ALTER TABLE `order_items`
  ADD PRIMARY KEY (`order_item_id`),
  ADD KEY `idx_order_items_order` (`order_id`),
  ADD KEY `idx_order_items_variant` (`variant_id`);

--
-- Indexes for table `price_history`
--
ALTER TABLE `price_history`
  ADD PRIMARY KEY (`price_id`),
  ADD KEY `variant_id` (`variant_id`),
  ADD KEY `created_by` (`created_by`),
  ADD KEY `idx_price_changes` (`product_id`,`effective_from`);

--
-- Indexes for table `products`
--
ALTER TABLE `products`
  ADD PRIMARY KEY (`product_id`),
  ADD UNIQUE KEY `sku` (`sku`),
  ADD UNIQUE KEY `slug` (`slug`),
  ADD KEY `idx_product_search` (`name`,`status`),
  ADD KEY `idx_product_category` (`category_id`,`featured`),
  ADD KEY `idx_product_brand` (`brand_id`,`base_price`);

--
-- Indexes for table `product_attributes`
--
ALTER TABLE `product_attributes`
  ADD PRIMARY KEY (`attribute_id`);

--
-- Indexes for table `product_attribute_values`
--
ALTER TABLE `product_attribute_values`
  ADD PRIMARY KEY (`value_id`),
  ADD UNIQUE KEY `unique_attribute_value` (`attribute_id`,`value`);

--
-- Indexes for table `product_reviews`
--
ALTER TABLE `product_reviews`
  ADD PRIMARY KEY (`review_id`),
  ADD UNIQUE KEY `unique_product_user_review` (`product_id`,`user_id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `order_item_id` (`order_item_id`),
  ADD KEY `idx_review_rating` (`product_id`,`rating`,`is_approved`);

--
-- Indexes for table `product_variants`
--
ALTER TABLE `product_variants`
  ADD PRIMARY KEY (`variant_id`),
  ADD UNIQUE KEY `sku` (`sku`),
  ADD KEY `idx_variant_product` (`product_id`,`is_default`);

--
-- Indexes for table `related_products`
--
ALTER TABLE `related_products`
  ADD PRIMARY KEY (`relation_id`),
  ADD UNIQUE KEY `unique_product_relation` (`product_id`,`related_product_id`,`relation_type`),
  ADD KEY `related_product_id` (`related_product_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `username` (`username`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indexes for table `user_addresses`
--
ALTER TABLE `user_addresses`
  ADD PRIMARY KEY (`address_id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `idx_user_geo` (`latitude`,`longitude`);

--
-- Indexes for table `variant_attribute_combinations`
--
ALTER TABLE `variant_attribute_combinations`
  ADD PRIMARY KEY (`combination_id`),
  ADD UNIQUE KEY `unique_variant_attribute` (`variant_id`,`attribute_id`),
  ADD KEY `attribute_id` (`attribute_id`),
  ADD KEY `value_id` (`value_id`);

--
-- Indexes for table `wishlists`
--
ALTER TABLE `wishlists`
  ADD PRIMARY KEY (`wishlist_id`),
  ADD UNIQUE KEY `unique_user_wishlist` (`user_id`,`name`);

--
-- Indexes for table `wishlist_items`
--
ALTER TABLE `wishlist_items`
  ADD PRIMARY KEY (`wishlist_item_id`),
  ADD UNIQUE KEY `unique_wishlist_variant` (`wishlist_id`,`variant_id`),
  ADD KEY `variant_id` (`variant_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `brands`
--
ALTER TABLE `brands`
  MODIFY `brand_id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `categories`
--
ALTER TABLE `categories`
  MODIFY `category_id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `inventory_transactions`
--
ALTER TABLE `inventory_transactions`
  MODIFY `transaction_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `orders`
--
ALTER TABLE `orders`
  MODIFY `order_id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `order_items`
--
ALTER TABLE `order_items`
  MODIFY `order_item_id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `price_history`
--
ALTER TABLE `price_history`
  MODIFY `price_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `products`
--
ALTER TABLE `products`
  MODIFY `product_id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `product_attributes`
--
ALTER TABLE `product_attributes`
  MODIFY `attribute_id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `product_attribute_values`
--
ALTER TABLE `product_attribute_values`
  MODIFY `value_id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `product_reviews`
--
ALTER TABLE `product_reviews`
  MODIFY `review_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `product_variants`
--
ALTER TABLE `product_variants`
  MODIFY `variant_id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `related_products`
--
ALTER TABLE `related_products`
  MODIFY `relation_id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `user_id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `user_addresses`
--
ALTER TABLE `user_addresses`
  MODIFY `address_id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `variant_attribute_combinations`
--
ALTER TABLE `variant_attribute_combinations`
  MODIFY `combination_id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `wishlists`
--
ALTER TABLE `wishlists`
  MODIFY `wishlist_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `wishlist_items`
--
ALTER TABLE `wishlist_items`
  MODIFY `wishlist_item_id` int NOT NULL AUTO_INCREMENT;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `categories`
--
ALTER TABLE `categories`
  ADD CONSTRAINT `categories_ibfk_1` FOREIGN KEY (`parent_category_id`) REFERENCES `categories` (`category_id`);

--
-- Constraints for table `inventory_transactions`
--
ALTER TABLE `inventory_transactions`
  ADD CONSTRAINT `inventory_transactions_ibfk_1` FOREIGN KEY (`variant_id`) REFERENCES `product_variants` (`variant_id`),
  ADD CONSTRAINT `inventory_transactions_ibfk_2` FOREIGN KEY (`created_by`) REFERENCES `users` (`user_id`);

--
-- Constraints for table `orders`
--
ALTER TABLE `orders`
  ADD CONSTRAINT `orders_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`),
  ADD CONSTRAINT `orders_ibfk_2` FOREIGN KEY (`shipping_address_id`) REFERENCES `user_addresses` (`address_id`),
  ADD CONSTRAINT `orders_ibfk_3` FOREIGN KEY (`billing_address_id`) REFERENCES `user_addresses` (`address_id`);

--
-- Constraints for table `order_items`
--
ALTER TABLE `order_items`
  ADD CONSTRAINT `order_items_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `orders` (`order_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `order_items_ibfk_2` FOREIGN KEY (`variant_id`) REFERENCES `product_variants` (`variant_id`);

--
-- Constraints for table `price_history`
--
ALTER TABLE `price_history`
  ADD CONSTRAINT `price_history_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`),
  ADD CONSTRAINT `price_history_ibfk_2` FOREIGN KEY (`variant_id`) REFERENCES `product_variants` (`variant_id`),
  ADD CONSTRAINT `price_history_ibfk_3` FOREIGN KEY (`created_by`) REFERENCES `users` (`user_id`);

--
-- Constraints for table `products`
--
ALTER TABLE `products`
  ADD CONSTRAINT `products_ibfk_1` FOREIGN KEY (`brand_id`) REFERENCES `brands` (`brand_id`),
  ADD CONSTRAINT `products_ibfk_2` FOREIGN KEY (`category_id`) REFERENCES `categories` (`category_id`);

--
-- Constraints for table `product_attribute_values`
--
ALTER TABLE `product_attribute_values`
  ADD CONSTRAINT `product_attribute_values_ibfk_1` FOREIGN KEY (`attribute_id`) REFERENCES `product_attributes` (`attribute_id`) ON DELETE CASCADE;

--
-- Constraints for table `product_reviews`
--
ALTER TABLE `product_reviews`
  ADD CONSTRAINT `product_reviews_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`),
  ADD CONSTRAINT `product_reviews_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`),
  ADD CONSTRAINT `product_reviews_ibfk_3` FOREIGN KEY (`order_item_id`) REFERENCES `order_items` (`order_item_id`);

--
-- Constraints for table `product_variants`
--
ALTER TABLE `product_variants`
  ADD CONSTRAINT `product_variants_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`) ON DELETE CASCADE;

--
-- Constraints for table `related_products`
--
ALTER TABLE `related_products`
  ADD CONSTRAINT `related_products_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`),
  ADD CONSTRAINT `related_products_ibfk_2` FOREIGN KEY (`related_product_id`) REFERENCES `products` (`product_id`);

--
-- Constraints for table `user_addresses`
--
ALTER TABLE `user_addresses`
  ADD CONSTRAINT `user_addresses_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `variant_attribute_combinations`
--
ALTER TABLE `variant_attribute_combinations`
  ADD CONSTRAINT `variant_attribute_combinations_ibfk_1` FOREIGN KEY (`variant_id`) REFERENCES `product_variants` (`variant_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `variant_attribute_combinations_ibfk_2` FOREIGN KEY (`attribute_id`) REFERENCES `product_attributes` (`attribute_id`),
  ADD CONSTRAINT `variant_attribute_combinations_ibfk_3` FOREIGN KEY (`value_id`) REFERENCES `product_attribute_values` (`value_id`);

--
-- Constraints for table `wishlists`
--
ALTER TABLE `wishlists`
  ADD CONSTRAINT `wishlists_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `wishlist_items`
--
ALTER TABLE `wishlist_items`
  ADD CONSTRAINT `wishlist_items_ibfk_1` FOREIGN KEY (`wishlist_id`) REFERENCES `wishlists` (`wishlist_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `wishlist_items_ibfk_2` FOREIGN KEY (`variant_id`) REFERENCES `product_variants` (`variant_id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
