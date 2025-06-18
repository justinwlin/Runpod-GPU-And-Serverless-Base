import os
import asyncio
import runpod

# Use the MODEL environment variable; fallback to a default if not set
mode_to_run = os.getenv("MODE_TO_RUN", "pod")
model_length_default = 25000

print("------- ENVIRONMENT VARIABLES -------")
print("Mode running: ", mode_to_run)
print("------- -------------------- -------")

async def handler(event):
    inputReq = event.get("input", {})
    return inputReq

if mode_to_run == "pod":
    async def main():
        prompt = "Hello World"
        requestObject = {"input": {"prompt": prompt}}
        response = await handler(requestObject)
        print(response)

    asyncio.run(main())
else: 
    runpod.serverless.start({
        "handler": handler,
        "concurrency_modifier": 1,
    })