# Runpod GPU Pod / Serverless LLM Basis

[Example of a repo using this template](https://github.com/justinwlin/Runpod-OpenLLM-Pod-and-Serverless/tree/main)

## Summary

This Docker configuration uses Runpod as a basis so that you can work with both pod and serverless. 

## Environment Variables

Below is a table of the environment variables that can be passed to the Docker container. These variables enable customization of the deployment's behavior, offering flexibility for different scenarios.

| Variable               | Description                                                                                                                  | Expected Values              | Default Value                   |
|------------------------|------------------------------------------------------------------------------------------------------------------------------|------------------------------|---------------------------------|
| `MODE_TO_RUN`          | Determines the container's operational mode, affecting the execution of `handler.py` and the initiation of services.         | `serverless`, `pod` | pod                            |
| `CONCURRENCY_MODIFIER` | A factor used to adjust the concurrency level for handling requests, allowing for tuning based on workload.                  | Integer                     | `1`                             |


### Mode Descriptions

- `serverless`: Executes `handler.py` for serverless request handling, optimal for scalable, efficient deployments.
- `pod`: Initiates essential services like OpenSSH and Jupyter Lab, bypassing `handler.py`, suitable for development or tasks requiring GPU resources.

## Getting Started

1. **Build the Docker Image**: Create your image using the Dockerfile, optionally specifying the `MODEL`, `CONCURRENCY_MODIFIER`, and `MAX_MODEL_LEN` variables as needed.

    ```sh
    docker build --build-arg MODEL_ARG=<your_model_identifier> --build-arg MAX_MODEL_LEN=<desired_max_length> -t your_image_name .
    ```

2. **Run the Container**: Start your container with the desired `MODE_TO_RUN`, `MAX_MODEL_LEN`, and any other environment variables.

    ```sh
    docker run -e MODE_TO_RUN=serverless -e CONCURRENCY_MODIFIER=2 -e MAX_MODEL_LEN=25000 your_image_name
    ```

    You can also just leave the Docker run **empty** and let the default run take over. And if you want to instead modify the ENV variables, just use Runpod's GUI where you can write the ENV variables there instead of in the **RUN** command if you are running on runpod. This can be helpful especially if you are for ex. debugging in GPU Pod, and then you want to just deploy on SERVERLESS by just changing the ENV variable when you are making a new template.

3. **Accessing Services**: Depending on the chosen mode,
    - In `serverless` and `both`, interact with the deployed model through the specified handler.
    - In `pod` and `both`, access Jupyter Lab and SSH services as provided.

### Using Depot

For those using Depot to build and deploy containers, the command structure is slightly different. Here's how you can include the environment variables as build arguments with Depot:

```bash
depot build -t yourusername/serverlessllm:1.0 . \
  --build-arg MODE_TO_RUN=pod \
  --build-arg MODEL=mistralai/Mistral-7B-Instruct-v0.1 \
  --build-arg CONCURRENCY_MODIFIER=1 \
  --build-arg MAX_MODEL_LEN=25000 \
  --push --platform linux/amd64
```

### Using Docker CLI
For traditional Docker builds, you can incorporate the environment variables into your build command like so:
```bash
docker build -t yourusername/serverlessllm:1.0 . \
  --build-arg MODE_TO_RUN=pod \
  --build-arg MODEL=mistralai/Mistral-7B-Instruct-v0.1 \
  --build-arg CONCURRENCY_MODIFIER=1 \
  --build-arg MAX_MODEL_LEN=25000
```

# Developer Experience

Start using the container with [GPU_POD](https://runpod.io/gsc?template=pu8uaqw765&ref=wqryvm1m
) (This is my runpod public URL to the template all ready to go for you.)

![alt text](GPU_POD.png)

If you want to deploy on serverless it's super easy! Essentially copy the template but set the environment variable for the MODE to serverless. **Check to make sure the model repository names match up** as I might update template names, or you might be using a different model. Find the right one by refering to Docker which model you want to use. **MAKE SURE TO INCLUDE THE USERNAME/IMAGE:TAG** if you are missing the username, image, or tag it won't work!!:

For the container size, look at the compressed docker image size on Dockerhub, and I generally like to add another 5GB to 10GB ontop of that. You can play around to see. 

![alt text](SERVERLESS.png)

If you end up wanting to change the handler.py I recommend to build using a flag to target the "Dockerfile_Iteration" after you build using the standard "Dockerfile" once. This way you can have the models cached during the docker build process in the base image and only update the handler.py. This way you can avoid the long wait time to "redownload the model" and just update the handler.py.


```sh
docker build -f Dockerfile_Iteration -t your_image_name .
```

## Overall Methodology:
The methodology is:
1. Build your first Dockerfile where we preload the model + everything the first time
2. Launch a GPU Pod on Runpod and test the handler.py
  -- If everything looks good, just use the same image for serverless and modify the env variable to change how it starts up
  -- If you need to iterate, iterate on Runpod and then copy and paste the handler.py back locally and then build using the Docker_Iteration file, which means you won't have to redownload the whole model again and instead just keep iterating on handler.py
3. Once ready, then relaunch back on GPU Pod and Serverless until ready.

> Note! If the base models are already built for you on my CI/CD pipeline, what that means is that you can just use the Dockerfile_Iteration file, to target that specific repository and just modify the handler.py. This way you can avoid the long wait time to "redownload the model" and just update the handler.py.

# Serverless

## Example Clientside Code

Click here to see the example code I wrote for 'normal' and 'stream' mode. [stream_client_side.py](./stream_client_side.py)

### Notes:
I purposely kept the API very simple. The prompt you can construct however you want, rather than separating out things like system / user prompts. You can just construct the prompt `f"{system_prompt} {user_prompt}"` and then send it to the API. The API will then generate the text based on the prompt and return the text. And if you disagree, you can easily modify the handler.py to act differently of for your use-case, especially if you want to change and add more properties such as temperature etc. But I wanted to keep it as simple as possible at first.

## Expected API Input and Output

### Input Structure

The API expects input provided as a JSON object with the following structure:

```json
{
  "input": {
    "prompt": "<user_prompt>",
    "answerType": "<stream | normal>"
  }
}
```

## Output Structure
> Note you can see more examples on my stream_client_side.py

Stream Mode ("stream"): The API yields multiple JSON objects, each containing a part of the generated text:

```How to call streammode on runpod:```

[Documentation on stream mode invocation:](https://docs.runpod.io/serverless/endpoints/invoke-jobs#stream-results)

```
{"text": "generated text part 1"}
{"text": "generated text part 2"}
...
```

Normal Mode ("normal"): The API returns a single JSON object with the complete generated text:

[Invoking the API with /run](https://docs.runpod.io/serverless/endpoints/invoke-jobs#asynchronous-endpoints)
```json
{
  "text": "generated text"
}
```
