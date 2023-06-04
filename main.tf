provider "google" {
  credentials = file("./ninth-beacon-388117-d7f8eeedc1e1.json")
  #credentials = "${var.google_cred}"
  project     = "ninth-beacon-388117"
  region      = "us-central1"
}
###############################################################
variable "my_secret_pub" {
  description = "My pub secret value"
}

variable "my_secret_pvt" {
  description = "My pvt secret value"
}

#variable "google_cred" {
#  description = "My google cred value"
#}
##########################################################################################


resource "google_compute_address" "static-ip-address" {
  name   = "gke-ip"
  region = "us-central1"
  #network_tier = "STANDARD"
}


resource "google_compute_instance" "default" {
  count         = 1
  name         = "test001-${count.index + 2}"
  machine_type = "n1-standard-1"
  zone         = "us-central1-c"

  tags = ["testing"]

  boot_disk {
    initialize_params {
      image = "rhel-cloud/rhel-8"
      size ="20"
    }
  }

  // Local SSD disk
  scratch_disk {
    interface = "SCSI"
  }

  network_interface {
    network = "default"
    access_config {
      nat_ip = "${google_compute_address.static-ip-address.address}"
    }
  }
  
    provisioner "remote-exec" {
    on_failure = continue
    connection {
        type     = "ssh"
        timeout  = "5m"
        user     = "gcp"
        host = "${google_compute_address.static-ip-address.address}"
#        host = "${google_compute_address.static-ip-address[count.index].address}"
        #private_key = "${file("./gcp.pem")}"
	private_key = "${var.my_secret_pvt}"
    }
    inline=[
      "sleep 5",
      "sudo yum update -y"
      ]
  }

  metadata = {
    ssh-keys = "gcp:${var.my_secret_pub}"
	#ssh-keys = "gcp:${file("./gcp.pub")}"
  }
  metadata_startup_script = "echo hi > /test.txt"
}


resource "local_file" "inventory" {
  content = <<-EOT
    ${join("\n", [google_compute_address.static-ip-address.address])}
  EOT

  filename = "inventory.ini"
}

resource "null_resource" "ansible_provisioner" {
  provisioner "local-exec" {
    command = <<-EOT
      ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i inventory.ini ./Ansible/install_java.yml -u gcp --private-key="${var.my_secret_pvt}"
    EOT
  }
  depends_on = ["local_file.inventory", "google_compute_address.static-ip-address", "google_compute_instance.vm_instance"]
}
