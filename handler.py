import os
import asyncio

# Use the MODEL environment variable; fallback to a default if not set
concurrency_modifier = int(os.getenv("CONCURRENCY_MODIFIER", 1))
mode_to_run = os.getenv("MODE_TO_RUN", "pod")
model_length_default = 25000

print("------- ENVIRONMENT VARIABLES -------")
print("Concurrency: ", concurrency_modifier)
print("Mode running: ", mode_to_run)
print("------- -------------------- -------")

async def handler(event):
    inputReq = event.get("input", {})
    return inputReq

# https://docs.runpod.io/serverless/workers/handlers/handler-concurrency
def adjust_concurrency(current_concurrency):
    return concurrency_modifier

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
        "concurrency_modifier": adjust_concurrency,
    })