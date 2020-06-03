FROM amazon/opendistro-for-elasticsearch-kibana

RUN /usr/share/kibana/bin/kibana-plugin remove opendistro_security

COPY --chown=kibana:kibana conf/kibana.yml /usr/share/kibana/config/
