provider "aws" {
  profile = "default"
  region = "us-east-1"
}

resource "aws_instance" "testInstances" {
   ami = "ami-0e3d652ea58740cfa"
   instance_type = "r5.large"
   subnet_id = "subnet-0f3818246efe28a23"
   vpc_security_group_ids = [
      "sg-0f779e4de779bd9c5",
   ]
   count = 2
}

resource "null_resource" "testInstances" {
   provisioner "local-exec" {
      command = join("_", aws_instance.testInstances.*.private_ip)
      interpreter = ["bash", "/home/ubuntu/clusterSetup.sh", "bigdata", "2"]
   }
   
   provisioner "local-exec" {
      when = destroy
      command = 2
      interpreter = ["bash", "/home/ubuntu/clusterClean.sh", "2"]
      on_failure = continue
   }
}