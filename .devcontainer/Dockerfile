# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

# Visual Studio Code image with .NET

# NOTE:
# See here for image contents: https://github.com/devcontainers/images/tree/main/src/dotnet

ARG VARIANT="7.0-bullseye-slim"
FROM mcr.microsoft.com/vscode/devcontainers/dotnet:${VARIANT}

RUN sudo apt update -y && sudo apt install python3-pip python3-wheel -y
