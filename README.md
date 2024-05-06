# Data Science Docker Environment

This Docker image extends the Jupyter SciPy Notebook container, tailored to provide a ready-to-use environment for data science and machine learning tasks. Powered by CPU-based operations, it includes popular Python libraries such as PyTorch, OpenCV, and SimpleITK. Additionally, it incorporates the installation of Rust and the evcxr_jupyter kernel for Rust development directly within the Jupyter Notebook environment.

Moreover, the image encompasses supplementary tools like Plastimatch and DCMTK, enhancing its capabilities for medical image processing and manipulation.

This Docker image serves as a comprehensive solution for developers and data scientists seeking a flexible and powerful environment for their analyses and experiments, featuring support for multiple programming languages and data/image processing tools.


## Usage

1.  Ensure you have Docker and Docker Compose installed on your system.
2.  Clone this repository.
3.  Navigate to the repository directory.
4.  Run `docker-compose up` to build and start the container.
5.  Access Jupyter Notebook in your browser at `http://localhost:1515`.

## Folder Structure

    .
    ├── Dockerfile
    ├── docker-compose.yml
    └── notebook/
        ├── notebooks/  # Place your Jupyter notebooks here
    
# Running Containers

Run the following command to build and start the container:

  docker-compose up -d 

Docker compose example: docker-compose.yml

    version: '3'
    services:
      notebook:
        build: .
        ports:
          - '8888:8888'
        volumes:
          - ./notebook:/home/jovyan/work
          - /mnt:/mnt
        restart: always

## Accessing Container as Root

To access the container as the root user and install additional Python libraries, you can use the following command:

    docker exec -it -u root container_id bash

Replace `container_id` with the ID of the running container.

