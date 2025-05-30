# Runpod GPU Pod / Serverless LLM Basis

[Docker Starter Container](https://hub.docker.com/repository/docker/justinrunpod/pod-server-base/general)

# Runpod Images:

## Summary

This Docker configuration uses Runpod as a basis so that you can work with both pod and serverless. The idea is that you can work with your handler.py in a GPU / CPU Pod, validate it all works by just running the `python handler.py` file, and then when you deploy to serverless you should be getting essentially the same exact behavior.

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

### Using Depot to Build

For those using Depot to build and deploy containers, the command structure is slightly different. Here's how you can include the environment variables as build arguments with Depot:

```bash
depot build -t justinwlin/runpod_gpu_and_serverless_basis:1.0 .
```

### Using Docker CLI
For traditional Docker builds, you can incorporate the environment variables into your build command like so:

```bash
docker build -t yourusername/containername:1.0 .
```
Or if you want to set different defaults can either set it in the dockerfile or during the build step:
```bash
docker build -t yourusername/containername:1.0 . \
  --build-arg MODE_TO_RUN=pod
```

# Developer Experience

If you want to deploy on serverless it's super easy! Essentially copy the template but set the environment variable for the MODE to serverless.

If you end up wanting to change the handler.py I recommend to build using a flag to target the "Dockerfile_Iteration" after you build using the standard "Dockerfile" once. This way you can have the models cached during the docker build process in the base image and only update the handler.py. This way you can avoid the long wait time to "redownload the model" and just update the handler.py.

```bash
docker build -f Dockerfile_Iteration -t your_image_name .
```

## Overall Methodology / Workflow for iterating:
The methodology is:
1. Build your first Dockerfile where we preload the model + dependencies + everything the first time
2. Launch a GPU Pod on Runpod and test the handler.py
  -- If everything looks good, just use the same image for serverless and modify the env variable to change how it starts up
  -- If you need to iterate, iterate on Runpod and then copy and paste the handler.py back locally and then build using the Docker_Iteration file, which means you won't have to redownload large dependencies again and instead just keep iterating on handler.py
3. Once ready, then relaunch back on GPU Pod and Serverless until ready.

Obviously modify the base image, and not just keep using the Docker_Iteration file if there is something fundamental about the base image you should change such as switching out the model, missing a dependency, etc.
