# InfraBri

Sabri Harrass's personal portfolio: Azure, Terraform, Bicep, Linux and networking. An English-language website with a monochrome terminal design.

## Website

All website content and styling live in `dist/index.html`. Open this file in a browser for a local preview. There is no build step, package installation, external font or JavaScript dependency. Projects use native expandable HTML details.

The portfolio presents learning projects and IT support experience. Cisco CCNA is marked as preparation in progress.

## Publish with GitHub Pages

1. Push this repository to your GitHub account using the `main` branch. A public repository supports Pages on GitHub Free; private repository support depends on your GitHub plan.
2. Open the repository's **Settings → Pages**. Under **Build and deployment → Source**, select **GitHub Actions**.
3. Open **Actions → Deploy InfraBri to GitHub Pages → Run workflow**, choose `main`, and run it. You can also trigger publication by pushing a new commit to `main` after Pages is enabled.
4. Wait for the deployment to succeed. The workflow's deployment result and **Settings → Pages** show the actual published URL.

The workflow in `.github/workflows/pages.yml` publishes only `dist/`. Documentation and server configuration remain in the repository and are not part of the deployed website. Subsequent pushes to `main` deploy automatically.

The Pages URL will normally follow `https://S4BR1-H4RR4SS.github.io/infrabri/` when the repository is named `infrabri`. Use the deployment URL shown in GitHub Pages settings as authoritative.

## Connect infrabri.be

First get the default Pages site working. Then add `infrabri.be` under **Settings → Pages → Custom domain** and save it **before changing DNS**.

At the DNS provider managing your active nameservers, set:

| Type | Name | Value |
|---|---|---|
| A | `@` | `185.199.108.153` |
| A | `@` | `185.199.109.153` |
| A | `@` | `185.199.110.153` |
| A | `@` | `185.199.111.153` |
| CNAME | `www` | `S4BR1-H4RR4SS.github.io` |

The CNAME target must not contain `https://` or a repository path. Replace conflicting web A/CNAME records, and remove obsolete web AAAA records if they still point elsewhere. Keep email MX and TXT records. Do not keep an Azure VM address in the apex A records for this Pages setup.

Once GitHub confirms DNS and the certificate is ready, enable **Enforce HTTPS**. DNS propagation and HTTPS availability can take time. For an Actions deployment, the custom domain is configured in Pages settings; a repository `CNAME` file is not used.

The domain requires separate DNS configuration. Follow the current official [GitHub custom domain instructions](https://docs.github.com/en/pages/configuring-a-custom-domain-for-your-github-pages-site/managing-a-custom-domain-for-your-github-pages-site) if the provider's interface differs.

## Edit and update

Change `dist/index.html`, commit the change and push to `main`. Check the resulting Actions run before considering the update published.

Navigation uses in-page anchors, so the same file works at a project Pages URL and a custom domain. The shell commands on the page are visual headings, not an executable terminal.

Verified contact details and repository links can be added to the section with `id="next"`. Do not commit credentials or Terraform state; `.gitignore` excludes common local secrets and state files.

## Optional Azure hosting

The original `Caddyfile`, `compose.yaml` and `start-website.sh` remain available if you later choose to host on a VM. See [the Azure hosting guide](docs/AZURE_HOSTING.md). GitHub Pages does not use these files or require a VM.

## Documentation

- [GitHub Pages workflows](https://docs.github.com/en/pages/getting-started-with-github-pages/using-custom-workflows-with-github-pages)
- [GitHub Pages publishing sources](https://docs.github.com/en/pages/getting-started-with-github-pages/configuring-a-publishing-source-for-your-github-pages-site)
- [Custom domain configuration](https://docs.github.com/en/pages/configuring-a-custom-domain-for-your-github-pages-site/managing-a-custom-domain-for-your-github-pages-site)
