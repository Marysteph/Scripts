wget -qO - https://packages.irods.org/irods-signing-key.asc | sudo apt-key add -
echo "deb [arch=amd64] https://packages.irods.org/apt/ $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/renci-irods.list
sudo apt-get update  # this primes the system for installation

sudo apt-get install irods-icommands # installs 

iinit # initialise for log in details 
ils  # iplant version of ls

iput -rPT Documents/hello_world/test-data /iplant/home/dave_k/ # upload directory (bulk upload) directly to home directory in cyverse

icp /iplant/home/mukani/analyses/tutorial_data.csv /iplant/home/dave_k/ # iplant version of coy from one folder to another in cyverse

iget -Pf /iplant/home/dave_k/Ordered_snp_allele.csv . # download file from path in cyverse to path in curent shell

ils -l | awk '{ print $7 " " $4 }' # print the name nd size of file