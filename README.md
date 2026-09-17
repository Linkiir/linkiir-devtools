# Linkiir Developer Tools

Development and testing tools for Linkiir Grid: data simulators, message
inspection, and load generation. These are workflow nodes you build interfaces
*with*, not adapters that connect to an external system.

A **catalog** is a package of node templates and shared libraries that one
Linkiir Grid publishes and other grids subscribe to. Subscribing adds this
content to your grid without a product upgrade.

| | |
|---|---|
| **Catalog id** | `lktool` |
| **Publisher** | Linkiir Inc |
| **Tools** | 1 |
| **Libraries** | 0 |
| **Documentation** | [https://help.linkiir.com/docs/catalogs/](https://help.linkiir.com/docs/catalogs/) |

---

## Subscribe

In Grid, open **Settings → Catalogs → Subscribe** and paste this URL:

```
https://github.com/Linkiir/linkiir-devtools
```

| Field | Value |
|---|---|
| **URL** | the address above |
| **Ref** | `main` |
| **SSH private key** | leave blank — this is a public repository, cloned anonymously |
| **Install name** | `linkiir-devtools` |

Use the install name exactly as given. Grid records it on every node built from
this catalog, so a consistent name keeps a node's origin readable when you
contact support.

Subscribing requires the **Manage catalogs** permission (Administration tier).
Full instructions, including how to review an update before applying it, are in
[the Catalogs documentation](https://help.linkiir.com/docs/catalogs/).

## What belongs here

This catalog holds tools rather than adapters. An **adapter** connects a
workflow to an external system and lives in one of the domain catalogs below. A
**tool** is used while building or testing an interface and connects to nothing
in particular — a synthetic-message generator, a message inspector, a load
harness. Because a tool is self-contained, it fits here regardless of which
protocols or vendors you integrate with, so every grid can use it without
subscribing to a domain catalog it does not otherwise need.

## Tools

| Tool | Node type | Trigger | Version | Node type id |
|---|---|---|---|---|
| **Data Simulator** | source | interval | 1.0.0 | `LKTOOL_DATA_SIMULATOR` |

### Data Simulator

Emits synthetic messages on every poll interval and pushes them onto the queue,
with the message type chosen from a dropdown. Use it to build and load-test an
interface before a live feed exists: point a transform at it, start the
workflow, and watch realistic traffic flow through.

`LKTOOL_DATA_SIMULATOR` · source node · version 1.0.0 · 7 configuration fields ·
no library

**Message types**

| Option | Produces |
|---|---|
| `HL7 v2.5.1 ADT^A01 (Admit)` | Pipe-delimited ADT admit with MSH, EVN, PID, NK1, PV1, two OBX vitals, AL1 and DG1. CR-separated segments. |
| `C-CDA R2.1 CCD` | Continuity of Care Document with a conformant header plus Allergies and Problems sections. |
| `FHIR R4 Patient` | US Core–profiled Patient resource with an MR identifier, name, telecom, gender, birth date and address. |
| `FHIR R4 Observation` | Vital-signs Observation (body weight, LOINC 29463-7) referencing the same patient. |
| `X12 5010 270 (Eligibility Inquiry)` | Full interchange — ISA/GS envelope, 005010X279A1 eligibility inquiry, GE/IEA. |
| `X12 5010 271 (Eligibility Response)` | The matching response for the same member: active coverage, co-pay and deductible benefit lines. |

**Configuration**

| Field | Default | What it does |
|---|---|---|
| Interval | `10000` | Milliseconds between batches. Lower it to raise throughput. |
| Message Type | HL7 ADT^A01 | Which message to generate. |
| Messages Per Interval | `1` | How many to emit per interval. Capped at 1000. |
| Topic | _(empty)_ | Optional queue topic. Empty uses the node's configured destination. |
| Randomize Content | `true` | Off uses a fixed patient rotation, making a run repeatable. |
| Random Seed | `0` | `0` varies each start; any other value pins the sequence for a regression test. |
| Live Mode | `true` | Off generates and counts messages without queuing them. |

**No PHI.** Every name, address, identifier and payer is invented. Three fixed
patients are rotated so repeated messages describe a stable population — an
upsert or patient-match rule needs the same MRN to recur. Because the data is
synthetic, the output is safe to share, commit and attach to a support ticket.

**Sample output** for all six message types is in
[`nodes/data_simulator/samples/`](nodes/data_simulator/samples).

**Adding a message type** means adding one entry to `samples.lua` and one option
to the Message Type dropdown in `node_config.json`. Templates are literal text
with `{{TOKEN}}` placeholders rather than grammar-built messages, so what you
read in `samples.lua` is exactly what gets queued.

## Repository layout

```
catalog.json                              catalog manifest
nodes/<slug>/node_config.json             a node definition
nodes/<slug>/*.lua                        its scripts
nodes/<slug>/samples/                     sample output for each message type
libraries/<name>/<version>/library.json   a published library version
libraries/<name>/<version>/<name>/*.lua   its modules
```

The layout matches Grid's own on-disk layout, so a pull applies no transform.

## Other Linkiir catalogs

| Catalog | Covers |
|---|---|
| [linkiir-fhir-adapters](https://github.com/Linkiir/linkiir-fhir-adapters) | FHIR adapters and FHIR tooling |
| [linkiir-ehr-adapters](https://github.com/Linkiir/linkiir-ehr-adapters) | EHR and practice management over proprietary APIs, openEHR |
| [linkiir-interop-adapters](https://github.com/Linkiir/linkiir-interop-adapters) | HL7 v2, C-CDA, IHE, HIE, public health, engine migration |
| [linkiir-payer-adapters](https://github.com/Linkiir/linkiir-payer-adapters) | X12 EDI, clearinghouses, payer APIs, pharmacy |
| [linkiir-diagnostics-adapters](https://github.com/Linkiir/linkiir-diagnostics-adapters) | labs and LIS, imaging and PACS, devices |
| [linkiir-data-adapters](https://github.com/Linkiir/linkiir-data-adapters) | relational and NoSQL databases, warehouses, BI |
| [linkiir-transport-adapters](https://github.com/Linkiir/linkiir-transport-adapters) | object storage, file transport, message brokers |
| [linkiir-ai-adapters](https://github.com/Linkiir/linkiir-ai-adapters) | AI and LLM services |
| [linkiir-notification-adapters](https://github.com/Linkiir/linkiir-notification-adapters) | chat, SMS, voice, email, paging |
| [linkiir-business-adapters](https://github.com/Linkiir/linkiir-business-adapters) | CRM, ERP, ITSM, HR, identity, scheduling |
| **linkiir-devtools** _(this one)_ | data simulators, message inspection, load generation |

## Documentation and support

Product documentation lives at
**[help.linkiir.com](https://help.linkiir.com/docs/catalogs/)** — how catalogs
work, subscribing and reviewing updates, building nodes from catalog content,
and offline delivery. This repository holds the tool content itself; it is not
the documentation site.

For a question about a specific tool, quote its node type id.

## License

Copyright © Linkiir Inc. All rights reserved.

This source is published so Linkiir Grid customers can read, audit and run it.
It is **not** open source, and no open-source licence is granted. Use of this
content is governed by your agreement with Linkiir Inc covering Linkiir Grid.
For licensing enquiries, contact Linkiir.
