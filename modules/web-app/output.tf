output "inventory" {
  value = ansible_playbook.example.temp_inventory_file
}

output "stderr" {
  value = ansible_playbook.example.ansible_playbook_stderr
}

output "stdout" {
  value = ansible_playbook.example.ansible_playbook_stdout
}
