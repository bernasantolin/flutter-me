FROM node:20-alpine AS builder

WORKDIR /app

COPY package.json package-lock.json ./

RUN npm install

COPY . .

RUN npm run build

FROM nginx:alpine AS runner 

# WORKDIR /usr/share/nginx/html
WORKDIR /app

RUN rm -rf ./*

# Copy built artifacts from the builder stage
COPY --from=builder /app/.next /usr/share/nginx/html/.next
COPY --from=builder /app/public /usr/share/nginx/html/public
COPY --from=builder /app/package.json /usr/share/nginx/html/package.json

# Install Node.js in the Nginx container to run the app
RUN apk add --no-cache nodejs npm

# Install necessary packages for running Next.js
RUN npm install --prefix /app

COPY nginx.conf /usr/nginx/nginx.conf

EXPOSE 4000

CMD ["npm", "start"]
