#!/usr/bin/env bash

# Load environment variables
ENV_CONTENT=$(cat "$(dirname $0)/../.env")
WEAVIATE_URL=$(echo "$ENV_CONTENT" | grep -E '^WEAVIATE_URL=' | cut -d '=' -f 2-)
WEAVIATE_API_KEY=$(echo "$ENV_CONTENT" | grep -E '^WEAVIATE_API_KEY=' | cut -d '=' -f 2-)

# Function to initialize schema
init_schema() {
    curl -s "$WEAVIATE_URL/v1/schema" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $WEAVIATE_API_KEY" \
        -d '{
            "class": "Command",
            "properties": [
                {"name": "query", "dataType": ["text"]},
                {"name": "command", "dataType": ["text"]},
                {"name": "confidence", "dataType": ["number"]}
            ],
            "vectorizer": "none"
        }' > /dev/null 2>&1
}

# Function to search for similar commands
search_command() {
    local query="$1"
    curl -s "$WEAVIATE_URL/v1/graphql" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $WEAVIATE_API_KEY" \
        -d "{\"query\": \"{ Get { Command(where: {path: [\\\"query\\\"], operator: Equal, valueText: \\\"$query\\\"}, limit: 1) { command } } }\"}" \
        | grep -o '"command":"[^"]*"' | sed 's/"command":"//' | sed 's/"$//' | head -1
}

# Function to store a new command
store_command() {
    local query="$1"
    local command="$2"
    curl -s "$WEAVIATE_URL/v1/objects" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $WEAVIATE_API_KEY" \
        -d "{\"class\": \"Command\", \"properties\": {\"query\": \"$query\", \"command\": \"$command\", \"confidence\": 1.0}}" > /dev/null
}

# Main logic
case "$1" in
    "init")
        init_schema
        ;;
    "search")
        search_command "$2"
        ;;
    "store")
        store_command "$2" "$3"
        ;;
esac
