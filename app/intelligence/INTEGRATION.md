# Intelligence Layer Integration Guide

## Integration with Existing Services

### 1. Analytics Service Integration

The Intelligence Layer consumes structured events from `analytics_service`.

**Event Types Consumed:**
- `memory_posted` - Trigger content processing
- `memory_liked` - Update user preferences
- `comment_created` - Process comment intelligence
- `memory_viewed` - Update feed ranking preferences
- `user_registered` - Initialize user preferences

**Integration Pattern:**
```python
# In analytics_service.py (after event emission)
from app.intelligence.event_consumer import IntelligenceEventConsumer

async def emit_event(...):
    event_id = await super().emit_event(...)
    
    # Trigger intelligence processing (async, non-blocking)
    if event_type in INTELLIGENCE_EVENT_TYPES:
        await IntelligenceEventConsumer.consume_event(event_id)
    
    return event_id
```

### 2. Memory Service Integration

**On Memory Creation:**
```python
# In memory_service.py
from app.intelligence.content_intelligence import ContentIntelligenceService

async def create_memory(...):
    memory = await super().create_memory(...)
    
    # Queue intelligence processing (non-blocking)
    await ContentIntelligenceService.queue_processing(
        job_type="tag_extraction",
        entity_type="memory",
        entity_id=memory.id
    )
    
    return memory
```

**On Memory Update:**
- Re-process tags if content changed
- Update embeddings if significant changes

### 3. Feed Service Integration

**Personalized Feed Ranking:**
```python
# In feed_service.py
from app.intelligence.feed_intelligence import FeedIntelligenceService

async def get_feed(...):
    feed_items = await super().get_feed(...)
    
    # Apply intelligence-based ranking
    if user_id:
        feed_items = await FeedIntelligenceService.rank_feed_items(
            feed_items, user_id
        )
    
    return feed_items
```

### 4. Comment Service Integration

**Comment Quality Scoring:**
```python
# In comment_service.py
from app.intelligence.comment_intelligence import CommentIntelligenceService

async def create_comment(...):
    comment = await super().create_comment(...)
    
    # Score comment quality (async)
    await CommentIntelligenceService.score_comment_quality(
        comment.id, comment.content
    )
    
    return comment
```

### 5. Media Processor Integration

**Image/Video Intelligence:**
```python
# In media_processor.py
from app.intelligence.media_intelligence import MediaIntelligenceService

async def process_media(...):
    # After media processing completes
    if mime_type.startswith('image/'):
        await MediaIntelligenceService.describe_image(
            storage_path, memory_id
        )
    elif mime_type.startswith('video/'):
        await MediaIntelligenceService.summarize_video(
            storage_path, memory_id
        )
```

## Event Consumer Pattern

### Event Consumer Service

```python
# app/intelligence/event_consumer.py
class IntelligenceEventConsumer:
    """Consumes analytics events and triggers intelligence processing."""
    
    @staticmethod
    async def consume_event(event_id: UUID):
        """Process analytics event for intelligence."""
        # Fetch event from analytics_events table
        # Determine processing needed
        # Queue background jobs
        pass
```

### Background Job Worker

```python
# app/intelligence/worker.py
class IntelligenceWorker:
    """Background worker for processing intelligence jobs."""
    
    async def process_job(self, job_id: UUID):
        """Process a single intelligence job."""
        # Fetch job from intelligence_processing_jobs
        # Execute processing based on job_type
        # Update job status
        # Store results
        pass
```

## LangGraph Integration

### Using LangGraph for Complex Reasoning

For complex multi-step reasoning tasks, use LangGraph with existing checkpoint system:

```python
# app/intelligence/graphs/memory_analysis_graph.py
from langgraph.graph import StateGraph
from app.db.graph_db import get_checkpointer

def create_memory_analysis_graph():
    """Create LangGraph for memory analysis."""
    workflow = StateGraph(MemoryAnalysisState)
    
    workflow.add_node("extract_tags", extract_tags_node)
    workflow.add_node("analyze_sentiment", analyze_sentiment_node)
    workflow.add_node("find_similar", find_similar_node)
    workflow.add_node("update_knowledge", update_knowledge_node)
    
    workflow.set_entry_point("extract_tags")
    workflow.add_edge("extract_tags", "analyze_sentiment")
    workflow.add_edge("analyze_sentiment", "find_similar")
    workflow.add_edge("find_similar", "update_knowledge")
    
    checkpointer = get_checkpointer()
    return workflow.compile(checkpointer=checkpointer)
```

## Caching Integration

### Redis Cache (Short-Term Memory)

```python
# app/intelligence/cache/redis_cache.py
import redis.asyncio as redis

class RedisCache:
    """Redis-based short-term memory cache."""
    
    def __init__(self):
        self.client = redis.from_url(REDIS_URL)
    
    async def get(self, key: str) -> Optional[Any]:
        """Get cached value."""
        pass
    
    async def set(self, key: str, value: Any, ttl: int):
        """Set cached value with TTL."""
        pass
```

### Database Cache (LLM Responses)

```python
# app/intelligence/cache/db_cache.py
class DatabaseCache:
    """Database-based cache for LLM responses."""
    
    async def get_cached_response(
        self, cache_key: str
    ) -> Optional[Dict[str, Any]]:
        """Get cached LLM response."""
        # Check intelligence_cache table
        # Return if not expired
        pass
    
    async def cache_response(
        self, cache_key: str, response: Dict[str, Any], ttl_days: int
    ):
        """Cache LLM response."""
        pass
```

## Configuration

### Environment Variables

Add to `.env`:
```bash
# LLM Provider (OpenAI, Anthropic, etc.)
INTELLIGENCE_LLM_PROVIDER=openai
INTELLIGENCE_LLM_API_KEY=sk-...
INTELLIGENCE_LLM_MODEL=gpt-4-turbo-preview

# Cache Configuration
INTELLIGENCE_REDIS_URL=redis://localhost:6379
INTELLIGENCE_CACHE_ENABLED=true

# Processing Configuration
INTELLIGENCE_ASYNC_PROCESSING=true
INTELLIGENCE_JOB_QUEUE_SIZE=100
INTELLIGENCE_MAX_CONCURRENT_JOBS=5

# Feature Flags
INTELLIGENCE_TAG_EXTRACTION_ENABLED=true
INTELLIGENCE_FEED_RANKING_ENABLED=true
INTELLIGENCE_MEDIA_INTELLIGENCE_ENABLED=true
```

### Settings Integration

```python
# app/config.py
class Settings(BaseSettings):
    # ... existing settings ...
    
    # Intelligence Layer
    intelligence_llm_provider: str = "openai"
    intelligence_llm_api_key: Optional[str] = None
    intelligence_llm_model: str = "gpt-4-turbo-preview"
    intelligence_redis_url: Optional[str] = None
    intelligence_cache_enabled: bool = True
    intelligence_async_processing: bool = True
```

## Deployment Considerations

### Background Workers

Deploy separate worker processes for intelligence processing:

```bash
# Worker process
uvicorn app.intelligence.worker:app --workers 2
```

Or use task queue (Celery, RQ, etc.):

```python
# app/intelligence/tasks.py
from celery import Celery

celery_app = Celery('intelligence')

@celery_app.task
def process_intelligence_job(job_id: UUID):
    """Celery task for intelligence processing."""
    pass
```

### Monitoring

- Monitor job queue size
- Track processing latency
- Alert on high error rates
- Monitor LLM API usage and costs

### Scaling

- Horizontal scaling of worker processes
- Database connection pooling for cache
- Redis cluster for high-availability cache
- Rate limiting for LLM API calls

