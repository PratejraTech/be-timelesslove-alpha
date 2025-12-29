# Environment Variable Management

## Quick Start

1. **Local Development:**h
   ./scripts/env-setup.sh local
   # Edit .env with your values
   2. **Production:**
   
   ./scripts/env-setup.sh production
   # Edit .env.production with production values
   ## File Structure

- `.env.example` - Master template (committed)
- `.env.local.example` - Local development template (committed)
- `.env.production.example` - Production template (committed)
- `.env.staging.example` - Staging template (committed)
- `.env.test.example` - Test template (committed)
- `.env` - Your local file (gitignored)
- `.env.production` - Production file (gitignored, on server)

## Security Rules

1. ✅ **DO** commit `.env.*.example` files
2. ❌ **NEVER** commit `.env` files with real values
3. ✅ **DO** use strong secrets in production
4. ✅ **DO** rotate secrets periodically
5. ✅ **DO** validate environment files before deployment

## Generating Secrets
h
# JWT Secret (32+ bytes)
openssl rand -hex 32

# Database Password
openssl rand -base64 32## Environment Loading Order

1. Environment-specific file (`.env.production`, `.env.staging`, etc.)
2. `.env` file (fallback)
3. System environment variables (highest priority)