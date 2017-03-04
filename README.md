# Docker image for daphne (interface server for Django channels)

See https://github.com/django/daphne/ and
https://channels.readthedocs.io/en/stable/.

## Building the image

```bash
docker-compose build
```

or just pull it with:

```bash
docker-compose pull
```

## Using the image

To use the image, you will most likely want to create your own Dockerfile that
looks something like this:

```
FROM tbeadle/daphne:1.0.3
COPY proj/channel_settings.py /home/daphne/proj/
# This is only needed if daphne is going to be running behind a proxy like nginx.
CMD ["--proxy-headers"]
```

In this case, `proj/channel_settings.py` is a file that contains the
`CHANNEL_LAYERS` setting from your project's `settings.py`.  What I like to do,
so that my daphne image is as minimal as possible, is create a
`channel_settings.py` in the same directory as `settings.py` that contains
something like this:

```python
CHANNEL_LAYERS = {
    'default': {
        'BACKEND': 'asgi_redis.RedisChannelLayer',
        'ROUTING':
            'proj.routing.channel_routing'
            if 'SECRET_KEY' in os.environ
            else [],
        'CONFIG': {
            'hosts': [(os.environ.get('REDIS_HOST', 'redis'), 6379)],
        },
    },
}

# These will get overridden in settings.py but are necessary for daphne to be
# able to start.  django.setup() requires that they be set.
DEBUG = False
LOGGING = {}
SECRET_KEY = 'this can be anything except an empty string'
```

Then, at the **top** of my project's `settings.py`, I put:

```python
from .channel_settings import *
```

This way the `CHANNEL_LAYERS` setting is in one place that can be used by my
django project and by my daphne instance.

The important thing is that this file gets copied to
`/home/daphne/proj/channel_settings.py` by way of the Dockerfile.

The `CMD` contains command-line options to give to daphne besides the default
ones, which include:

```bash
-b 0.0.0.0 --access-log - [your options go here] proj.asgi:channel_layer
```

See
https://github.com/tbeadle/docker-gunicorn/tree/master/samples/django_channels
for an example that uses this image.
