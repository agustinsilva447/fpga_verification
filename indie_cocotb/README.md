# EAMTA Demo


## Set up

```shell
python3.10 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

## List tests  

```shell
pytest --collect-only
```

## Run test

```shell
pytest -k <test_name>
pytest -k test_butterfly
```