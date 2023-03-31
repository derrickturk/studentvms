output "public_ip" {
  value = "${aws_instance.studentvm.public_ip}"
}

output "public_dns" {
  value = "${aws_instance.studentvm.public_dns}"
}

output "admin_password" {
  description = "Windows Administrator account password"
  value = resource.random_string.admin_password.result
}

output "student_username" {
  description = "Student username"
  value = "Student1"
}

output "student_password" {
  description = "Student password"
  value = resource.random_string.student_password.result
}
