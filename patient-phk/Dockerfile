# 1. Use an official Node.js runtime as the base image
FROM node:18-alpine

# 2. Set working directory inside container
WORKDIR /app

# 3. Copy package.json and package-lock.json first (for faster builds)
COPY package*.json ./

# 4. Install app dependencies
RUN npm install

# 5. Copy the rest of your application code
COPY . .

# 6. Expose the application port
EXPOSE 3001

# 7. Start the app
CMD ["node", "index.js"]