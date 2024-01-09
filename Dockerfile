# Use a lightweight base image
FROM nginx:alpine

# Set the working directory to the website folder
WORKDIR /usr/share/nginx/html

# Copy the static website files into the container
COPY ./website .

# Expose the port the app runs on
EXPOSE 80

# CMD to start Nginx
CMD ["nginx", "-g", "daemon off;"]