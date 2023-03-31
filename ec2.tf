locals {
  machine_count = ceil(var.student_count / 2)

  machine_students = { for i in range(local.machine_count) :
    i =>
    [for j in range(i * 2, min(var.student_count, (i + 1) * 2)) :
      {
        index    = j
        name     = "Student${j + 1}"
        fullname = "Student ${j + 1}"
      }
    ]
  }
}

resource "random_string" "admin_password" {
  length = 32
}

resource "random_string" "student_password" {
  count   = var.student_count
  length  = 12
  special = false
}

data "aws_ami" "latest_windows" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["Windows_Server-2022-English-Full-Base-*"]
  }
}

resource "aws_instance" "studentvm" {
  count = local.machine_count

  ami                    = data.aws_ami.latest_windows.id
  instance_type          = var.instance_type
  key_name               = var.keypair_name
  vpc_security_group_ids = ["${aws_security_group.studentvm.id}"]

  tags = {
    Name  = "studentvm${count.index}"
    Group = "studentvms"
  }

  connection {
    host     = self.public_ip
    port     = 5986
    type     = "winrm"
    user     = "Administrator"
    password = random_string.admin_password.result
    insecure = true
    https    = true
  }

  provisioner "file" {
    destination = "setup.ps1"
    source      = "setup.ps1"
  }

  provisioner "file" {
    destination = "user.ps1"
    source      = "user.ps1"
  }

  provisioner "remote-exec" {
    inline = concat(
      [
        "powershell.exe -ExecutionPolicy ByPass -File setup.ps1 -python_installer \"${var.python_installer}\" -vscode_installer \"${var.vscode_installer}\"",
        "powershell.exe Remove-Item setup.ps1",
      ],
      [
        for s in local.machine_students[count.index] :
        "powershell.exe -ExecutionPolicy ByPass -File user.ps1 -username ${s.name} -password \"${random_string.student_password[s.index].result}\" -userfull \"${s.fullname}\""
      ],
      "powershell.exe Remove-Item user.ps1",
    )
  }

  # see https://gist.github.com/RulerOf/10af91c7fa9e5a951467b94f712d8d9f
  user_data = <<-EOF
    <powershell>
    net user Administrator "${random_string.admin_password.result}"
    winrm set winrm/config/service/auth '@{Basic="true"}'
    $Cert = New-SelfSignedCertificate -CertstoreLocation Cert:\LocalMachine\My -DnsName "studentvm"
    Enable-PSRemoting -SkipNetworkProfileCheck -Force
    Get-ChildItem WSMan:\Localhost\listener | Where -Property Keys -eq "Transport=HTTP" | Remove-Item -Recurse
    New-Item -Path WSMan:\LocalHost\Listener -Transport HTTPS -Address * -CertificateThumbPrint $Cert.Thumbprint -Force
    New-NetFirewallRule -DisplayName "Windows Remote Management (HTTPS-In)" -Name "Windows Remote Management (HTTPS-In)" -Profile Any -LocalPort 5986 -Protocol TCP
    </powershell>
  EOF
}

resource "aws_security_group" "studentvm" {
  name        = "studentvm"
  description = "RDP and WinRM from specified CIDR block"

  # RDP
  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = [var.student_cidr_block]
  }

  # WinRM (HTTP)
  ingress {
    from_port   = 5986
    to_port     = 5986
    protocol    = "tcp"
    cidr_blocks = [var.admin_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
