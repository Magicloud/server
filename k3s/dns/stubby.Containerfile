FROM alpine:latest

RUN apk add --no-cache stubby tsocks

ENV LD_PRELOAD=libtsocks.so

CMD [ "stubby" ]