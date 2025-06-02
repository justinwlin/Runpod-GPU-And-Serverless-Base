# Summary

RunPod provides two primary services: Pods and Serverless.

Pods are Docker container instances with access to Nvidia GPUs. Using RunPod base templates, they often come with Jupyter Notebooks, SSH ability, so-on, so that developers can easily connect VSCode to a running instance or work straight in the browser.

Serverless are just Pods, but with a managed request queue and autoscaling system. Meaning if you get 50 requests, they go into a queue, and RunPod will spin up as many "workers" (which are just Pods) underneath to serve the requests by executing a specified function.

## Iteration Process

What this means though is that if you have an environment that works in a Pod, you can have it switch over to serverless by just defining the `runpod.serverless.start({...})` call when it is in a serverless environment.

So a recommended workflow is:
1. Work on this repository as a base image
2. Take notes as you define additional python packages or system installations
3. Iterate by just running the `python handler.py` function until you get the result you want.
4. Once you are happy, copy the `handler.py` that you have, take the requirements, and add it to the DockerFile and start.sh script.
    - Tip: You can use ChatGPT/Claude or tools such as Cursor,  to help you add the additional dependencies.
5. Rebuild the Dockerfile, push to pod, test manually to make sure works. Then you can deploy to serverless by just making sure you set the environment variable `MODE_TO_RUN` to `serverless`. **Make sure not to forget this step**, otherwise no handler will be defined when the serverless environment executes meaning the worker will just hang.


## Example handler.py

So taking a look at the example `handler.py` in this repository you can see that the main section is just the `mode_to_run` variable check where I execute the `handler` function directly or call the `runpod.serverless.start`. 

```
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
```

## Example start.sh

We can also see in the start.sh script, depending on the environment variable I either call the python_handler, which in a serverless environment on RunPod will properly define which function to call for  the workers when called.

Or I just start up Jupyter notebook, where a developer can start working with it.

```
case $MODE_TO_RUN in
    serverless)
        call_python_handler
        ;;
    pod)
        # Pod mode implies only starting services without calling handler.py
        start_jupyter
        ;;
    *)
        echo "Invalid MODE_TO_RUN value: $MODE_TO_RUN. Expected 'serverless', 'pod', or 'both'."
        exit 1
        ;;
esac
```