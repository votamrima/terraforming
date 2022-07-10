#

variable "proxmox_api_url" {
  type = string
}

variable "proxmox_api_token_id" {
  type = string
}
variable "proxmox_api_token_secret" {
  type      = string
  sensitive = true
}

source "proxmox" "centos8-packer" {
  proxmox_url = "${var.proxmox_api_url}"
  username    = "${var.proxmox_api_token_id}"
  token    = "${var.proxmox_api_token_secret}"
  #password    = "${var.proxmox_api_token_secret}"

  insecure_skip_tls_verify = true

  node  = "proxmox"
  vm_id = "108"
  vm_name = "centos8-packer"
  template_description = "centos8-packer description"

  #iso_file         = "local:iso/CentOS-Stream-8-x86_64-20220316-boot.iso"
  iso_file         = "ocp1:iso/CentOS-Stream-8-x86_64-latest-dvd1.iso"

  iso_storage_pool = "local"
  unmount_iso      = true

  qemu_agent = true

  scsi_controller = "virtio-scsi-pci"

  disks {
    disk_size         = "15G"
    format            = "vmdk"
    storage_pool      = "ocp1"
    storage_pool_type = "directory"
    type              = "virtio"
  }

  cores = "2"

  memory = "4096"

  network_adapters {
    model = "virtio"
    bridge = "vmbr0"
    firewall = "false"
   } 

  cloud_init              = true
  cloud_init_storage_pool = "ocp1"

  boot_command = [
    "<tab><bs><bs><bs><bs><bs>text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ks.conf<enter><wait><enter>"
  ]
  #guest_os_type          = "RedHat_64"
  boot      = "c"
  boot_wait = "5s"

  http_directory = "http" 
  #http_bind_address = "192.168.241.157"
  #http_port_min = 8080

  ssh_username = "admin"
  #ssh_private_key_file = "/home/seymur/.ssh/id_rsa"
  ssh_private_key_file = "~/.ssh/id_rsa"
  ssh_password = "admin"
  ssh_port = 22
  ssh_timeout = "30m"

}

build {
    source "proxmox.centos8-packer" {
        name = "centos8-packer"
    }

    provisioner "shell" {
      inline = [
        "echo Installing Updates",
        "yum update -y",
        "yum install -y cloud-init qemu-guest-agent cloud-utils-growpart gdisk",
      ]

      only = ["proxmox"]
    }
}