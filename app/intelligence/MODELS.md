# Intelligence Layer Data Models

## Database Tables

### 1. `intelligence_user_preferences` (Medium-Term Memory)
Stores learned user preferences and interaction patterns.

```sql
CREATE TABLE intelligence_user_preferences (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
    family_unit_id UUID NOT NULL REFERENCES family_units(id) ON DELETE CASCADE,
    
    -- Preference data (JSONB for flexibility)
    preferred_tags TEXT[] DEFAULT '{}',
    preferred_topics JSONB DEFAULT '{}',
    interaction_patterns JSONB DEFAULT '{}',
    content_preferences JSONB DEFAULT '{}',
    
    -- Metadata
    last_updated TIMESTAMPTZ DEFAULT NOW(),
    confidence_score FLOAT DEFAULT 0.0, -- 0.0 to 1.0
    sample_size INTEGER DEFAULT 0, -- Number of interactions used
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    
    UNIQUE(user_id)
);

CREATE INDEX idx_intelligence_user_prefs_user ON intelligence_user_preferences(user_id);
CREATE INDEX idx_intelligence_user_prefs_family ON intelligence_user_preferences(family_unit_id);
```

### 2. `intelligence_family_knowledge` (Long-Term Memory)
Stores learned family patterns, relationships, and knowledge.

```sql
CREATE TABLE intelligence_family_knowledge (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    family_unit_id UUID NOT NULL REFERENCES family_units(id) ON DELETE CASCADE,
    
    -- Knowledge type
    knowledge_type TEXT NOT NULL, -- 'relationship', 'tradition', 'date', 'theme', 'narrative'
    
    -- Knowledge data (JSONB for flexibility)
    knowledge_data JSONB NOT NULL,
    
    -- Relationships to other entities
    related_memory_ids UUID[] DEFAULT '{}',
    related_user_ids UUID[] DEFAULT '{}',
    
    -- Confidence and source
    confidence_score FLOAT DEFAULT 0.0,
    source_event_ids UUID[] DEFAULT '{}', -- Analytics events that led to this knowledge
    verification_status TEXT DEFAULT 'unverified', -- 'unverified', 'verified', 'disputed'
    
    -- Metadata
    first_observed TIMESTAMPTZ DEFAULT NOW(),
    last_observed TIMESTAMPTZ DEFAULT NOW(),
    observation_count INTEGER DEFAULT 1,
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_intelligence_family_knowledge_family ON intelligence_family_knowledge(family_unit_id);
CREATE INDEX idx_intelligence_family_knowledge_type ON intelligence_family_knowledge(knowledge_type);
CREATE INDEX idx_intelligence_family_knowledge_data ON intelligence_family_knowledge USING GIN(knowledge_data);
```

### 3. `intelligence_cache` (LLM Response Cache)
Caches expensive LLM API responses.

```sql
CREATE TABLE intelligence_cache (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    -- Cache key (hash of input + model + params)
    cache_key TEXT NOT NULL UNIQUE,
    
    -- Cache metadata
    cache_type TEXT NOT NULL, -- 'llm_response', 'embedding', 'analysis'
    model_name TEXT NOT NULL,
    
    -- Cached data
    cached_data JSONB NOT NULL,
    
    -- Expiration
    expires_at TIMESTAMPTZ NOT NULL,
    
    -- Metadata
    hit_count INTEGER DEFAULT 0,
    last_accessed TIMESTAMPTZ DEFAULT NOW(),
    
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_intelligence_cache_key ON intelligence_cache(cache_key);
CREATE INDEX idx_intelligence_cache_expires ON intelligence_cache(expires_at);
CREATE INDEX idx_intelligence_cache_type ON intelligence_cache(cache_type);
```

### 4. `intelligence_embeddings` (Vector Embeddings)
Stores vector embeddings for similarity search.

```sql
-- Requires pgvector extension
CREATE EXTENSION IF NOT EXISTS vector;

CREATE TABLE intelligence_embeddings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    -- Entity reference
    entity_type TEXT NOT NULL, -- 'memory', 'user', 'topic'
    entity_id UUID NOT NULL,
    family_unit_id UUID NOT NULL REFERENCES family_units(id) ON DELETE CASCADE,
    
    -- Embedding data
    embedding vector(1536), -- OpenAI ada-002 dimension (adjust for your model)
    embedding_model TEXT NOT NULL,
    
    -- Source content (for debugging/regeneration)
    source_text TEXT,
    source_metadata JSONB DEFAULT '{}',
    
    -- Metadata
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_intelligence_embeddings_entity ON intelligence_embeddings(entity_type, entity_id);
CREATE INDEX idx_intelligence_embeddings_family ON intelligence_embeddings(family_unit_id);
CREATE INDEX idx_intelligence_embeddings_vector ON intelligence_embeddings USING ivfflat(embedding vector_cosine_ops);
```

### 5. `intelligence_processing_jobs` (Job Queue)
Tracks asynchronous intelligence processing jobs.

```sql
CREATE TABLE intelligence_processing_jobs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    -- Job metadata
    job_type TEXT NOT NULL, -- 'tag_extraction', 'summarization', 'embedding', etc.
    entity_type TEXT NOT NULL, -- 'memory', 'comment', 'media'
    entity_id UUID NOT NULL,
    family_unit_id UUID NOT NULL REFERENCES family_units(id) ON DELETE CASCADE,
    
    -- Job status
    status TEXT NOT NULL DEFAULT 'pending', -- 'pending', 'processing', 'completed', 'failed'
    priority INTEGER DEFAULT 5, -- 1 (highest) to 10 (lowest)
    
    -- Job data
    input_data JSONB NOT NULL,
    output_data JSONB,
    error_message TEXT,
    
    -- Retry logic
    retry_count INTEGER DEFAULT 0,
    max_retries INTEGER DEFAULT 3,
    
    -- Timing
    started_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_intelligence_jobs_status ON intelligence_processing_jobs(status, priority);
CREATE INDEX idx_intelligence_jobs_entity ON intelligence_processing_jobs(entity_type, entity_id);
CREATE INDEX idx_intelligence_jobs_family ON intelligence_processing_jobs(family_unit_id);
```

## Pydantic Models

### User Preferences Model
```python
from pydantic import BaseModel
from typing import Dict, List, Optional
from datetime import datetime
from uuid import UUID

class UserPreferences(BaseModel):
    """Medium-term memory: User preferences and patterns."""
    id: UUID
    user_id: UUID
    family_unit_id: UUID
    preferred_tags: List[str] = []
    preferred_topics: Dict[str, float] = {}  # topic -> relevance score
    interaction_patterns: Dict[str, Any] = {}  # time patterns, frequency, etc.
    content_preferences: Dict[str, Any] = {}  # media types, lengths, etc.
    last_updated: datetime
    confidence_score: float = 0.0
    sample_size: int = 0
    created_at: datetime
    updated_at: datetime
```

### Family Knowledge Model
```python
class FamilyKnowledge(BaseModel):
    """Long-term memory: Family patterns and knowledge."""
    id: UUID
    family_unit_id: UUID
    knowledge_type: str  # 'relationship', 'tradition', 'date', 'theme', 'narrative'
    knowledge_data: Dict[str, Any]
    related_memory_ids: List[UUID] = []
    related_user_ids: List[UUID] = []
    confidence_score: float = 0.0
    source_event_ids: List[UUID] = []
    verification_status: str = 'unverified'
    first_observed: datetime
    last_observed: datetime
    observation_count: int = 1
    created_at: datetime
    updated_at: datetime
```

### Processing Job Model
```python
class ProcessingJob(BaseModel):
    """Intelligence processing job."""
    id: UUID
    job_type: str
    entity_type: str
    entity_id: UUID
    family_unit_id: UUID
    status: str = 'pending'
    priority: int = 5
    input_data: Dict[str, Any]
    output_data: Optional[Dict[str, Any]] = None
    error_message: Optional[str] = None
    retry_count: int = 0
    max_retries: int = 3
    started_at: Optional[datetime] = None
    completed_at: Optional[datetime] = None
    created_at: datetime
    updated_at: datetime
```

## Short-Term Memory (In-Memory Cache)

Short-term memory uses Redis or similar in-memory cache. Structure:

```python
# Cache key patterns:
# session:{user_id}:recent_memories -> List[UUID]
# session:{user_id}:feed_context -> Dict
# session:{user_id}:search_history -> List[str]
# processing:{job_id} -> Job state
# llm_cache:{hash} -> Cached LLM response
```

