# Runpod GPU Pod / Serverless LLM Basis

[Example of a repo using this template](https://github.com/justinwlin/Runpod-OpenLLM-Pod-and-Serverless/tree/main)

[Docker Starter Container](https://hub.docker.com/repository/docker/justinwlin/runpod_pod_and_serverless/general)

## Summary

This Docker configuration uses Runpod as a basis so that you can work with both pod and serverless. The idea is that you can work with your handler.py in a GPU / CPU Pod, validate it all works by just running the `python handler.py` file, and then when you deploy to serverless you should be getting essentially the same exact behavior.

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


### Using Depot

For those using Depot to build and deploy containers, the command structure is slightly different. Here's how you can include the environment variables as build arguments with Depot:

```bash
depot build -t yourusername/containername:1.0 .
```

### Using Docker CLI
For traditional Docker builds, you can incorporate the environment variables into your build command like so:
```bash
docker build -t yourusername/containername:1.0 . \
  --build-arg MODE_TO_RUN=pod
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
  -- If you need to iterate, iterate on Runpod and then copy and paste the handler.py back locally and then build using the Docker_Iteration file, which means you won't have to redownload large dependencies again and instead just keep iterating on handler.py
3. Once ready, then relaunch back on GPU Pod and Serverless until ready.
