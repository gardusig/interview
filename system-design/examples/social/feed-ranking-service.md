# Home feed ranking service

## Introduction

The **ranking service** scores and orders candidates for “For You” feeds after **retrieval** returns hundreds of items. It separates **candidate generation** (cheap, broad) from **heavy scoring** (ML features, business rules).

**Primary users:** viewers (personalized feed), data science (feature pipelines), operators (explore/exploit knobs).

**Interview pacing:** Deep dive **candidate retrieval + scoring + feature freshness**.

Pair with [news-feed](./news-feed.md) (fanout/write path) — this doc is **ranking read path**, not post delivery.

## Requirements discovery

| Lock (target) |
| --- |
| 200M DAU; 20 home loads / DAU / day |
| 500 candidates retrieved; top 50 shown |
| p99 rank &lt; 120 ms after retrieval |
| Feature store lag &lt; 5 min acceptable |

## Architecture (user → database)

```mermaid
flowchart TB
 viewer([Viewer])
 feed[Feed API · ECS]
 retrieve[Retriever · ECS]
 rank[Ranker · ECS]
 cache[(Redis · feature cache)]
 store[(Feature store · DynamoDB)]
 index[(OpenSearch / vector index)]

 viewer --> feed --> retrieve --> index
 retrieve --> rank
 rank --> cache
 rank --> store
 rank --> feed

 classDef user fill:#e3f2fd,#42a5f5,stroke:#1565c0,color:#111
 classDef edge fill:#fff8e1,#ffb74d,stroke:#ef6c00,color:#111
 classDef app fill:#e8f5e9,#66bb6a,stroke:#2e7d32,color:#111
 classDef data fill:#fce4ec,#ef5350,stroke:#c62828,color:#111
 classDef async fill:#f3e5f5,#ab47bc,stroke:#6a1b9a,color:#111
 class viewer user
 class feed,retrieve,rank app
 class cache,store,index data
```

**Narrative:** **Retriever** pulls candidate IDs from social graph + trending index. **Ranker** loads features, applies weighted model + diversity rules, returns ordered list to **Feed API**.

## Deep dive: retrieval vs ranking

- **Retrieval sources:** follow graph, trending, ads slot (separate).
- **Scoring:** logistic/regression blend; explore bucket for cold start.
- **Caching:** per-user feature vector TTL; invalidate on follow block.

## Related

- [News feed](./news-feed.md)
- [Ads auction](../platform/ads-auction-platform.md)
- [OpenSearch drill](../aws/opensearch.md)
