"""
Health check API endpoint for monitoring and load balancer use.
"""

from fastapi import APIRouter
from app.config import get_settings
from app.db.supabase import get_supabase_service_client


router = APIRouter()


@router.get("")
async def health():
    """
    Health check endpoint.
    
    Returns API status and optionally database connectivity status.
    Does not require authentication for monitoring/load balancer use.
    """
    settings = get_settings()
    
    # Basic health status
    status_response = {
        "status": "healthy",
        "version": settings.api_version,
        "environment": settings.environment
    }
    
    # Optionally check database connectivity
    try:
        supabase = get_supabase_service_client()
        # Simple query to verify database connection
        # Using a lightweight query that should always work
        result = supabase.table("family_units").select("id", count="exact").limit(0).execute()
        status_response["database"] = "connected"
    except Exception as e:
        # Database check failed, but don't fail the entire health check
        # This allows the API to report unhealthy database while still being reachable
        status_response["database"] = "disconnected"
        status_response["database_error"] = str(e)
    
    return status_response

