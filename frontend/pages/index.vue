<template>
  <div class="app-container">
    <div class="card">
      <h1 class="title">NLP to SQL Query Executor</h1>

      <div class="input-wrapper">
        <textarea
          v-model="command"
          placeholder="e.g., Show me all users from London"
          class="input-area"
        ></textarea>
        <button 
          @click="toggleListening" 
          class="voice-button" 
          :class="{ 'is-listening': isListening }"
          title="Speak your command"
        >
          <span v-if="!isListening">🎤</span>
          <span v-else class="pulse-icon">🛑</span>
        </button>
      </div>

      <button
        @click="sendQuery"
        :disabled="loading"
        class="submit-button"
        :class="{ 'submit-button--disabled': loading }"
      >
        {{ loading ? "Processing..." : "Run Query" }}
      </button>

      <div v-if="rawOutput" class="console-section">
        <h3 class="section-label">Execution Log</h3>
        <pre class="console-text">{{ rawOutput }}</pre>
      </div>

      <div v-if="processedData.length > 0" class="output-section">
        <h2 class="output-title">Query Results</h2>
        <div v-for="(resultSet, index) in processedData" :key="index" class="result-set">
          <div class="result-set-header">
            <span class="result-count">{{ resultSet.data.length }} row(s) found</span>
          </div>
          <div class="results-table-container">
            <table class="results-table">
              <thead>
                <tr>
                  <th v-for="key in resultSet.headers" :key="key">{{ formatHeader(key) }}</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(row, rowIndex) in resultSet.data" :key="rowIndex">
                  <td v-for="key in resultSet.headers" :key="key">{{ row[key] ?? '-' }}</td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <div v-if="error" class="error-message">
        <strong>Error:</strong> {{ error }}
      </div>

      <div v-if="loading" class="loading-state">
        <div class="loading-spinner"></div>
        <span>Consulting AI and Database...</span>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from "vue";

const command = ref("");
const rawOutput = ref("");
const processedData = ref([]);
const loading = ref(false);
const error = ref(null);

const isListening = ref(false);
let recognition = null;

onMounted(() => {
  const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition;
  if (SpeechRecognition) {
    recognition = new SpeechRecognition();
    recognition.continuous = true;
    recognition.interimResults = true;
    recognition.lang = 'en-US';

    recognition.onresult = (event) => {
      let interimTranscript = '';
      for (let i = event.resultIndex; i < event.results.length; ++i) {
        if (event.results[i].isFinal) {
          command.value += event.results[i][0].transcript;
        } else {
          interimTranscript += event.results[i][0].transcript;
        }
      }
    };

    recognition.onerror = (event) => {
      console.error("Speech recognition error", event.error);
      isListening.value = false;
    };

    recognition.onend = () => {
      isListening.value = false;
    };
  }
});

const toggleListening = () => {
  if (!recognition) {
    alert("Speech recognition is not supported in this browser.");
    return;
  }
  if (isListening.value) {
    recognition.stop();
  } else {
    isListening.value = true;
    recognition.start();
  }
};

const sendQuery = async () => {
  if (isListening.value) recognition.stop();
  error.value = null;
  processedData.value = [];
  rawOutput.value = "";

  if (!command.value.trim()) {
    error.value = "Please enter a command.";
    return;
  }

  loading.value = true;
  try {
    const res = await fetch("http://localhost:8080/query", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ command: command.value }),
    });

    const fullText = await res.text();
    const jsonStart = fullText.indexOf('{');
    if (jsonStart !== -1) {
      rawOutput.value = fullText.substring(0, jsonStart).trim();
      const jsonPart = fullText.substring(jsonStart);
      const parsed = JSON.parse(jsonPart);
      if (parsed.data && Array.isArray(parsed.data)) {
        processedData.value = [{
          data: parsed.data,
          headers: parsed.data.length > 0 ? Object.keys(parsed.data[0]) : []
        }];
      }
    } else {
      rawOutput.value = fullText;
    }
    if (!res.ok && !rawOutput.value) throw new Error("Server error occurred");
  } catch (e) {
    error.value = e.message;
  } finally {
    loading.value = false;
  }
};

const formatHeader = (key) => key.replace(/_/g, ' ').toUpperCase();
</script>

<style scoped>
.input-wrapper {
  position: relative;
  width: 100%;
}

.voice-button {
  position: absolute;
  right: 12px;
  bottom: 12px;
  background: #f3f4f6;
  border: none;
  border-radius: 50%;
  width: 40px;
  height: 40px;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 20px;
  transition: all 0.3s ease;
}

.voice-button:hover { background: #e5e7eb; }

.is-listening {
  background: #fee2e2 !important;
  color: #ef4444;
  box-shadow: 0 0 10px rgba(239, 68, 68, 0.4);
}

.pulse-icon { animation: pulse 1.5s infinite; }

@keyframes pulse {
  0% { transform: scale(1); opacity: 1; }
  50% { transform: scale(1.2); opacity: 0.7; }
  100% { transform: scale(1); opacity: 1; }
}

.app-container {
  min-height: 100vh;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: 40px 20px;
  display: flex;
  justify-content: center;
  font-family: 'Inter', sans-serif;
}

.card {
  max-width: 1000px;
  width: 100%;
  background: #ffffff;
  box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.2);
  border-radius: 16px;
  padding: 32px;
  display: flex;
  flex-direction: column;
  gap: 24px;
}

.title {
  font-size: 1.8rem;
  font-weight: 800;
  color: #1f2937;
  text-align: center;
  margin: 0;
}

.input-area {
  width: 100%;
  height: 150px;
  padding: 16px;
  padding-right: 60px;
  border: 2px solid #e5e7eb;
  border-radius: 10px;
  font-size: 16px;
  transition: border-color 0.2s;
  box-sizing: border-box;
  resize: vertical;
}

.input-area:focus { outline: none; border-color: #667eea; }

.submit-button {
  width: 100%;
  background: #764ba2;
  color: white;
  font-weight: 700;
  padding: 14px;
  border-radius: 10px;
  border: none;
  cursor: pointer;
}

.console-section { background: #1a1a1a; border-radius: 8px; padding: 16px; border-left: 4px solid #10b981; }
.section-label { color: #9ca3af; font-size: 0.75rem; margin-bottom: 8px; text-transform: uppercase; }
.console-text { color: #10b981; font-family: monospace; font-size: 0.9rem; margin: 0; white-space: pre-wrap; }

/* BEAUTIFUL TABLE STYLING */
.results-table-container {
  overflow-x: auto;
  border: 1px solid #e5e7eb;
  border-radius: 12px;
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05);
}

.results-table {
  width: 100%;
  border-collapse: separate;
  border-spacing: 0;
  background: white;
}

.results-table th {
  background: #f8fafc;
  padding: 14px 16px;
  text-align: left;
  font-size: 0.85rem;
  font-weight: 700;
  color: #475569;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  border-bottom: 2px solid #e2e8f0;
}

.results-table td {
  padding: 14px 16px;
  border-bottom: 1px solid #f1f5f9;
  color: #1e293b; /* Deep Dark Color for beauty and contrast */
  font-size: 0.95rem;
  font-weight: 500;
}

.results-table tbody tr:nth-child(even) {
  background-color: #fdfdfd;
}

.results-table tbody tr:hover {
  background-color: #f1f5f9;
  transition: background-color 0.2s ease;
}

.results-table tr:last-child td {
  border-bottom: none;
}

.output-title {
  font-size: 1.4rem;
  font-weight: 700;
  color: #1e293b;
  margin-bottom: 8px;
}

.result-count {
  font-size: 0.9rem;
  color: #64748b;
  font-weight: 600;
  margin-bottom: 12px;
  display: block;
}

.error-message { background: #fef2f2; border: 1px solid #fee2e2; color: #b91c1c; padding: 16px; border-radius: 8px; }
.loading-spinner { width: 20px; height: 20px; border: 3px solid #f3f3f3; border-top: 3px solid #764ba2; border-radius: 50%; animation: spin 1s linear infinite; }
@keyframes spin { 0% { transform: rotate(0deg); } 100% { transform: rotate(360deg); } }
</style>