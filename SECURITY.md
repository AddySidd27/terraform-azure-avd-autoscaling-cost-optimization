# Security policy

## Reporting

Do not publish credentials, registration tokens, Terraform state, or tenant identifiers in issues or pull requests.

For a real security issue in a deployed environment, use your organization's security incident process.

## Repository rules

- Never commit `terraform.tfvars`.
- Never commit `.tfstate` files.
- Never commit saved plan files (`*.tfplan`) or generated ZIP archives.
- Rotate any credential that appears in a screenshot, terminal transcript, issue, or chat.
- Never paste registration tokens into documentation.
- Review generated Terraform plans before applying.
- Use a protected remote state backend for shared deployments.
