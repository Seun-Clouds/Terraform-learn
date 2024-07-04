#Get the ID of the instance
output "aws_ami_id" {
  value = module.myapp-server.aws_ami_id.id
}

#Get the public IP  of the instance
output "ec2_public_ip" {
  value = module.myapp-server.ec2_public_ip.public_ip
}