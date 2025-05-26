# tailscale-cert-services
manage common services with tailscale certificates

### Primary script
- generate-tailscale-cert.sh
  - Usage: `./generate-tailscale-cert.sh [--schedule-renewal]`
    - `--schedule-renewal`: Schedules a cron job to renew the certificate monthly at 4:00 am.

### Service specific scripts
- proxmox-cert.sh --> Runs Tailscale cert generation and updates Proxmox to use the cert, then schedules renewal for Proxmox.
  - Usage: `./proxmox-cert.sh`
    - No parameters. 
- syncthing-cert.sh --> 
  - Usage: `./syncthing-cert.sh`
    - No parameters.

### Renewal scheduling script
- schedule-renewal.sh
  - Usage: `./schedule-renewal.sh [--tailscale|--proxmox]`
    - `--tailscale`: Schedules renewal for the Tailscale certificate only.
    - `--proxmox`: Schedules renewal for the Tailscale certificate and updates Proxmox with it.

---

this project is used by [tailmox](https://github.com/willjasen/tailmox) to setup tailscale certificates for proxmox hosts
