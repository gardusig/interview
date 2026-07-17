# 📡 API design

## 📇 Index

1. [1. API design](#1-api-design)

Public **REST** shape, **gRPC** for internal RPC, and **HTTP** ergonomics (errors, pagination, idempotency). For ingress patterns (API Gateway, throttling), see [edge-and-ingress.md](./edge-and-ingress.md). For internal load balancing of gRPC, see [compute.md](./compute.md).

## 1. API Design

### REST vs gRPC vs WebSocket

* **REST**
 * Human-readable, easy debugging (curl, browser)
 * Works naturally over HTTP
 * Flexible but weaker contracts
 * Enforced via documentation / OpenAPI, not at the protocol level
* **gRPC**
 * Strong contracts via protobuf
 * Lower latency, smaller payloads
 * Built-in streaming
 * Harder to debug, limited native browser support
* **WebSockets**
 * Persistent, bidirectional connection
 * Server can push updates (no polling)
 * Low latency for real-time data
 * Harder to scale (stateful connections)

**Rule of thumb**:
- REST → public/external request–response APIs
- gRPC → internal service-to-service communication
- WebSockets → real-time client updates

On **AWS**, public REST often sits behind **Amazon API Gateway** or an **Application Load Balancer**; internal gRPC is commonly fronted by an **Application Load Balancer** (gRPC support) or **Network Load Balancer** for high-throughput L4 forwarding.

---

### Idempotency

* An operation is **idempotent** if repeating it produces the same result.
* Required for safe retries under failures.

**Examples**:

* `PUT /trips/{id}` → idempotent
* `POST /trips` → not idempotent by default

---

### Versioning Strategies

* **URI-based**: `/v1/trips`
* **Header-based**: `Accept-Version: v1`

**Tradeoff**:

* URI-based is explicit and easy
* Header-based keeps URLs clean but harder to debug

---

### Pagination

Pagination is used to return large datasets in smaller, manageable chunks while maintaining performance and correctness.

* **Offset-based pagination**: `?offset=100&limit=20`
 * Uses row offsets to skip records
 * Easy to implement and understand
 * Performance degrades for large offsets (DB must scan/skips rows)
 * Results become inconsistent when rows are inserted or deleted

 **Example issue**:
 - Page 1 returns items 1–20
 - A new item is inserted at the top
 - Page 2 now skips or duplicates items

* **Cursor-based pagination**: `?cursor=abc123`
 * Uses a stable cursor (e.g. last seen ID or timestamp)
 * Maintains consistent ordering across pages
 * Efficient for large datasets
 * Requires a well-defined sort key (ID, timestamp)

 **Example**:
 - `GET /trips?after=trip_123&limit=20`
 - Returns trips created after `trip_123`

**Preferred for production**: Cursor-based pagination, especially for high-traffic or frequently updated datasets.

---

### HTTP Error Handling

* Use meaningful HTTP status codes to clearly communicate failure types

 * `400` Bad Request — invalid or malformed input
 * `401` Unauthorized — missing or invalid authentication token
 * `403` Forbidden — authenticated but not allowed to perform the operation
 * `404` Not Found — resource does not exist
 * `409` Conflict — request conflicts with current state
 * `500` Internal Server Error — unexpected server failure

---

### HTTP Parameters

* **Path params** → resource identity
 * `/trips/{tripId}`
* **Query params** → filtering, sorting, pagination
 * `?status=active&limit=20`
* **Headers** → metadata
 * Auth tokens
 * Trace IDs
 * Idempotency keys

---

### External and partner HTTP APIs

Treat third-party **External HTTP API** dependencies like any other risky downstream: timeouts, retries with backoff, idempotency where possible, and explicit failure modes (see [reliability.md](./reliability.md)). In interviews, name **real** integration patterns (webhooks, OAuth2 client credentials, signed callbacks) rather than fictional services.

## 🔗 Related

- [Topics index](../topics-index.md)
- [Edge and ingress](./edge-and-ingress.md)
- [Compute](./compute.md)
- [Reliability](./reliability.md)
- [AWS reference layout]./aws-reference-layout.md
