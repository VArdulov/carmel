## Carmel finite-state toolkit - J. Graehl

 (carmel includes EM and gibbs-sampled (pseudo-Bayesian) training)

 (see `carmel/LICENSE` - free for research/non-commercial)

 (see `carmel/README` and `carmel/carmel-tutorial`).

## Building from source

```
mkdir build
cd build
cmake ..
make
make install
```
optional cmake parameters:
 - -DCMAKE_INSTALL_PREFIX=/custom/install/path
 - -DBOOST_ROOT=/path/to/boost (if it is not installed in standard location)
 - -DOPENFST_ROOT=/path/to/openfst (if desired, and it is not installed in standard location)

prerequisites: 
 - cmake 3.1 or higher
 - a C++11 compiler
 - Boost. Tested on versions between 1.53 and 1.59, but others should work, too 
 - Optionally, openfst (http://www.openfst.org)

## Subdirectories

* `carmel`: finite state transducer toolkit with EM and gibbs-sampled
  (pseudo-Bayesian) training

* `forest-em`: derivation forests EM and gibbs (dirichlet prior bayesian) training

* `graehl/shared`: utility C++/Make libraries used by carmel and forest-em

* `gextract`: some python bayesian syntax MT rule inference

* `sblm`: some simple pcfg (e.g. penn treebank parses, but preferably binarized)

* `clm`: some class-based LM feature? I forget.

* `cipher`: some word-class discovery and unsupervised decoding of simple
probabilistic substitution cipher (uses carmel, but look to the tutorial in
carmel/ first)

* `util`: misc shell/perl scripts
