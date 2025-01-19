# Stage 1: Base stage with Node.js Alpine image
FROM node:20-alpine AS builder

# Set the working directory for subsequent instructions
WORKDIR /builder

# Copy dependencies files first
COPY package.json package-lock.json ./ 

# Install dependencies
RUN npm install

# Copy the rest of the application code
COPY . .

# Build the application
RUN npm run build

# Stage 2: Runner stage starts from the nginx:alpine image
FROM nginx:alpine AS runner 

# Set the working directory in the container
WORKDIR /usr/share/nginx/html

# Remove the default Nginx static assets
RUN rm -rf ./*

# Copy built artifacts from the builder stage
COPY --from=builder /builder/.next /usr/share/nginx/html/.next
COPY --from=builder /builder/public /usr/share/nginx/html/public
COPY --from=builder /builder/package.json /usr/share/nginx/html/package.json
COPY --from=builder /builder/package-lock.json /usr/share/nginx/html/package-lock.json
COPY --from=builder /builder/.next/static /usr/share/nginx/html/.next/static

# Copy the Nginx configuration file
COPY nginx.conf /usr/nginx/nginx.conf

# Install Node.js in the Nginx container to run the app
RUN apk add --no-cache nodejs npm

# Install necessary packages for running Next.js
RUN npm install --prefix /usr/share/nginx/html

# Expose ports
EXPOSE 80 4000

# Start both Nginx and the Next.js app
CMD ["/bin/sh", "-c", "npm start --prefix /usr/share/nginx/html & nginx -g 'daemon off;'"]