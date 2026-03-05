# Stage 1 : Build Flutter Web
FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app
COPY pubspec.* ./
RUN flutter pub get
COPY . .
# On crée le .env à partir des arguments de build pour Railway
ARG API_URL
ARG APP_NAME
ARG SUPABASE_URL
ARG SUPABASE_ANON_KEY
ARG SUPABASE_BUCKET
RUN echo "API_URL=$API_URL" > .env && \
    echo "APP_NAME=$APP_NAME" >> .env && \
    echo "SUPABASE_URL=$SUPABASE_URL" >> .env && \
    echo "SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY" >> .env && \
    echo "SUPABASE_BUCKET=$SUPABASE_BUCKET" >> .env
RUN flutter build web --release --base-href /

# Stage 2 : Serve avec Nginx
FROM nginx:alpine
RUN rm -rf /usr/share/nginx/html/*
COPY --from=build /app/build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 3000
CMD ["nginx", "-g", "daemon off;"]