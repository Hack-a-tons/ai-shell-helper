#!/usr/bin/env bash
# This script sends a request to the OpenAI API and checks the response.

# Go to this script working directory
cd "$(dirname $0)"

# Constants
MODELS=(
  "gpt-4.1"
)

# Load the OpenAI API key from the environment
export ENV_CONTENT=$(cat ../.env)
export AZURE_API_VERSION=$(echo "$ENV_CONTENT" | grep -E '^AZURE_API_VERSION=' | cut -d '=' -f 2-)
export AZURE_OPENAI_KEY=$(echo "$ENV_CONTENT" | grep -E '^OPENAI_API_KEY=' | cut -d '=' -f 2-)
export AZURE_OPENAI_ENDPOINT=$(echo "$ENV_CONTENT" | grep -E '^OPENAI_ENDPOINT=' | cut -d '=' -f 2-)

case $1 in
"")
  # Code to execute if $1 is empty
  echo >&2 "No model specified. Please provide a valid model as the first argument."
  echo >&2 "Usage: $0 model_name message"
  exit 1
  ;;
*)
  # Check if $1 is a valid model name
  for MODEL in "${MODELS[@]}"; do
    if [ "$1" == "$MODEL" ]; then
      break
    fi
  done
  # If $1 doesn't match any of the valid models, exit with an error message
  if [ "$1" != "$MODEL" ]; then
    echo >&2 "Invalid model specified: $1"
    echo >&2 "Valid models are: ${MODELS[@]}"
    echo >&2 "Usage: $0 model_name message"
    exit 1
  fi
  ;;
esac

# Valid model name selected
echo >&2 "Valid model selected: $1"

# Check if $2 is empty
if [ -z "$2" ]; then
  echo >&2 "No message specified. Please provide a message as the second argument."
  echo >&2 "Usage: $0 model_name message"
  exit 1
fi
export MESSAGE="${2//$'\n'/\\n}"

# Send a request to the OpenAI API
REQUEST="$(
  cat <<EOF
curl -s "$AZURE_OPENAI_ENDPOINT/openai/deployments/$MODEL/chat/completions?api-version=$AZURE_API_VERSION" \
  -H "Content-Type: application/json" \
  -H "api-key: $AZURE_OPENAI_KEY" \
  -d "{\"messages\":[{\"role\": \"system\", \"content\": \"You are an expert at translating natural language to shell commands for a zsh shell on macOS. Respond ONLY with the single, executable shell command. Do not add any explanation, markdown, or any other text.\"}, {\"role\": \"user\", \"content\": \"$MESSAGE\"}]}"
EOF
)"
echo >&2 "Sending request to OpenAI..."
echo >&2 "$REQUEST"
eval "$REQUEST"
