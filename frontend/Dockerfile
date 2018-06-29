FROM node:9.9.0 AS webpack

COPY . /frontend
WORKDIR /frontend/
RUN npm install
RUN npm run prod

FROM nginx:1.13.10-alpine
COPY --from=webpack /frontend/dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]

