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
| **Tools** | 0 |
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

## Contents

This catalog is registered and reserved, but **no tools have been published to
it yet**. Grid will refuse a subscribe until it holds at least one node or
library, so there is nothing to add to your grid from here today.

The first tool planned for this catalog is a **Data Simulator** — a source node
that emits synthetic HL7 v2, X12, CDA, and FHIR messages on a timer, with the
message type chosen from a dropdown, for building and load-testing interfaces
without a live feed.

Watch this repository to be notified when it ships, or talk to your Linkiir
contact.

## Repository layout

```
catalog.json                              catalog manifest
nodes/<slug>/node_config.json             a node definition
nodes/<slug>/*.lua                        its scripts
nodes/<slug>/samples/                     de-identified sample messages
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
