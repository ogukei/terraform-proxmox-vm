
# https://pve.proxmox.com/wiki/Cloud-Init_Support
# wget https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img
# qm create 9000 --memory 2048 --net0 virtio,bridge=vmbr0
# qm importdisk 9000 noble-server-cloudimg-amd64.img local-lvm
# qm set 9000 --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-9000-disk-0
# qm set 9000 --ide2 local-lvm:cloudinit
# qm set 9000 --boot order=scsi0
# qm set 9000 --serial0 socket --vga serial0
# qm set 9000 --name template-ubuntu-server-24.04
# qm template 9000

terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.1-rc6"
    }
  }
}

provider "proxmox" {
  pm_api_url = var.pm_api_url
  pm_api_token_id = var.pm_api_token_id
  pm_api_token_secret = var.pm_api_token_secret
  pm_tls_insecure = true
}

resource "proxmox_vm_qemu" "default" {
  name = "proxima"
  target_node = "alpha-centauri"
  clone = "template-ubuntu-server-24.04"

  cpu_type = "host"
  sockets = 1
  cores = 4
  memory = 4096
  scsihw = "virtio-scsi-single"
  boot = "order=scsi0"

  serial {
    id = 0
  }

  disks {
    scsi {
      scsi0 {
        disk {
          storage = "local-lvm"
          size    = "32G"
          iothread = true
        }
      }
    }
    ide {
      ide2 {
        cloudinit {
          storage = "local-lvm"
        }
      }
    }
  }

  network {
    id = 0
    model = "virtio"
    bridge = "vmbr3"
  }

  ipconfig0 = "ip=10.10.2.5/24,gw=10.10.2.1"
  nameserver = "1.1.1.1 8.8.8.8"

  ciuser = var.ci_username
  cipassword = var.ci_password
  sshkeys = var.ci_sshkeys
}
