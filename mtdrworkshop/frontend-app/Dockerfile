FROM node:18

WORKDIR /usr/src/app

COPY package*.json ./

RUN npm install

# Copy files
COPY . .

# Development
# RUN npm run dev

# Production
RUN npm run build

# Port
EXPOSE 3000
CMD ["npm", "run", "start"]