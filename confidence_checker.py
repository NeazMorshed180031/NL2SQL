# import json
# from datetime import datetime

# # Define the queries and their confidence analysis
# queries_data = [
#     {
#         "Complexity": "Complex",
#         "NLP Query": "List the names of all users who have purchased an 'iPhone 13 Pro', including the total amount they have spent on that specific product across all their orders.",
#         "SQL Query": """SELECT u.first_name, u.last_name, SUM(oi.line_total) AS total_spent 
# FROM users u 
# JOIN orders o ON u.user_id = o.user_id 
# JOIN order_items oi ON o.order_id = oi.order_id 
# WHERE oi.product_name = 'iPhone 13 Pro' 
# GROUP BY u.user_id, u.first_name, u.last_name;""",
#         "Confidence": 100,
#         "Status": "✓ Correct",
#         "Analysis": "Query is fully correct. It properly joins users, orders, and order_items tables, filters by product_name, and aggregates spending by user. All table relationships are correct."
#     },
#     {
#         "Complexity": "Complex",
#         "NLP Query": "Identify the top-selling product category by revenue and list all the brands that have products within that specific category.",
#         "SQL Query": """SELECT c.name AS category_name, b.name AS brand_name 
# FROM categories c 
# JOIN products p ON c.category_id = p.category_id 
# JOIN brands b ON p.brand_id = b.brand_id 
# WHERE c.category_id = (
#   SELECT p2.category_id 
#   FROM order_items oi 
#   JOIN product_variants pv ON oi.variant_id = pv.variant_id 
#   JOIN products p2 ON pv.product_id = p2.product_id 
#   GROUP BY p2.category_id 
#   ORDER BY SUM(oi.line_total) DESC 
#   LIMIT 1
# );""",
#         "Confidence": 100,
#         "Status": "✓ Correct",
#         "Analysis": "Query correctly identifies the top-selling category by revenue in the subquery and retrieves all brands in that category. The joins through product_variants are necessary and correct."
#     },
#     {
#         "Complexity": "Complex",
#         "NLP Query": "For products that have at least one review with a rating of 5, show the product name, its current stock quantity (summed across all variants), and the name of the brand.",
#         "SQL Query": """SELECT p.name, SUM(pv.stock_quantity) AS total_stock, b.name AS brand_name 
# FROM products p 
# JOIN product_reviews pr ON p.product_id = pr.product_id 
# JOIN product_variants pv ON p.product_id = pv.product_id 
# JOIN brands b ON p.brand_id = b.brand_id 
# WHERE pr.rating = 5 AND pr.is_approved = 1 
# GROUP BY p.product_id, p.name, b.name;""",
#         "Confidence": 95,
#         "Status": "✓ Correct",
#         "Analysis": "Query is correct and properly aggregates stock across variants. Filtering by is_approved is good practice. Minor consideration: if a product has multiple 5-star reviews, grouping will still work correctly."
#     },
#     {
#         "Complexity": "Complex",
#         "NLP Query": "Find all users who have a billing address in 'New York' and have placed an order with a 'delivered' status, showing their email and the order number.",
#         "SQL Query": """SELECT u.email, o.order_number 
# FROM users u 
# JOIN orders o ON u.user_id = o.user_id 
# JOIN user_addresses ua ON o.billing_address_id = ua.address_id 
# WHERE ua.city = 'New York' AND o.status = 'delivered';""",
#         "Confidence": 100,
#         "Status": "✓ Correct",
#         "Analysis": "Query correctly joins through billing_address_id to filter by city and order status. All foreign key relationships are properly used."
#     },
#     {
#         "Complexity": "Medium",
#         "NLP Query": "Show the SKU and current stock quantity for all product variants that have 30 or fewer items remaining in stock.",
#         "SQL Query": """SELECT sku, stock_quantity 
# FROM product_variants 
# WHERE stock_quantity <= 30;""",
#         "Confidence": 100,
#         "Status": "✓ Correct",
#         "Analysis": "Simple and correct query. Directly accesses product_variants table with appropriate filter condition."
#     },
#     {
#         "Complexity": "Medium",
#         "NLP Query": "Calculate the average rating for each product that has at least one approved review.",
#         "SQL Query": """SELECT p.name, AVG(pr.rating) AS average_rating 
# FROM products p 
# JOIN product_reviews pr ON p.product_id = pr.product_id 
# WHERE pr.is_approved = 1 
# GROUP BY p.product_id, p.name;""",
#         "Confidence": 100,
#         "Status": "✓ Correct",
#         "Analysis": "Query correctly calculates average ratings for products with approved reviews. The WHERE clause ensures only approved reviews are included in the calculation."
#     },
#     {
#         "Complexity": "Medium",
#         "NLP Query": "Retrieve all orders placed after November 1st, 2025, that have a payment status of 'paid' but a shipping status of 'pending'.",
#         "SQL Query": """SELECT * 
# FROM orders 
# WHERE created_at > '2025-11-01' 
#   AND payment_status = 'paid' 
#   AND shipping_status = 'pending';""",
#         "Confidence": 100,
#         "Status": "✓ Correct",
#         "Analysis": "Query correctly filters orders by date and status conditions. All field names and enum values match the schema."
#     },
#     {
#         "Complexity": "Medium",
#         "NLP Query": "List the names of all sub-categories that fall under the 'Electronics' parent category.",
#         "SQL Query": """SELECT name 
# FROM categories 
# WHERE parent_category_id = (
#   SELECT category_id 
#   FROM categories 
#   WHERE name = 'Electronics'
# );""",
#         "Confidence": 100,
#         "Status": "✓ Correct",
#         "Analysis": "Query correctly uses self-referential join through parent_category_id to find subcategories. The subquery approach is clean and appropriate."
#     },
#     {
#         "Complexity": "Simple",
#         "NLP Query": "Show the names and descriptions of all brands that are currently marked as active.",
#         "SQL Query": """SELECT name, description 
# FROM brands 
# WHERE is_active = 1;""",
#         "Confidence": 100,
#         "Status": "✓ Correct",
#         "Analysis": "Simple and correct query. Directly filters brands by the is_active flag."
#     },
#     {
#         "Complexity": "Simple",
#         "NLP Query": "What is the total number of users registered in the system?",
#         "SQL Query": """SELECT COUNT(*) 
# FROM users;""",
#         "Confidence": 100,
#         "Status": "✓ Correct",
#         "Analysis": "Basic COUNT query is correct. Returns total number of rows in users table."
#     }
# ]

# # Calculate statistics
# total_queries = len(queries_data)
# confidence_scores = [q['Confidence'] for q in queries_data]
# avg_confidence = sum(confidence_scores) / len(confidence_scores)
# queries_100 = len([c for c in confidence_scores if c == 100])
# queries_95_99 = len([c for c in confidence_scores if 95 <= c < 100])
# queries_below_95 = len([c for c in confidence_scores if c < 95])

# # Count by complexity
# complexity_counts = {}
# complexity_confidence = {}
# for q in queries_data:
#     comp = q['Complexity']
#     if comp not in complexity_counts:
#         complexity_counts[comp] = 0
#         complexity_confidence[comp] = []
#     complexity_counts[comp] += 1
#     complexity_confidence[comp].append(q['Confidence'])

# # Write to test.txt
# with open('test.txt', 'w', encoding='utf-8') as f:
#     f.write("=" * 100 + "\n")
#     f.write("SQL QUERY CONFIDENCE ANALYSIS REPORT\n")
#     f.write(f"Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
#     f.write("=" * 100 + "\n\n")
    
#     # Summary statistics
#     f.write("EXECUTIVE SUMMARY\n")
#     f.write("=" * 100 + "\n")
#     f.write(f"Total Queries Analyzed: {total_queries}\n")
#     f.write(f"Average Confidence Score: {avg_confidence:.1f}%\n")
#     f.write(f"Queries with 100% Confidence: {queries_100}\n")
#     f.write(f"Queries with 95-99% Confidence: {queries_95_99}\n")
#     f.write(f"Queries with <95% Confidence: {queries_below_95}\n\n")
    
#     # Confidence breakdown by complexity
#     f.write("=" * 100 + "\n")
#     f.write("CONFIDENCE BREAKDOWN BY COMPLEXITY\n")
#     f.write("=" * 100 + "\n")
#     f.write(f"{'Complexity':<15} {'Count':<10} {'Avg Confidence':<20}\n")
#     f.write("-" * 100 + "\n")
#     for comp in sorted(complexity_counts.keys(), key=lambda x: {'Simple': 1, 'Medium': 2, 'Complex': 3}[x]):
#         avg = sum(complexity_confidence[comp]) / len(complexity_confidence[comp])
#         f.write(f"{comp:<15} {complexity_counts[comp]:<10} {avg:.1f}%\n")
#     f.write("\n")
    
#     # Quick reference table
#     f.write("=" * 100 + "\n")
#     f.write("QUICK REFERENCE TABLE\n")
#     f.write("=" * 100 + "\n")
#     f.write(f"{'#':<5} {'Complexity':<12} {'Confidence':<12} {'Status':<15}\n")
#     f.write("-" * 100 + "\n")
#     for idx, row in enumerate(queries_data, 1):
#         f.write(f"{idx:<5} {row['Complexity']:<12} {row['Confidence']}%{' ':<8} {row['Status']:<15}\n")
#     f.write("\n")
    
#     # Detailed analysis
#     f.write("=" * 100 + "\n")
#     f.write("DETAILED QUERY ANALYSIS\n")
#     f.write("=" * 100 + "\n\n")
    
#     for idx, row in enumerate(queries_data, 1):
#         f.write(f"[Query {idx}] Complexity: {row['Complexity']} | Confidence: {row['Confidence']}% | {row['Status']}\n")
#         f.write("-" * 100 + "\n")
#         f.write(f"NLP Query:\n{row['NLP Query']}\n\n")
#         f.write(f"SQL Query:\n{row['SQL Query']}\n\n")
#         f.write(f"Analysis:\n{row['Analysis']}\n")
#         f.write("=" * 100 + "\n\n")
    
#     # Key findings
#     f.write("=" * 100 + "\n")
#     f.write("KEY FINDINGS\n")
#     f.write("=" * 100 + "\n")
#     f.write("1. All queries are syntactically correct and properly use the database schema\n")
#     f.write("2. Complex queries demonstrate proper understanding of multi-table joins\n")
#     f.write("3. All foreign key relationships are correctly implemented\n")
#     f.write("4. Aggregation functions (SUM, AVG, COUNT) are appropriately used\n")
#     f.write("5. Subqueries are properly structured and efficient\n")
#     f.write("6. Filtering conditions match enum values defined in the schema\n\n")
    
#     f.write("=" * 100 + "\n")
#     f.write("END OF REPORT\n")
#     f.write("=" * 100 + "\n")

# # Also print to console
# print("=" * 100)
# print("SQL QUERY CONFIDENCE ANALYSIS SUMMARY")
# print("=" * 100)
# print(f"\nTotal Queries Analyzed: {total_queries}")
# print(f"Average Confidence Score: {avg_confidence:.1f}%")
# print(f"Queries with 100% Confidence: {queries_100}")
# print(f"Queries with 95-99% Confidence: {queries_95_99}")
# print(f"Queries with <95% Confidence: {queries_below_95}")

# print("\n" + "=" * 100)
# print("CONFIDENCE BREAKDOWN BY COMPLEXITY")
# print("=" * 100)
# print(f"{'Complexity':<15} {'Count':<10} {'Avg Confidence':<20}")
# print("-" * 100)
# for comp in sorted(complexity_counts.keys(), key=lambda x: {'Simple': 1, 'Medium': 2, 'Complex': 3}[x]):
#     avg = sum(complexity_confidence[comp]) / len(complexity_confidence[comp])
#     print(f"{comp:<15} {complexity_counts[comp]:<10} {avg:.1f}%")

# print("\n✓ Full report written to 'test.txt'")
# print("✓ Analysis complete!")

import json
import re
from datetime import datetime

# Database schema definition for validation
SCHEMA = {
    "users": ["user_id", "first_name", "last_name", "email", "created_at"],
    "orders": ["order_id", "user_id", "order_number", "status", "payment_status", 
               "shipping_status", "created_at", "billing_address_id"],
    "order_items": ["item_id", "order_id", "variant_id", "product_name", "line_total"],
    "products": ["product_id", "name", "category_id", "brand_id"],
    "product_variants": ["variant_id", "product_id", "sku", "stock_quantity"],
    "product_reviews": ["review_id", "product_id", "rating", "is_approved"],
    "categories": ["category_id", "name", "parent_category_id"],
    "brands": ["brand_id", "name", "description", "is_active"],
    "user_addresses": ["address_id", "user_id", "city"]
}

# Foreign key relationships
FOREIGN_KEYS = {
    ("orders", "user_id"): ("users", "user_id"),
    ("orders", "billing_address_id"): ("user_addresses", "address_id"),
    ("order_items", "order_id"): ("orders", "order_id"),
    ("order_items", "variant_id"): ("product_variants", "variant_id"),
    ("products", "category_id"): ("categories", "category_id"),
    ("products", "brand_id"): ("brands", "brand_id"),
    ("product_variants", "product_id"): ("products", "product_id"),
    ("product_reviews", "product_id"): ("products", "product_id"),
    ("categories", "parent_category_id"): ("categories", "category_id"),
    ("user_addresses", "user_id"): ("users", "user_id")
}

# Valid enum values
ENUM_VALUES = {
    "status": ["pending", "processing", "delivered", "cancelled"],
    "payment_status": ["pending", "paid", "failed", "refunded"],
    "shipping_status": ["pending", "shipped", "delivered"]
}

def calculate_confidence(sql_query, nlp_query, complexity):
    """
    Automatically calculate confidence score based on multiple criteria
    Returns: (confidence_score, status, analysis_details)
    """
    score = 100
    issues = []
    warnings = []
    
    # Normalize SQL for parsing
    sql_normalized = sql_query.upper().strip()
    sql_lower = sql_query.lower()
    
    # 1. SYNTAX VALIDATION (30 points)
    syntax_score = validate_syntax(sql_query, issues)
    
    # 2. SCHEMA COMPLIANCE (30 points)
    schema_score = validate_schema(sql_query, issues, warnings)
    
    # 3. QUERY LOGIC (25 points)
    logic_score = validate_logic(sql_query, nlp_query, complexity, issues, warnings)
    
    # 4. BEST PRACTICES (15 points)
    practice_score = validate_best_practices(sql_query, warnings)
    
    # Calculate weighted score
    total_score = syntax_score + schema_score + logic_score + practice_score
    
    # Determine status
    if total_score >= 95 and len(issues) == 0:
        status = "✓ Correct"
    elif total_score >= 85:
        status = "⚠ Warning"
    else:
        status = "✗ Failed"
    
    # Generate analysis
    analysis = generate_analysis(total_score, issues, warnings, sql_query)
    
    return int(total_score), status, analysis

def validate_syntax(sql_query, issues):
    """Validate SQL syntax (30 points)"""
    score = 30
    sql_upper = sql_query.upper()
    
    # Check for basic SQL structure
    if "SELECT" not in sql_upper:
        issues.append("Missing SELECT clause")
        score -= 10
    
    if "FROM" not in sql_upper:
        issues.append("Missing FROM clause")
        score -= 10
    
    # Check for unmatched parentheses
    if sql_query.count('(') != sql_query.count(')'):
        issues.append("Unmatched parentheses")
        score -= 5
    
    # Check for missing semicolon at end (minor)
    if not sql_query.strip().endswith(';'):
        score -= 1
    
    # Check for SQL injection patterns (basic check)
    dangerous_patterns = ["--", "/*", "*/", "xp_", "sp_"]
    for pattern in dangerous_patterns:
        if pattern in sql_query.lower():
            issues.append(f"Potentially dangerous pattern detected: {pattern}")
            score -= 3
    
    return max(0, score)

def validate_schema(sql_query, issues, warnings):
    """Validate against database schema (30 points)"""
    score = 30
    sql_lower = sql_query.lower()
    
    # Extract table names from FROM and JOIN clauses
    table_pattern = r'(?:from|join)\s+(\w+)'
    tables_used = re.findall(table_pattern, sql_lower)
    
    # Check if tables exist in schema
    for table in tables_used:
        if table not in SCHEMA:
            issues.append(f"Table '{table}' does not exist in schema")
            score -= 8
    
    # Extract column references
    for table_alias, table_name in extract_table_aliases(sql_query):
        # Check column references for this table
        column_pattern = rf'{table_alias}\.(\w+)'
        columns = re.findall(column_pattern, sql_lower)
        
        if table_name in SCHEMA:
            for col in columns:
                if col not in SCHEMA[table_name]:
                    issues.append(f"Column '{col}' does not exist in table '{table_name}'")
                    score -= 5
    
    # Validate JOIN conditions
    join_score = validate_joins(sql_query, issues, warnings)
    score += join_score - 10  # Adjust within 30 point allocation
    
    return max(0, score)

def validate_logic(sql_query, nlp_query, complexity, issues, warnings):
    """Validate query logic (25 points)"""
    score = 25
    sql_upper = sql_query.upper()
    sql_lower = sql_query.lower()
    
    # Check GROUP BY usage
    if "GROUP BY" in sql_upper:
        # Verify aggregate functions are used
        has_aggregate = any(func in sql_upper for func in ["SUM(", "AVG(", "COUNT(", "MAX(", "MIN("])
        if not has_aggregate:
            warnings.append("GROUP BY without aggregate function")
            score -= 3
    
    # Check for aggregate without GROUP BY (except COUNT(*))
    has_aggregate = any(func in sql_upper for func in ["SUM(", "AVG("])
    if has_aggregate and "GROUP BY" not in sql_upper:
        issues.append("Aggregate function without GROUP BY")
        score -= 5
    
    # Validate WHERE clause usage
    if "WHERE" in sql_upper:
        # Check for enum values validation
        for enum_field, valid_values in ENUM_VALUES.items():
            if enum_field in sql_lower:
                # Extract the value being compared
                for value in valid_values:
                    if f"'{value}'" in sql_lower:
                        break
                else:
                    # Check if any value is used
                    pattern = rf"{enum_field}\s*=\s*'(\w+)'"
                    matches = re.findall(pattern, sql_lower)
                    for match in matches:
                        if match not in valid_values:
                            issues.append(f"Invalid enum value '{match}' for field '{enum_field}'")
                            score -= 4
    
    # Complexity validation
    if complexity == "Complex":
        # Should have JOIN
        if "JOIN" not in sql_upper:
            warnings.append("Complex query should typically involve JOINs")
            score -= 3
    
    # Check for proper filtering in subqueries
    if "LIMIT 1" in sql_upper and "ORDER BY" not in sql_upper:
        warnings.append("LIMIT 1 without ORDER BY may produce unpredictable results")
        score -= 2
    
    return max(0, score)

def validate_best_practices(sql_query, warnings):
    """Validate SQL best practices (15 points)"""
    score = 15
    sql_upper = sql_query.upper()
    
    # Avoid SELECT *
    if "SELECT *" in sql_upper:
        warnings.append("Using SELECT * is not recommended; specify columns explicitly")
        score -= 3
    
    # Check for table aliases
    if "FROM" in sql_upper and " AS " not in sql_upper and "JOIN" in sql_upper:
        # Complex queries should use aliases
        if sql_query.count("JOIN") > 1:
            warnings.append("Consider using table aliases for better readability")
            score -= 2
    
    # Check for proper indentation (basic check)
    lines = sql_query.split('\n')
    if len(lines) > 3 and all(not line.startswith(' ') for line in lines[1:] if line.strip()):
        warnings.append("Poor formatting/indentation")
        score -= 1
    
    return max(0, score)

def validate_joins(sql_query, issues, warnings):
    """Validate JOIN conditions (10 points within schema validation)"""
    score = 10
    sql_lower = sql_query.lower()
    
    # Extract JOIN conditions
    join_pattern = r'join\s+(\w+)\s+(\w+)\s+on\s+(\w+)\.(\w+)\s*=\s*(\w+)\.(\w+)'
    joins = re.findall(join_pattern, sql_lower)
    
    for join in joins:
        table1, alias1, left_table, left_col, right_table, right_col = join
        
        # Verify foreign key relationship exists
        fk_valid = False
        for (fk_table, fk_col), (pk_table, pk_col) in FOREIGN_KEYS.items():
            if (left_col == fk_col and right_col == pk_col) or \
               (right_col == fk_col and left_col == pk_col):
                fk_valid = True
                break
        
        if not fk_valid:
            warnings.append(f"JOIN condition {left_table}.{left_col} = {right_table}.{right_col} may not match foreign key relationships")
            score -= 2
    
    return max(0, score)

def extract_table_aliases(sql_query):
    """Extract table names and their aliases"""
    sql_lower = sql_query.lower()
    aliases = []
    
    # Pattern: table_name alias or table_name AS alias
    pattern = r'(?:from|join)\s+(\w+)(?:\s+as)?\s+(\w+)'
    matches = re.findall(pattern, sql_lower)
    
    for table, alias in matches:
        aliases.append((alias, table))
    
    return aliases

def generate_analysis(score, issues, warnings, sql_query):
    """Generate detailed analysis text"""
    analysis_parts = []
    
    if score == 100:
        analysis_parts.append("Query is fully correct with perfect score.")
    elif score >= 95:
        analysis_parts.append("Query is correct with minor considerations.")
    elif score >= 85:
        analysis_parts.append("Query has some issues that should be addressed.")
    else:
        analysis_parts.append("Query has significant issues requiring correction.")
    
    if issues:
        analysis_parts.append(f"Issues found: {'; '.join(issues)}.")
    
    if warnings:
        analysis_parts.append(f"Warnings: {'; '.join(warnings)}.")
    
    # Positive observations
    sql_upper = sql_query.upper()
    positives = []
    
    if "JOIN" in sql_upper:
        join_count = sql_query.upper().count("JOIN")
        positives.append(f"Uses {join_count} JOIN(s) properly")
    
    if "GROUP BY" in sql_upper and any(f in sql_upper for f in ["SUM(", "AVG(", "COUNT("]):
        positives.append("Correctly uses aggregation with GROUP BY")
    
    if "WHERE" in sql_upper:
        positives.append("Includes proper filtering conditions")
    
    if positives:
        analysis_parts.append(f"Strengths: {', '.join(positives)}.")
    
    return " ".join(analysis_parts)

# Query test data
queries_data = [
    {
        "Complexity": "Complex",
        "NLP Query": "List the names of all users who have purchased an 'iPhone 13 Pro', including the total amount they have spent on that specific product across all their orders.",
        "SQL Query": """SELECT u.first_name, u.last_name, SUM(oi.line_total) AS total_spent 
FROM users u 
JOIN orders o ON u.user_id = o.user_id 
JOIN order_items oi ON o.order_id = oi.order_id 
WHERE oi.product_name = 'iPhone 13 Pro' 
GROUP BY u.user_id, u.first_name, u.last_name;"""
    },
    {
        "Complexity": "Complex",
        "NLP Query": "Identify the top-selling product category by revenue and list all the brands that have products within that specific category.",
        "SQL Query": """SELECT c.name AS category_name, b.name AS brand_name 
FROM categories c 
JOIN products p ON c.category_id = p.category_id 
JOIN brands b ON p.brand_id = b.brand_id 
WHERE c.category_id = (
  SELECT p2.category_id 
  FROM order_items oi 
  JOIN product_variants pv ON oi.variant_id = pv.variant_id 
  JOIN products p2 ON pv.product_id = p2.product_id 
  GROUP BY p2.category_id 
  ORDER BY SUM(oi.line_total) DESC 
  LIMIT 1
);"""
    },
    {
        "Complexity": "Complex",
        "NLP Query": "For products that have at least one review with a rating of 5, show the product name, its current stock quantity (summed across all variants), and the name of the brand.",
        "SQL Query": """SELECT p.name, SUM(pv.stock_quantity) AS total_stock, b.name AS brand_name 
FROM products p 
JOIN product_reviews pr ON p.product_id = pr.product_id 
JOIN product_variants pv ON p.product_id = pv.product_id 
JOIN brands b ON p.brand_id = b.brand_id 
WHERE pr.rating = 5 AND pr.is_approved = 1 
GROUP BY p.product_id, p.name, b.name;"""
    },
    {
        "Complexity": "Complex",
        "NLP Query": "Find all users who have a billing address in 'New York' and have placed an order with a 'delivered' status, showing their email and the order number.",
        "SQL Query": """SELECT u.email, o.order_number 
FROM users u 
JOIN orders o ON u.user_id = o.user_id 
JOIN user_addresses ua ON o.billing_address_id = ua.address_id 
WHERE ua.city = 'New York' AND o.status = 'delivered';"""
    },
    {
        "Complexity": "Medium",
        "NLP Query": "Show the SKU and current stock quantity for all product variants that have 30 or fewer items remaining in stock.",
        "SQL Query": """SELECT sku, stock_quantity 
FROM product_variants 
WHERE stock_quantity <= 30;"""
    },
    {
        "Complexity": "Medium",
        "NLP Query": "Calculate the average rating for each product that has at least one approved review.",
        "SQL Query": """SELECT p.name, AVG(pr.rating) AS average_rating 
FROM products p 
JOIN product_reviews pr ON p.product_id = pr.product_id 
WHERE pr.is_approved = 1 
GROUP BY p.product_id, p.name;"""
    },
    {
        "Complexity": "Medium",
        "NLP Query": "Retrieve all orders placed after November 1st, 2025, that have a payment status of 'paid' but a shipping status of 'pending'.",
        "SQL Query": """SELECT * 
FROM orders 
WHERE created_at > '2025-11-01' 
  AND payment_status = 'paid' 
  AND shipping_status = 'pending';"""
    },
    {
        "Complexity": "Medium",
        "NLP Query": "List the names of all sub-categories that fall under the 'Electronics' parent category.",
        "SQL Query": """SELECT name 
FROM categories 
WHERE parent_category_id = (
  SELECT category_id 
  FROM categories 
  WHERE name = 'Electronics'
);"""
    },
    {
        "Complexity": "Simple",
        "NLP Query": "Show the names and descriptions of all brands that are currently marked as active.",
        "SQL Query": """SELECT name, description 
FROM brands 
WHERE is_active = 1;"""
    },
    {
        "Complexity": "Simple",
        "NLP Query": "What is the total number of users registered in the system?",
        "SQL Query": """SELECT COUNT(*) 
FROM users;"""
    }
]

# Calculate confidence for each query AUTOMATICALLY
for query in queries_data:
    confidence, status, analysis = calculate_confidence(
        query["SQL Query"], 
        query["NLP Query"], 
        query["Complexity"]
    )
    query["Confidence"] = confidence
    query["Status"] = status
    query["Analysis"] = analysis

# Calculate statistics
total_queries = len(queries_data)
confidence_scores = [q['Confidence'] for q in queries_data]
avg_confidence = sum(confidence_scores) / len(confidence_scores)
queries_100 = len([c for c in confidence_scores if c == 100])
queries_95_99 = len([c for c in confidence_scores if 95 <= c < 100])
queries_below_95 = len([c for c in confidence_scores if c < 95])

# Count by complexity
complexity_counts = {}
complexity_confidence = {}
for q in queries_data:
    comp = q['Complexity']
    if comp not in complexity_counts:
        complexity_counts[comp] = 0
        complexity_confidence[comp] = []
    complexity_counts[comp] += 1
    complexity_confidence[comp].append(q['Confidence'])

# Write to test.txt
with open('test.txt', 'w', encoding='utf-8') as f:
    f.write("=" * 100 + "\n")
    f.write("AUTOMATED SQL QUERY CONFIDENCE ANALYSIS REPORT\n")
    f.write(f"Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
    f.write("=" * 100 + "\n\n")
    
    f.write("CONFIDENCE CALCULATION METHODOLOGY\n")
    f.write("=" * 100 + "\n")
    f.write("Confidence scores are automatically calculated based on:\n")
    f.write("  • Syntax Validation (30 points): SQL structure, parentheses matching, basic injection checks\n")
    f.write("  • Schema Compliance (30 points): Table/column existence, foreign key relationships\n")
    f.write("  • Query Logic (25 points): Proper use of GROUP BY, aggregates, WHERE clauses, enum values\n")
    f.write("  • Best Practices (15 points): Avoid SELECT *, use aliases, proper formatting\n")
    f.write("Total: 100 points maximum\n\n")
    
    # Summary statistics
    f.write("EXECUTIVE SUMMARY\n")
    f.write("=" * 100 + "\n")
    f.write(f"Total Queries Analyzed: {total_queries}\n")
    f.write(f"Average Confidence Score: {avg_confidence:.1f}%\n")
    f.write(f"Queries with 100% Confidence: {queries_100}\n")
    f.write(f"Queries with 95-99% Confidence: {queries_95_99}\n")
    f.write(f"Queries with <95% Confidence: {queries_below_95}\n\n")
    
    # Confidence breakdown by complexity
    f.write("=" * 100 + "\n")
    f.write("CONFIDENCE BREAKDOWN BY COMPLEXITY\n")
    f.write("=" * 100 + "\n")
    f.write(f"{'Complexity':<15} {'Count':<10} {'Avg Confidence':<20}\n")
    f.write("-" * 100 + "\n")
    for comp in sorted(complexity_counts.keys(), key=lambda x: {'Simple': 1, 'Medium': 2, 'Complex': 3}[x]):
        avg = sum(complexity_confidence[comp]) / len(complexity_confidence[comp])
        f.write(f"{comp:<15} {complexity_counts[comp]:<10} {avg:.1f}%\n")
    f.write("\n")
    
    # Quick reference table
    f.write("=" * 100 + "\n")
    f.write("QUICK REFERENCE TABLE\n")
    f.write("=" * 100 + "\n")
    f.write(f"{'#':<5} {'Complexity':<12} {'Confidence':<12} {'Status':<15}\n")
    f.write("-" * 100 + "\n")
    for idx, row in enumerate(queries_data, 1):
        f.write(f"{idx:<5} {row['Complexity']:<12} {row['Confidence']}%{' ':<8} {row['Status']:<15}\n")
    f.write("\n")
    
    # Detailed analysis
    f.write("=" * 100 + "\n")
    f.write("DETAILED QUERY ANALYSIS\n")
    f.write("=" * 100 + "\n\n")
    
    for idx, row in enumerate(queries_data, 1):
        f.write(f"[Query {idx}] Complexity: {row['Complexity']} | Confidence: {row['Confidence']}% | {row['Status']}\n")
        f.write("-" * 100 + "\n")
        f.write(f"NLP Query:\n{row['NLP Query']}\n\n")
        f.write(f"SQL Query:\n{row['SQL Query']}\n\n")
        f.write(f"Automated Analysis:\n{row['Analysis']}\n")
        f.write("=" * 100 + "\n\n")
    
    f.write("=" * 100 + "\n")
    f.write("END OF REPORT\n")
    f.write("=" * 100 + "\n")

# Print to console
print("=" * 100)
print("AUTOMATED SQL QUERY CONFIDENCE ANALYSIS SUMMARY")
print("=" * 100)
print(f"\nTotal Queries Analyzed: {total_queries}")
print(f"Average Confidence Score: {avg_confidence:.1f}%")
print(f"Queries with 100% Confidence: {queries_100}")
print(f"Queries with 95-99% Confidence: {queries_95_99}")
print(f"Queries with <95% Confidence: {queries_below_95}")

print("\n" + "=" * 100)
print("CONFIDENCE BREAKDOWN BY COMPLEXITY")
print("=" * 100)
print(f"{'Complexity':<15} {'Count':<10} {'Avg Confidence':<20}")
print("-" * 100)
for comp in sorted(complexity_counts.keys(), key=lambda x: {'Simple': 1, 'Medium': 2, 'Complex': 3}[x]):
    avg = sum(complexity_confidence[comp]) / len(complexity_confidence[comp])
    print(f"{comp:<15} {complexity_counts[comp]:<10} {avg:.1f}%")

print("\n✓ Full report written to 'test.txt'")
print("✓ Automated analysis complete!")
print("\nConfidence Calculation Breakdown:")
print("  • Syntax Validation: 30 points")
print("  • Schema Compliance: 30 points")
print("  • Query Logic: 25 points")
print("  • Best Practices: 15 points")
print("  = 100 points total")