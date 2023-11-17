terraform {
  required_providers {
    ansible = {
      source = "ansible/ansible"
      version = "1.1.0"
    }
  }
}

resource "ansible_playbook" "example" {
  playbook                = "playbook.yml"

  # Inventory configuration
  name   = var.host    # name of the host to use for inventory configuration

  # Ansible vault
  # you may also specify "vault_id" if it was set to the desired vault
  vault_password_file = "password.txt"
  vault_files = [
    "vault.yml",
  ]

  # Play control
  # Configure our playbook execution, to run only tasks with specified tags.
  # in this example, we have only one tag; "tag1".
  tags = [
    "tag1",
    "tag2"
  ]

  check_mode = false
  diff_mode  = false

  # Connection configuration and other vars
  extra_vars = {
    ansible_user = "shtech"
    ansible_ssh_private_key_file = "~/.ssh/id_rsa"
    ansible_python_interpreter = "/usr/bin/python3"
  }

  replayable = false
  verbosity  = 3 
}
