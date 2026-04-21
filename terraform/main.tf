terraform{
    required_providers {
    google = {
     source = "hashicorp/google"   
    }
    }
    backend "gcs" {
       bucket = "tfstate-authentik"
       prefix = "terraform/state"
    }
}

provider "google" {
    project = var.project
    region = var.region
}

resource "google_service_account" "sa_terraform-vm" {
    account_id = "terraform-vm"
    display_name = "Terraform VM"
}

resource "google_project_iam_member" "sa_terraform-vm_iam" {
    for_each = toset(var.iam_roles)
    project = var.project
    role = each.value
    member = "serviceAccount:${google_service_account.sa_terraform-vm.email}"
}



resource "google_compute_instance" "vm-terraform" {
    name = "vm-terraform5"
    machine_type = "e2-medium"
    zone = "northamerica-northeast1-a"
    boot_disk {
        initialize_params {
            image = "debian-cloud/debian-11"
        }
    }
    network_interface {
        network = "default"
        access_config {
        }
    }

    scheduling {
        automatic_restart = true
        on_host_maintenance = "MIGRATE"
    }

    service_account {
        email = google_service_account.sa_terraform-vm.email
        scopes = ["cloud-platform"]
    }
    metadata_startup_script = templatefile("${path.module}/scripts/startup.sh.tftpl", {
        git_repo = var.git_repo
        ssh_private_key = var.ssh_private_key
    })
}

resource "google_compute_firewall" "allow-authentik" {
    name = "allow-authentik"
    network = "default"

    allow {
        protocol = "tcp"
        ports = ["9000", "9443", "80", "443"]
    }

    source_ranges = ["0.0.0.0/0"]
    target_tags = []
}

output "authentik_ip" {
    value = google_compute_instance.vm-terraform.network_interface.0.access_config.0.nat_ip
}
