# Proposal: AI Tutor Mode for Forge

## 1. Objective
Introduce an interactive **AI Tutor** mode that leverages local Large Language Models (LLMs) via **Ollama**. This feature provides context-aware, Socratic guidance, turning Forge into a dynamic learning environment while maintaining 100% privacy and offline capability.

## 2. User Experience

### Entering Tutor Mode
- While working on a challenge, the user presses the `t` key.

### First-Run & Model Selection
1. **Discovery**: Forge queries the local Ollama instance (`/api/tags`) for available models.
2. **Selection**: 
   - If models are found, Forge presents a numbered list (e.g., `1. llama3:8b`, `2. deepseek-coder`).
   - The user chooses a model, which is then saved for the duration of the session (or persisted in `.progress`).
3. **No Models Found**: If Ollama is running but has no models, or if Ollama is unreachable, Forge displays a helpful message:
   - *"No Ollama models found. Please run 'ollama pull llama3' in your terminal first."*
   - Forge then immediately exits back to the challenge prompt.

### The Interactive Session
Once a model is selected, the user enters a dedicated **Tutor Session**:
- **Chat**: The user can ask questions like "Why am I getting a syntax error on line 4?" or "Explain how this loop works."
- **Socratic Guidance**: The tutor responds based on the current code and challenge context.
- **Session Commands**:
  - `exit` / `q`: Close the tutor session and return to the challenge.
  - `model`: List available models and switch to a different one mid-session.
  - `reset`: Clear the conversation history to start fresh.

## 3. Technical Architecture

### Ollama REST Integration
- **Discovery**: `GET /api/tags`
- **Inference**: `POST /api/chat` with `stream: true` (for a responsive feel).

### Contextual Awareness
Each request to the LLM will include a "System Message" and a "Context Bundle":
1. **System Message**: Enforces the Socratic persona, the "No Spoiling" rule, and the Forge philosophy.
2. **Code Context**: The current contents of the user's workspace file.
3. **Challenge Context**: The title, description, and requirements from the curriculum JSON.
4. **Diagnostic Context**: The output of the last failed `swift` execution (compiler errors or diffs).

### Session Management
- Forge will maintain a `[ChatMessage]` array in memory during the interactive session to support multi-turn conversations.
- This history is cleared when exiting the session or using the `reset` command.

## 4. Proposed Implementation Steps

### Phase 1: Infrastructure
- Create `OllamaClient.swift` to handle communication with the local API.
- Add `TutorSession.swift` to manage the interactive loop and message history.

### Phase 2: Integration
- Add the `t` key handler to `ChallengeFlow.swift`.
- Implement the model selection picker.

### Phase 3: Prompt Tuning
- Refine the system prompt to ensure the tutor is helpful but doesn't "leak" solutions.
- Ensure the tutor understands the specific constraints of the current challenge (e.g., "Don't use `filter` yet").

## 5. Security & Privacy
- **Local-Only**: Data never leaves `localhost`.
- **Transparency**: The user can see exactly what context is being sent to the model.

---
*Brainstorming note: This implementation ensures that the AI Tutor feels like a seamless part of the Forge CLI, not a bolted-on extra.*
