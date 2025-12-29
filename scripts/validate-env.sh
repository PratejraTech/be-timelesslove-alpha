#!/bin/bash
# Validate environment file

ENV_FILE=${1:-.env}

if [ ! -f "$ENV_FILE" ]; then
    echo "❌ Error: $ENV_FILE not found"
    exit 1
fi

echo "🔍 Validating $ENV_FILE..."
echo ""

# Check for required variables
REQUIRED_VARS=(
    "SUPABASE_URL"
    "SUPABASE_ANON_KEY"
    "SUPABASE_SERVICE_ROLE_KEY"
    "SUPABASE_JWT_SECRET"
    "JWT_SECRET_KEY"
    "CLOUDFLARE_TUNNEL_TOKEN"
)

MISSING_VARS=()

for var in "${REQUIRED_VARS[@]}"; do
    if ! grep -q "^${var}=" "$ENV_FILE" || grep -q "^${var}=$" "$ENV_FILE" || grep -q "^${var}=your-" "$ENV_FILE"; then
        MISSING_VARS+=("$var")
    fi
done

if [ ${#MISSING_VARS[@]} -ne 0 ]; then
    echo "❌ Missing or incomplete variables:"
    for var in "${MISSING_VARS[@]}"; do
        echo "   - $var"
    done
    exit 1
fi

# Check for placeholder values
if grep -q "your-" "$ENV_FILE" || grep -q "generate-" "$ENV_FILE"; then
    echo "⚠️  Warning: Found placeholder values in $ENV_FILE"
    echo "   Please replace all placeholder values with actual values"
    exit 1
fi

echo "✅ $ENV_FILE is valid"