resource "aws_security_group" "wordpress" {
vpc_id = var.aws_vpc

 ingress {
   from_port = 22
   to_port = 22
   protocol = "tcp"
   cidr_blocks = ["0.0.0.0/0"]
 }

 ingress {
   from_port = 80
   to_port = 80
   protocol = "tcp"
   cidr_blocks = ["0.0.0.0/0"]
 }

 ingress {
   from_port = 443
   to_port = 443
   protocol = "tcp"
   cidr_blocks = ["0.0.0.0/0"]
 }

 ingress {
   from_port = 0
   to_port = 0
   protocol = "tcp"
 cidr_blocks = ["0.0.0.0/0"]
 }


 resource "aws_key_pair" "ssh-key" {
   key_name = "ssh-key"
   public_key = file(var.ssh_public_key_file)
 }


 resource "aws_instamce" "wordpress" {
   ami = var.aws_ami
   instance_type = "t3.micro"
   associate_public_ip_address = true
   vpc_security_group_ids = [aws_security_group.wordpress.id]
   key_name = aws_key_pair.ssh_key.key_name
 }


 tags = {
   "name" = "Wordpress Server"
   "kind" = "Ubuntu"
   "ENV" = "Dev"
 }

 depends_on = [
   aws_key_pair.ssh_key,
   aws_security_group.wordpress
 ]



 connection {
   type = "ssh"
   host = self.public_ip
   user = "ubuntu"
   private_key = file(var.ssh_private_key_file)
 }


 provisioner "remote-exec" {
   inline = ["hostname"]
 }



 provisioner "local-exec" {
   command = "echo '[defaults]\nhost_key_checking = False\ninventory = ${var.ansible_inventory}' > ${var.ansible.config}"
 }
 provisioner "local-exec" {
   command = "echo ${self.public_ip} > ${var.ansible_inventory}"
 }
 
 provisioner "local-exec" {
   command = "ansible-playbook --private-key ${var.ssh_private_key_file} -u ubuntu ${var.ansible_playbook}"
 }
}
