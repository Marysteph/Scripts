
for ((i=1;i<=100;i++));do echo foo$i; sleep 1;done 
for ((i=1;i<100;i++)); do echo foo$i; sleep 1; done

sudo adduser --home /home/<username> <username> # create use

sudo chown -R beca-09:beca-09 .ssh/ # change permissions to vm 

ssh-keygen -t rsa # generate key for successful login

# copy the .pub key from the patner into the last entry in authorised-key file.

ssh <username>@<ip_address> # way to ssh to user
ssh -i .ssh/authorized_keys beca-11@10.0.72.60

##
sudo mkdir /home/<newuser>/<.ssh>  # create a new file in users directory
sudo vi /home/<newuser>/<.ssh>/<authorized_keys> # create key file for user to successfully login

sudo usermod -aG sudo <newuser> # allow newuser to be su

# now to docker
sudo apt-get update # Update the apt package index:

sudo apt-get install apt-transport-https ca-certificates curl software-properties-common  # Install packages to allow apt to use a repository over HTTPS:

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - # Add Docker’s official GPG key

sudo apt-key fingerprint 0EBFCD88 # Verify that you now have the key with the fingerprint last 8 digits

sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" # set up the stable repository

sudo apt-get update # Update the apt package index.

sudo apt-get install docker-ce # Install the latest version of Docker CE

sudo docker run hello-world # Verify that Docker CE is installed correctly by running the hello-world image.

sudo docker run docker/whalesay cowsay "$(fortune)" # second test

sudo usermod -aG docker beca-09 # add docker to su group

docker run -ti centos # run latest centos image

docker run -ti centos:7 # run centos 7 image

docker start <container_id> # start the container saved

docker attach <container_id> # load the started container

docker commit mysoft1 centoswith # save the container as image with files and changes

docker run --volume myfirstvol:/root/newfolder -ti centos:7 # create a volume using centos
# touch /root/newfolder/docvol.txt

sudo su - # turn to root user 

cat /var/lib/docker/volumes/myfirstvol/_data/docvol.txt # view the file created in volume cmd above

docker run --volume myfirstvol:/root/newfolder2:ro -ti centos # load a read only folder/file 

# a docker file needs to be named .docker 
		# the centos base image
		FROM centos:7

		# labels
		LABEL centos.version="7"

		# apps to install

		RUN yum -y update && yum -yy install vim
		RUN useradd beca-09
		ADD <url_of_file_to_be_used> <location/where/to/be/downloaded> # will be created if non-existent

		USER beca-09
		# the working directory
		WORKDIR /home/

docker build -t vimimage .

		#entry point addition to the docker file
		
		ENTRYPOINT ["/bin/echo", "hello world!"]


docker build -t vimimagecho . # build new image

docker run vimimagecho # run new image

docker run --entrypoint "/bin/which" entrypoint ls # to modify the entrypoint executable

docker run -ti --entrypoint "/bin/bash" vimimagecho # to run the image interactively

 echo $null >Dockerfile # empty the file
 

 Rscript 100_tree.R # in the container
 
 docker rmi --force <IMAGEID> # to forcefully remove an image as well as the attached containers

docker rm $(docker ps -a -q) # Remove all stopped containers, running containers will throw an error (unless forced with --force tag) 

## to push an image into an existing 

docker login # username and password

docker build -t davekk/new_repo:0.0 . # name of repository with tags

docker push davekk/new_repo:0.0  # push it to repo

docker save -i <name_of_image>

docker load 
