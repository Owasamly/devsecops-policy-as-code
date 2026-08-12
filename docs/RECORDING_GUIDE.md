# Portfolio Evidence and Recording Guide

## Recommended screenshots

Keep four final screenshots; they tell the complete story without repetition.

1. **CI overview** — the GitHub Actions run showing all three green jobs.
2. **Policy rejection** — terminal output from `make demo-fail`, with all five finding codes visible.
3. **Approved plan** — the end of `make scan`, showing zero violations and the saved report paths.
4. **Applied controls** — selected output from `make verify`, showing encryption, public-access blocking, versioning, tags, and restricted ingress.

The architecture image can be a fifth portfolio asset but should not replace proof from the running project.

## Prepare the terminal

- Use a readable font at 18–22 px.
- Hide unrelated tabs, notifications, tokens, and personal directories.
- Use a clean prompt and maximize the terminal.
- Run `clear` before each evidence command.
- Crop the final image around the command and result.

## Generate the evidence

### 1. Prove policy tests

```bash
make policy-test
```

Optional screenshot: the three passing OPA tests.

### 2. Demonstrate the blocked path

```bash
clear
make demo-fail
```

Capture the five codes:

```text
NETWORK_WORLD_INGRESS
S3_ENCRYPTION_REQUIRED
S3_PUBLIC_ACCESS_BLOCK_REQUIRED
S3_REQUIRED_TAGS
S3_VERSIONING_REQUIRED
```

### 3. Demonstrate the approved path

```bash
clear
make scan
jq . reports/policy-report.json
```

The report should be an empty JSON array.

### 4. Apply and verify locally

```bash
make apply
clear
make verify
```

After recording:

```bash
make destroy
make localstack-down
```

## Suggested video sequence

Target 45–60 seconds:

1. Show the repository structure for 3 seconds.
2. Run `make demo-fail` and pause on the five blocked findings.
3. Run `make scan` and pause on the successful policy gate.
4. Show the GitHub Actions run with all jobs green.
5. Show `make verify` or a shortened selection of its AWS API output.
6. Finish on the architecture image or README title.

Avoid recording dependency downloads or the full LocalStack startup. Those add time but do not demonstrate the security mechanism.

## Suggested filenames

```text
policy-as-code-ci-success.png
policy-as-code-deny-findings.png
policy-as-code-approved-plan.png
policy-as-code-localstack-verification.png
policy-as-code-demo.mp4
policy-as-code-architecture.png
```
