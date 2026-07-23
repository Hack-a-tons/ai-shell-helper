#!/usr/bin/env bash
# Translates natural language to shell commands via OpenAI or Google Vertex AI.

cd "$(dirname $0)"

# --- Load .env ---
ENV_CONTENT=$(cat ../.env)
eval "$(echo "$ENV_CONTENT" | grep -E '^[A-Z_]+=' | sed 's/^/export /')"

AI_PROVIDER="${AI_PROVIDER:-openai}"
echo >&2 "Provider: $AI_PROVIDER"

# Validate $2 (message)
if [ -z "$2" ]; then
    echo >&2 "Usage: $0 <model> <message> [working_dir]"
    exit 1
fi

# $3 is the user's working directory
WORK_DIR="${3:-$PWD}"
MESSAGE="Current directory: ${WORK_DIR}\nQuery: ${2//$'\n'/\\n}"

SYSTEM_PROMPT="You are an expert at translating natural language to shell commands for a zsh shell on macOS. Respond ONLY with a single, executable shell command. Never include explanations, markdown, color codes, or escape sequences. If the request is unclear or not related to shell commands, respond with 'echo Please provide a specific command request'."

# --- Extract command from response ---
extract_command() {
    local response="$1"
    local provider="$2"
    if command -v jq >/dev/null 2>&1; then
        if [ "$provider" = "vertex" ]; then
            echo "$response" | jq -r '.candidates[0].content.parts[0].text' 2>/dev/null
        else
            echo "$response" | jq -r '.choices[0].message.content' 2>/dev/null
        fi
    else
        if [ "$provider" = "vertex" ]; then
            echo "$response" | sed -n 's/.*"text": *"\([^"]*\)".*/\1/p' | head -1
        else
            echo "$response" | sed -n 's/.*"content": *"\([^"]*\)".*/\1/p' | head -1
        fi
    fi
    # Strip markdown backticks and surrounding whitespace
    sed 's/^`//; s/`$//; s/^[[:space:]]*//; s/[[:space:]]*$//'
}

# ============================================================
# OpenAI (Azure)
# ============================================================
if [ "$AI_PROVIDER" = "openai" ]; then
    if [ -z "$OPENAI_API_KEY" ] || [ -z "$OPENAI_ENDPOINT" ]; then
        echo >&2 "Missing OPENAI_API_KEY or OPENAI_ENDPOINT in .env"
        exit 1
    fi

    MODEL="${1:-gpt-4.1}"

    RESPONSE=$(curl -s "$OPENAI_ENDPOINT/openai/deployments/$MODEL/chat/completions?api-version=$AZURE_API_VERSION" \
        -H "Content-Type: application/json" \
        -H "api-key: $OPENAI_API_KEY" \
        -d "{\"messages\":[{\"role\":\"system\",\"content\":\"$SYSTEM_PROMPT\"},{\"role\":\"user\",\"content\":\"$MESSAGE\"}]}")

    extract_command "$RESPONSE" "openai"

# ============================================================
# Google Vertex AI (Gemini)
# ============================================================
elif [ "$AI_PROVIDER" = "vertex" ]; then
    if [ -z "$VERTEX_AI_PROJECT" ] || [ -z "$AI_MODEL" ]; then
        echo >&2 "Missing VERTEX_AI_PROJECT or AI_MODEL in .env"
        exit 1
    fi

    VERTEX_AI_LOCATION="${VERTEX_AI_LOCATION:-global}"
    GOOGLE_APPLICATION_CREDENTIALS="${GOOGLE_APPLICATION_CREDENTIALS:-.config/service-account-key.json}"

    # Resolve relative path from repo root
    if [[ "$GOOGLE_APPLICATION_CREDENTIALS" != /* ]]; then
        GOOGLE_APPLICATION_CREDENTIALS="../$GOOGLE_APPLICATION_CREDENTIALS"
    fi

    if [ ! -f "$GOOGLE_APPLICATION_CREDENTIALS" ]; then
        echo >&2 "Service account key not found: $GOOGLE_APPLICATION_CREDENTIALS"
        exit 1
    fi

    # Extract service account credentials
    CLIENT_EMAIL=$(grep '"client_email"' "$GOOGLE_APPLICATION_CREDENTIALS" | sed 's/.*: *"\(.*\)".*/\1/')
    PRIVATE_KEY=$(sed -n '/"private_key":/,/-----END PRIVATE KEY-----/p' "$GOOGLE_APPLICATION_CREDENTIALS" | sed 's/.*"private_key": *"//; s/".*//;' | sed 's/\\n/\n/g')

    # Build JWT
    now=$(date +%s)
    exp=$((now + 3600))
    header=$(printf '{"alg":"RS256","typ":"JWT"}' | base64 | tr '+/' '-_' | tr -d '=')
    payload=$(printf '{"iss":"%s","scope":"https://www.googleapis.com/auth/cloud-platform","aud":"https://oauth2.googleapis.com/token","iat":%d,"exp":%d}' "$CLIENT_EMAIL" "$now" "$exp" | base64 | tr '+/' '-_' | tr -d '=')
    signature=$(printf '%s.%s' "$header" "$payload" | openssl dgst -sha256 -sign <(echo "$PRIVATE_KEY") | base64 | tr '+/' '-_' | tr -d '=')
    assertion="${header}.${payload}.${signature}"

    # Exchange JWT for access token
    access_token=$(curl -s -X POST "https://oauth2.googleapis.com/token" \
        -d "grant_type=urn%3Aietf%3Aparams%3Aoauth%3Agrant-type%3Ajwt-bearer" \
        -d "assertion=$assertion" | sed -n 's/.*"access_token":"\([^"]*\)".*/\1/p')

    if [ -z "$access_token" ]; then
        echo >&2 "Failed to obtain access token"
        exit 1
    fi

    # Call Vertex AI
    if [ "$VERTEX_AI_LOCATION" = "global" ]; then
        vertex_url="https://aiplatform.googleapis.com/v1/projects/${VERTEX_AI_PROJECT}/locations/global/publishers/google/models/${AI_MODEL}:generateContent"
    else
        vertex_url="https://${VERTEX_AI_LOCATION}-aiplatform.googleapis.com/v1/projects/${VERTEX_AI_PROJECT}/locations/${VERTEX_AI_LOCATION}/publishers/google/models/${AI_MODEL}:generateContent"
    fi

    RESPONSE=$(curl -s "$vertex_url" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $access_token" \
        -d "{
            \"contents\": [{\"role\": \"user\", \"parts\": [{\"text\": \"$MESSAGE\"}]}],
            \"systemInstruction\": {\"parts\": [{\"text\": \"$SYSTEM_PROMPT\"}]},
            \"generationConfig\": {\"temperature\": 0, \"maxOutputTokens\": 1024}
        }")

    extract_command "$RESPONSE" "vertex"

else
    echo >&2 "Unknown AI_PROVIDER: $AI_PROVIDER (expected 'openai' or 'vertex')"
    exit 1
fi
