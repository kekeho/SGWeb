from controller import app, index
from user import urls as user_urls
from typing import List
from fastapi.applications import get_swagger_ui_html

def add_route(path: str, child_path_list: List):
    global app
    for (methods, child_path, func, model) in child_path_list:
        app.add_api_route(
            path=f'/api/{path}/{child_path}',
            endpoint=func,
            response_model=model,
            methods=methods,
        )


app.add_api_route('/api/', index)

add_route('user', user_urls.path_list)
