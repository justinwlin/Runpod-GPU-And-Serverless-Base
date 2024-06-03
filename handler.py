import os
import openllm
import runpod
import asyncio
import torch
import numpy as np
import random
import uuid

# Use the MODEL environment variable; fallback to a default if not set
model_name = os.getenv("MODEL", "mistralai/Mistral-7B-Instruct-v0.1")
concurrency_modifier = int(os.getenv("CONCURRENCY_MODIFIER", 1))
mode_to_run = os.getenv("MODE_TO_RUN", "pod")
model_length_default = 25000

print("------- ENVIRONMENT VARIABLES -------")
print("Concurrency: ", concurrency_modifier)
print("Mode running: ", mode_to_run)
print("------- -------------------- -------")

# LOAD THE MODEL
# model = loadModelPseudo(model_name)

async def handler(event):
    inputReq = event.get("input", {})
    return inputReq

def adjust_concurrency(current_concurrency):
    return concurrency_modifier

if mode_to_run in ["both", "serverless"]:
    runpod.serverless.start({
        "handler": handler,
        "concurrency_modifier": adjust_concurrency,
        "return_aggregate_stream": True,
    })

if mode_to_run == "pod":
    async def main():
        prompt = "What is the capital of France?"
        requestObject = {"input": {"prompt": prompt}}
        
        async for response in handler(requestObject):
            print(response)

    asyncio.run(main())
