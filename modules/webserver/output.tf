#Get the ID of the instance
output "aws_ami_id" {
  value = data.aws_ami.latest-amazon-linux-image
}

#Get the public IP  of the instance
output "ec2_public_ip" {
  value = aws_instance.myapp-server
}