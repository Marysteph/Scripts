# the ubuntu base image
		FROM ubuntu:18.04

		# labels
		LABEL ubuntu.version="18.04"

		# apps to install
		
		RUN useradd beca-09
		RUN apt-get -y update && apt-get install -yy tzdata && apt-get -yy install r-base && apt-get -yy install vim
		#RUN package.install(ape)
		# Set the timezone.
		RUN R -e "install.packages('ape', repos = 'http://cran.us.r-project.org')" 
		ADD https://raw.githubusercontent.com/davekk/summary_r_scripts/master/100_tree.R /home/
		RUN chmod 755 /home/100_tree.R && touch /home/hundred_trees.nh && chmod 777 /home/hundred_trees.nh

		USER beca-09
		# the working directory
		WORKDIR /home/
		
		#entry point addition to the docker file
		
		ENTRYPOINT ["/bin/bash"]
# RUN apk add --no-cache tzdata

docker build -t my-r-file . 

docker run -ti my-r-file

# 