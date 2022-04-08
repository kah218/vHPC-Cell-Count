#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Mar  7 09:35:16 2022

@author: kah218
"""

# This script is written to analyze data from Mikael'a ImageJ Macro for counting.
import os
import sys
import re
import numpy as np
import pandas as pd
import glob


# Set directories
outpath = '/Users/kah218/Desktop/Julia'
inpath = '/Users/kah218/Desktop/Julia'


# Define functions to pull csv lists from directories. Think of it as a stack of CSVs.
def find_csv(inpath, prefix):
    csvlist = []
    for f in glob.glob(inpath + '/'+prefix+'*.csv'):
        temp_df = pd.read_csv(f)
        csvlist.append(temp_df)
    return(csvlist)


# Define functions to concatenate data. This part esspentially combines that stack of CSVs into one sheet.
def concat_data(csvlist):
    df = pd.concat(csvlist)
    return(df)


# Data Compilation, reset index column
csvlist_data = find_csv(inpath, "")

df_data = concat_data(csvlist_data)
df_data.set_index('Label')


# Split the area and mean into 2 separate data frames.
df_area = df_data.loc[:,["Label","Area"]]
df_area.set_index('Label')
df_mean = df_data.loc[:,["Label","Mean"]]
df_mean.set_index('Label')


# Make a density data frame.
df_density = pd.DataFrame({'Label': df_data.Label, '': df_mean["Mean"].div(df_area["Area"])})
df_density.set_index('Label')


# Split the name by the delimter
#df_area.reset_index()
df_area.loc[:,["Label"]] = df_area.loc[:,["Label"]].astype("string")
df_area[['Label', 'AP']] = df_area['Label'].astype("string").str.split('_', expand=True)
df_area.set_index('Label')


#df_mean.reset_index()
df_mean.loc[:,["Label"]] = df_mean.loc[:,["Label"]].astype("string")
df_mean[['Label', 'AP']] = df_mean['Label'].astype("string").str.split('_', expand=True)
df_mean.set_index('Label')


#df_density.reset_index()
df_density.loc[:,["Label"]] = df_density.loc[:,["Label"]].astype("string")
df_density[['Label', 'AP']] = df_density['Label'].astype("string").str.split('_', expand=True)
df_density.set_index('Label')


#Spread rows into columns
df_area2 = df_area.pivot(index='Label', columns='AP', values='Area')
df_mean2 = df_mean.pivot(index='Label', columns='AP', values='Mean')
df_density2 = df_density.pivot(index='Label', columns='AP', values='')


#Save to an Excel sheet 
with pd.ExcelWriter(outpath+"/Data.xlsx", engine='xlsxwriter') as writer:
    df_area2.to_excel(writer, sheet_name="Area")
    df_mean2.to_excel(writer, sheet_name="Mean")
    df_density2.to_excel(writer, sheet_name="Mean over Area")
    writer.save()
    
