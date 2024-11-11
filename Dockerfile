FROM hexpm/elixir:1.17.3-erlang-27.1.2-ubuntu-focal-20241011

# install build dependencies
RUN apt-get update -y && apt-get install -y build-essential git \
    && apt-get clean && rm -f /var/lib/apt/lists/*_*

# Install hex and rebar
RUN mix local.hex --force && \
    mix local.rebar --force

ENV MIX_ENV=prod
ENV ERL_FLAGS="+JPperf true"

WORKDIR /app

# Fetch dependencies
COPY mix.exs .
COPY mix.lock .
RUN mix deps.get
RUN mix deps.compile

# Copy over all the necessary application files and directories
COPY config/config.exs ./config/
COPY config/prod.exs ./config/
COPY config/runtime.exs ./config/
COPY lib ./lib
COPY priv ./priv
COPY rel ./rel
CMD ["mix", "release", "--overwrite"]