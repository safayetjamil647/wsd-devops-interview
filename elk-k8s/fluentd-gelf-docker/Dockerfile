FROM fluent/fluentd:v1.16-debian

USER root

# Install gelf plugin and dependencies
RUN gem install fluent-plugin-gelf

USER fluent
