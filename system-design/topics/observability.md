# 📊 Observability

## 📇 Index

1. [6. Observability](#6-observability)

Logs, metrics, traces, correlation, and how they support **analytics** and **debugging**. Maps to **Amazon CloudWatch**, **AWS X-Ray**, **Amazon OpenSearch Service**, **AWS CloudTrail**, and **OpenTelemetry**-compatible tooling.

## 6. Observability

> “Why is the system behaving the way it is?”

### Signals

* **Logs**:
 * Debugging specific failures
 * Auditing and forensics
* **Metrics**:
 * Alerting
 * Capacity planning
 * Trend analysis
* **Traces**:
 * Root-cause analysis
 * Identifying latency bottlenecks
 * Understanding service interactions

### Structured logging and aggregation

Prefer **structured logs** (JSON or key-value fields) over opaque strings so you can search and aggregate by `service`, `user_id`, `trip_id`, `error_code`, etc.

**AWS:** **Amazon CloudWatch Logs** for collection and retention; **CloudWatch Logs Insights** for ad hoc queries. Export to **Amazon S3** for long retention or **Amazon OpenSearch Service** for heavier search and dashboards.

**Portable / SaaS:** ELK stack (Elasticsearch, Logstash, Kibana), Grafana Loki, Datadog, Splunk—same concepts, different hosting.

### Metrics and alerting

Instrument **RED**-style (rate, errors, duration) or **USE** (utilization, saturation, errors) per service. Alert on **SLO burn** and **symptoms** (latency, error rate, consumer lag), not only on CPU.

**AWS:** **Amazon CloudWatch** metrics and alarms; **AWS Lambda** and **Amazon ECS** built-in metrics; custom metrics via API or embedded metric format.

### Distributed tracing

Traces stitch together **spans** across API Gateway, Lambda, ECS tasks, **AWS Step Functions**, and downstream databases.

**AWS:** **AWS X-Ray** integrates with many AWS services; **OpenTelemetry** (OTel) is the vendor-neutral standard—export to X-Ray, Jaeger, or SaaS APM.

**Portable:** Jaeger, Zipkin, Grafana Tempo.

### Analytics over logs and data lakes

For **product** or **operations** analytics (funnels, aggregates over days of data), logs and events often land in **object storage** and are queried with SQL engines.

**AWS:** **Amazon S3** + **AWS Glue** (catalog, ETL) + **Amazon Athena** (SQL over S3); **Amazon Redshift** for warehouse workloads; **Amazon Kinesis Data Firehose** (or **Amazon Data Firehose**) to load streams into S3 or OpenSearch.

**Other clouds (interview translation):** BigQuery, Snowflake, Azure Synapse—same **lake / warehouse** story.

### Stream analytics

For **windowed aggregations** or **CEP** over high-volume streams, use a stream processor (**Apache Flink**, **Amazon Managed Service for Apache Flink**, **ksqlDB** with Kafka) rather than overloading OLTP databases.

### Correlation IDs

* Unique identifier per request
* Propagated via headers and async messages

**Why**
* Tie logs, metrics, and traces together
* Essential for debugging distributed systems

**Best practices**
* Generate at system entry
* Never regenerate mid-flow
* Include in logs automatically

### Debugging practice (beyond dashboards)

* **Logs + trace ID:** jump from a spike in errors to a single `trace_id` and span timeline.
* **Profiling:** for CPU-bound services, language profilers (**pprof** for Go, **async-profiler** for JVM) find hot paths—not a replacement for traces.
* **Feature flags:** safely reproduce production behavior for a cohort (**AWS AppConfig** or portable vendors) without redeploying.
* **Replay:** for event-driven systems, **replay** a partition or time window into a **shadow consumer** (MSK/Kinesis) to debug without affecting live state.

### Audit and API activity

**AWS CloudTrail** records **control plane** API calls (who changed IAM, created buckets). Distinguish from application request logs (CloudWatch / ALB access logs).

## 🔗 Related

- [Topics index](../topics-index.md)
- [Data stores](./data-stores.md)
- [Messaging and async](./messaging-async.md)
- [AWS reference layout]./aws-reference-layout.md
