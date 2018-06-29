# PrivID

PrivID is a proof of concept implementation of a privacy improved customer
recognition system created for the Advanced Services Engineering course at 
TU Wien during the spring/summer term of 2018.

## Motivation

The main goal is to replace other identification methods such as loyalty cards
known from supermarkets that are used to analyze customer behavior and improve
on various aspects of operations. In many cases, it is enough to simply be able
to associate purchases with one person, even when the person's name or identity
are unknown, for analytics purposes. This can be achieved by running face 
recognition on customers entering the store, captured by security cameras, and 
assigning them anonymous identities which persist across store visits. This is
similar to recognizing familiar faces in public without knowing their names.

Under the light of recent privacy regulations, storing and processing data
about users has become a burden. The PrivID concept aims to alleviate these 
issues by doing away with sensitive, user-related information.

## Architecture

At the heart of this prototype lies a service providing face recognition using
a deep convolutional neural network to create face embeddings. These embeddings
are stored in-memory and compared to the embeddings of other persons in the
database. At no point is a name or other ID mechanism linked to this data.

This service can be used to identify a person from pictures and digitize real
world actions for analytics.

## Quick start

The fastest way to get going is using Docker and Docker Compose locally. Simply
call the following from the project's root directory:

```
$ docker-compose up
```

The frontend will be served at `http://localhost:80`, the backend at
`http://localhost:8080`. You will need to enter the endpoint of the backend in
the frontend.

You can also deploy the services to a Kubernetes cluster using the provided
deployments. See the [Google Cloud Kubernetes Engine quickstart guide](https://cloud.google.com/kubernetes-engine/docs/quickstart) or the [Hello Minikube tutorial](https://kubernetes.io/docs/tutorials/hello-minikube/#create-a-service) for step-by-step instructions.

## Next steps

This PoC is not ready for production. To take it there, the architecture needs
to be changed to include a designated database to actually share embeddings
between the face recogintion instances. 

Additionally, the pre-processing steps necessary for face recognition should be
extracted into a pipeline with improved scalability.

A system like this can benefit greatly from network effects, like providing the
service to multiple API consumers and collecting more information on shoppers 
to improve confidence in the matches. In such a scenario, it might be better to
abstract over the identities and provide API consumer-specific IDs for each
identified person.