FROM elixir:latest

ENV PORT 4000
ENV APP_HOME /peakt

RUN curl -sL https://deb.nodesource.com/setup_6.x | bash -
RUN apt-get update && apt-get install -y inotify-tools make gcc nodejs

RUN mix local.hex --force
RUN mix local.rebar --force

WORKDIR $APP_HOME

EXPOSE $PORT
