# fondahub/airflow:2.2.5-python3.8
FROM apache/airflow:2.2.5-python3.8
USER root
RUN apt-get update --fix-missing
RUN apt-get install -y build-essential python3-dev python2.7-dev \
    libldap2-dev libsasl2-dev slapd ldap-utils tox \
    lcov valgrind && apt-get autoremove -yqq --purge \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
USER airflow
COPY requirements.txt .
RUN pip install --no-cache-dir --user -r  requirements.txt
