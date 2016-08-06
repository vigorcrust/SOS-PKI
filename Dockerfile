FROM ruby:alpine

RUN apk add --no-cache openssl

EXPOSE 4567
