variable "keypair_name" {
  description = "AWS keypair name"
  type = string
  default = "Virginia Keys"
}

variable "instance_type" {
  description = "AWS instance type"
  type = string
  default = "m5.large"
}

variable "student_cidr_block" {
  description = "CIDR block allowed to connect via RDP"
  type = string
  default = "0.0.0.0/0"
}

variable "admin_cidr_block" {
  description = "CIDR block allowed to connect via WinRM"
  type = string
  default = "0.0.0.0/0"
}

variable "python_installer" {
  description = "URL of desired Python installer"
  type = string
  default = "https://www.python.org/ftp/python/3.11.2/python-3.11.2-amd64.exe"
}

variable "vscode_installer" {
  description = "URL of desired VSCode installer"
  type = string
  default = "https://code.visualstudio.com/sha/download?build=stable&os=win32-x64"
}

variable "student_count" {
  description = "Number of students; will create one box per two students, rounding up"
  type = number
}
