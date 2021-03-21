FROM ubuntu:latest

# Define function directory
ARG FUNCTION_DIR="/function"

# Install aws-lambda-cpp build dependencies
RUN apt-get -y update && apt-get install python3 python3-pip -y

# Copy function code
COPY app ${FUNCTION_DIR}

RUN pip3 install \
        --target ${FUNCTION_DIR} \
         -r ${FUNCTION_DIR}/requirements.txt

# Install the runtime interface client
RUN pip3 install \
        --target ${FUNCTION_DIR} \
        awslambdaric

# Set working directory to function root directory
WORKDIR ${FUNCTION_DIR}

ENTRYPOINT [ "/usr/bin/python3", "-m", "awslambdaric" ]

CMD [ "lambda_consumer.lambda_handler"]
