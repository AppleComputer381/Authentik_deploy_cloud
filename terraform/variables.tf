variable "project" {
    type = string
    default = "test-authentik"
}

variable "region" {
    type = string
    default = "northamerica-northeast1"
}

variable "iam_roles" {
    type = list(string)
    default = [
        "roles/compute.instanceAdmin",
        "roles/storage.objectAdmin",
        "roles/iam.serviceAccountUser",
        
    ]
}

variable "git_repo" {
    type = string
    default = ""
}

variable "ssh_private_key" {
    type = string
    default = ""
}
