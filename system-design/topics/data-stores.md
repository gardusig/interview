# 🗄️ Data stores

## 📇 Index

1. [2. SQL vs NoSQL tradeoffs](#2-sql-vs-nosql-tradeoffs)

SQL vs NoSQL tradeoffs and index design. Maps to **Amazon DynamoDB** (NoSQL access patterns) and **Amazon RDS** / **Amazon Aurora** (relational) on AWS.

## 2. SQL vs NoSQL Tradeoffs

### SQL Databases

* **Strong consistency**
 * Reads always reflect the latest committed write.
 * Important when correctness matters more than latency (e.g. payments, balances).
* **ACID transactions**
 * **Atomicity** — all operations in a transaction succeed or none do.
 * Prevents partial updates (e.g. money debited but not credited).
 * **Consistency** — the database moves from one valid state to another.
 * Enforces constraints like foreign keys, uniqueness, and invariants.
 * **Isolation** — concurrent transactions do not interfere incorrectly.
 * Prevents issues like dirty reads and lost updates.
 * **Durability** — once a transaction commits, it will survive crashes.
 * Data is persisted to disk and recoverable after failures.
* **Joins and complex queries**
 * Supports relational queries across multiple tables.
 * Enables expressive querying without duplicating data.
* **Rigid schema**
 * Schema must be defined upfront and enforced by the database.
 * Prevents invalid data but makes schema evolution more expensive.
* **Typically vertical scaling**
 * Performance is often improved by scaling a single node (more CPU/RAM).
 * Horizontal scaling is possible but more complex (sharding, replicas).

### Use SQL when:

* Financial data
* Strong invariants
* Complex relationships

### Indexes in SQL Databases

An index is a **separate data structure** (usually a B-tree) that maps:

> column values → row locations

This allows the database to find data **without scanning the entire table**.

* Improve read performance by avoiding full table scans.
 * Example: querying trips by `rider_id` without an index requires scanning all trips.
 * With an index on `rider_id`, the database jumps directly to matching rows.
* Add overhead to writes.
 * Every insert, update, or delete must also update the index.
 * Example: adding an index on `status` means every trip status change updates both the table and the index.
* Consume additional storage.
 * Indexes store copies of key values and pointers to rows.
 * Multiple indexes can significantly increase storage costs.
* Flexible and ad-hoc.
 * Indexes can usually be added later.
 * Supports a wide variety of query patterns (filters, joins, sorting).

### SQL rule:
Index only what you query frequently.

* Good index: `GET /trips?driver_id=123&status=ACTIVE`
 → composite index on `(driver_id, status)`
* Bad index: fields rarely used in filters or sorting

**AWS:** **Amazon RDS** (PostgreSQL, MySQL, etc.) and **Amazon Aurora** are the standard managed relational choices. Use them when the interview clearly needs joins, transactions, or ad hoc query flexibility.

---

### NoSQL Databases

* **Horizontal scaling**
 * Built to scale by adding more nodes rather than upgrading a single machine.
 * Data is automatically partitioned and distributed across nodes.
* **High write throughput**
 * Optimized for fast inserts and updates at scale.
 * Avoids costly joins and complex multi-row transactions.
* **Eventual consistency**
 * Writes propagate asynchronously to replicas.
 * Reads may temporarily return stale data, but the system converges over time.
* **Denormalized data model**
 * Data is intentionally duplicated to match query patterns.
 * Minimizes read-time computation and eliminates joins.

### Use NoSQL when:
* Very high traffic or unpredictable load
* Simple, well-defined access patterns
* Systems that can tolerate temporary inconsistency
* Real-time or large-scale workloads

### Indexes in NoSQL Databases

In NoSQL systems, indexes are **part of the data model**, not an afterthought.
They must be designed **before data is written**, based on known access patterns.

* **Primary key**
 * Always exists and defines how data is physically stored.
 * Composed of a **partition key** and an optional **sort key**.
 * Determines:
 * Which node stores the data
 * How data is ordered within a partition
 * Optimized for direct key-based lookups and range queries.
 * **Example**:
 * `PK: user_id`
 > Fast lookup by user ID, but no support for other query patterns.
* **Secondary indexes**
 * Explicitly defined to support additional query patterns.
 * Internally behave like separate tables that replicate data.
 * Types:
 * **GSI (Global Secondary Index)** — different partition and/or sort keys
 * New partition key allowed
 * Queries across users/entities
 * Eventually consistent by default
 * **LSI (Local Secondary Index)** — same partition key, different sort key
 * Same partition key
 * Only different sorting
 * Strongly consistent reads supported
* **Base table**
 * Table: `Orders`
 * **Partition key (PK):** `user_id`
 * **Sort key (SK):** `order_id`
 * GSI **Partition key**: `status`
 * GSI **Sort key**: `created_at`

 Example item:
 ```json
 {
 "user_id": "u123",
 "order_id": "o987",
 "status": "SHIPPED",
 "created_at": "2025-01-10",
 "total": 150.00
 }
 ```

 Query:
 ```
 Get all SHIPPED orders sorted by creation date
 PK = "SHIPPED"
 SK begins with "2025-01"
 ```

### Tradeoffs in NoSQL Indexes
* Writes are more expensive (base table + indexes).
* Indexes consume additional throughput and storage.
* Queries are limited to predefined access patterns.
* Poor key design can cause hot partitions and throttling.

### NoSQL Rule
Model your data around queries.
Changing access patterns later is expensive and often requires data migration.

**AWS:** **Amazon DynamoDB** matches this model (PK/SK, GSI, LSI). Interview answers should tie every access pattern to keys and indexes.

---

### Search indexes and OpenSearch

For **full-text search**, **faceted queries**, or **log/search analytics** at scale, teams often add a dedicated search cluster. On AWS, **Amazon OpenSearch Service** is the managed option (Elasticsearch-compatible API). It complements DynamoDB or RDS: the primary store remains source of truth; search indexes are **derived** (async indexing, CDC, or batch rebuild). See also [observability.md](./observability.md) for using OpenSearch in logging and analytics paths.

## 🔗 Related

- [Topics index](../topics-index.md)
- [Caching](./caching.md)
- [Concurrency](./concurrency.md)
- [AWS reference layout]./aws-reference-layout.md
