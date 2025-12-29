# Intelligence Layer API Design

## Overview

The Intelligence Layer provides both internal APIs (for service integration) and optional external APIs (for frontend features). All APIs respect family boundaries and privacy controls.

## Internal Service APIs

### 1. Content Intelligence Service

#### `extract_tags(content: str, memory_id: UUID) -> List[str]`
Extract relevant tags from memory content.

**Input:**
- `content`: Memory title + description
- `memory_id`: Memory UUID for context

**Output:**
- List of suggested tags

**Caching:** Yes (7 days TTL)

#### `summarize_content(content: str, max_length: int = 150) -> str`
Generate a summary of memory content.

**Input:**
- `content`: Full memory content
- `max_length`: Maximum summary length

**Output:**
- Summary text

**Caching:** Yes (30 days TTL)

#### `analyze_sentiment(content: str) -> Dict[str, Any]`
Analyze sentiment of memory or comment.

**Output:**
```json
{
  "sentiment": "positive" | "neutral" | "negative",
  "confidence": 0.0-1.0,
  "emotions": ["joy", "nostalgia", ...],
  "score": -1.0 to 1.0
}
```

**Caching:** Yes (7 days TTL)

#### `enhance_content(content: str, content_type: str) -> Dict[str, Any]`
Suggest improvements to memory content.

**Output:**
```json
{
  "suggested_title": "...",
  "suggested_description": "...",
  "suggested_tags": [...],
  "confidence": 0.0-1.0
}
```

**Caching:** No (user-specific)

### 2. Feed Intelligence Service

#### `rank_feed_items(feed_items: List[MemoryFeedItem], user_id: UUID) -> List[MemoryFeedItem]`
Re-rank feed items based on user preferences.

**Input:**
- `feed_items`: List of feed items from feed service
- `user_id`: User for personalization

**Output:**
- Re-ranked list of feed items

**Caching:** Short-term (session cache)

#### `recommend_similar_memories(memory_id: UUID, user_id: UUID, limit: int = 5) -> List[UUID]`
Find similar memories using embeddings.

**Output:**
- List of similar memory UUIDs

**Caching:** Yes (7 days TTL)

#### `cluster_memories_by_topic(family_unit_id: UUID, limit: int = 10) -> Dict[str, List[UUID]]`
Group memories by topic themes.

**Output:**
```json
{
  "topic_name": [memory_id1, memory_id2, ...],
  ...
}
```

**Caching:** Yes (1 day TTL)

### 3. Memory System APIs

#### `get_user_preferences(user_id: UUID) -> UserPreferences`
Get medium-term user preferences.

**Caching:** Yes (in-memory, 1 hour TTL)

#### `update_user_preferences(user_id: UUID, event: AnalyticsEvent) -> None`
Update user preferences based on new event.

**Async:** Yes (background job)

#### `get_family_knowledge(family_unit_id: UUID, knowledge_type: Optional[str] = None) -> List[FamilyKnowledge]`
Get long-term family knowledge.

**Caching:** Yes (1 day TTL)

#### `learn_from_event(event: AnalyticsEvent) -> None`
Learn from analytics event and update knowledge.

**Async:** Yes (background job)

### 4. Media Intelligence Service

#### `describe_image(image_url: str, memory_id: UUID) -> Dict[str, Any]`
Generate description for image.

**Output:**
```json
{
  "description": "...",
  "alt_text": "...",
  "tags": [...],
  "detected_objects": [...],
  "scene_type": "..."
}
```

**Caching:** Yes (permanent, keyed by image hash)

#### `summarize_video(video_url: str, memory_id: UUID) -> Dict[str, Any]`
Extract key moments from video.

**Output:**
```json
{
  "summary": "...",
  "key_moments": [
    {"timestamp": 0, "description": "..."},
    ...
  ],
  "duration": 120,
  "tags": [...]
}
```

**Caching:** Yes (permanent, keyed by video hash)

### 5. Comment Intelligence Service

#### `score_comment_quality(comment: str, context: Dict[str, Any]) -> float`
Score comment quality (0.0 to 1.0).

**Caching:** Yes (7 days TTL)

#### `suggest_reply(comment: str, memory_context: Dict[str, Any]) -> List[str]`
Suggest contextual replies.

**Output:**
- List of suggested reply texts

**Caching:** No (context-specific)

## External API Endpoints (Optional)

### GET `/api/v1/intelligence/preferences`
Get current user's learned preferences.

**Auth:** Required
**Response:**
```json
{
  "preferred_tags": [...],
  "preferred_topics": {...},
  "confidence_score": 0.85
}
```

### GET `/api/v1/intelligence/recommendations`
Get personalized memory recommendations.

**Auth:** Required
**Query Params:**
- `limit`: Number of recommendations (default: 10)
- `type`: Recommendation type ('similar', 'trending', 'personalized')

**Response:**
```json
{
  "recommendations": [
    {
      "memory_id": "...",
      "reason": "Similar to memories you've liked",
      "confidence": 0.92
    },
    ...
  ]
}
```

### GET `/api/v1/intelligence/family-insights`
Get family-level insights (aggregated, privacy-safe).

**Auth:** Required (Adult role)
**Response:**
```json
{
  "topics": [...],
  "trends": [...],
  "milestones": [...]
}
```

### POST `/api/v1/intelligence/enhance-memory`
Request content enhancement suggestions.

**Auth:** Required
**Body:**
```json
{
  "memory_id": "...",
  "content": "..."
}
```

**Response:**
```json
{
  "suggestions": {
    "title": "...",
    "description": "...",
    "tags": [...]
  }
}
```

## Background Job APIs

### POST `/api/v1/intelligence/jobs/process`
Trigger intelligence processing job (internal).

**Body:**
```json
{
  "job_type": "tag_extraction",
  "entity_type": "memory",
  "entity_id": "...",
  "priority": 5
}
```

### GET `/api/v1/intelligence/jobs/{job_id}`
Get job status.

**Response:**
```json
{
  "id": "...",
  "status": "completed",
  "output_data": {...}
}
```

## Error Handling

All APIs return consistent error format:

```json
{
  "error": {
    "code": "INTELLIGENCE_ERROR",
    "message": "Human-readable error",
    "details": {...}
  }
}
```

## Rate Limiting

- External APIs: 100 requests/hour per user
- Internal APIs: No limit (service-to-service)
- Background jobs: Queue-based throttling

## Privacy Controls

- All APIs respect family boundaries
- User preferences are private to user
- Family knowledge is scoped to family unit
- No cross-family data leakage

