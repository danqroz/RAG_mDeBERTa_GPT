FROM python:3.10.10

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

WORKDIR /app

RUN apt-get update \
    && pip install --upgrade pip \
    && pip install pipenv 

COPY Pipfile* ./

RUN PIPENV_VENV_IN_PROJECT=1 pipenv install --skip-lock

RUN pip install -U nltk
RUN pip install sentence-transformers

ENV MODEL_NAME "timpal0l/mdeberta-v3-base-squad2" 
ENV EMBEDDING_MODEL "intfloat/multilingual-e5-base" 

RUN python -c "import nltk; nltk.download('punkt')"

RUN python -c 'from sentence_transformers import SentenceTransformer; SentenceTransformer("'${EMBEDDING_MODEL}'")'

RUN python -c 'from sentence_transformers import SentenceTransformer; SentenceTransformer("'${MODEL_NAME}'")'

COPY . .

ENV PYTHONPATH "${PYTHONPATH}:/app"

EXPOSE 81

CMD ["pipenv", "run", "streamlit", "run", "app/main.py", "--server.port=81"]