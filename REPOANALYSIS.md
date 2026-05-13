# api-documentation — RepoDocs
_Generated on 2026-05-11_

## Summary

### Overview
`api-documentation` is a static documentation site for PowerReviews' public-facing customer APIs (Read Services and Write Services). It is a content-only repo — Swagger/OpenAPI specs plus a MadCap Flare-generated HTML help system — that publishes to the `developers.powerreviews.com` S3 bucket fronted by CloudFront. It is the canonical public reference for merchants integrating with the PowerReviews review/Q&A platform.

### Tech Stack
| Category | Technology | Version |
|----------|-----------|---------|
| Language | HTML / JavaScript (static) | _N/A_ |
| Framework | Swagger UI (static distribution) | _Not pinned (vendored under `swagger-ui/`)_ |
| Framework | MadCap Flare WebHelp (HTML5 Top Navigation) | Build 13.3.6547.24746 (per `Default.mcwebhelp`) |
| API Spec | OpenAPI / Swagger | 2.0 (per `api-specs/*.yaml`) |
| Database | _None_ | _N/A_ |
| Build Tool | `deploy.sh` bash script (legacy) + GitHub Actions workflow | _N/A_ |
| CI/CD | GitHub Actions | `actions/checkout@master` |
| Cloud/Infra | AWS S3 + CloudFront (CloudFormation: `infra/developer-cloudfront.yaml`) | _N/A_ |

### Consumers
| Consumer | Type | How They Use It |
|----------|------|----------------|
| `developers.powerreviews.com` (public site) | External hosted asset | Site is sourced from this repo via GitHub Actions sync to S3 bucket `developers.powerreviews.com`. |
| PowerReviews merchants / integrators | External humans | Browse Swagger UI and help content to learn how to call Read and Write APIs. |
| AWS CloudFront distribution (origin `developers.powerreviews.com.s3.amazonaws.com`) | External infrastructure | Serves repo assets over HTTPS; defined in `infra/developer-cloudfront.yaml`. |
| GitHub Actions runner | CI | Performs `aws s3 sync` on every push to `master` (`.github/workflows/push.yml`). |
| Slack channel `github-token-scan` | External alerting | Notified by `secrets-scan.yml` when TruffleHog finds secrets. |

### Dependencies on Org Repos
| Repo | Reason |
|------|--------|
| readservices-b2c | Documents that service's REST API; `readservices.yaml` declares `host: readservices-b2c.powerreviews.com`. |
| write-services | Documents that service's REST API; `writeservices.yaml` declares `host: writeservices.powerreviews.com`. The repo also contains a `write-services/` subfolder. |

### External Integrations
| Service | Purpose | Integration Type |
|---------|---------|-----------------|
| AWS S3 | Deploy target (sync repo to `s3://developers.powerreviews.com`) | SDK (AWS CLI via GH Actions / `deploy.sh`) |
| AWS CloudFront | CDN distribution in front of S3 origin | SDK (CloudFormation in `infra/`) |
| AWS ACM | TLS certificate for `developers.powerreviews.com` (referenced in CloudFront template) | SDK |
| Slack (webhook) | Secret-scan failure notification via `rtCamp/action-slack-notify` | Webhook (outbound) |
| TruffleHog (`edplato/trufflehog-actions-scan`) | Scheduled GitHub-token / secret scanning | SDK (GH Action) |
| Google Fonts (`fonts.googleapis.com`) | Webfont loading in `swagger-ui/index.html` | REST |

### Async & Scheduled Work
| Channel / Job | Type | Direction | Purpose |
|--------------|------|-----------|---------|
| `secret-scan` GH Actions cron (`0 14 * * 1-5`, weekdays 14:00 UTC) | Scheduled job | N/A | Runs TruffleHog secret scan, posts to Slack on failure. |
| `deploy-docs` GH Actions on `push` to `master` | Triggered job | N/A | Syncs repo contents to S3. |

### Upgrade Alerts
| Dependency | Current Version | Issue | Severity |
|-----------|----------------|-------|----------|
| `actions/checkout` | `@master` (mutable ref, in both workflows) | Pinning to `@master` is unsupported by `actions/checkout` and is a supply-chain risk; `@master` no longer exists for newer versions. | Severe |
| `edplato/trufflehog-actions-scan` | `@master` | Action is unmaintained / archived (no recent releases); using `@master` is a supply-chain risk. | Severe |
| Swagger UI (vendored `swagger-ui/`) | Distribution copied from upstream `dist/`, version not pinned; last touched 2020 | Pre-Swagger-UI 4.x bundles have known XSS-class CVEs (e.g. CVE-2019-17495 in 3.x); files here date to the 2020-era distribution. | Critical |
| MadCap Flare WebHelp output | Generated 2020-09-25 (build 13.3.6547.24746) | Output toolchain is 5+ years stale; included `jquery.min.js` and `modernizr` shims have well-known CVEs in versions of that era. | Severe |
| CloudFront `MinimumProtocolVersion` | `TLSv1` (in `infra/developer-cloudfront.yaml`) | TLS 1.0/1.1 are deprecated by AWS; the value should be at least `TLSv1.2_2021`. | Severe |

## API Reference

This repo defines no executable APIs of its own — it publishes specs for two PowerReviews services. The OpenAPI/Swagger 2.0 specs in `api-specs/` describe:

### Read Services (`api-specs/readservices.yaml`)
- **Host:** `readservices-b2c.powerreviews.com`
- **Auth:** `apikey` query parameter (required on all endpoints)
- **Endpoints:**
  | Method | Path | Operation | Tag |
  |--------|------|-----------|-----|
  | GET | `/m/{merchantId}/l/{locale}/product/{pageIds}/snippet` | `getProductSnippetsUsingGET` | Snippets |
  | GET | `/m/{merchantId}/l/{locale}/product/{pageId}/questions` | (per spec) | Q&A |
  | GET | `/m/{merchantId}/l/{locale}/product/{pageId}/reviews` | (per spec) | Reviews |
  | GET | `/m/{merchantId}/reviews` | (per spec) | Reviews |
  | GET | `/m/{merchantId}/questions` | (per spec) | Q&A |
  | GET | `/m/{merchantId}/l/{locale}/question/{questionId}/answers` | (per spec) | Q&A |
  | GET | `/m/{merchant_id}/l/{locale}/configuration` | (per spec) | Configuration |
- **Common path/query params:** `merchantId`, `locale` (e.g. `fr_FR`), `pageId(s)`, `apikey`.
- **Response schemas:** `QueryResponse` and related (defined in same YAML).
- **Standard responses:** 200 OK / 401 Unauthorized / 403 Forbidden / 404 Not Found.

### Write Services (`api-specs/writeservices.yaml`, with `writeservices-bak.yaml` as the prior snapshot)
- **Host:** `writeservices.powerreviews.com`
- **Endpoints:**
  | Method | Path | Operation | Tag |
  |--------|------|-----------|-----|
  | POST | `/api/b2b/answer` | `submitAnswerUsingPOST` | B2B Answer |
  | POST | `/api/b2b/merchant-response` | (per spec) | B2B MerchantResponse |
  | POST | `/api/b2b/question` | `submitQuestionUsingPOST` | B2B Question |
  | GET | `/api/b2b/writereview/review_template` | `startReviewUsingGET` | B2B Write a Review |
  | POST | `/api/b2b/writereview/submit_review` | `submitReviewUsingPOST` | B2B Write a Review |
- **Common query params:** `apikey` (UUID), `f` (feature flag array), `locale`, `merchant_group_id` + `site_id` pair, `merchant_id`, `page_id`, `page_id_variant`, `unique_review_id`, `order_id`, `merchant_user_id`, `merchant_user_email`.
- **Request body schemas:** `AnswerData`, `QuestionData`, `WriteAReviewB2BPostRequest`.
- **Response schemas:** `AnswerResponse`, `QuestionResponse`, `B2BReviewData`, with shared types `BaseReviewField«object»`, `SimpleReviewField`, `CollectionReviewField`, `CompositeReviewField`, `MerchantInformation`, `ProductInformation`, `WriteAReviewB2BContextInformation`, `ErrorMessage`, `IdAndValue`.
- **Standard responses:** 200 / 201 / 401 / 403 / 404.

### Static HTML help content (`Content/`)
Not an API — supplementary topical pages including `Read API/`, `Write API/` (with iOvation, Use Cases sub-pages), `Getting Started APIs/`, `What's New/`, `reference/`, `Resources/`, and XSD schemas (`review_data_complete v{1,2,3}.xsd`, `review_data_summary v{1,2,3}.xsd`) describing the XML export feed format.

## Architecture

### System-context diagram
```
                +----------------------------------+
                |          Authors / Devs          |
                |  (push to GitHub master branch)  |
                +-----------------+----------------+
                                  | git push
                                  v
                +----------------------------------+
                |        GitHub: api-documentation |
                |  .github/workflows/push.yml      |
                |  (AWS keys in GH secrets)        |
                +-----------------+----------------+
                                  | aws s3 sync . s3://developers.powerreviews.com
                                  v
                +----------------------------------+        +-----------------------+
                |          S3 bucket               |<------>|  CloudFormation:      |
                |  developers.powerreviews.com     |        |  infra/               |
                |  (REDUCED_REDUNDANCY, public)    |        |  developer-cloudfront |
                +-----------------+----------------+        |  .yaml                |
                                  ^                         +-----------------------+
                                  | OriginAccessIdentity
                +-----------------+----------------+
                |    CloudFront distribution       |
                |  Aliases: developers.powerreviews|
                |  .com  (ACM cert us-east-1)      |
                +-----------------+----------------+
                                  | HTTPS
                                  v
                +----------------------------------+
                |       PowerReviews merchants     |
                |        (browser readers)         |
                +----------------------------------+

  Sibling scheduled job:
  .github/workflows/secrets-scan.yml  ----> TruffleHog scan ----> Slack #github-token-scan
```

### Key components
- **`api-specs/`** — Hand-maintained Swagger 2.0 YAML/JSON specs (`readservices.yaml`, `writeservices.yaml`, plus `writeservices-bak.yaml`).
- **`swagger-ui/`** — Vendored static Swagger UI bundle (`swagger-ui-bundle.js`, `swagger-ui.css`, `index.html`) modified to load `readservices.yaml`.
- **`Content/`, `Data/`, `Resources/`, `Skins/`, `Default.htm`, `Default.mcwebhelp`, `Sitemap.xml`** — Output from MadCap Flare (HTML5 Top Navigation skin, build 13.3.6547.24746, generated 2020-09-25). Provides browsable topical documentation; entry point is `Default.htm` → `Content/Home.htm`.
- **`write-services/index.html`** — Per-service landing page wired into the help nav.
- **`deploy.sh`** — Legacy bash deploy that staged content and ran `aws s3 sync`; superseded by GH Actions per README ("The old Jenkins publishing job has been disabled").
- **`infra/developer-cloudfront.yaml`** — CloudFormation defining the CloudFront distribution (alias `developers.powerreviews.com`, ACM cert ARN, S3 origin, TLSv1 minimum, default object `Default.htm`).

### Data flow
1. Author edits a YAML spec or help content and pushes to `master`.
2. GitHub Actions runs `aws s3 sync . s3://developers.powerreviews.com/ --storage-class REDUCED_REDUNDANCY --delete`.
3. CloudFront serves content with a 600-second default TTL; bucket sits behind an Origin Access Identity (`E1NTYBWDUDNWIV`).
4. End users hit `https://developers.powerreviews.com/`, land on `Default.htm`, and navigate to Swagger UI (`/swagger-ui/`) or topical pages under `/Content/`.

### CI/CD tooling
**GitHub Actions** is in use (`.github/workflows/`):
- **`push.yml`** — On push to `master`: checkout → `aws s3 sync` to deploy bucket. Credentials from `AWS_ACCESS_KEY_ID`/`AWS_SECRET_ACCESS_KEY` repo secrets.
- **`secrets-scan.yml`** — Cron `0 14 * * 1-5` (weekdays 14:00 UTC): runs `edplato/trufflehog-actions-scan@master` with `--regex --entropy=False --max_depth=1`; on failure posts to Slack channel `github-token-scan` via `rtCamp/action-slack-notify@v2.0.2`.

No build/test stages — purely deploy-on-push.

### Test architecture
No automated tests. The README documents manual local testing only: "Start a local http server in the root folder, and navigate to `<SERVER BASE>/swagger-ui/`." A 58-byte `test` file exists but is unused. The trailing `.gitignore` entry of `staging` matches the staging folder created by the legacy `deploy.sh`.

### Data model / database schema
Not applicable — no database. The repo does ship XML feed schemas in `Content/`: `review_data_complete v{1,2,3}.xsd` and `review_data_summary v{1,2,3}.xsd`, which describe the structure of PowerReviews' bulk-export XML files (versions 1/2/3 of complete and summary feeds).

### Auth & trust boundaries
- **Inbound to the docs site**: anonymous — content is public, served via CloudFront with `ViewerProtocolPolicy: redirect-to-https`, only `HEAD`/`GET` methods allowed; no auth on any path.
- **Inbound to the documented APIs (not this repo's runtime)**: per the specs, `apikey` query parameter; 401/403 responses are documented for failure.
- **Outbound (deploy path)**: GH Actions authenticates to AWS via static `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY` repo secrets (not OIDC). S3 → CloudFront uses an Origin Access Identity (`E1NTYBWDUDNWIV`).
- **Authorization model**: none on the docs themselves (public read). The S3 deploy uses `--acl public-read` (in `deploy.sh`); GH Actions deploy omits `--acl` but relies on bucket policy.

### Data ownership
- **S3 bucket `developers.powerreviews.com`** — Owner (the only writer). Contents are the rendered repo. No other org repo writes here per the file contents and IaC. Not shared with siblings.
- **CloudFront distribution** — Owner of the configuration via `infra/developer-cloudfront.yaml`.

No other datastores (no DB, no cache, no DynamoDB / Postgres / Redis).

### Deployment topology
- **Runtime**: Static assets on S3, served via CloudFront — no compute, no containers, no Lambda.
- **Scaling model**: CDN-cached static; effectively stateless and unbounded via CloudFront `PriceClass_All`.
- **Replica count / autoscale**: N/A (CDN).
- **Environments**: Single environment — production at `developers.powerreviews.com`. No staging/dev environment defined in repo.
- **Regions**: ACM cert in `us-east-1`; CloudFront is global; bucket region not specified in the template (default us-east-1 implied).

## Repo Activity
Derived from git history; current HEAD is `c0f2112`.
- **Created**: 2017-09-17 (`ae903ac` "Initial Files").
- **Last meaningful change**: 2020-09-25 (`c0f2112` "Updated Use Cases document file, per request from Corbin."). Prior content change: 2020-07-29 (`cdbd09e` nav rename to "Enterprise API"). The 2020-07 secrets-scan workflow additions are also meaningful infra changes.
- **Activity level**: 0 commits in the last 90 days. The repo has had 0 commits since 2020-09-25 — it has been effectively dormant for ~5.5 years as of 2026-05-11.
- **Hot spots**: Over the last 6 months: none — no commits. Looking back 6 months before the last commit (2020-03-25 → 2020-09-25) the most-touched files were `Sitemap.xml`, `Resources/Scripts/require.config.js`, and the MadCap regeneration artifacts (`HTML5 - Top Navigation.mclog`, `Default.mcwebhelp`, `Data/HelpSystem.xml`, `Data/HelpSystem.js`) — all churned by re-publishing the Flare output rather than by source changes.
- **Recent major changes**: _No major changes in the last 6 months._ Historically: migration from a Jenkins publishing job to GitHub Actions (Sep 2019, IT-6169), CloudFront introduction (Nov 2019, IT cf), addition of scheduled TruffleHog secret-scan workflow (Jul 2020), SSL certificate swap (Mar 2020).

---

## Revised Summary
_Revised on 2026-05-12 against commit 33a8d3e_

### Overview
`api-documentation` is the static publishing artifact for `developers.powerreviews.com` — the public OpenAPI/Swagger reference and MadCap Flare help center for PowerReviews' two customer-facing integration surfaces: the **Read Services B2C display API** (consumer storefront read path) and the **Write Services** UGC submission API (B2B review/Q&A/answer/merchant-response writes). It is a content-only repo owned by Technical Writing / Developer Experience, with no compute and no runtime dependencies — its only operational role is to be `aws s3 sync`'d to the `developers.powerreviews.com` S3 bucket on every push to `master`. Among the ~12 MadCap Flare / static doc repos in the org (`PWRDocumentation`, `Documentation-Output`, `PWRInternalDocs`, `InternalDocumentation-Output`, etc.), this is the only one that documents externally-callable customer APIs rather than internal help content.

### Tech Stack
| Category | Technology | Version |
|----------|-----------|---------|
| Language | HTML / JavaScript (static, no build) | _N/A_ |
| Framework | Swagger UI (vendored bundle) | unpinned, ~2020-era 3.x dist |
| Framework | MadCap Flare WebHelp (HTML5 Top Navigation skin) | build 13.3.6547.24746 (2020-09-25) |
| API Spec | OpenAPI / Swagger | 2.0 |
| Build Tool | `aws s3 sync` (GH Actions) / legacy `deploy.sh` | _N/A_ |
| CI/CD | GitHub Actions | `actions/checkout@master` (mutable) |
| Cloud/Infra | AWS S3 + CloudFront + ACM (CloudFormation in `infra/`) | TLS minimum `TLSv1` |

### Consumers
| Consumer | Type | How They Use It |
|----------|------|----------------|
| `developers.powerreviews.com` (CloudFront → S3) | Cloud Service | Hosts the rendered repo contents as the public developer portal. |
| PowerReviews merchants / integrators | External humans | Read API specs and integration guides. |
| GitHub Actions runner | CI System | Performs the deploy on push to `master`. |
| Slack channel `github-token-scan` | External alerting | TruffleHog secret-scan failures via `rtCamp/action-slack-notify`. |

### Dependencies on Org Repos
| Repo | Reason |
|------|--------|
| `readservices-b2c` | `api-specs/readservices.yaml` is the authoritative public contract for this Java/Spring backend (`host: readservices-b2c.powerreviews.com`); any path/param/response change there must be re-published here. |
| `write-services` | `api-specs/writeservices.yaml` (+ `writeservices-bak.yaml`) and the `write-services/` landing page are the authoritative public contract for the Java write-path service (`host: writeservices.powerreviews.com`). |
| `PWRDocumentation` / `Documentation-Output` | Sibling MadCap Flare doc pipeline for the customer help center (`help.powerreviews.com`). This repo is the developer counterpart — separate Flare project, separate S3 bucket, but shares the toolchain choice (and its staleness). |

Note: the org-summary dependency map lists only `readservices-b2c` and `write-services` for this repo, which matches the code. No other org repo writes to `s3://developers.powerreviews.com` based on the IaC and external-footprint table.

### Upgrade Alerts
| Dependency | Current Version | Issue | Severity |
|-----------|----------------|-------|----------|
| Swagger UI (vendored under `swagger-ui/`) | Unpinned 3.x-era dist, last touched 2020 | Pre-4.x Swagger UI has documented XSS-class CVEs (e.g., CVE-2019-17495); the rendered site is public and serves an attacker-controllable spec URL pattern. | Critical |
| `actions/checkout@master` (both workflows) | Mutable `@master` ref | `actions/checkout` no longer maintains a `master` branch on current majors; mutable refs are a supply-chain risk and may silently break the deploy. | Severe |
| `edplato/trufflehog-actions-scan@master` | Unmaintained third-party action pinned to `@master` | Action is effectively abandoned; org-wide this same action is in use across 70+ repos (see external-dependency table) — concentrated supply-chain exposure. | Severe |
| MadCap Flare WebHelp output (`jquery.min.js`, `modernizr`, generated JS) | 2020-09-25 generation, build 13.3.6547.24746 | 5+ year-old vendored JS shims with well-known CVE history; not patched on any cadence because the repo has zero commits since 2020. | Severe |
| CloudFront `MinimumProtocolVersion` in `infra/developer-cloudfront.yaml` | `TLSv1` | AWS has deprecated TLS 1.0/1.1; should be at least `TLSv1.2_2021`. The sibling org CloudFront module `pwr-terraform-cloudfront` (used by 20+ repos) is the modern pattern this repo should adopt. | Severe |

### Coupling Profile
| Dependency | Protocol | Frequency Pattern | Failure Mode |
|-----------|----------|-------------------|--------------|
| `readservices-b2c` (org repo) | Documentation-only / spec file | Manual, batched (whenever an author updates `readservices.yaml`) | Soft — spec drift silently misleads integrators; runtime API is unaffected. |
| `write-services` (org repo) | Documentation-only / spec file | Manual, batched | Soft — spec drift misleads integrators; runtime API is unaffected. |
| AWS S3 (`developers.powerreviews.com`) | Object store via AWS CLI | Event-triggered (every push to `master`) | Hard — failed sync means the site doesn't update; no retry, no notification beyond GH Actions UI. |
| AWS CloudFront | CDN in front of S3 origin | Per-request (viewer traffic), one-time provisioning via CFN | Soft — stale 600s TTL cache masks deploy failures briefly; no invalidation is issued by the deploy workflow. |
| AWS ACM (us-east-1) | TLS certificate, referenced by CloudFront | Startup-only (CFN deploy) | Hard — cert expiry or replacement breaks HTTPS for the entire developer portal. |
| Slack webhook (`rtCamp/action-slack-notify`) | Outbound webhook | Scheduled (on secret-scan failure only) | Soft — missed notification; no escalation. |
| TruffleHog GH Action | GH Actions invocation | Scheduled (`0 14 * * 1-5`, weekdays 14:00 UTC) | Soft — scan failure produces a Slack ping; no auto-block. |
| Google Fonts CDN (`fonts.googleapis.com` in `swagger-ui/index.html`) | sync HTTP from end-user browser | Per-request (page load) | Soft — degraded typography; no functional impact. |

No retry logic, circuit breaker, or DLQ exists anywhere — the repo has no runtime code paths to instrument.

### Architectural Notes
- **Shared infrastructure**: This repo is one of ~22 AWS CloudFront-fronted S3 properties in the org (per the external-dependency table — alongside `analytics-ui`, `moderation-ui`, `ui-library`, `ui-library-hosted-collect`, `unsubscribe-ui`, the sibling docs pipelines, etc.) but is the only one still using a hand-rolled CloudFormation template in `infra/developer-cloudfront.yaml` rather than the shared `pwr-terraform-cloudfront` Terraform module that the rest of the modern frontends consume. Consolidating onto that module would inherit the modern TLS minimum and the standardized OAI/OAC pattern.
- **Bounded-context overlaps**: The repo encodes the *external contract* for two domain concepts that have authoritative implementations elsewhere:
  - **Reviews / Snippets / Q&A response shape** — `QueryResponse` and friends in `readservices.yaml` mirror types served by `readservices-b2c` (which itself reads from `denormalization-services` / Elasticsearch). Drift here is silent.
  - **B2B review/question/answer submission shape** — `WriteAReviewB2BPostRequest`, `AnswerData`, `QuestionData`, `B2BReviewData`, `BaseReviewField«object»` etc. in `writeservices.yaml` mirror DTOs in `write-services` (Java), which in turn shares the `pwr-data-model` types with `core-data-services`, `moderation-services`, `ingestion-services`, and the rest of the UGC backbone. No automated round-trip generation exists — these YAMLs are hand-maintained, and the upstream services have evolved heavily (12+ commits to `write-services` since this repo's last touch in 2020-09-25). The `writeservices-bak.yaml` file is evidence of manual snapshotting rather than spec generation.
  - **XML feed schemas (`Content/review_data_complete v{1,2,3}.xsd`, `review_data_summary v{1,2,3}.xsd`)** — these describe the same bulk-export feed format that `core-data-content-exporter`, `outbound-syndication`, `content-publication`, and `distribution-services` actually produce. None of those services regenerate or validate against these XSDs; the contract is documentation, not enforcement.
- **Architectural evolution**: Git history shows two completed migrations and one stalled trajectory: (a) Jenkins → GitHub Actions for publishing (Sep 2019, IT-6169) and (b) direct-S3 → S3-behind-CloudFront (Nov 2019). Since then the repo has had **zero commits in 5.5 years** — the documented APIs have continued to evolve in `readservices-b2c` and `write-services` without corresponding spec updates, which is the single largest content risk on this repo. The base "Upgrade Alerts" focus on toolchain decay, but the more urgent issue is **spec/implementation drift**: any merchant integrating today against `developers.powerreviews.com` is reading 2020-era contracts. Re-anchoring requires either (1) generating Swagger from `write-services`/`readservices-b2c` at build time (modern Spring Boot springdoc-openapi pattern, already common in newer org services) and pushing the generated YAML here via CI, or (2) retiring this repo entirely and adopting the same Flare pipeline as `PWRDocumentation`/`Documentation-Output`.
