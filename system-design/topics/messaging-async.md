# 📬 Queue, async processing, and messaging

## 📇 Index

1. [5. Queue & async processing & messaging](#5-queue--async-processing--messaging)

Delivery semantics, partitioning, topics, DLQs, and **workflow-style orchestration**. Maps to **Amazon MSK**, **Amazon EventBridge**, **Amazon SQS**, **Amazon SNS**, **Amazon Kinesis Data Streams**, and **AWS Step Functions** on AWS.

## 5. Queue & Async Processing & Messaging

### Delivery Semantics

* **At-most-once**
 * Messages may be lost
 * No retries
 * Used when loss is acceptable (metrics, logs)
* **At-least-once** (most common)
 * Messages are retried until acknowledged
 * Duplicates possible
 * Requires idempotent consumers
* **Exactly-once** (rare)
 * No loss, no duplicates
 * Requires coordination across producer, broker, and consumer
 * High latency and complexity

### Partitioning

* Messages are split across **partitions** (or shards)
* Each partition is consumed by **only one consumer at a time**
* Enables horizontal scalability

**Tradeoffs**
* More partitions → higher throughput
* Fewer partitions → stronger ordering
* Hot keys can overload a single partition

### Parallel Processing via Partitioned Queues

Partitioned queues enable safe parallelism without locks by guaranteeing that all messages with the same key are processed sequentially by a single consumer.

> Hash a stable key (e.g. ad_id, user_id, trip_id) to determine which partition a message belongs to.
> `partition = hash(key) % N`

All events with the same key:
- Go to the same partition
- Are consumed in order

### Batch Processing

Consumers should poll messages in batches to reduce overhead.

Benefits:
- Fewer network calls
- Fewer DB writes
- Better CPU cache locality

Tradeoff:
- Slightly higher latency
- Requires tuning batch size and flush interval

### Dead-Letter Queues (DLQ)

* Messages that repeatedly fail processing are moved aside
* Prevent poison messages from blocking progress

**Common triggers**
* Exceeded retry limit
* Validation errors
* Schema incompatibility

### Topics (Publish–Subscribe)

* Logical event stream supporting **fan-out**
* Messages are written once and consumed by **multiple consumer groups**
* Each consumer group processes all partitions independently

Why this matters:
- Decouples producers from downstream logic
- Enables independent scaling
- Prevents cascading failures
- Allows different SLAs per consumer

### Priority Queues

* Messages processed based on importance, not arrival time

**Implementations**
* Separate queues/topics per priority
* Priority field + consumer-side scheduling

**Use cases**
* User-facing requests over background jobs
* SLA-sensitive workflows

**Tradeoff**
* Priority handling increases system complexity
* Risk of starving low-priority messages

---

### Amazon MSK vs Amazon Kinesis Data Streams

Both are **real AWS** stream products; interviewers often ask when to pick which.

**Amazon MSK (Apache Kafka)** — Durable **log** with **topics** and **partitions**, **consumer groups**, replay by offset, rich ecosystem (Kafka Connect, stream processors). Strong fit when you need **multiple independent consumers** on the same log, **ordering per partition**, and **replay** for reprocessing or new services.

**Amazon Kinesis Data Streams** — Managed **shards** with **ordered records per shard**, multiple consumers via **enhanced fan-out** or classic iterator model. Strong fit when you already standardize on AWS-native streaming, **simple producers** (e.g. SDK PutRecord), and **Lambda or Flink** consumers; different operational and ecosystem tradeoffs than Kafka.

**Rule of thumb:** If the problem screams “Kafka” (consumer groups, compacted topics, cross-vendor skills), **MSK** is the honest AWS answer. If the problem is “AWS-native firehose of events with shard scaling,” discuss **Kinesis**. Do not invent hybrid names—stick to documented products.

---

### Workflow and orchestration

Long-running or multi-step processes (sagas, human steps, compensations) are often modeled with a **workflow engine** instead of embedding all state in application code.

**AWS Step Functions** — Visual/state-machine style workflows, **Standard** (durable, auditable, longer execution) vs **Express** (high volume, short duration, different durability semantics). Integrates with **AWS Lambda**, **Amazon DynamoDB**, **Amazon SNS**, **Amazon SQS**, and other AWS APIs. Good interview answer when steps are **explicit**, **retryable**, and **observable** as a state machine.

**Portable / industry analogies** (do **not** put proprietary names on AWS-only diagrams): **Temporal** and **Cadence** are common in large microservice shops for code-first durable execution; **Apache Airflow** is **batch / DAG scheduling**, not a drop-in replacement for request-driven sagas. Name these in **prose** when comparing patterns, not as fake AWS services.

Design points: **idempotent activities**, **timeouts**, **compensation** on failure, and **external** callbacks (webhooks) tied with correlation IDs (see [observability.md](./observability.md)).

## 🔗 Related

- [Topics index](../topics-index.md)
- [Reliability](./reliability.md)
- [Observability](./observability.md)
- [Compute](./compute.md)
- [AWS reference layout]./aws-reference-layout.md
