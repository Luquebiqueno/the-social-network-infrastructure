# Monitoring Module

Creates CloudWatch Log Groups for the backend, frontend, and Keycloak; an encrypted SNS alert topic; and EC2 alarms for high CPU utilization and failed status checks.

When an email is configured, AWS sends a subscription confirmation message. Alerts are not delivered until the subscription is confirmed.
