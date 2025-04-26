# Use official Node.js image
FROM node:20-alpine

# Set working directory inside the container
WORKDIR /hello-world-express-phk

# Copy package.json and package-lock.json first
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy rest of the application code
COPY . .

# Expose port (same as in your app)
EXPOSE 3000

# Command to run the app
CMD ["npm", "start"]
