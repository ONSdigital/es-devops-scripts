# DevOps for Algorithmia Algorithms

## Purpose

To automate the creation, building, testing, deployment and publishing of algorithms in ALgorithmia.

To give the software engineer fine grained control when developing algorithms (as opposed to using the Algorithmia web interface)

## Files

| File                        | Description                                                                            |
| --------------------------- |----------------------------------------------------------------------------------------|
| **createAlgorithm.sh**      | A fully self-contained script to create an algorithm.                                  |
| **algorithmia/create.sh**   | Creates an algorithm in Algorithmia via its algorithm management REST API.
| **algorithmia/deploy.sh**   | Deploys an algorithm in Algorithmia by pushing code to the Algorithmia Git repository  |
| **algorithmia/deploy.sh**   | Publishes an algorithm in Algorithmia via its algorithm management REST API.           |


## Creating an algorithm

### createAlgorithm.sh

A `bash` script to create an `algorithm` in [Algorithmia](https://algorithmia.com)

For a given GitHub repository the script will:
1. Create an algorithm in Algorithmia in the language of your choice
2. Pull the code from the newly crated Algorithmia Git repository and push it to the GitHub repository master branch
3. Create a `feature/devops` branch in GitHub
4. Configure CI pipelines (currently Travis & Jenkins) for the algorithm
5. Add sample unit and integration tests
6. Push the `feature/devops` branch to GitHub (which will trigger the CI pipelines)

### Usage

The following steps outline what's typically involved in creating an algorithm

1. Create a public repository for your algorithm in GitHub.
2. Run `createAlgorithm` script to create the algorithm. This will create a `feature/devops` branch in GitHub.

### Example

```
bash es-devops-scripts/createAlgorithm.sh -a 'My Algorithm' -k xxx  -l java -g my-git-repo
```

### Parameters

The following parameters can be specified when creating an algorithm.

#### Algorithm (*-a*)
**Mandatory Parameter**

The English name of the algorithm (can contain spaces and special charaacters).

The name is stripped of spaces and special characters when creating the Algorithmia Git repository.

#### Algorithmia API Key (*-k*)
**Mandatory Parameter**

An API key in Algorithmia with API management permissions on the specified owner ('ons' by default) of the algorithm.

#### Language(*-l*)
**Mandatory Parameter**

The language for your algorithm.

Supported languages are 'java', 'scala' and 'python3-1' (although this uses a Python 3.6).

#### GitHub Repository (*-g*)
**Mandatory Parameter**

The GitHub repository (within [ONSdigital](https://github.com/ONSdigital) ) to which your algorithm source code will be pushed.

#### GitHub Repository (*-n*)
**Optional Parameter**

Internet access for your algorithm (defaults to 'isolated').

Options are 'isolated' (not internet access) or 'full'.

#### GitHub Repository (*-o*)
**Optional Parameter**

The owner of the algorithm in Algorithmia (defaults to 'ons').

#### Algorithmia Git Repository (*-r*)
**Optional Parameter**

Defaults to the ONS proof of concept Algorithmia Git repository.

Use 'git.algorithmia.com/git' to create an algorithm in [public Algorithmia](https://algorithmia.com).

#### Algorithmia Management API URL(*-u*)
**Optional Parameter**

Defaults to the ONS proof of concept Algorithmia.

Use 'https://api.algorithmia.com' to create an algorithm in [public Algorithmia](https://algorithmia.com).

## Configuring Travis CI

Once your algorithm has been created you will need to add a couple of environment variables to the job in Travis.

Unfortunately Travis CI does not support global environment variables across projects for security reasons so the variables need to be configured for every algorithm.

### Environment Variables

The following environment variables must be created.

#### ALGORITHMIA_PASSWORD

The Travis CI script assumes a user called 'travis' exists in Algorithmia.

This user account is used to push code into the Algorithmia GitHub repository during the 'deploy' phase.

This variable contains the password for the 'travis' user and should not be displayed in the build log.

#### ES_ALGORITHMIA_API_KEY

This variable contains an Algorithmia API key with API management permissions on the specified owner ('ons' by default) of the algorithm and should not be displayed in the build log.

The API key is used when running tests against the deploy algorithm.

## License

All content is licensed under the terms of [The MIT License](LICENSE).
