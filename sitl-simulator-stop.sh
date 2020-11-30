docker stop $(docker ps -a | grep drone- | awk '{print $1}')
docker rm $(docker ps -a | grep drone- | awk '{print $1}')
docker stop simulator
docker rm simulator
