FROM python:3.9-alpine3.13
LABEL maintainer="https://github.com/Scotchtoffee"

ENV PYTHONUNBUFFERED=1

COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt
COPY ./app /app
WORKDIR /app
EXPOSE 8000

#we could create a different "RUN" command for every single line, but using a double ampersand backslash
#makes it more efficient
#creating more than one RUN creates different layers in the image we are using, and it's better
#to avoid doing it to keep our images lightweight

# "-m venv" creates a virtual environment to avoid any possible conflicts with other dependencies in other projects
# "rm -rf /tmp && \" removes the tmp (temporary) directory to avoid any extra dependencies in our Docker image
# make sure to remove temporary files as part of your build process to save as much space and speed when deploying your app
# addUSER calls the USER COMMAND, which adds a new user inside our Docker image
# and it's a good practice because if you don't specify, it will use the ROOT USER, and this user has permission to do everything on the server
# DON'T RUN YOUR APP WITH THE ROOT USER. If your app gets compromised, the attacker will have full access to the Docker container
# "ENV PATH="/py/bin:$PATH" adds /py/bin to the system PATH so that every time we run Python commands, it will run automatically from our virtual environment


# Sets dev=false so when it is used by any configuration other than the docker-compose file, it remains false so we don't run our app in dev mode.
# However, if it’s used by docker-compose file, it will be overwritten to true so it will install the dev dependencies.
ARG DEV=False
RUN python -m venv /py && \ 
    /py/bin/pip install --upgrade pip && \
    /py/bin/pip install -r /tmp/requirements.txt && \
    if [ "$DEV" = "true" ]; \
        then /py/bin/pip install -r /tmp/requirements.dev.txt ; \
    fi && \
    rm -rf /tmp && \
    adduser \
        --disabled-password \
        --no-create-home \
        django-user
        
# Update PATH to include virtual environment
ENV PATH="/py/bin:$PATH"

# Switch to non-root user for security
USER django-user
