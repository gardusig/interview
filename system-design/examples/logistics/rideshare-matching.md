# Rideshare on-demand matching

## Introduction

Rideshare matches **riders** requesting trips to **drivers** with supply nearby. The system optimizes **time-to-match**, **surge pricing**, and **offer timeouts** while keeping location updates fresh.

**Primary users:** riders (request trip), drivers (accept offers), operators (surge, supply dashboards).

**Interview pacing:** [60-minute runbook](../../prep/interview-runbook-60m.md) — deep dive **supply/demand matching + surge**.

Distinct from [delivery dispatch](./delivery-dispatch-matching.md) (courier jobs): here both sides are mobile consumers and **geo-indexed supply** dominates.

## Requirements discovery

### Interview Q&A cheat sheet

| Lock (target) |
| --- |
| 20M trips/day peak regions |
| Match p99 &lt; 15 s |
| Driver location update every 3–5 s |
| Surge by geohash cell |
| Out of scope: autonomous fleet routing |

### Parsed requirements

| Field | Target |
| --- | --- |
| Active drivers (peak city) | 50k online |
| Rider request RPS (peak) | ~30k/s global |
| Offer TTL | 15 s before re-offer |

## AWS service map

| Service | Role |
| --- | --- |
| DynamoDB | Trips, offers, driver state |
| ElastiCache | Geo supply index, surge multipliers |
| Amazon MSK | Location stream |
| ECS Fargate | Matcher + pricing |
| API Gateway + ALB | Mobile APIs |

## Architecture (user → database)

```mermaid
flowchart TB
 rider([Rider])
 driver([Driver])
 api[Trip API · ECS]
 matcher[Matcher · ECS]
 geo[(Redis · geo index)]
 trips[(DynamoDB · trips)]
 loc[[MSK · location events]]

 rider --> api
 driver -->|GPS| loc --> matcher
 api --> matcher
 matcher --> geo
 matcher --> trips
 driver -->|accept| api

 classDef user fill:#e3f2fd,#42a5f5,stroke:#1565c0,color:#111
 classDef edge fill:#fff8e1,#ffb74d,stroke:#ef6c00,color:#111
 classDef app fill:#e8f5e9,#66bb6a,stroke:#2e7d32,color:#111
 classDef data fill:#fce4ec,#ef5350,stroke:#c62828,color:#111
 classDef async fill:#f3e5f5,#ab47bc,stroke:#6a1b9a,color:#111
 class rider,driver user
 class api,matcher app
 class geo,trips data
 class loc async
```

**Narrative:** Drivers publish location to **MSK**; **matcher** maintains **geo index** in Redis, scores candidates, sends **time-bound offers**. **Surge** reads demand/supply ratio per cell.

## Deep dive: matching + surge

- **Geohash** cells with cap on candidates evaluated.
- **Batch offers** to top-K drivers; first accept wins (optimistic locking on trip).
- **Surge:** `multiplier = f(wait_time, supply_density)` cached per cell.

## Related

- [Delivery dispatch](./delivery-dispatch-matching.md)
- [Maps routing](./maps-navigation-routing.md)
- [Real-time tracking](./real-time-delivery-tracking.md)
- [MSK drill](../aws/msk-kinesis.md)
