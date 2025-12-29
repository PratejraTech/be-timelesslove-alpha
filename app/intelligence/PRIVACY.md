# Intelligence Layer Privacy & Security

## Privacy Principles

1. **Family Boundaries**: All intelligence is scoped to family units. No cross-family data access.
2. **User Control**: Users can opt-out of intelligence features.
3. **Data Minimization**: Only process data necessary for features.
4. **Transparency**: Users can see what intelligence knows about them.
5. **Right to Deletion**: Users can delete their intelligence data.

## Privacy Controls

### User Preferences

Users can control intelligence features:

```sql
-- Add to user_profiles table
ALTER TABLE user_profiles ADD COLUMN intelligence_preferences JSONB DEFAULT '{
  "tag_extraction_enabled": true,
  "feed_personalization_enabled": true,
  "content_suggestions_enabled": true,
  "media_intelligence_enabled": true,
  "analytics_learning_enabled": true
}'::jsonb;
```

### Family-Level Controls

Adults can control family-level intelligence:

```sql
-- Add to family_units table
ALTER TABLE family_units ADD COLUMN intelligence_settings JSONB DEFAULT '{
  "knowledge_graph_enabled": true,
  "pattern_detection_enabled": true,
  "cross_member_insights_enabled": true
}'::jsonb;
```

## Data Handling

### Short-Term Memory (Cache)

- **Retention**: 1-24 hours (configurable)
- **Scope**: User-specific, session-based
- **Deletion**: Automatic expiration
- **Privacy**: No PII in cache keys

### Medium-Term Memory (User Preferences)

- **Retention**: 90 days rolling window
- **Scope**: User-specific
- **Deletion**: User can delete via API
- **Privacy**: Stored per-user, not shared

### Long-Term Memory (Family Knowledge)

- **Retention**: Permanent (with deletion rights)
- **Scope**: Family unit
- **Deletion**: Family admin can delete
- **Privacy**: Aggregated, no individual user data

### LLM API Calls

- **Data Sent**: Only content necessary for processing
- **Provider Privacy**: Subject to LLM provider's privacy policy
- **No Storage**: Responses cached, but original API calls not stored
- **Opt-Out**: Users can disable LLM processing

## Security Measures

### Access Control

- All intelligence APIs require authentication
- Family-scoped queries verify family membership
- User preferences only accessible by user
- Family knowledge only accessible by family members

### Data Encryption

- At rest: Database encryption (Supabase handles)
- In transit: TLS for all API calls
- Cache: Redis with password authentication

### Audit Logging

Log all intelligence operations:

```python
# app/intelligence/audit.py
class IntelligenceAudit:
    """Audit logging for intelligence operations."""
    
    async def log_access(
        self,
        user_id: UUID,
        resource_type: str,
        resource_id: UUID,
        action: str
    ):
        """Log access to intelligence data."""
        await analytics_service.emit_event(
            event_type="intelligence_access",
            user_id=user_id,
            metadata={
                "resource_type": resource_type,
                "resource_id": str(resource_id),
                "action": action
            }
        )
```

## Compliance

### GDPR Compliance

- **Right to Access**: Users can request their intelligence data
- **Right to Deletion**: Users can delete intelligence data
- **Data Portability**: Export intelligence data
- **Consent**: Opt-in for intelligence features

### COPPA Compliance

- Children's data: Minimal processing
- Parental controls: Adults control child intelligence features
- No profiling: Limited intelligence for child accounts

## Data Retention Policies

### Automatic Deletion

- Short-term cache: Automatic expiration
- Old preferences: 90 days rolling window
- Failed jobs: 30 days retention
- Expired cache: Automatic cleanup

### Manual Deletion

- User deletion: Cascade delete intelligence data
- Family deletion: Cascade delete family knowledge
- Account closure: Delete all intelligence data

## Transparency Features

### User Dashboard

Provide API endpoints for users to see their intelligence data:

```python
# GET /api/v1/intelligence/my-data
{
  "preferences": {...},
  "knowledge_about_me": [...],
  "processing_history": [...]
}
```

### Family Insights (Adults Only)

```python
# GET /api/v1/intelligence/family-data
{
  "family_knowledge": [...],
  "patterns": [...],
  "insights": [...]
}
```

## Best Practices

1. **Minimize Data**: Only process necessary data
2. **Anonymize**: Remove PII before LLM processing when possible
3. **Aggregate**: Use aggregated data for family insights
4. **Encrypt**: Encrypt sensitive intelligence data
5. **Audit**: Log all intelligence operations
6. **Test**: Regular privacy audits and testing
7. **Document**: Clear privacy documentation for users

## Incident Response

### Data Breach

1. Immediately disable affected intelligence features
2. Notify affected users
3. Audit access logs
4. Rotate API keys
5. Review and update security measures

### Privacy Violation

1. Investigate violation
2. Delete affected data
3. Notify affected users
4. Update privacy controls
5. Document incident

