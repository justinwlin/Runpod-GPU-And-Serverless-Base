# Runpod GPU Pod / Serverless LLM Basis

[Docker Starter Container]([https://hub.docker.com/repository/docker/justinrunpod/pod-server-base/general](https://hub.docker.com/repository/docker/justinrunpod/pod-server-base/tags/1.0/sha256-6f14a81e9737443b70333cb250b562a9ad811a666d29c7710d38bfae3f22c20e)

[RunPod template](https://runpod.io/console/deploy?template=kkfdqs5wv3&ref=p1oqnqy1)

# Runpod Images:

## Summary

This Docker configuration uses Runpod as a basis so that you can work with both pod and serverless. The idea is that you can work with your handler.py in a GPU / CPU Pod, validate it all works by just running the `python handler.py` file, and then when you deploy to serverless you should be getting essentially the same exact behavior.

If you are interested further can read the [more info markdown file](./more_info.md).

**MAKE SURE TO SET THE ENVIRONNMENT VARIABLE**!!

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

## Scoping out the changes
I recommend to first spin up a GPU Pod / a CPU pod using the base runpod templates I provide at the top. You can then go to the /app directly, and add stuff to the requirements.txt, manually run `apt-get` commands, and so-on. And test and confirm what dependencies you need to add to the Dockerfile / the requirements.txt. Then you can locally modify the repository, and build your own image and push it to then confirm everything works as you expect.

## How to customize?
1. Add to the requirements.txt any python requirements
2. Modify the Docker container as needed if you need to install other system dependencies so on
3. You can modify the start.sh script in order to execution other bash functions as necessary. Make sure that your bash function isn't blocking the eventual sleep infinity call or the python app.py call.

### Example Build Command

```bash
docker build -t justinrunpod/pod-server-base:1.0 . --push --platform linux/amd64
```


## Overall Methodology / Workflow for iterating:
The methodology is:
1. Deploy with this repository image to Pod
2. As you install python packages or system packages write it down
3. Modify the handler.py until you get it working
4. Copy the handler.py / your system requirements, plug into an LLM to help it modify the DockerFile / start.sh script to your liking
5. Push the image, and test on Pod until the behavior is what you expect.
6. Deploy to serverless by using the same template and setting the ENV variable `MODE_TO_RUN` to "serverless"
