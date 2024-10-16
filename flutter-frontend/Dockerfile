FROM ghcr.io/cirruslabs/flutter:stable

WORKDIR /app

COPY pubspec.* .
RUN flutter pub get

COPY . .
RUN flutter build web

CMD ["flutter", "run", "--release", "-d", "web-server", "--web-port", "3000", "--web-hostname", "0.0.0.0"]