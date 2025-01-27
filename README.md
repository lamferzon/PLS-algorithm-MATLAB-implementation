# Implementation in MATLAB of the PLS algorithm for classification

![GitHub repo size](https://img.shields.io/github/repo-size/LorenzoF6/PLS_Algorithm_Implementation)
![GitHub top language](https://img.shields.io/github/languages/top/LorenzoF6/PLS_Algorithm_Implementation?color=yellow&label=MATLAB)
![GitHub](https://img.shields.io/github/license/LorenzoF6/PLS_Algorithm_Implementation)
![GitHub release (latest by date)](https://img.shields.io/github/v/release/LorenzoF6/PLS_Algorithm_Implementation?color=g)

## Authors
* **FERRARI Lorenzo**, postgraduate in Computer Engineering at University of Bergamo.
* **LEONI Lorenzo**, postgraduate in Computer Engineering at University of Bergamo.

## Description
Implementation of the **discriminant PLS algorithm** through a MATLAB class. It provides the following features:
* *estimation* of a PLS model by using the NIPALS algorithm, both PLS1 and PLS2 versions;
* *validation* of the estimated model by providing not only the test MCE for each class, but also the test confusion matrix;
* *cross-validation* to find the best reduction order;
* *graphing* of the matrix T for orders 1, 2, and 3;
* *classification* of new data;

Moreover, [PLS.m](Scripts/PLS.m) can also estimate a PCA model, therefore it is possible to compare it with PLS.

## Installation
It is enough to put [PLS.m](Scripts/PLS.m) in your working directory and methods of this MATLAB class will be ready to be called in your script.

## Coding example 
[Data_analysis.mlx](Scripts/Data_analysis.mlx) contains an example of how this MATLAB class can be used to solve a classification problem by using the PLS algorithm. In particular, the covered problem deals with **steel plates fault detection**. The source dataset is available on [Kaggle](https://www.kaggle.com/datasets/uciml/faulty-steel-plates).

### Results plotting 
The following graphs summarize some results of the data analysis:

<img src="Presentation/Images/ForREADME/plot2.svg" alt="plot1" width="70%" height="70%" align="center" />
<img src="Presentation/Images/ForREADME/plot1.svg" alt="plot2" width="70%" height="70%" align="center" />
<img src="Presentation/Images/ForREADME/plot3.svg" alt="plot3" width="70%" height="70%" align="center" />
<img src="Presentation/Images/ForREADME/plot4.svg" alt="plot4" width="70%" height="70%" align="center" />
