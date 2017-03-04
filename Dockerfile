FROM python:3.6

ENV \
	TINI_VERSION=v0.14.0 \
	DAPHNE_VERSION=1.0.3 \
	CHANNELS_VERSION=1.0.3
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini

RUN pip install --no-cache-dir \
		asgi-redis==1.0.0 \
		channels==${CHANNELS_VERSION} \
		daphne==${DAPHNE_VERSION} \
	&& useradd -m -U daphne
WORKDIR /home/daphne
USER daphne
EXPOSE 8000
ENV DJANGO_SETTINGS_MODULE=proj.channel_settings
COPY asgi.py /home/daphne/proj/
COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
CMD []
