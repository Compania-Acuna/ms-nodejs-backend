FROM node:20-alpine

WORKDIR /app
COPY package*.json ./
RUN npm install --production

COPY . .

EXPOSE 80

CMD ["node", "app.js"]

######## COMANDOS ########

## Comandos para construir la imagen:
# docker build -t img-nodejs-backend .

## Levantar el contenedor con un nombre específico (reemplaza "cnt-nodejs-backend" por el nombre que desees):
# docker run -d -p 80:80 --name cnt-nodejs-backend img-nodejs-backend

## Listar contenedores
# docker ps

## Detener contenedor:
# docker stop cnt-nodejs-backend

## Borrar contenedor:
# docker rm cnt-nodejs-backend
