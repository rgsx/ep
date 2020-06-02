FROM ubuntu:18.04
RUN apt -y update && apt -y install nginx && apt clean
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
