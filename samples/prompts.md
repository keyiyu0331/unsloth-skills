# Test prompts

Use these word for word for every model, so the runs can be compared. Run each skill twice:
- **(a)** the natural prompt, which tests whether the model picks the skill by itself;
- **(b)** the same prompt starting with `@skill-name`, which forces the skill to load and tests whether the model can carry it out.

## csv-dashboard
Attach `samples/sales.csv`, or paste its contents after the prompt.

- (a) `Here's my sales data. Can you build me a dashboard showing how revenue changes over time and which region sells the most?`
- (b) `@csv-dashboard Here's my sales data. Can you build me a dashboard showing how revenue changes over time and which region sells the most?`

## regex-workbench
Paste `samples/access.log` after the prompt.

- (a) `I need a regex that pulls the IP, user, timestamp, HTTP method, path and status code out of these log lines. The comment line and the malformed line must not match.`
- (b) `@regex-workbench I need a regex that pulls the IP, user, timestamp, HTTP method, path and status code out of these log lines. The comment line and the malformed line must not match.`
