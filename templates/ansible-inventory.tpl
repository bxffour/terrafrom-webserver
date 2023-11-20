[nodes]
%{ for node in nodes ~}
${node}
%{ endfor ~}

[nodes:vars]
ansible_ssh_private_key_file=${ssh_priv_key}
ansible_user=${ansible_ssh_user}
