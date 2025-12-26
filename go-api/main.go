package main

import (
	"bytes"
	"database/sql"
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"strings"

	_ "github.com/go-sql-driver/mysql"
)

// --- Configuration Constants ---
const modelName = "gemini-2.5-flash-preview-09-2025"
const apiKey = "" // insert your gemini apiKey
const apiUrl = "https://generativelanguage.googleapis.com/v1beta/models/" + modelName + ":generateContent?key=" + apiKey

// --- MySQL Database Details ---
// --- MySQL Database Details ---
const DBUser = ""
const DBPass = ""
const DBHost = "" // Updated from localhost
const DBPort = ""
const DBName = ""

const dbConnStr = DBUser + ":" + DBPass + "@tcp(" + DBHost + ":" + DBPort + ")/" + DBName

// --- Global Variables ---
var db *sql.DB
var dbSchema string // Variable to hold the dynamically generated schema

// --- LLM Structured Output Definitions ---

type SQLResponse struct {
	GeneratedSQL string `json:"generated_sql"`
	Confidence   string `json:"confidence"`
}

type LLMResponse struct {
	Candidates []struct {
		Content struct {
			Parts []struct {
				Text string `json:"text"`
			} `json:"parts"`
		} `json:"content"`
	} `json:"candidates"`
}

// --- CORS Middleware Function (The Fix) ---

// enableCORS is a middleware that sets the required CORS headers and handles preflight requests.
func enableCORS(next http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		// Set headers for all requests
		w.Header().Set("Access-Control-Allow-Origin", "*")
		w.Header().Set("Access-Control-Allow-Methods", "POST, GET, OPTIONS, PUT, DELETE")
		w.Header().Set("Access-Control-Allow-Headers", "Accept, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization")

		// Handle preflight OPTIONS request
		if r.Method == "OPTIONS" {
			w.WriteHeader(http.StatusOK)
			return
		}

		// Call the next handler
		next(w, r)
	}
}

// --- Dynamic Schema Retrieval ---

// generateSchemaFromDB connects to the DB and builds the schema string for the LLM.
func generateSchemaFromDB() error {
	log.Println("Generating dynamic database schema...")

	// Query to get all tables and their columns in the target database
	query := `
		SELECT 
			TABLE_NAME, 
			GROUP_CONCAT(COLUMN_NAME ORDER BY ORDINAL_POSITION SEPARATOR ', ')
		FROM 
			information_schema.COLUMNS
		WHERE 
			TABLE_SCHEMA = ?
		GROUP BY 
			TABLE_NAME
		ORDER BY
			TABLE_NAME;
	`
	rows, err := db.Query(query, DBName)
	if err != nil {
		return fmt.Errorf("failed to query information schema: %w", err)
	}
	defer rows.Close()

	var schemaBuilder strings.Builder
	schemaBuilder.WriteString("Database Schema:\n")

	for rows.Next() {
		var tableName string
		var columnList string
		if err := rows.Scan(&tableName, &columnList); err != nil {
			return fmt.Errorf("failed to scan schema row: %w", err)
		}
		// Format: - table_name (col1, col2, col3)
		schemaBuilder.WriteString(fmt.Sprintf("- %s (%s)\n", tableName, columnList))
	}

	if err := rows.Err(); err != nil {
		return fmt.Errorf("error during schema row iteration: %w", err)
	}

	// Add the final instruction prompt
	instruction := `
IMPORTANT INSTRUCTIONS:
- Generate ONLY a valid SQL SELECT query
- Use fully qualified column names (table.column)
- Return ONLY the JSON with generated_sql and confidence
- No explanations, no markdown, no extra text
`
	schemaBuilder.WriteString(instruction)

	dbSchema = schemaBuilder.String()
	log.Println("Schema generated successfully from actual database.")

	return nil
}

// --- LLM API Logic ---

// ExecuteLLMQuery calls the Gemini API to convert NLP to SQL.
func ExecuteLLMQuery(nlpQuery string) (*SQLResponse, error) {
	log.Printf("Converting NLP to SQL: \"%s\"", nlpQuery)

	// Use the dynamically generated schema in the system prompt
	systemPrompt := "You are a specialized SQL query generator. Your sole function is to accept a natural language request and convert it into a valid SQL SELECT query based ONLY on the provided database schema. " + dbSchema

	// Define the JSON Schema for the structured output.
	responseSchema := map[string]interface{}{
		"type": "OBJECT",
		"properties": map[string]interface{}{
			"generated_sql": map[string]string{"type": "STRING", "description": "The valid SQL SELECT query."},
			"confidence":    map[string]string{"type": "STRING", "description": "The confidence level of the generated query, one of HIGH, MEDIUM, or LOW."},
		},
		"required": []string{"generated_sql", "confidence"},
	}

	// Construct the API payload
	payload := map[string]interface{}{
		"contents": []map[string]interface{}{
			{"parts": []map[string]string{{"text": nlpQuery}}},
		},
		"systemInstruction": map[string]interface{}{
			"parts": []map[string]string{{"text": systemPrompt}},
		},
		"generationConfig": map[string]interface{}{
			"responseMimeType": "application/json",
			"responseSchema":   responseSchema,
		},
	}

	// Marshal the payload into JSON for the request body
	jsonPayload, err := json.Marshal(payload)
	if err != nil {
		return nil, fmt.Errorf("failed to marshal JSON payload: %w", err)
	}

	// Create and execute the HTTP POST request
	req, err := http.NewRequest("POST", apiUrl, bytes.NewBuffer(jsonPayload))
	if err != nil {
		return nil, fmt.Errorf("failed to create request: %w", err)
	}
	req.Header.Set("Content-Type", "application/json")

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		return nil, fmt.Errorf("failed to execute API request: %w", err)
	}
	defer resp.Body.Close()

	// Read the raw response body
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("failed to read API response body: %w", err)
	}

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("API request failed with status code %d: %s", resp.StatusCode, string(body))
	}

	// Unmarshal the outer LLM response structure
	var llmResponse LLMResponse
	if err := json.Unmarshal(body, &llmResponse); err != nil {
		return nil, fmt.Errorf("failed to unmarshal LLM response: %w", err)
	}

	if len(llmResponse.Candidates) == 0 || len(llmResponse.Candidates[0].Content.Parts) == 0 {
		return nil, fmt.Errorf("LLM response missing content")
	}

	jsonOutput := llmResponse.Candidates[0].Content.Parts[0].Text

	// Unmarshal the inner JSON string into the SQLResponse struct
	var sqlResponse SQLResponse
	err = json.Unmarshal([]byte(jsonOutput), &sqlResponse)
	if err != nil {
		return nil, fmt.Errorf("failed to parse LLM structured response (raw output: %s): %w", jsonOutput, err)
	}

	log.Printf("LLM Result: %s (Confidence: %s)", sqlResponse.GeneratedSQL, sqlResponse.Confidence)
	return &sqlResponse, nil
}

// --- Database Execution Logic ---

type DBResult map[string]interface{}

// ExecuteSQL runs the generated SQL query against the database.
func ExecuteSQL(sqlQuery string) ([]DBResult, error) {
	log.Printf("Executing SQL on DB: %s", sqlQuery)

	if db == nil {
		return nil, fmt.Errorf("database connection not initialized")
	}

	rows, err := db.Query(sqlQuery)
	if err != nil {
		return nil, fmt.Errorf("failed to execute query: %w", err)
	}
	defer rows.Close()

	// Get column names
	columns, err := rows.Columns()
	if err != nil {
		return nil, fmt.Errorf("failed to get column names: %w", err)
	}

	// Prepare result structure
	results := make([]DBResult, 0)

	// Create a slice of pointers to interface{} to hold the values from the current row
	values := make([]interface{}, len(columns))
	valuePtrs := make([]interface{}, len(columns))
	for i := range columns {
		valuePtrs[i] = &values[i]
	}

	// Iterate through the rows and append them to results
	for rows.Next() {
		err := rows.Scan(valuePtrs...)
		if err != nil {
			return nil, fmt.Errorf("failed to scan row: %w", err)
		}

		row := make(DBResult)
		for i, colName := range columns {
			val := *(valuePtrs[i].(*interface{}))
			// Handle NULL values and byte slices (e.g., for strings)
			if val == nil {
				row[colName] = nil
			} else if b, ok := val.([]byte); ok {
				row[colName] = string(b)
			} else {
				row[colName] = val
			}
		}
		results = append(results, row)
	}

	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("error after row iteration: %w", err)
	}

	return results, nil
}

// initDB establishes the database connection.
func initDB() error {
	var err error
	db, err = sql.Open("mysql", dbConnStr)
	if err != nil {
		return fmt.Errorf("error opening database: %w", err)
	}

	if err = db.Ping(); err != nil {
		db.Close()
		return fmt.Errorf("error connecting to database: %w", err)
	}

	log.Println("Database connection established successfully.")

	// Generate the schema immediately after connecting
	if err := generateSchemaFromDB(); err != nil {
		return fmt.Errorf("failed to generate schema: %w", err)
	}

	return nil
}

// --- HTTP Handler ---

func handleQuery(w http.ResponseWriter, r *http.Request) {
	// The CORS headers are already set by the middleware before this point

	if r.Method != "POST" {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	var request struct {
		Command string `json:"command"`
	}

	if err := json.NewDecoder(r.Body).Decode(&request); err != nil {
		http.Error(w, "Invalid JSON payload", http.StatusBadRequest)
		return
	}

	if request.Command == "" {
		http.Error(w, "Command field is required", http.StatusBadRequest)
		return
	}

	log.Printf("Received command: %s", request.Command)

	// 1. NLP to SQL Conversion
	sqlResponse, err := ExecuteLLMQuery(request.Command)
	if err != nil {
		http.Error(w, fmt.Sprintf("LLM conversion error: %v", err), http.StatusInternalServerError)
		return
	}

	if sqlResponse.GeneratedSQL == "" {
		http.Error(w, "LLM failed to generate SQL query", http.StatusInternalServerError)
		return
	}

	// CONSOLE THE PROCESSED SQL COMMAND (Kept for internal visibility)
	fmt.Println("NLP Processed SQL:", sqlResponse.GeneratedSQL)

	// 2. SQL Execution
	results, err := ExecuteSQL(sqlResponse.GeneratedSQL)
	if err != nil {
		// Log the SQL to help debugging why execution failed
		log.Printf("Failed SQL Query: %s", sqlResponse.GeneratedSQL)
		http.Error(w, fmt.Sprintf("SQL execution error: %v", err), http.StatusInternalServerError)
		return
	}

	// 3. Construct and Return ONLY the required data
	log.Printf("Execution successful. Returning %d rows of data.", len(results))

	// MODIFIED: Only return the 'data' field to the user
	response := map[string]interface{}{
		"data": results,
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}

// --- Main Application Flow ---

func main() {
	fmt.Println("--- Go Text-to-SQL Executor ---")
	fmt.Println("Dynamic Schema: ON")
	fmt.Println("API Endpoint: POST http://localhost:8080/query")
	fmt.Println("========================================")

	if err := initDB(); err != nil {
		log.Fatalf("Failed to initialize database: %v", err)
	}
	defer db.Close()

	// Set up HTTP endpoint, using the CORS middleware
	http.HandleFunc("/query", enableCORS(handleQuery))
	log.Println("Server starting on :8080")
	log.Fatal(http.ListenAndServe(":8080", nil))
}
