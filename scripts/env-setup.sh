#!/bin/bash
# Environment Setup Helper Script

set -e

ENV_TYPE=${1:-local}

echo "🔧 Setting up environment: $ENV_TYPE"
echo ""

case $ENV_TYPE in
    local|dev|development)
        if [ -f ".env.local.example" ]; then
            cp .env.local.example .env
            echo "✅ Created .env from .env.local.example"
        else
            cp .env.example .env
            echo "✅ Created .env from .env.example"
        fi
        echo "📝 Please edit .env with your local values"
        ;;
    production|prod)
        if [ -f ".env.production.example" ]; then
            cp .env.production.example .env.production
            echo "✅ Created .env.production from .env.production.example"
        else
            echo "❌ .env.production.example not found"
            exit 1
        fi
        echo "📝 Please edit .env.production with your production values"
        ;;
    staging|stage)
        if [ -f ".env.staging.example" ]; then
            cp .env.staging.example .env.staging
            echo "✅ Created .env.staging from .env.staging.example"
        else
            echo "❌ .env.staging.example not found"
            exit 1
        fi
        echo "📝 Please edit .env.staging with your staging values"
        ;;
    test)
        if [ -f ".env.test.example" ]; then
            cp .env.test.example .env.test
            echo "✅ Created .env.test from .env.test.example"
        else
            echo "❌ .env.test.example not found"
            exit 1
        fi
        echo "📝 Please edit .env.test with your test values"
        ;;
    *)
        echo "Usage: $0 [local|production|staging|test]"
        exit 1
        ;;
esac

echo ""
echo "⚠️  Remember: Never commit .env files with real values!"