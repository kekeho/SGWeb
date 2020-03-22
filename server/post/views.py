from django.shortcuts import render, Http404
from django.http.response import JsonResponse
from django.views.decorators.csrf import csrf_exempt

import subprocess
import json

from .models import Post, Tag


@csrf_exempt
def test(request):
    """Model: Post"""
    if request.method == 'POST':
        tag_list = [ lambda t: Tag(name=t) for t in request.POST.getlist('tags')]
        data  = json.loads(request.body)
        content = data['content']
        print(request.body)

        # TODO: Change to Docker
        (status, output) = subprocess.getstatusoutput(content)

        return_data = {
            "content": content,
            "result_output":  output,
            "result_status": status
        }
        return JsonResponse(data=return_data)
        