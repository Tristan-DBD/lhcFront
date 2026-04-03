# Stage 1: Build Flutter Web
FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app

# Copier seulement le nécessaire pour le build
COPY pubspec.* ./
RUN flutter --version
RUN flutter pub get

COPY . .

# Créer un .env vide si absent (Flutter l'exige comme asset, les vraies valeurs viennent des --dart-define)
RUN test -f .env || touch .env

ARG API_URL
ARG SUPABASE_URL
ARG SUPABASE_ANON_KEY
ARG SUPABASE_BUCKET
ARG APP_NAME
ARG APP_VERSION

# Build Web avec variables d'environnement via Dart define
RUN flutter build web --release \
    --base-href / \
    --dart-define=API_URL=${API_URL} \
    --dart-define=SUPABASE_URL=${SUPABASE_URL} \
    --dart-define=SUPABASE_ANON_KEY=${SUPABASE_ANON_KEY} \
    --dart-define=SUPABASE_BUCKET=${SUPABASE_BUCKET} \
    --dart-define=APP_NAME="${APP_NAME}" \
    --dart-define=APP_VERSION="${APP_VERSION}"

# Stage 2: Serve with Nginx
FROM nginx:alpine

# Install gettext for envsubst (needed to inject $PORT at runtime)
RUN apk add --no-cache gettext

# Copy Flutter build output to Nginx html folder
COPY --from=build /app/build/web /usr/share/nginx/html

# Use custom Nginx config template
COPY nginx.conf /etc/nginx/conf.d/default.conf.template

EXPOSE 8080

# At runtime, Railway injects $PORT. Use envsubst to inject it into nginx config.
CMD sh -c "envsubst '\$PORT' < /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'"