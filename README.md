## using_terraform
This repository is the outcome of my study of Terraform, I have been using it for a while now so I am going to start and publish some examples of what I have been creating at home on Azure during the journey towards the certification

### Connect_VNets

This was a little exercise into creating a project that tested my abilities to create a project that could be used by anyone and everyone to show what can be done with terraform.

This project builds two Vnets one named Infra and one named web, adds a subnet into each of the vnets, then creates the Vnet peerings between the two vnets allowing the traffic to flow between the two vnets. To test that this is happening two Centos VM's are created one with a Public IP (no security is created).  Outputs are given that will give you an IP to SSH too and the Ip to ping from the server you have logged onto to teh server with no public ip. 

### Create_Jenkins_Server

I followed along with labs created by Michael Levan on the Cloud skills Devops course, he created a jenkins server and then ran the install code. Ive just combined it all under one roof here, I did for the exercise. You will have to stage the "installjenkins.sh" in a public repo, you can use it from where it is, but I wont check it works all the time unless I have to use it or update it later.

Michaels labs are great, very informatative, hes just started a podcast called Head In the Clouds that promises to be good. https://open.spotify.com/show/3Ffj8BXSOLljLL4vF4fkNC