FROM node:18

WORKDIR /usr/app

COPY src/package.json .
COPY src/package-lock.json .
RUN npm install

COPY src/ .

EXPOSE 80