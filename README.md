# Probability
The following are some of the project I completed during the second half of my coop term. This information is the cumulative summary of two major projects I completed, and one additional utility function I built while doing so.

## "Gambler's Ruin" Simulation

Gambler's Ruin is a game in which *k* players start with some money *m<sub>1</sub>*,  *m<sub>2</sub>*, ..., *m<sub>k</sub>*. Each game is comprised of multiple iterations, and each iteration involves performing a 'gamble'. A 'gamble' requires two random people - one winner, and one loser - to be chosen form the *k* players. The winner gains $1 while the loser forgoes $1. We keep performing a new iteration as long as every player *i* has *m<sub>i</sub>* > 0.

The problem revolves around the completion time of a game. It is evident that the completion time is random. But *how* random? and *what kind* of random? To study this problem, I wrote a naïve simulation of this experiment in MATLAB, which happened to be quite slow. I was later able to massively optimize the simulation using techniques such as vectorization, software caching, and pre-emptive resource allocation etc.

The file `final_repo\'Gambler's Ruin' Simulation\optimized_gen_2.m` contains the MATLAB code I developed after multiple iterations of testing and improvement. The file `final_repo\'Gambler's Ruin' Simulation\'Gambler Ruin' Simulation.pdf` contains a summary of the results I found. Moreover, I have also explained the techniques I used to optimize my simulations throughout the term using the Gambler's Ruin problem as an example in file `final_repo\Research Domain\Simulation and Analysis of Stochastic Processes.pdf`.

## Queue Analysis

### Multiserver Queue Analysis

The most important project related to the queues was **Multiserver Queue Analysis**, which analysed a load-balancer having access to a large number of servers. Given that the load-balancer receives periodic requests, and that the amount of time taken to service request *k* is *S<sub>k</sub>*, an exponential random variable, what is the expected number of busy servers E[B(*t*)]? Here, B(*t*) is the number of busy servers at some time *t*.

This problem was of particular interest to me due to it's direct applicability what I study in Computer Engineering here at the University of Waterloo. I was able to obtain a mathematical expression for E[B(*t*)] using tools generally used in Signal Processing (Dirac-delta impulse, Convolution, etc.). Additionally, I was also able to find the empirical evidence supporting this.

The file `final_repo\Queues\Multi-server System Analysis.pdf` contains the found expression and a summary of the empirical evidence. The file `final_repo\Research Domain\Multi-server System Analysis.pdf` contains the derivation of the obtained expression. The files `final_repo\Queues\queue_simulator.m`, and `final_repo\Queues\server_simulator.m` contain the simulation code for this problem.

### Random Queue Analysis

This project invovled analyzing a simpler random queue. The aim of this project was to act as a precursor the the above problem. In this problem, the delays between consecutive arriving requests were exponential random variables, and so were the service times. The aim was to analyze the system as the inter-arrival delays and service times became more and more deterministic.

The file `final_repo\Queues\Random Queueing System Analysis.pdf` contains a summary of the problem and the empirically obtained results.

## Graphing Utility

This is a tool I developed and improved throughout my coop term. The file `final_repo\Graphing Utility\ezdraw.m` contains a function that plots the input data and does the following in addition to it:
- Re-positions graph around the mean.
- Ensures that the maximum/minimum values are a part of the graph.
- Redraws the major and the minor grid in a square shape.
- Modifies axis ticks depending upon the scale of the graph.
- Prints out the mean of the observed data, and the filtered version of it.

All of the above mentioned properties are modifiable and can be changed it you wish to. For more information regarding the `ezdraw.m` function, refer to the comments inside it.

## Other Projects

### Approximation Complex Derivatives

This is something that I came up with at the end of my 2A term. This involves representing a funciton in terms of its Fourier series expansion, and then exploiting the fact that {sin(*w*), cos(*w*)} is a basis for the vector space of all linear combinations of sin(*w*), cos(*w*).

This technique does have issues though. There is only a certain class of functions whose derivatives can be approximated in this manner. Using one of those functions as an example, I calculated the expressions for -1<sup>th</sup>, -0.5<sup>th</sup>, *i*<sup>th</sup>, -*x*<sup>*-1*<sup>th</sup></sup> derivative of a function. Please read the file `final_repo\Research Domain\Calculating Complex Derivatives.pdf` for more details.
