# Use a lightweight base image
FROM nginx:alpine

# Copy your website files to the nginx web server directory
COPY website/ /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Command to run the nginx server
CMD ["nginx", "-g", "daemon off;"]