# Optional: host InfraBri on an Azure VM

The main deployment route is now GitHub Pages; see the repository README. The instructions below are an alternative VM deployment.

A responsive, English-language portfolio for an existing Azure VM. Monochrome terminal styling, system monospace fonts and native expandable project notes. No Node.js or build step is required. Open `dist/index.html` in your browser to preview the website locally.

The content covers Azure/Terraform/Bicep hub-and-spoke labs, Linux/SSH automation, Cisco/Netmiko labs, education and IT support experience. Projects are described as learning projects, and CCNA preparation is marked as in progress.

## Included files

- `dist/index.html`: page content, styles, navigation and expandable projects.
- `Caddyfile`: configuration for infrabri.be and the www redirect.
- `compose.yaml`: Docker-based Caddy server with persistent certificate storage.
- `start-website.sh`: configuration checks and website startup.

The website has not been deployed. No Azure VM or DNS changes have been made. HTTPS becomes available after the DNS records, server and network access are configured correctly.

## GitHub repository and Azure hosting

Suggested repository name: `infrabri`.

GitHub stores the source code. The Azure VM runs the website with Docker and Caddy. For this setup, `infrabri.be` continues to point to the VM's public IP; uploading the source to GitHub does not change DNS or host the website automatically.

Keep `dist/index.html` tracked: in this project it is the website source, not generated build output. `.gitignore` excludes local credentials, Terraform state and runtime data.

After the repository has been created on your GitHub account, you can deploy from the VM instead of copying files from your Mac. Install Git if it is missing, then use the actual repository clone URL:

```bash
git clone https://github.com/S4BR1-H4RR4SS/infrabri.git
cd infrabri
sudo bash start-website.sh
```

This command assumes you are in a directory without an existing `infrabri` folder. Keep a backup of any previous deployment before replacing it. A private repository requires GitHub authentication; use a credential manager or SSH rather than putting a token inside the clone URL.

Before running the startup script, complete the DNS, network and Docker steps below. For later updates on the VM:

```bash
cd ~/infrabri
git pull --ff-only
sudo docker compose up -d
sudo docker compose exec website caddy validate --config /etc/caddy/Caddyfile --adapter caddyfile
sudo docker compose exec website caddy reload --config /etc/caddy/Caddyfile --adapter caddyfile
```

If Git reports local changes, review them before pulling. Do not force-reset the working directory. Commit website changes in your development checkout and push them to GitHub; use the VM as the deployment checkout.

## 1. Check the existing Azure VM

This guide assumes an existing Ubuntu VM with SSH access. Find its current public IPv4 address in the Azure portal; do not reuse an old lab address without checking it.

Confirm that the public IP resource uses a static address and that the VM is running. Allow inbound TCP ports 80 and 443 in the applicable Azure Network Security Group. Preserve existing rules and check for higher-priority deny rules. Restrict SSH port 22 to your own IP where possible. Do not add a broad Any/Any rule.

If Apache, Nginx or another container already uses ports 80/443, integrate this site with that server or deliberately free those ports. The startup script does not stop existing services.

## 2. Point infrabri.be to the VM

Add the following records at the DNS provider responsible for your active nameservers. This may be different from the company where you bought the domain.

| Type | Name/host | Value | TTL |
|---|---|---|---|
| A | `@` or blank | Your VM's current public IPv4 address | 3600 |
| CNAME | `www` | `infrabri.be` | 3600 |

An A record contains an IPv4 address, not a URL or hostname. Replace only conflicting web records for these names. Preserve MX and TXT records used for email and verification. Remove an old AAAA record only if no working IPv6 web server uses that address. If you use Cloudflare, use `DNS only` during this initial setup so domain validation reaches the VM directly.

Check from your Mac:

```bash
dig +short infrabri.be A
dig +short www.infrabri.be CNAME
dig +short www.infrabri.be A
dig +short infrabri.be AAAA
```

Wait until both web names resolve to the correct server. DNS updates depend on caches and TTL values and may not appear everywhere immediately.

## 3. Install Docker on Ubuntu if needed

For a new installation, follow the official [Docker Engine on Ubuntu guide](https://docs.docker.com/engine/install/ubuntu/), under “Install using the apt repository”. Install Docker Engine and the Compose plugin. This route uses the packages `docker-ce`, `docker-ce-cli`, `containerd.io`, `docker-buildx-plugin` and `docker-compose-plugin`.

If Docker is already installed, check it before replacing anything:

```bash
sudo docker version
sudo docker compose version
```

The commands below use `sudo`; adding your account to the Docker group is unnecessary.

## 4. Copy the website from your Mac

Extract the ZIP file. Open Terminal in the directory containing the extracted `infrabri` folder and fill in your own values:

```bash
VM_IP='YOUR_CURRENT_PUBLIC_IPV4'
VM_USER='YOUR_VM_USERNAME'
KEY_PATH="$HOME/.ssh/vmkey"

scp -i "$KEY_PATH" -r infrabri "$VM_USER@$VM_IP:~/"
ssh -i "$KEY_PATH" "$VM_USER@$VM_IP"
```

Use the SSH key that belongs to this VM and adjust the example path if needed. Verify an unfamiliar or changed host key through a trusted channel before accepting it. Never publish private keys, `.tfstate` files or secrets in `dist/`.

## 5. Start the website on the VM

Run these commands inside your SSH session after Docker and DNS are ready:

```bash
cd ~/infrabri
sudo bash start-website.sh
sudo docker compose logs --tail=80 website
```

Caddy requests and renews HTTPS certificates. TCP ports 80 and 443 must be reachable, and both DNS names must point to the server. An active guest firewall must also permit web traffic. Docker-published ports can bypass UFW rules; use the Azure NSG as an explicit network boundary. Do not disable the firewall to resolve a connectivity problem.

The `caddy_data` volume stores certificates. Avoid `docker compose down -v` during routine updates because it deletes this storage.

## 6. Verify from your Mac

```bash
curl -I http://infrabri.be
curl -I https://infrabri.be
curl -I https://www.infrabri.be
```

Expected results: HTTP redirects to HTTPS, the main site returns HTTP 200, and www redirects to `https://infrabri.be`. Also open the site on your phone and check navigation and expandable project details.

| Symptom | Check first |
|---|---|
| Wrong website | DNS, old A/AAAA records, registrar parking and browser cache |
| Timeout | VM status, NSG, guest firewall and ports 80/443 |
| Certificate error | Both DNS names, reachability, Caddy logs and any CAA records |
| “Port is already allocated” | An existing web server or container using ports 80/443 |
| “Permission denied (publickey)” | VM username, key path and matching public key |

## Edit the website

All content and styles are in `dist/index.html`. Project entries use native HTML `<details>` elements; the first is expanded by default. The navigation links scroll to page sections. The displayed shell commands are visual headings, not an executable terminal.

The design uses only black, grey and white. It has no trackers, cookies, external fonts, JavaScript dependencies or forms.

Public contact details and repository URLs have not been supplied. Add your verified email address, GitHub and LinkedIn links in the section with `id="next"` when ready. Review education and project descriptions before publishing.

For content updates, copy the changed `dist/index.html` into the same folder on the VM; Caddy serves it immediately. After changing `Caddyfile`, validate and reload it:

```bash
sudo docker compose exec website caddy validate --config /etc/caddy/Caddyfile --adapter caddyfile
sudo docker compose exec website caddy reload --config /etc/caddy/Caddyfile --adapter caddyfile
```

The container uses the official `caddy:2-alpine` tag. Update it deliberately with `sudo docker compose pull` followed by `sudo docker compose up -d`. Keep a copy of the previous configuration so you can restore it.

## Official documentation

- [Azure VM custom domains](https://learn.microsoft.com/en-us/azure/virtual-machines/custom-domain)
- [Caddy automatic HTTPS](https://caddyserver.com/docs/automatic-https)
- [Docker Engine on Ubuntu](https://docs.docker.com/engine/install/ubuntu/)

Prepared on 23 September 2026. No Azure resources were created and no billable infrastructure changes were made.
