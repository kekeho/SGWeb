from fastapi import FastAPI
from starlette.requests import Request

app = FastAPI(
    title='Muse Server',
    description='Destributed Library Project: Server system',
    version='0.0.1'
)


async def index(request: Request):
    return {'message': 'Hello'}
