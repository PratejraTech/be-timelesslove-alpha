# Intelligence Layer Architecture Plan

## Overview

The Intelligence Layer is a specialized information processing system that uses Large Language Models (LLMs) to enhance the Timeless Love platform with intelligent features. It processes user-generated content, learns from family interactions, and provides personalized experiences while maintaining privacy and data integrity.

## Location Assessment

**Location: `app/intelligence/`**

✅ **This location is appropriate** because:
- Follows existing pattern (`app/services/`, `app/models/`, `app/utils/`)
- Keeps intelligence logic separate from core business logic
- Allows for modular development and testing
- Aligns with the existing `app/db/graph_db.py` LangGraph integration

## Core Principles

1. **Privacy First**: All processing respects family boundaries and user privacy
2. **Event-Driven**: Consumes structured events from `analytics_service`
3. **Non-Blocking**: Intelligence processing happens asynchronously
4. **Observable**: All operations emit metrics and logs
5. **Idempotent**: Processing can be safely retried
6. **Family-Scoped**: All intelligence is scoped to family units

## Architecture Components

### 1. Memory System (Short/Medium/Long Term)

#### Short-Term Memory (Session Cache)
- **Purpose**: Store recent interactions and context for current session
- **Storage**: In-memory cache (Redis or similar)
- **TTL**: 1-24 hours
- **Use Cases**:
  - Current user's recent memory views
  - Active feed context
  - Recent search queries
  - Temporary processing state

#### Medium-Term Memory (User Preferences)
- **Purpose**: Store learned user preferences and patterns
- **Storage**: Supabase `intelligence_user_preferences` table
- **Retention**: 90 days rolling window
- **Use Cases**:
  - User's content preferences (tags, topics)
  - Interaction patterns (when they're most active)
  - Preferred memory types (photos vs videos)
  - Comment style preferences

#### Long-Term Memory (Family Knowledge Graph)
- **Purpose**: Store learned family patterns, relationships, and history
- **Storage**: Supabase `intelligence_family_knowledge` table + LangGraph checkpoints
- **Retention**: Permanent (with privacy controls)
- **Use Cases**:
  - Family member relationships and roles
  - Recurring events and traditions
  - Important dates and anniversaries
  - Family story patterns and themes
  - Cross-memory connections and narratives

### 2. Caching Strategy

#### LLM Response Cache
- **Purpose**: Cache expensive LLM API calls
- **Storage**: Redis or Supabase `intelligence_cache` table
- **Key Strategy**: Content hash + model + parameters
- **TTL**: 7-30 days (depending on content type)
- **Use Cases**:
  - Tag extraction results
  - Content summaries
  - Sentiment analysis
  - Similarity embeddings

#### Embedding Cache
- **Purpose**: Cache vector embeddings for similarity search
- **Storage**: Supabase with pgvector extension (or dedicated vector DB)
- **Retention**: Permanent (updated on content change)
- **Use Cases**:
  - Memory content embeddings
  - User preference embeddings
  - Topic clustering

### 3. LLM Processing Modules

#### Content Intelligence
- **Tag Extraction**: Auto-extract relevant tags from memory descriptions
- **Content Enhancement**: Suggest title improvements, descriptions
- **Summarization**: Generate memory summaries for feed previews
- **Sentiment Analysis**: Detect emotional tone of memories/comments
- **Content Moderation**: Flag inappropriate content (with human review)

#### Feed Intelligence
- **Personalized Ranking**: Re-rank feed based on user preferences
- **Content Recommendations**: Suggest similar memories or related content
- **Topic Clustering**: Group related memories into themes
- **Trend Detection**: Identify emerging topics in family content

#### Comment Intelligence
- **Quality Scoring**: Assess comment quality and relevance
- **Reply Suggestions**: Suggest contextual replies
- **Sentiment Analysis**: Monitor comment sentiment
- **Moderation Support**: Flag potentially problematic comments

#### Media Intelligence
- **Image Description**: Generate alt-text and descriptions for images
- **Video Summarization**: Extract key moments from videos
- **Scene Detection**: Identify locations, people, activities
- **Content Tagging**: Auto-tag media with relevant metadata

#### Analytics Intelligence
- **Pattern Detection**: Identify usage patterns and anomalies
- **Predictive Insights**: Predict user engagement
- **Behavior Understanding**: Learn family interaction patterns
- **Recommendation Engine**: Suggest optimal posting times, content types

## Implementation Plan

### Phase 1: Foundation (Weeks 1-2)
1. Create `app/intelligence/` directory structure
2. Set up memory storage (tables + cache)
3. Implement basic caching layer
4. Create event consumer for analytics events
5. Set up LLM client abstraction

### Phase 2: Content Processing (Weeks 3-4)
1. Implement tag extraction service
2. Implement content summarization
3. Implement sentiment analysis
4. Add content enhancement suggestions
5. Integrate with memory creation/update flows

### Phase 3: Feed Intelligence (Weeks 5-6)
1. Implement personalized feed ranking
2. Build content recommendation engine
3. Add topic clustering
4. Integrate with existing feed service

### Phase 4: Memory System (Weeks 7-8)
1. Implement short-term memory cache
2. Build medium-term preference storage
3. Create long-term knowledge graph
4. Add memory retrieval and update APIs

### Phase 5: Advanced Features (Weeks 9-10)
1. Media intelligence processing
2. Comment intelligence features
3. Analytics intelligence patterns
4. Privacy controls and user preferences

## Data Models

See `MODELS.md` for detailed data model specifications.

## API Design

See `API.md` for API endpoint specifications.

## Integration Points

See `INTEGRATION.md` for integration with existing services.

## Privacy & Security

See `PRIVACY.md` for privacy controls and data handling.

