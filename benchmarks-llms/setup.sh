#!/bin/bash

# script to set up the environment and install necessary Python packages

# Ensure pip is up-to-date
python3 -m pip install --upgrade pip

# Install the required package
# This version is supported only for >=python3.9
# I had to install this version manually on ault 
pip install -U google-generativeai==0.8.3

pip install openai

pip install anthropic 

pip install ollama

pip install matplotlib
pip install seaborn
