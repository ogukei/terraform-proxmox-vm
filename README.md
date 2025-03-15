# terraform-proxmox-vm  
Minimal Terraform Setup for Proxmox VMs

## Setup

1. Install Terraform  
   For macOS, run the following command:
   ```bash
   brew install terraform
   # Terraform v1.5.7 on darwin_arm64
   ```

2. Create a Terraform User on Proxmox  
   On your Proxmox server, execute the following commands to create a dedicated role and user:
   ```bash
   pveum role add TerraformProv -privs "Datastore.AllocateSpace Datastore.AllocateTemplate Datastore.Audit SDN.Use Sys.Modify VM.Allocate VM.Audit VM.Config.CDROM VM.Config.CPU VM.Config.Cloudinit VM.Config.Disk VM.Config.HWType VM.Config.Memory VM.Config.Network VM.Config.Options VM.Console VM.Monitor VM.PowerMgmt"
   pveum user add terraform-prov@pve --password <password>
   pveum aclmod / -user terraform-prov@pve -role TerraformProv
   ```
   https://registry.terraform.io/providers/Terraform-for-Proxmox/proxmox/latest/docs

3. Issue Proxmox API Tokens  
   In the Proxmox Web interface, navigate to Datacenter > Permissions > API Tokens and generate the required tokens.

4. Create VM Template  
   Follow the steps below (for more details, see https://pve.proxmox.com/wiki/Cloud-Init_Support):
   ```bash
   wget https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img
   qm create 9000 --memory 2048 --net0 virtio,bridge=vmbr0
   qm importdisk 9000 noble-server-cloudimg-amd64.img local-lvm
   qm set 9000 --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-9000-disk-0
   qm set 9000 --ide2 local-lvm:cloudinit
   qm set 9000 --boot order=scsi0
   qm set 9000 --serial0 socket --vga serial0
   qm set 9000 --name template-ubuntu-server-24.04
   qm template 9000
   ```

5. Configure Terraform Variables  
   Create a `terraform.tfvars` file in the repository root directory with the following content:
   ```hcl
   pm_api_url = "http://example.com/api2/json"
   pm_api_token_id = "<token-id>"
   pm_api_token_secret = "<token-secret>"

   ci_username = "user"
   ci_password = "<password>"
   ci_sshkeys = "ssh-ed25519 AAAAC3Nz ..."
   ```

6. Customize the Terraform Configuration  
   Edit `main.tf` to suit your environment. In particular, update the network bridge configuration (e.g., `vmbr3`) to match your setup.

## Environment Details

- Terraform: v1.5.7 (darwin_arm64)
- Proxmox Virtual Environment: 8.2.2
- Hardware: MINISFORUM MS-01 Core i9-13900H, 32GB RAM, 1TB SSD
- pfSense: 2.7.2-RELEASE (VM)
