FROM node:18
WORKDIR /phk_app
COPY . .
RUN npm install
CMD ["npm", "start"]
