# Application of Tree search in the game environment of Ms. Pac-Man
## Search Agents controlled via Hill Climbing and Simulated Annealing on Matlab

## Link to my thesis presentation slides that covers this material is as follows:
## https://www.slideshare.net/secret/bra2UyB2gKgMw
## Link to my thesis document: https://mspace.lib.umanitoba.ca/xmlui/bitstream/handle/1993/33907/Hoque_Sanyat.pdf?sequence=1&isAllowed=y

Designed multi-agent based autonomous bots that interact with each other via optimization algorithm using tree search algorithms 
such as DFS, Hill Climbing, Simulated Annealing as well as another modified Simulated Annealing algorithm in a game environment 
inducing emergent behaviors. 

Some scenarios of the behavior of ghost agents using Hill Climbing algorithm, Simulated Annealing and 
another Simulated Annealing inspired algorithm to reach their adversary are uploaded online. 
## The link is as follows: https://www.youtube.com/watch?v=WKvz4TrcLS8

Ms. Pac-Man provides a solid proving arena for programming novel artificial intelligent
algorithms and the development of NPCs. This game provides a good opportunity for
constructing and evaluating deterministic or non-deterministic tree search algorithms.
Throughout the last decade, several artificial intelligence algorithms have been applied to tackle
the dynamic probabilistic behavior of Ms. Pac-Man. These include proposed models of swarm
intelligence based on ant colony optimization [7][8] and Monte Carlo tree search [9][10]. These
algorithms show some efficacy in surrounding their adversary to lower its score in the game
environment. Using stochastic search to optimize path selection of ghost agents provides
satisfactory results in dealing with the stochastic nature of their adversary, which makes Ant
Colony optimization algorithm a good choice in dealing with Ms. Pac-Man.
The work here was interested in developing other novel algorithms that may be simpler to
implement while yielding comparable NPC behaviour patterns. Therefore, another nondeterministic algorithm, mSA, was developed and applied by ghost agents and was evaluated
against HC and vSA in terms of their performance of ghosts in the game, showing comparable
or superior results in terms of the time and proximity of converging upon Ms. Pac-Man. Further,
and to the author‟s knowledge, this is the first time a probabilistic optimization algorithm based 
upon modifications suggested by simulated annealing was used by ghost agents to demonstrate
flanking and blocking behaviors in order to minimize the score of Ms. Pac-Man. These
modifications were inspired by trade-offs seen during phases of exploration and exploitation.
One of the limitations of this thesis work is that it was not possible to compare the proposed
model‟s performance with the algorithms of past research due to the use of a different simulators.
The simulator in Ms. Pac-Man Vs. Ghost Team competition is a good benchmarking platform for
understanding the fitness of various computational intelligence algorithms used by related
agents. However, it was the intent of this work to develop an entirely new algorithm for use
within NPC game agents. For this reason, it was desirable to work from within a simulator
developed for this purpose, facilitating algorithm exploration as opposed to algorithm
implementation. To mitigate this issue, the algorithm developed here could now be constructed
and run in the Ghost vs. Ms. Pac-Man simulator, and compared with other algorithms that
showed satisfactory performance in the competition. 

It should be noted that the trade-off between exploration and exploitation within algorithms such
the mSA presented here demonstrate that for game NPCs, although simple to implement display
apparently complex behaviours. My development of mSA was from simulated annealing. This
just happened to be the route I have taken, there are other approaches that may have led to
similar interplay of exploration and exploitation. There are also alternative probability of
acceptance functions that could have been developed and in the future this may be the case.
However, it is the interplay between exploration and exploitation that may yet benefit a variety
of search strategies, not being restricted to improving NPCs within games.
