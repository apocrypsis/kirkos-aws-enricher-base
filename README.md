# AWS Base Enricher

This repo contains Vector VRL transforms for performing basic enrichment of AWS logs for use in downstream detection rules. It is intended to be one part of a larger detection pipeline.

It parses and normalises logs into standard JSON, and extracts important fields out to an `_intel` key at the root of the object. 

## Why a custom `_intel` field? Why not normalise to ECS or OCSF?

There are several industry standards for log normalisation, e.g., Elastic Common Schema (ECS), Splunk Common Information Model (CIM), OpenTelemetry Semantic Conventions (OTel SemConv). However, many of them tend to lean towards a specific vendor's products, so normalising to one format will cause rules written for other platforms to fail without additional translation. Most schemas also tend to be specialised for endpoint telemetry, with support for platforms such as cloud bolted on later. In contrast, the Open Cybersecurity Schema Framework (OCSF) aims to be vendor- and platform-agnostic, but suffers from the shortcoming that OCSF-formatted data isn't easy to query due to deep-nested arrays and objects. 

Based on these identified shortcomings, we instead add a custom private field. This retains the original log format and ensures that existing detection rules continue working regardless of platform. The new field simply enables additional rules.

