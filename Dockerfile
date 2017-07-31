FROM elixir:1.5
RUN apt-get update -qq && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# IMAGEMAGICK
# install ImageMagick
RUN apt-get install imagemagick -y

# Clean the cache created by package installations
RUN \
  apt-get clean

RUN mix local.hex --force
RUN mix local.rebar --force

# Set up working directory
RUN mkdir /app
ADD . /app
WORKDIR /app

ENV PORT 80
EXPOSE 80

RUN mix deps.get
RUN mix compile

CMD mix phoenix.server
