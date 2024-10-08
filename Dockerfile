FROM python:3.9-alpine3.13
LABEL maintainer="londonappdeveloper.com"

ENV PYTHONUNBUFFERED 1

COPY ./requirements.txt /requirements.txt
#Editable to .(current directory)
COPY ./app /app
#added during uwsgi server
COPY ./scripts /scripts

WORKDIR /app
EXPOSE 8000

#part 1 to create django project using docker-compose(docker-compose run --rm app sh -c "django-admin startproject app .")
# RUN python -m venv /py && \
#     /py/bin/pip install --upgrade pip && \
#     /py/bin/pip install -r /requirements.txt && \
#     adduser --disabled-password --no-create-home app

#after adding postgres dependencies(dependencies needed after the postgres driver is installed) and 
#Temp dependencies needed to install driver. and after updating lets install psycopg2 in requirements.txt
# original: build-base postgresql-dev musl-dev && \  updated:build-base postgresql-dev musl-dev linux-headers && \
RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    apk add --update --no-cache postgresql-client && \
    apk add --update --no-cache --virtual .tmp-deps \
        build-base postgresql-dev musl-dev linux-headers && \
    /py/bin/pip install -r /requirements.txt && \
    apk del .tmp-deps && \
    adduser --disabled-password --no-create-home app && \
    mkdir -p /vol/web/static && \
    mkdir -p /vol/web/media && \
    chown -R app:app /vol && \
    chmod -R 755 /vol && \
    chmod -R +x /scripts

# original:ENV PATH="/py/bin:$PATH" updated(uwsgi):ENV PATH="/scripts:/py/bin:$PATH"
ENV PATH="/scripts:/py/bin:$PATH"

USER app

CMD ["run.sh"]