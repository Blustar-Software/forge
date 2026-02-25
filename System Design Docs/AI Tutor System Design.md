# AI Tutor System Design

## 1. Introduction
This document details the system design for the AI Tutor mode in Forge. The tutor aims to provide private, context-aware, Socratic guidance using local Large Language Models (LLMs) via Ollama, enhancing the learning experience without requiring external network access or data sharing.

## 2. Objectives
*   **Interactive Learning**: Offer real-time, on-demand assistance tailored to the user's current challenge.
*   **Socratic Method**: Guide users towards solutions through questioning and explanation, rather than providing direct answers.
*   **Privacy & Offline Capability**: Utilize local Ollama instances for all LLM processing.
*   **Contextual Awareness**: Provide relevant guidance based on the user's code, challenge details, and recent diagnostics.
*   **Seamless Integration**: Feel like a natural extension of the Forge CLI experience.

## 3. User Experience

### 3.1 Entering Tutor Mode
*   Activated by pressing the `t` key while on a challenge prompt.

### 3.2 Initial Setup & Model Selection
1.  **Model Discovery**: Upon first entry or when requested (`model` command), Forge queries the Ollama instance (`GET /api/tags`) to list available LLMs.
2.  **Model Selection**:
    *   If models are found, a numbered list is presented to the user.
    *   The user selects a model, which is stored for the current session (and potentially persisted in `.progress` for future sessions).
3.  **No Models / Ollama Unreachable**:
    *   A user-friendly message is displayed (e.g., "No Ollama models found. Please run 'ollama pull [model-name]'...").
    *   The tutor session is immediately exited, returning the user to the challenge prompt.

### 3.3 Interactive Tutor Session
*   **Chat Interface**: Users can ask questions related to syntax errors, code logic, concepts, etc.
*   **Guidance**: The AI tutor provides Socratic responses, adhering to the system prompt's rules (no direct spoilers, focus on learning principles).
*   **Session Commands**:
    *   `exit` / `q`: Terminates the tutor session and returns to the challenge.
    *   `model`: Lists available models and allows switching mid-session.
    *   `reset`: Clears the conversation history for a fresh start.

## 4. Technical Architecture

### 4.1 Ollama REST API Integration (`OllamaClient.swift`)
*   **Model Discovery**: `GET /api/tags` endpoint used to list available models.
*   **Inference**: `POST /api/chat` endpoint used for generating responses. Requests utilize `stream: true` for a responsive user experience.

### 4.2 Contextual Awareness
Requests to the LLM are bundled with context:
*   **System Message**: Enforces the AI's persona (Socratic, no spoilers, adherence to Forge philosophy).
*   **Code Context**: The current content of the active workspace file.
*   **Challenge Context**: Details from the current challenge's JSON data (title, description, requirements).
*   **Diagnostic Context**: Output from the last failed Swift execution (compiler errors, diffs).

### 4.3 Session Management (`TutorSession.swift`)
*   Maintains an in-memory array of `ChatMessage` objects to support multi-turn conversations.
*   History is cleared upon session exit or `reset` command.

### 4.4 Entry Point (`TutorAttach.swift`, `CommandHandlers.swift`)
*   Handles the `t` key binding and initiates the tutor session flow, including model discovery and selection.

## 4.5 Configuration
*   **Ollama API URL**: Configurable, defaults to `http://localhost:11434`.
*   **Default Model**: A default model can be specified or inferred.
*   **Persistence**: Session history and model preference can be persisted via `.progress` files.

## 5. Security & Privacy
*   **Local-Only Processing**: All LLM interactions are confined to `localhost`, ensuring data never leaves the user's machine.
*   **Transparency**: Users can inspect the exact context being sent to the LLM.

---
*Design Note: The goal is to create an integrated, private, and effective learning assistant within the Forge environment.*
