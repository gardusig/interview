# 💾 Caching

## 📇 Index

1. [4. Caching](#4-caching)

What, where, and how to cache; invalidation tradeoffs. Maps to **Amazon ElastiCache** (Redis), **Amazon CloudFront**, and application-side caches.

## 4. Caching

### What to Cache?

* **Read-heavy data**: Profiles, metadata, configuration
* **Expensive computations**: Aggregations, ranking, recommendations
* **Slowly changing data**: Feature flags, pricing rules, reference data

### Where to Cache?

* **Client-side**: Browser cache, mobile local storage
* **CDN**: Static assets, public APIs
* **Application cache**: Redis, Memcached

### How to Cache?
* App checks cache first
* On miss → fetch from DB → populate cache

### Avoid caching
* Highly volatile data
* Strongly consistent transactions
* Large unbounded result sets

---

### Cache Invalidation Strategies

* **TTL-based expiration**
 * Simple, eventually consistent
 * Risk of stale reads

* **Write-through invalidation**
 * Update cache synchronously on writes
 * Higher write latency, stronger consistency

* **Event-based invalidation**
 * Invalidate via pub/sub or CDC
 * Scales well but increases complexity

**Hard truth**
> Cache invalidation is hard because correctness depends on timing, not logic.

**AWS:** **Amazon ElastiCache for Redis** is the common managed cache behind **AWS Lambda** or **Amazon ECS** tasks. **Amazon CloudFront** caches HTTP responses and static objects at the edge (see [edge-and-ingress.md](./edge-and-ingress.md)).

## 🔗 Related

- [Topics index](../topics-index.md)
- [Edge and ingress](./edge-and-ingress.md)
- [Data stores](./data-stores.md)
- [AWS reference layout]./aws-reference-layout.md
