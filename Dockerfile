# Minimal dockerfile to build multi stage docker image
# Change FROM nginx to specific tag to optimize image size ex. nginx:version-alpine

## Stage 1 ##
# Use node 16 image as builder and alias it as builder
FROM node:16 as builder

# Define work directory inside docker container
WORKDIR /app
# Copy package.json and package-lock.json to work directory
COPY ./app/package*.json .
# install dependencies
RUN npm install
# Copy app to work directory, this layers changes a lot so it is done last
COPY ./app/ .
RUN npm run build

## Stage 2 ##
# Use nginx as base image to serve static files built from stage 1
FROM nginx as nginx

# If you do not want to use the default nginx
# Copy our own nginx.conf to /etc/nginx/nginx.conf inside the container
COPY ./nginx/nginx.conf /etc/nginx/nginx.conf

# Copy from Stage 1 to Stage 2's public folder where nginx will serve it
COPY --from=builder /app/build /usr/share/nginx/html
EXPOSE 80
ENTRYPOINT [ "nginx"]
CMD ["-g", "daemon off;"]
