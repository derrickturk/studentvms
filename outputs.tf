output "public_ip" {
  value = aws_instance.studentvm[*].public_ip
}

output "public_dns" {
  value = aws_instance.studentvm[*].public_dns
}

output "admin_password" {
  description = "Windows Administrator account password"
  value       = resource.random_string.admin_password.result
}

output "student_config" {
  description = "Student machine assignment, username, passwords"
  value = flatten([for i, ss in local.machine_students :
    [for s in ss :
      {
        public_dns   = aws_instance.studentvm[i].public_dns
        name         = s.name
        password     = resource.random_string.student_password[i].result
        machine_name = aws_instance.studentvm[i].tags.Name
      }
    ]
  ])
}
